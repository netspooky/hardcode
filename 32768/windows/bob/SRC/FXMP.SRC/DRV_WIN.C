/*
  drv_win.h - win32 waveOut driver for fxmp
  Copyright (C) 1999-2001, Bekir Osman Keskin, Kuno Woudt 

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>

#ifdef LINUX
#include <unistd.h>
#endif

#include "fxmp.h"

#include <memory.h>   /* for memset among other things. */
#include <wtypes.h>
#include "drv_win.h"

#define WIN_NUMBUFFERS    6             /* number of buffers */
#define WIN_BUFSIZE     120           /* in milliseconds */
#define WIN_LATENCY       0

/* We don't need most of the stuff from <mmsystem.h>, so let's
   disable it. -- Kuno Woudt <warp-tmt@dds.nl> */
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


MMRESULT        mmr;    /* waveOut return codes */
HWAVEOUT        hwo;    /* waveOut handle */
WAVEFORMATEX    wfe;    /* format of waveform-audio data */
WAVEHDR         header[WIN_NUMBUFFERS];  /* wave data chunk header */
char *          buffer[WIN_NUMBUFFERS];
WORD            buffersout; /* number of buffers playing/about to be played */
WORD            nextbuffer; /* next buffer to be played */
ULONG           buffersize; 
ULONG           bufferpos;  /* current position within buffer[] */
char *          bufferptr;  /* pointer to position within buffer[] */


slong *intbuffer;

#ifndef EIGHTBITS
sshort *soundbuffer;
#else
schar *soundbuffer;
#endif


/* all the errors listed in mmsystem.h, mainly for debugging, should definitly
   be disabled for 64k's :)    -- <warp-tmt@dds.nl> */
#ifdef DEBUG
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
  exit(2);
}
#else
#define mmerror(a, b) exit(2)
#endif /*  DEBUG  */


static void CALLBACK 
win_callback(HWAVEOUT hwo, UINT uMsg, DWORD dwInstance, 
             DWORD dwParam1, DWORD dwParam2)
{
  if (uMsg==WOM_DONE) --buffersout;
}


int 
win_init (fxmp_player *p)
{
  int n;

  hwo = 0;
  wfe.wFormatTag = WAVE_FORMAT_PCM;
  wfe.nChannels = 2;
  wfe.nSamplesPerSec = FXMP_SAMPLE_RATE ;
  wfe.wBitsPerSample = 16;
  wfe.nBlockAlign = (wfe.nChannels * wfe.wBitsPerSample) >> 3;
  wfe.nAvgBytesPerSec = wfe.nSamplesPerSec * wfe.nBlockAlign;
  wfe.cbSize = sizeof(WAVEFORMATEX);

  mmr = waveOutOpen(&hwo, WAVE_MAPPER, &wfe, (DWORD)win_callback, 0, CALLBACK_FUNCTION);
  if(mmr!=MMSYSERR_NOERROR)
    mmerror("Failed to open waveOut device", mmr);

  buffersize=(FXMP_SAMPLE_RATE<<2)*WIN_BUFSIZE/1000;
  
  for(n=0; n<WIN_NUMBUFFERS; n++)
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

#ifndef EIGHTBITS
  soundbuffer = (sshort *) malloc (FXMP_BUFFER_SIZE);
  intbuffer = (slong *) malloc (FXMP_BUFFER_SIZE * 2);
  memset (intbuffer, 0, FXMP_BUFFER_SIZE * 2);
#else
  printf ("MEUCH %d\n", FXMP_BUFFER_SIZE);
  soundbuffer = (schar *) malloc (FXMP_BUFFER_SIZE);
#endif 
  return 0;
}

void win_deinit (fxmp_player *p)
{
  int n;

  if(hwo)
    {
      waveOutReset(hwo);
      for (n=0;n<WIN_NUMBUFFERS;n++)
        {
	  if (header[n].dwFlags&WHDR_PREPARED)
	    waveOutUnprepareHeader(hwo,&header[n],sizeof(WAVEHDR));
          free(buffer[n]);
        }
	while (waveOutClose(hwo)==WAVERR_STILLPLAYING) Sleep(10);
	hwo=NULL;
    }
}

void win_soundout (int fd, void *buf, int len)
{
  if(!len) return;

  if((bufferpos + len) > buffersize)
    {
      header[nextbuffer].dwBufferLength=bufferpos;
      mmr = waveOutWrite(hwo, &header[nextbuffer], sizeof(WAVEHDR));
      if(mmr!=MMSYSERR_NOERROR)
        mmerror("waveOutWrite failed", mmr);
      if (++nextbuffer>=WIN_NUMBUFFERS) nextbuffer%=WIN_NUMBUFFERS;
      ++buffersout;
      while(!(buffersout<WIN_NUMBUFFERS)) Sleep(14);
      bufferpos = 0;
      bufferptr = buffer[nextbuffer];
    }

  memcpy(bufferptr, buf, len);
  bufferpos += len;
  bufferptr += len;
}

