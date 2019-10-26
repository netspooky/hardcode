/*
  This file is part of fxmp, an .xm player.
  fxmp is copyright 2000 by Osman Keskin <spectre@winterland.net>
  
  microsoft windows (tm) waveOut support by Warp of Bliss 
  <warp-tmt@dds.nl>, see the notes in dsp_init() for more info.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA
*/

/* Disable conversion warning messages in Visual C++ */
#ifdef _WIN32
#pragma warning( disable: 4761 )  
#endif

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#ifdef _WIN32
#include <memory.h>   /* for memset among other things. */
#endif 

#ifdef WAVEOUT
#include <wtypes.h>

/* We don't need most of the stuff from <mmsystem.h>, so let's
   disable it. -- <warp-tmt@dds.nl> */
#define MMNODRV         /* no Installable driver support     */
#define MMNOSOUND       /* no Sound support                  */
/* #define MMNOWAVE        no Waveform support               */
#define MMNOMIDI        /* no MIDI support                   */
#define MMNOAUX         /* no Auxiliary audio support        */
#define MMNOMIXER       /* no Mixer support                  */
#define MMNOTIMER       /* no Timer support                  */
#define MMNOJOY         /* no Joystick support               */
#define MMNOMCI         /* no MCI support                    */
#define MMNOMMIO        /* no Multimedia file I/O support    */
#define MMNOMMSYSTEM    /* no General MMSYSTEM functions     */

#include <mmsystem.h>
#include <mmreg.h>

#endif /*  WAVEOUT  */

#ifdef LINUX
#include <unistd.h>
#include <linux/soundcard.h>
#include <sys/ioctl.h>
#endif

#include "drv_dsp.h"
#include "fxmp.h"

#ifdef LINUX
int dspfd;
#endif

slong *intbuffer;

#ifndef EIGHTBITS
sshort *soundbuffer;
#else
schar *soundbuffer;
#endif

ulong sbpos = 0;
int oldnos = 0;

#ifdef LINUX
/* for /dev/dsp version of dsp_get_bytes,... -- <warp-tmt@dds.nl> */
long bytes = 0;
#endif

#ifdef WAVEOUT
MMRESULT        mmr;  /* waveOut return codes */
HWAVEOUT        hwo;   /* waveOut handle */
WAVEFORMATEX    wfe;  /* format of waveform-audio data */
WAVEHDR         header[NUMBUFFERS];  /* wave data chunk header smurf */
char *          buffer[NUMBUFFERS];
WORD            buffersout; /* number of buffers playing/about to be played */
WORD            nextbuffer; /* next buffer to be played */
ULONG           buffersize; 
ULONG           bufferpos;  /* current position within buffer[] */
char *          bufferptr;  /* pointer to position within buffer[] */
MMTIME          mmt;  /* waveOutGetPosition thingy */

int             first = 1;
long            compensate = 0; /* for get_bytes */
#endif /*  WAVEOUT  */


/* all the errors listed in mmsystem.h, mainly for debugging, should definitly
   be disabled for 64k's :)    -- <warp-tmt@dds.nl> */
