/*
  drv_seq.c - sequencer code for fxmp
  Copyright (C) 1999 Tijs van Bakel.
  Tijs van Bakel <smoke@casema.net>, 
 
  This file is part of crapstation, a collection of demobuilder tools.
 
  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2, or (at your option)
  any later version.
 
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.
 
  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING.  If not, write to
  the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
*/

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

#include <linux/soundcard.h>

#ifdef HAVE_ULTRASOUND_H
#include <linux/ultrasound.h>
#endif

#include "drv_seq.h"
#include "fxmp.h"

int seqfd;
SEQ_DEFINEBUF (2048);
int dev = 0;

void seqbuf_dump ()
{
  if (_seqbufptr)
  {
    if (write (seqfd, _seqbuf, _seqbufptr) == -1)
    {
      fprintf (stderr, "unable to write to /dev/sequencer");
      exit ( -1);
    }
    _seqbufptr = 0;
  }
}

void seq_reset ()
{
  /* from xmp oss_seq.c */
  int i;
  for (i = 0; i < 14; i++)
  {
    SEQ_STOP_NOTE (dev, i, 255, 0);
    SEQ_EXPRESSION (dev, i, 255);
    SEQ_MAIN_VOLUME (dev, i, 100);
    SEQ_CONTROL (dev, i, CTRL_PITCH_BENDER_RANGE, 8191);
    SEQ_BENDER (dev, i, 0);
    SEQ_PANNING (dev, i, 0);
    seqbuf_dump ();
  }
}

int seq_init (fxmp_player *p)
{
  struct synth_info si;
  int i;

  printf ("initializing sequencer\n");
  seqfd = open ("/dev/sequencer", O_RDWR, 0);
  if (!seqfd)
  {
    perror ("unable to open /dev/sequencer");
    return 1;
  }

  i = dev = p->driver->dev;
  ioctl (seqfd, SNDCTL_SEQ_RESETSAMPLES, &i);
  seq_reset ();

  si.device = dev;
  ioctl (seqfd, SNDCTL_SYNTH_INFO, &si);
  printf ("report %s\n", si.name);
  if (si.synth_subtype == SAMPLE_TYPE_GUS)
  {
    printf ("si.synth_subtype == SAMPLE_TYPE_GUS\n");
  }

  i = dev;
  ioctl (seqfd, SNDCTL_SYNTH_MEMAVL, &i);
  printf ("available memory %d bytes\n", i);

#ifdef HAVE_ULTRASOUND_H
  GUS_NUMVOICES (dev, 14);
#endif

  SEQ_VOLUME_MODE (dev, VOL_METHOD_LINEAR);
  seqbuf_dump ();

  ioctl (seqfd, SNDCTL_SEQ_SYNC, 0);
  ioctl (seqfd, SNDCTL_SEQ_RESET, 0);

  SEQ_MAIN_VOLUME (dev, 0, 100);
  seqbuf_dump ();
  return 0;
}

void seq_load_patches (fxmp_player *p)
{
  fxmp_module *xm = p->module;
  int i; 			/* instrument */
  int s; 			/* sample */
  fxmp_sample *smpPtr;
  struct patch_info *patch;
  int lpe, lps, len;
  int patchnr = 0;

  printf ("loading patches into sequencer..\n");
  for (i = 0; i < xm->n_insts; i++)
  {
    for (s = 0; s < xm->inst[i].n_samples; s++)
    {
      smpPtr = (fxmp_sample *) & (xm->inst[i].sample[s]);
      smpPtr->patchnr = patchnr;
      if (smpPtr->finetune != 0)
        printf ("FINETUNING ON %d\n", patchnr);

      patch = (struct patch_info *) calloc (1, sizeof (struct patch_info) + sizeof (int) + smpPtr->length);

      patch->device_no = dev;
      patch->instr_no = patchnr;
      patch->key = GUS_PATCH;
      patch->mode = WAVE_16_BITS;

      lpe = smpPtr->loopstart + smpPtr->looplen;
      lps = smpPtr->loopstart;
      len = smpPtr->looplen;

      patch->loop_start = lps;
      patch->loop_end = lpe;

      patch->mode |= ((smpPtr->type & FXMP_LOOP_PINGPONG)
                      ? WAVE_LOOPING | WAVE_BIDIR_LOOP : 0);
      patch->mode |= ((smpPtr->type & FXMP_LOOP_FORWARD)
                      ? WAVE_LOOPING : 0);

      patch->panning = 0;
      patch->volume = 120;

      patch->base_freq = 8272;
      patch->base_note = 130812;

      patch->high_note = 0x7fffffff;
      patch->low_note = 0;
      patch->detuning = 0;

      patch->len = smpPtr->length;
      memcpy (patch->data, smpPtr->data, smpPtr->length);

      SEQ_WRPATCH (patch, sizeof (struct patch_info) + patch->len - 1);

      free (patch);
      patchnr++;
    }
  }

  printf ("loaded %d patches\n", patchnr);
}

