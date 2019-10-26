/*
  ticker.h - ticker/tracker/poll code
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

  NOTE: this is a modified version of ticker.c which disables
  effects which aren't used in my 32k game.
  -- Kuno Woudt <warp-tmt@dds.nl>
*/

#include "fxmp.h"
#include <stdio.h>

#define FXMP_PORTATO
#define FXMP_VIBRATO
#define FXMP_SETSPEED
#define FXMP_ENVELOPE
#define FXMP_VOLUMEBYTE
#define FXMP_VOLUMESLIDE
#define FXMP_SETVOLUME


static uchar vibrato_tab[32] =
{
  0, 24, 49, 74, 97, 120, 141, 161,
  180, 197, 212, 224, 235, 244, 250, 253,
  255, 253, 250, 244, 235, 224, 212, 197,
  180, 161, 141, 120, 97, 74, 49, 24
};

void do_global_effects (fxmp_player *p)
{
#ifdef FXMP_GLOBAL_VOLUMESLIDE
  slong temp;

  /* global volume slide */
  if (p->global_volumeslide)
  {
    temp = p->global_volume + p->global_volumeslide;
    if (temp < 0) temp = 0;
    if (temp > 64) temp = 64;
    p->global_volume = (schar) temp;
  }
#endif
}


void do_tick_effects (fxmp_player *p, fxmp_channel *channel)
{
  fxmp_module *xm = p->module;
  slong temp = 0, tempi;
  fxmp_inst *insptr;
  uchar pos;

  /* volume slide */
#ifdef FXMP_VOLUMESLIDE
  if (channel->volumeslide != 0)
  {
    temp = channel->volume + channel->volumeslide;
    if (temp < 0) temp = 0;
    if (temp > 64) temp = 64;
    channel->volume = (schar) temp;
  }

  if (channel->keyoff && channel->volfade >= channel->volfade_dec)
  {
    channel->volfade -= channel->volfade_dec;
  }
#endif

  /* arpeggio */
#ifdef FXMP_ARPEGGIO
  if (channel->arpeggio > 0)
  {
    pos = channel->note;

    switch (p->tick % 3)
    {
      case 1:
        pos += channel->arpeggio >> 4;
        break;

      case 2:
        pos += channel->arpeggio & 0xF;
        break;
    }

    channel->period = fxmp_get_period (pos, channel->smpptr->finetune);
    channel->flags |= 1;
  }
#endif

  if (p->tick > 0)
  {
    /* porta up */
#ifdef FXMP_PORTAUP
    if (channel->portaup > 0)
    {
      channel->period -= channel->portaup << 2;
      if (channel->period < 0) channel->period += 768;
      channel->flags |= 1;
    }
#endif

    /* porta down */
#ifdef FXMP_PORTADOWN
    if (channel->portadown > 0)
    {
      channel->period += channel->portadown << 2;
      channel->flags |= 1;
    }
#endif

    /* porta to note */
#ifdef FXMP_PORTATO
    if (p->tick > 0 && channel->portanote_speed != 0)
    {
      temp = channel->portanote_period - channel->period;
      tempi = channel->portanote_speed * (p->speed - 1);

      if ((temp & 0x7FFFFFFF) < tempi && temp != 0)
      {
        channel->period = channel->portanote_period;
      }
      else if (temp != 0)
      {
        if (temp < 0) tempi = -tempi;
        channel->period += tempi;
      }

      channel->flags |= 1;
    }
#endif

    /* vibrato */
#ifdef FXMP_VIBRATO
    if (channel->vibrato_speed != 0)
    {
      pos = channel->vibrato_pos & 31;
      switch (channel->vibrato_wave % 4)
      {
        case 3:
        case 0:
          temp = (vibrato_tab[pos] * channel->vibrato_depth) >> 7;
          if (channel->vibrato_pos < 0) temp = -temp;
          break;
        case 1:
          temp = pos << 3;
          if (channel->vibrato_pos < 0) temp = 255 - temp;
          temp = (temp * channel->vibrato_depth) >> 7;
          break;
        case 2:
          temp = (channel->vibrato_depth * 255) >> 7;
          if (channel->vibrato_pos < 0) temp = -temp;
          break;
      }

      channel->period += temp;
      channel->vibrato_pos += channel->vibrato_speed;
      if (channel->vibrato_pos > 31) channel->vibrato_pos -= 64;

      channel->flags |= 1;
    }
#endif

    /* tremolo */
#ifdef FXMP_TREMOLO
    if (channel->tremolo_speed != 0)
    {
      pos = channel->tremolo_pos & 31;
      switch (channel->tremolo_wave % 4)
      {
        case 3:
        case 0:
          temp = (vibrato_tab[pos] * channel->tremolo_depth) >> 8;
          if (channel->tremolo_pos < 0) temp = -temp;
          break;
        case 1:
          temp = pos << 3;
          if (channel->tremolo_pos < 0) temp = 255 - temp;
          temp = (temp * channel->tremolo_depth) >> 7;
          break;
        case 2:
          temp = (channel->tremolo_depth * 255) >> 7;
          if (channel->tremolo_pos < 0) temp = -temp;
          break;
      }

      channel->volume += (char) temp;
      if (channel->volume > 64) channel->volume = 64;
      else if (channel->volume < 0) channel->volume = 0;
      channel->tremolo_pos += channel->tremolo_speed;
      if (channel->tremolo_pos > 31) channel->tremolo_pos -= 64;

      channel->flags |= 1;
    }
#endif
  }

  if (channel->cutnote > 1)
  {
    channel->cutnote--;
  }
  if (channel->cutnote == 1)
  {
    channel->volume = 0;
  }

  if (!(channel->flags & 2) && channel->old_period)
  {
    channel->period = channel->old_period;
    channel->old_period = 0;
    channel->flags |= 1;
  }

  /* recalc freq */
#ifdef FXMP_RECALCFREQ
  if (channel->flags & 1)
  {
    channel->flags &= 0xFE; /* clear the bit up */
    channel->freq = fxmp_get_freq (channel->period);
    if (p->driver->type == FXMP_TYPE_SOFTWARE)
    {
      channel->sample_inc = (channel->freq << 8) / FXMP_SAMPLE_RATE;
      if (channel->pingpong == 1) channel->sample_inc = -channel->sample_inc;
    }
  }
#endif

  /* envelopes */
#ifdef FXMP_ENVELOPE
  if (channel->inst)
  {
    insptr = &xm->inst[channel->inst - 1];

    if (insptr->voltype & 1)
    {
      if (insptr->voltype & 2)
      {
        if ((channel->keyoff == 0 && channel->env_volpos == channel->env_volsustain) ||
            (channel->env_volpos >= channel->env_volend && !(insptr->voltype & 4)))
        {
          channel->env_volactive = 1;
        }
        else
        {
          channel->env_volactive = 0;
/*          channel->keyoff = 0; */
        }
      }

      if (!channel->env_volactive)
      {
        channel->env_volpos++;

        if (insptr->voltype & 4)	/* looping enabled */
        {
          if (channel->env_volpos >= channel->env_volloopend)
            channel->env_volpos -= channel->env_vollooplen;
        }
        else /* no loop */
        {
          if (channel->env_volpos >= channel->env_volend)
          {
            channel->env_volactive = 1;
          }
        }
      }
    }

    if (insptr->pantype & 1)
    {
      if (insptr->pantype & 2)
      {
        if ((channel->keyoff == 0 && channel->env_panpos == channel->env_pansustain) ||
            (channel->env_panpos >= channel->env_panend && !(insptr->pantype & 4)))
        {
          channel->env_panactive = 1;
        }
        else
        {
          channel->env_panactive = 0;
/*          channel->keyoff = 0; */
        }
      }

      if (!channel->env_panactive)
      {
        channel->env_panpos++;

        if (insptr->pantype & 4)	/* looping enabled */
        {
          if (channel->env_panpos >= channel->env_panloopend)
            channel->env_panpos -= channel->env_panlooplen;
        }
        else /* no loop */
        {
          if (channel->env_panpos >= channel->env_panend)
          {
            channel->env_panactive = 1;
          }
        }
      }
    }
  }
#endif /* FXMP_ENVELOPE */
}