#ifdef WAVEOUT
void
mmerror(const char* err, MMRESULT mm)
{
  char* mmstr;

  switch(mm)
    {
    case WAVERR_BADFORMAT:      mmstr = "unsupported wave format."; break;
    case WAVERR_STILLPLAYING:   mmstr = "still something playing."; break;
    case WAVERR_UNPREPARED:     mmstr = "header not prepared."; break;
    case WAVERR_SYNC:           mmstr = "device is synchronous."; break;

    case MMSYSERR_ERROR:        mmstr = "unspecified error."; break;
    case MMSYSERR_BADDEVICEID:  mmstr = "device ID out of range."; break;
    case MMSYSERR_NOTENABLED:   mmstr = "driver failed enable."; break;
    case MMSYSERR_ALLOCATED:    mmstr = "device already allocated."; break;
    case MMSYSERR_INVALHANDLE:  mmstr = "device handle is invalid."; break;
    case MMSYSERR_NODRIVER:     mmstr = "no device driver present."; break;
    case MMSYSERR_NOMEM:        mmstr = "memory allocation error."; break;
    case MMSYSERR_NOTSUPPORTED: mmstr = "function isn't supported."; break;
    case MMSYSERR_BADERRNUM:    mmstr = "error value out of range."; break;
    case MMSYSERR_INVALFLAG:    mmstr = "invalid flag passed."; break;
    case MMSYSERR_INVALPARAM:   mmstr = "invalid parameter passed."; break;
    case MMSYSERR_HANDLEBUSY:   mmstr = "handle busy."; break;
    case MMSYSERR_INVALIDALIAS: mmstr = "specified alias not found."; break;
    case MMSYSERR_BADDB:        mmstr = "bad registry database."; break;
    case MMSYSERR_KEYNOTFOUND:  mmstr = "registry key not found."; break;
    case MMSYSERR_READERROR:    mmstr = "registry read error."; break;
    case MMSYSERR_WRITEERROR:   mmstr = "registry write error."; break;
    case MMSYSERR_DELETEERROR:  mmstr = "registry delete error."; break;
    case MMSYSERR_VALNOTFOUND:  mmstr = "registry value not found."; break;
    case MMSYSERR_NODRIVERCB:   mmstr = "driver does not call DriverCallback."; break;
    default:
      /*    mmstr = "shouldn't come here!"; */
      mmstr = "";
    }

  printf("%s: %s\n", err, mmstr);
  exit(1);
}

static void CALLBACK dsp_callback(HWAVEOUT hwo,UINT uMsg,DWORD dwInstance,DWORD dwParam1,DWORD dwParam2)
{
  if (uMsg==WOM_DONE) --buffersout;
}
#endif /*  WAVEOUT  */

int
dsp_init ()
{
#ifdef LINUX
  int temp;

  dspfd = open ("/dev/dsp", O_WRONLY, 0);
  if (dspfd == -1)
    {
      printf ("Can't open /dev/dsp\n");
      return 1;
    }

  /*
    a few changes here to make things work on my SB Live!, can't 
    remember exactly what I changed or why.. but things are fine now :)
    -- Warp (not being very helpful) of Bliss <warp-tmt@dds.nl> */
  ioctl(dspfd, SNDCTL_DSP_SYNC, NULL);
  temp = 1;
  ioctl (dspfd, SNDCTL_DSP_STEREO, &temp);
  temp = 16;
  ioctl (dspfd, SNDCTL_DSP_SAMPLESIZE, &temp);
  temp = SAMPLERATE;
  ioctl (dspfd, SNDCTL_DSP_SPEED, &temp);
  /*
  temp = 16 << 16 | 4096;
  ioctl (dspfd, SNDCTL_DSP_SETFRAGMENT, &temp);
  ioctl (dspfd, SNDCTL_DSP_GETBLKSIZE, &temp);
  temp = temp * 8;
  */
#endif


  /* 
     [complete waveOut rewrite pending, waveOut description removed]

     -- Warp of Bliss    a.k.a.  Kuno Woudt <warp-tmt@dds.nl>
  */

#ifdef WAVEOUT
  int n;

  hwo = 0;
  wfe.wFormatTag = WAVE_FORMAT_PCM;
  wfe.nChannels = 2;
  wfe.nSamplesPerSec = SAMPLERATE;
  wfe.wBitsPerSample = 16;
  wfe.nBlockAlign = (wfe.nChannels * wfe.wBitsPerSample) >> 3;
  wfe.nAvgBytesPerSec = wfe.nSamplesPerSec * wfe.nBlockAlign;
  wfe.cbSize = sizeof(WAVEFORMATEX);

  mmr = waveOutOpen(&hwo, WAVE_MAPPER, &wfe, (DWORD)dsp_callback, 0, CALLBACK_FUNCTION);
  if(mmr!=MMSYSERR_NOERROR)
    mmerror("Failed to open waveOut device", mmr);

  buffersize=(SAMPLERATE<<2)*WINBUFSIZE/1000;
  
  for(n=0; n<NUMBUFFERS; n++)
    {
      buffer[n] = malloc(buffersize);
      if(!buffer[n])
        mmerror("out of memory", 0);

      header[n].lpData = buffer[n];
      header[n].dwBufferLength = buffersize;
      mmr = waveOutPrepareHeader(hwo, &header[n], sizeof(WAVEHDR));
      if(mmr!=MMSYSERR_NOERROR)
        mmerror("Failed to prepare waveOut header", mmr);
    }
  buffersout = nextbuffer = 0;
  bufferpos = 0;
  bufferptr = buffer[0];

#endif /*  WAVEOUT  */

  soundbuffer = (sshort *) calloc(1, SOUNDBUFSIZE);
  intbuffer = (slong *) calloc(1, SOUNDBUFSIZE * 2);
  memset (intbuffer, 0, SOUNDBUFSIZE * 2);
  return 0;
}