void seq_test_patches (fxmp_module *xm)
{
  int i;

  printf ("testing patches..\n");

  for (i = 0; i < 10; i++)
  {
    SEQ_SET_PATCH (dev, 0, i);

    SEQ_START_NOTE (dev, 0, 70, 50);
    SEQ_START_TIMER ();
    SEQ_WAIT_TIME (200);
    SEQ_STOP_TIMER ();

    SEQ_STOP_NOTE (dev, 0, 70, 50);
    SEQ_START_TIMER ();
    SEQ_WAIT_TIME (200);
    SEQ_STOP_TIMER ();
  }

  seqbuf_dump ();
  ioctl (seqfd, SNDCTL_SEQ_SYNC, 0);
}

void seq_buf_dump ()
{
  seqbuf_dump ();
}

void seq_sync ()
{
  ioctl (seqfd, SNDCTL_SEQ_SYNC, 0);
}

void seq_wait_time (long time)
{
  SEQ_WAIT_TIME (time);
}

void seq_start_timer ()
{
  SEQ_START_TIMER ();
}

void seq_stop_timer ()
{
  SEQ_STOP_TIMER ();
}

void seq_set_offset (fxmp_channel *chan, int offset)
{
#ifdef HAVE_ULTRASOUND_H
  GUS_VOICE_POS (dev, chan->id, offset);
#endif
}

void seq_set_patch (fxmp_channel *chan, int patchNr)
{
  SEQ_SET_PATCH (dev, chan->id, patchNr);
}

void seq_set_volume (fxmp_channel *chan, int volume)
{
  SEQ_START_NOTE (dev, chan->id, 255, volume);
}

void seq_set_note (fxmp_channel *chan, int note)
{
  SEQ_START_NOTE (dev, chan->id, note - 1, 0);
}

void seq_set_pan (fxmp_channel *chan, int pan)
{
#ifdef HAVE_ULTRASOUND_H
  GUS_VOICEBALA (dev, chan->id, (pan + 0x80) >> 4);
#endif
}

void seq_set_bend (fxmp_channel *chan, int bend)
{
  SEQ_PITCHBEND (dev, chan->id, bend);
}

void seq_set_effect (int chorus, int reverb, int cutoff, int resonance)
{
  /* awe only */
}

void seq_ticker (fxmp_player *p)
{
  fxmp_module *xm = p->module;
  static double nextTime = 0.0, thisTime = 0.0;
  double timeInterval;
  int volume;
  fxmp_sample *smpptr;
  fxmp_inst *insptr;
  fxmp_channel *chan;
  int j;

  for (j = 0; j < xm->n_chans; j++)
  {
    chan = &p->channel[j];
    volume = chan->volume;
    /* note */
    if (chan->inst != 0)
    {
      insptr = &xm->inst[chan->inst - 1];
      smpptr = &insptr->sample[chan->sample_num];

      volume = (volume * smpptr->volume) >> 6;

      if (insptr->voltype & 1)	/* if there's volume envelope */

      {
        volume = (volume * insptr->static_volenv[chan->env_volpos]) >> 6;
      }

    }
    /*      if (chan->period != 0) */
    /* printf ("period = %d\n", chan->pitchbend); */
    p->driver->set_bend (chan, chan->pitchbend);
    p->driver->set_volume (chan, volume);
  }

  timeInterval = 100.0 * 60.0 / ((float) xm->bpm) / 24.0;
  nextTime += timeInterval;

  if (nextTime == 0.0)
    thisTime = 0.0;

  if (nextTime - thisTime >= 1.0)
  {
    if (nextTime > thisTime)
    {
      seq_wait_time ((long) nextTime);
      thisTime = nextTime;

      seq_buf_dump ();
      seq_sync ();
    }
  }
}

fxmp_driver fxmp_drv_seq =
{
  FXMP_TYPE_HARDWARE,    /* type */
  0,                     /* dev */
  seq_init,
  NULL,
  seq_set_note,
  seq_set_patch,
  seq_set_bend,
  seq_set_volume,
  seq_set_pan,
  seq_set_offset,
  seq_load_patches,
  seq_ticker
};