/* driver, dev, and i parameters will be removed */
int do_row_effects (fxmp_player *p, int ofs, fxmp_channel *channel)
{
  fxmp_module *xm = p->module;
  uchar note, inst, vol, fx, parm, oldparm;
  fxmp_sample *smpptr;
  fxmp_inst *insptr;
  int period;

  note = xm->pattern[p->pat][ofs].note;
  inst = xm->pattern[p->pat][ofs].inst;
  vol = xm->pattern[p->pat][ofs].vol;
  fx = xm->pattern[p->pat][ofs].fx;
  parm = xm->pattern[p->pat][ofs].parm;

  /* reset */
  if (inst > 0)
    channel->volume = xm->inst[inst - 1].sample[xm->inst[inst - 1].sample_of[note]].volume;

  if (note != 0 && inst == 0) inst = (uchar) channel->oldinst;
  channel->oldinst = inst;
  channel->hit = 0;

#ifndef TINY
  if (verbose < 0)
    printf ("%2x %2x %2x %2x %2x | ", note, inst, vol, fx, parm);
#endif

  /* VOLUME EFFECTS */
  if (vol >= 0x10 && vol <= 0x50)
  {
    channel->volume = vol - 0x10;
  }
  if (vol >= 0x80 && vol <= 0x8F)
  {
    channel->volume -= vol - 0x80;

    if (channel->volume < 0)
      channel->volume = 0;
  }
  if (vol >= 0x90 && vol <= 0x9F)
  {
    channel->volume += vol - 0x90;

    if (channel->volume > 64) channel->volume = 64;
  }
  if (vol >= 0xC0 && vol <= 0xCF)
  {
    channel->pan = (vol - 0xC8) * 16;
  }
  if (vol >= 0xD0 && vol <= 0xDF)
  {
    channel->pan -= vol - 0xD0;
    if (channel->pan < 0) channel->pan = 0;
  }
  if (vol >= 0xE0 && vol <= 0xEF)
  {
    channel->pan += vol - 0xE0;
    if (channel->pan > 255) channel->pan = 255;
  }

  channel->volumeslide = 0;
  if (fx == 0x01 && parm == 0) parm = channel->portaup;
  if (fx == 0x02 && parm == 0) parm = channel->portadown;
  if (fx == 0x03 && parm == 0) parm = channel->portanote_speed;
  channel->portaup = 0;
  channel->portadown = 0;
  channel->portanote_speed = 0;
  channel->arpeggio = 0;
  channel->tremolo_speed = 0;
  channel->vibrato_speed = 0;
  channel->cutnote = 0;
  channel->flags = 0;

  /*
      if (note != 0 && note != 97 && inst != 0)
      {
          if (xm->inst[inst - 1].voltype & 1)
          {
              channel->env_volpos = 0;
              channel->env_volactive = 0;
          }
          if (xm->inst[inst - 1].pantype & 1)
          {
              channel->env_panpos = 0;
              channel->env_panactive = 0;
          }
      }
  */

  if (note != 0 && note != 97 && fx != 3 && fx != 5)
  {
    channel->inst = inst;
    channel->hit = 1;

    if (channel->inst && xm->inst[channel->inst - 1].n_samples == 0)
        channel->inst = 0;

    if (channel->inst)
    {
      channel->insptr = insptr = &xm->inst[channel->inst - 1];
      channel->sample_num = insptr->sample_of[note];
      channel->smpptr = smpptr = &insptr->sample[channel->sample_num];

      channel->finetune = smpptr->finetune;
      channel->note = note + smpptr->relnote - 1;
      channel->keyoff = 0;
      channel->pan = smpptr->pan;

      p->driver->set_patch (channel, smpptr->patchnr);
      p->driver->set_note (channel, note);

      if (insptr->voltype & 1)
      {
        channel->env_volpos = 0;
        channel->env_volactive = 0;
        channel->env_volend = insptr->volenv[insptr->numvolpts - 1].pos;
        if (insptr->voltype & 2)
          channel->env_volsustain = insptr->static_volsustain;
        if (insptr->voltype & 4)
        {
          channel->env_volloopstart = insptr->static_volloopstart;
          channel->env_volloopend = insptr->static_volloopend;
          channel->env_vollooplen = channel->env_volloopend - channel->env_volloopstart;
        }
      }
      if (insptr->pantype & 1)
      {
        channel->env_panpos = 0;
        channel->env_panactive = 0;
        channel->env_panend = insptr->panenv[insptr->numpanpts - 1].pos;
        if (insptr->pantype & 2)
          channel->env_pansustain = insptr->static_pansustain;
        if (insptr->pantype & 4)
        {
          channel->env_panloopstart = insptr->static_panloopstart;
          channel->env_panloopend = insptr->static_panloopend;
          channel->env_panlooplen = channel->env_panloopend - channel->env_panloopstart;
        }
      }

      /* supposed bending calculation, which does not work yet */
      period = fxmp_note_to_period (channel->note, channel->finetune);
      channel->pitchbend = fxmp_period_to_bend (period, channel->note, channel->finetune);
    }
  }

  /* key off */
  if (note == 97)
  {
    channel->keyoff = 1;
  }

  /* EFFECTS */
  if (fx != 0 || parm != 0)
  {
    oldparm = parm;

    if (parm == 0)
      parm = channel->oldparm[fx];
    else
      channel->oldparm[fx] = parm;
 
    switch (fx)
    {
#ifdef FXMP_ARPEGGIO
      case 0x00:      /* arpeggio */

#ifndef TINY
        if (verbose > 0) printf ("ARPEGGIO %d\n", parm);
#endif

        channel->flags |= 2;
        channel->old_period = channel->period;
        channel->arpeggio = parm;
        break;
#endif

#ifdef FXMP_PORTAUP
      case 0x01:      /* porta up */

#ifndef TINY
        if (verbose > 0) printf ("PORTUP %d\n", parm);
#endif

        channel->portaup = parm;
        break;
#endif

#ifdef FXMP_PORTADOWN
      case 0x02:      /* porta down */

#ifndef TINY
        if (verbose > 0) printf ("PORTDN %d\n", parm);
#endif

        channel->portadown = parm;
        break;
#endif

#ifdef FXMP_PORTATO
      case 0x03:      /* porta to note */

        if (note != 0 && channel->inst != 0)
        {
          insptr = &xm->inst[channel->inst - 1];
          smpptr = &insptr->sample[channel->sample_num];

#ifndef TINY
        if (verbose > 0) printf ("PORTA TO NOTE %d\n", parm);
#endif
          channel->portanote_period = fxmp_get_period ((uchar) (note + smpptr->relnote - 1), smpptr->finetune);
        }

        channel->portanote_speed = parm;
        break;
#endif

#ifdef FXMP_VIBRATO
      case 0x04:      /* vibrato */

#ifndef TINY
        if (verbose > 0) printf ("VIBRATO\n");
#endif

        channel->vibrato_speed = parm >> 4;
        channel->vibrato_depth = parm & 0xF;
        if (channel->vibrato_wave < 4 && oldparm) channel->vibrato_pos = 15;

        /*
           FIXME: wtf?
           FIXME: gotta check if it should be reset or not too
        */
        break;
#endif

#ifdef FXMP_PORTATO_VOLSLIDE
      case 0x05:      /* porta to note + volume slide */

#ifndef TINY
        if (verbose > 0) printf ("PORTA+VOLUMESLIDE\n");
#endif

        if (note != 0 && channel->inst != 0)
        {
          insptr = &xm->inst[channel->inst - 1];
          smpptr = &insptr->sample[channel->sample_num];

          channel->portanote_period = fxmp_get_period ((uchar) (note + smpptr->relnote - 1), smpptr->finetune);
        }

        channel->portanote_speed = channel->oldparm[0x03];

        channel->volumeslide = -(parm & 0xF);
        channel->volumeslide += (parm >> 4);
        break;
#endif

#ifdef FXMP_VIBRATO_VOLSLIDE
      case 0x06:      /* vibrato + volume slide */

#ifndef TINY
        if (verbose > 0) printf ("VIBRATO+VOLUMESLIDE\n");
#endif

        channel->vibrato_depth = channel->oldparm[0x04] >> 4;
        channel->vibrato_speed = channel->oldparm[0x04] & 0xF;

        channel->volumeslide = -(parm & 0xF);
        channel->volumeslide += (parm >> 4);
        break;
#endif

#ifdef FXMP_TREMOLO
      case 0x07:      /* tremolo */

#ifndef TINY
        if (verbose > 0) printf ("TREMOLO\n");
#endif
        channel->tremolo_speed = parm >> 4;
        channel->tremolo_depth = parm & 0xF;
        if (channel->tremolo_wave < 4 && oldparm) channel->tremolo_pos = 15;
        break;
#endif

#ifdef FXMP_SETPAN
      case 0x08:      /* set panning */

#ifndef TINY
        if (verbose > 0) printf ("PAN\n");
#endif
        channel->pan = parm;
        break;
#endif

#ifdef FXMP_SAMPLEOFFSET
      case 0x09:      /* sample offset */

#ifndef TINY
        if (verbose > 0) printf ("SAMPLEOFFSET\n");
#endif
        channel->sample_pos = parm << 16;
        if ((channel->sample_pos >> 8) > channel->sample_len) channel->sample_pos = (channel->sample_len - 1) << 8;
        break;
#endif

#ifdef FXMP_VOLUMESLIDE
      case 0x0A:      /* volume slide */

#ifndef TINY
        if (verbose > 0) printf ("VOLSLIDE\n");
#endif
        channel->volumeslide = -(parm & 0xF);
        channel->volumeslide += (parm >> 4);
        break;
#endif

#ifdef FXMP_JUMPTO
      case 0x0B:      /* jump to pattern */

        p->tord = parm;
        if (p->tord > xm->songlen - 1) return 1;
        p->trow = -1;
        /* tick = speed - 1;
           pat = xm->order[ord]; */
        break;
#endif

#ifdef FXMP_SETVOLUME
      case 0x0C:      /* set volume */

#ifndef TINY
        if (verbose > 0) printf ("VOLSET\n");
#endif
        channel->volume = parm;
        break;
#endif

#ifdef FXMP_PATTERNBREAK
      case 0x0D:      /* pattern break */

        p->tord = p->ord + 1;
        if (p->tord > xm->songlen - 1) return 1;
        p->trow = parm - 1;
        break;
#endif

#ifdef FXMP_SETSPEED
      case 0x0F:      /* set speed */

        if (parm <= 0x1F)
        {
#ifndef TINY
          if (verbose > 0) printf ("SPEED %d\n", parm);
#endif
          xm->speed = parm;
        }
        else
        {
#ifndef TINY
          if (verbose > 0) printf ("BPM %d\n", parm);
#endif
          xm->bpm = parm;
        }
        break;
#endif

#ifdef FXMP_GLOBAL_VOLUME
      case 0x10:      /* set global volume */

        p->global_volume = parm;
        break;
#endif

#ifdef FXMP_GLOBAL_VOLUMESLIDE
      case 0x11:      /* set global volume slide */

#ifndef TINY
        if (verbose > 0) printf ("GLOBAL VOLSLIDE\n");
#endif

        p->global_volumeslide = -(parm & 0xF);
        p->global_volumeslide += (parm >> 4);
        break;
#endif

#ifdef FXMP_FINEVOLSLIDE
      case 0x0E:
#ifndef TINY
        if (verbose > 0) printf ("FINEVOLSLIDE\n");
#endif

        switch (parm >> 4)
        {
          case 0x4:     /* set vibrato waveform */
            channel->vibrato_wave = parm & 0xF;
            break;

          case 0x7:     /* set tremolo waveform */
            channel->tremolo_wave = parm & 0xF;
            break;

          case 0xA:     /* fine volume slide up */
            channel->volume += parm & 0xF;
            if (channel->volume > 64) channel->volume = 64;
            break;

          case 0xB:     /* fine volume slide down */
            channel->volume -= parm & 0xF;
            if (channel->volume < 0) channel->volume = 0;
            break;

          case 0xC:     /* cut note */
            channel->cutnote = (parm & 0xF) + 2;
            break;
        }
#endif

        break;
      }
    }

  return 0;
}