void
dsp_deinit ()
{
#ifdef LINUX
  close (dspfd);
#endif

#ifdef WAVEOUT
  int n;

  if(hwo)
    {
      waveOutReset(hwo);
      for (n=0;n<NUMBUFFERS;n++)
        {
	  if (header[n].dwFlags&WHDR_PREPARED)
	    waveOutUnprepareHeader(hwo,&header[n],sizeof(WAVEHDR));
          free(buffer[n]);
        }
	while (waveOutClose(hwo)==WAVERR_STILLPLAYING) Sleep(10);
	hwo=NULL;
    }

#endif /*  WAVEOUT  */
}

void
dsp_soundout (void *buf, int len)
{
#ifdef LINUX
  write (dspfd, buf, len);
  bytes+=len;
#endif

#ifdef WAVEOUT

/*
  printf("DDD: @pos = %d (%d), len = %d, @out = %d (%d), next@ = %d.\n",
          bufferpos, buffersize, len, buffersout, NUMBUFFERS, nextbuffer);
*/

  if(!len) return;

  if((bufferpos + len) > buffersize)
    {
      header[nextbuffer].dwBufferLength=bufferpos;
      mmr = waveOutWrite(hwo, &header[nextbuffer], sizeof(WAVEHDR));
      if(mmr!=MMSYSERR_NOERROR)
        mmerror("waveOutWrite failed", mmr);
      if (++nextbuffer>=NUMBUFFERS) nextbuffer%=NUMBUFFERS;
      ++buffersout;
      while(!(buffersout<NUMBUFFERS)) Sleep(14);
      bufferpos = 0;
      bufferptr = buffer[nextbuffer];
    }

  memcpy(bufferptr, buf, len);
  bufferpos += len;
  bufferptr += len;
      
/*
	ULONG done;

	while (buffersout<NUMBUFFERS) {
		done=VC_WriteBytes(buffer[nextbuffer],buffersize);
		if (!done) break;
		header[nextbuffer].dwBufferLength=done;
		waveOutWrite(hwaveout,&header[nextbuffer],sizeof(WAVEHDR));
		if (++nextbuffer>=NUMBUFFERS) nextbuffer%=NUMBUFFERS;
		++buffersout;
	}

*/
#endif /*  WAVEOUT  */

}

int
dsp_get_bytes (void)
{
#ifdef WAVEOUT
  mmt.wType = TIME_BYTES;

  mmr = waveOutGetPosition(hwo, &mmt, sizeof(MMTIME));
  if(mmr!=MMSYSERR_NOERROR)
    mmerror("Failed to determine waveOut position", mmr);

  if(mmt.wType!=TIME_BYTES)
    mmerror("Failed to determine waveOut position", -1);

  return mmt.u.cb - LATENCY;
#endif /* WAVEOUT */

#ifdef LINUX
  return bytes; /* FIXME: check latency on linux systems */
#endif
}

void
dsp_set_note (int chan, int note)
{
  chn *ch = &channel[chan];

  ch->period = getperiod (ch->note + 11, ch->finetune);
  ch->freq = getfreq (ch->period);
  ch->sampleinc = ((ch->freq << 8) / SAMPLERATE) / 2;
  ch->keyoff = 0;
  ch->pingpong = 0;
  ch->type = ch->smpptr->type & 3;
  ch->samplepos = 0;
  ch->samplelen = ch->smpptr->len;
  ch->samplestart = 0;
  if (ch->type == XM_LOOP_NONE)
    ch->sampleend = ch->samplelen;
  else
    ch->sampleend = ch->smpptr->loopstart + ch->smpptr->looplen;
}


/* dunno if i can find any use of those funcs */
void
dsp_set_patch (int chan, int patch)
{
}

void
dsp_set_bend (int chan, int bend)
{
}