void win_set_note (fxmp_channel *chan, int note)
{
  chan->period = fxmp_get_period (chan->note, chan->finetune);
  chan->freq = fxmp_get_freq (chan->period);
  chan->sample_inc = (chan->freq << 8) / FXMP_SAMPLE_RATE;
  chan->keyoff = 0; 
  chan->pingpong = 0;
  chan->volfade = 32768;
  chan->volfade_dec = chan->insptr->volfade;
  chan->type = chan->smpptr->type & 3;
  chan->sample_pos = 0;
  chan->sample_len = chan->smpptr->length;
  chan->sample_start = 0;

  if (chan->type == FXMP_LOOP_NONE)
    chan->sample_end = chan->sample_len;
  else
    chan->sample_end = chan->smpptr->loopstart + chan->smpptr->looplen;
}


/* dunno if i can find any use of those funcs */
void win_set_patch (fxmp_channel *chan, int patch)
{
}

void win_set_bend (fxmp_channel *chan, int bend)
{
}

void win_set_volume (fxmp_channel *chan, int volume)
{
}

void win_set_pan (fxmp_channel *chan, int pan)
{
}

void win_set_offset (fxmp_channel *chan, int offset)
{
}

void conv_32to16 (sshort *out, slong *in, ulong num)
{
  slong smp;
  for (; num--; ++out, ++in)
  {
    smp = *in >> 16;
    smp = smp > 32767 ? 32767 : smp < -32768 ? -32768 : smp;
    *out = (sshort)smp;
  }
}

slong *mix_st16norm (slong *out, sshort *samp, ulong count, ulong vr, ulong vl, register slong pos, slong inc)
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

void win_ticker (fxmp_player *p)
{
  fxmp_module *xm = p->module;
  int j, nos;
  ulong volmod, lvolmod, rvolmod;
  fxmp_sample *smpptr;
  fxmp_inst *insptr;
  fxmp_channel *chan;
  uchar volenv = 0;
  sshort pan;
  slong count, tickcount;
  slong *buffer;

  nos = (FXMP_SAMPLE_RATE * 60 / xm->bpm / 24);
  memset (intbuffer, 0, nos * 8);

  for (j = 0; j < xm->n_chans; j++)
  {
    chan = &p->channel[j];
    if (!chan->sample_inc) continue;

    pan = (uchar) chan->pan;

    if (chan->inst)
    {
      insptr = &xm->inst[chan->inst - 1];
      smpptr = &insptr->sample[chan->sample_num];

      volmod = chan->volume * p->global_volume;
      volmod = (volmod * chan->volfade) >> 13;

      if (insptr->voltype & 1)
      {
        volenv = insptr->static_volenv[chan->env_volpos];
        volmod = (volmod * volenv) >> 6;
      }

      if (insptr->pantype & 1)
      {
        pan += (insptr->static_panenv[chan->env_panpos] - 32) * (128 - ((pan - 128) & 0x7F)) / 32;
        lvolmod = (volmod * p->pantable[pan].l) >> 5;
        rvolmod = (volmod * p->pantable[pan].r) >> 5;
      }
      else
      {
        lvolmod = rvolmod = volmod;
      }

      buffer = intbuffer;

      for (tickcount = nos; tickcount;)
      {
        count = 1 + ((chan->sample_end << 8) - chan->sample_pos) / chan->sample_inc;
        if (count <= 0) break;
        if (count > tickcount) count = tickcount;

        if (chan->volume > 0)
          buffer = mix_st16norm (buffer, smpptr->data, count, lvolmod, rvolmod, chan->sample_pos, chan->sample_inc);

        chan->sample_pos += chan->sample_inc * count;
        tickcount -= count;
        if (tickcount == 0) continue;

        if (chan->type == FXMP_LOOP_NONE)
        {
          tickcount = 0;
          continue;
        }
        else if (chan->type == FXMP_LOOP_FORWARD)
        {
          chan->sample_pos -= (smpptr->looplen) << 8;
        }
        else if (chan->type == FXMP_LOOP_PINGPONG)
        {
          chan->sample_inc = -chan->sample_inc;

          switch (chan->pingpong)
          {
            case 0:
              chan->sample_end = smpptr->loopstart;
              chan->pingpong = 1;
              break;
            case 1:
              chan->sample_end = smpptr->loopstart + smpptr->looplen;
              chan->pingpong = 0;
              break;
          }
        }
      }
    }				/* if (chan->inst) */
  }				/* chanloop */

  conv_32to16 (soundbuffer, intbuffer, nos << 2);
  win_soundout (p->driver->dev, soundbuffer, nos << 2);
}

fxmp_driver fxmp_drv_win =
{
  FXMP_TYPE_SOFTWARE,    /* type */
  0,                     /* dev */
  win_init,
  win_deinit,
  win_set_note,
  win_set_patch,
  win_set_bend,
  win_set_volume,
  win_set_pan,
  win_set_offset,
  NULL,
  win_ticker
};