int fxmp_ticker (fxmp_player *p)
{
  fxmp_module *xm = p->module;
  ulong i, ofs;

  p->tick++;

  p->speed = xm->speed;
  if (p->speed == 0) p->speed = 1;

  if (p->ord != p->tord)
  {
    p->ord = p->tord;
    p->row = p->trow;
    p->tick = p->speed - 1;
    p->pat = xm->order[p->ord];
  }

  /* row based effects */
  if (p->tick >= p->speed || xm->speed == 0)
  {
    p->tick = 0;
    p->row++;

    if (p->row >= xm->patheader[p->pat].numrows)
    {
      p->row = 0;
      p->tick = 0;
      p->ord++;

      if (p->ord > xm->songlen - 1) 
#ifndef LOOP
        return 1;
#else
        p->ord = xm->restartpos;
#endif

      p->pat = xm->order[p->ord];
    }

    p->tord = p->ord;
    p->trow = p->row;
    ofs = p->row * xm->n_chans;

    p->global_volumeslide = 0;
    for (i = 0; i < xm->n_chans; i++)
    {
      if (do_row_effects (p, ofs + i, &p->channel[i]) != 0) return 1;
    }

#ifndef TINY
    if (verbose < 0) printf ("\n");
#endif
  }

  /* tick based global effects */
  do_global_effects (p);

  /* processing tick based effects and envelopes */
  for (i = 0; i < xm->n_chans; i++)
  {
    do_tick_effects (p, &p->channel[i]);
  }

  p->driver->ticker (p);

  return 0;
}