void
dsp_set_volume (int chan, int volume)
{
}

void
dsp_set_pan (int chan, int pan)
{
}

void
dsp_set_offset (int chan, int offset)
{
}

void conv_32to16(sshort *out, slong *in, ulong num)
{
  slong smp;
  for (; num--; ++out, ++in)
    {
      smp = *in >> 16;
      smp = smp > 32767 ? 32767 : smp < -32768 ? -32768 : smp;
      *out = (sshort)smp;
    }
}

slong *mix_st16norm(slong *out, sshort *samp, ulong count, ulong vr, ulong vl, register slong pos, slong inc)
{
  register sshort smp;
  while (count--)
    {
      smp = samp[pos >> 8];
      *(out++) += smp * vr;
      *(out++) += smp * vl;
      pos += inc;
    }
  return out;
}

/* EXPERIMENTAL */
void
dsp_ticker (xm_module * xm)
{
  int j, nos;
  ulong volmod,lvolmod,rvolmod;
  xm_sample *smpptr;
  xm_inst *insptr;
  chn *chan;
  uchar volenv=0;
  sshort pan;
  slong count, tickcount;
  slong *buffer;

  nos = (SAMPLERATE * 60 / xm->bpm / 24);
  /*  memset (soundbuffer, 0, nos*4); */
  memset (intbuffer, 0, nos*8);
  /*  clr (soundbuffer, nos, 0); */

  for (j = 0; j < xm->numchans; j++)
    {
      chan = &channel[j];
      sbpos = 0;

      pan = (uchar)chan->pan;

      if (chan->inst != 0)
        {
          insptr = &(xm->inst[chan->inst - 1]);
          smpptr = &(insptr->sample[chan->samplenum]);

          volmod = (chan->volume * globalvolume);
          volmod = (volmod * chan->volfade) >> 13;

          if (insptr->voltype & 1)
            {
              volenv = insptr->static_volenv[chan->env_volpos];
              volmod = (volmod * volenv) >> 6;
            }

          if (insptr->pantype & 1)
            {
              pan += (insptr->static_panenv[chan->env_panpos]-32)*(128-abs(pan-128))/32;
              lvolmod = (volmod * pantable[pan].l) >> 6;
              rvolmod = (volmod * pantable[pan].r) >> 6;
            }
          else
            {
              lvolmod = rvolmod = volmod;
            }

          buffer = intbuffer;

          for (tickcount = nos; tickcount; )
            {
              count = 1 + ((chan->sampleend << 8) - chan->samplepos) / chan->sampleinc;

              if (count > tickcount) count = tickcount;

              if (chan->volume > 0)
                buffer = mix_st16norm(buffer, smpptr->data, count, lvolmod, rvolmod, chan->samplepos, chan->sampleinc);

              chan->samplepos += chan->sampleinc * count;
              tickcount -= count;
              if (tickcount == 0) continue; 

              if (chan->type == XM_LOOP_NONE)
                {
                  tickcount = 0;
                  continue;
                }
              else if (chan->type == XM_LOOP_FORWARD)
                {
                  chan->samplepos -= smpptr->looplen << 8;
                }
              else if (chan->type == XM_LOOP_PINGPONG)
                {
                  chan->sampleinc = -chan->sampleinc;
                  switch (chan->pingpong)
                    {
                    case 0:
                      chan->sampleend = smpptr->loopstart;
                      chan->pingpong = 1;
                      break;
                    case 1:
                      chan->sampleend = smpptr->loopstart + smpptr->looplen;
                      chan->pingpong = 0;
                      break;
                    }
                }
              if (count<=0) break;
            }
        }       /* if (chan->inst != 0) */
    }       /* chanloop */

  conv_32to16 (soundbuffer, intbuffer, nos << 2);
  dsp_soundout (soundbuffer, nos << 2);
  sbpos = 0;
}

driver dsp =
{
  TYPE_SOFTWARE,    /* type */
  0,        /* dev */
  dsp_init,
  dsp_deinit,
  dsp_get_bytes,
  dsp_set_note,
  dsp_set_patch,
  dsp_set_bend,
  dsp_set_volume,
  dsp_set_pan,
  dsp_set_offset,
  NULL,
  dsp_ticker
};
