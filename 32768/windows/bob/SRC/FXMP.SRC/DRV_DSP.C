/*
  drv_dsp.c - /dev/dsp driver for fxmp
  Copyright (C) 1999-2001, Bekir Osman Keskin <spectre@portent.net>

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

#include <unistd.h>

#ifdef LINUX
#include <linux/soundcard.h>
#endif

#include <sys/ioctl.h>

#include "drv_dsp.h"
#include "fxmp.h"

slong *intbuffer;

#ifndef EIGHTBITS
sshort *soundbuffer;
#else
schar *soundbuffer;
#endif

int dsp_init (fxmp_player *p)
{
  int temp;

#ifdef LINUX
  p->driver->dev = open ("/dev/dsp", O_WRONLY, 0);
  if (p->driver->dev == -1)
  {
    printf ("Can't open /dev/dsp\n");
    return 1;
  }

  temp = 1;
  ioctl (p->driver->dev, SNDCTL_DSP_STEREO, &temp);
  temp = 16;
  ioctl (p->driver->dev, SNDCTL_DSP_SAMPLESIZE, &temp);
  temp = FXMP_SAMPLE_RATE;
  ioctl (p->driver->dev, SNDCTL_DSP_SPEED, &temp);
  temp = 16 << 16 | 12;
  ioctl (p->driver->dev, SNDCTL_DSP_SETFRAGMENT, &temp);
  ioctl (p->driver->dev, SNDCTL_DSP_GETBLKSIZE, &temp);
  temp = temp * 8;
#endif

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

void dsp_deinit (fxmp_player *p)
{
#ifdef LINUX
  close (p->driver->dev);
#endif
}

void dsp_soundout (int fd, void *buf, int len)
{
#ifdef LINUX
  write (fd, buf, len);
#endif
}

void dsp_set_note (fxmp_channel *chan, int note)
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
void dsp_set_patch (fxmp_channel *chan, int patch)
{
}

void dsp_set_bend (fxmp_channel *chan, int bend)
{
}

void dsp_set_volume (fxmp_channel *chan, int volume)
{
}

void dsp_set_pan (fxmp_channel *chan, int pan)
{
}

void dsp_set_offset (fxmp_channel *chan, int offset)
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

void dsp_ticker (fxmp_player *p)
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
  dsp_soundout (p->driver->dev, soundbuffer, nos << 2);
}

fxmp_driver fxmp_drv_dsp =
{
  FXMP_TYPE_SOFTWARE,    /* type */
  0,                     /* dev */
  dsp_init,
  dsp_deinit,
  dsp_set_note,
  dsp_set_patch,
  dsp_set_bend,
  dsp_set_volume,
  dsp_set_pan,
  dsp_set_offset,
  NULL,
  dsp_ticker
};
