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

#ifndef __DRV_DSP_H
#define __DRV_DSP_H

#include "types.h"
#include "config.h"
#include "fxmp.h"

#define SAMPLERATE 44100
#define SOUNDBUFSIZE 4096

#ifdef WAVEOUT
#define NUMBUFFERS   6             /* number of buffers */
#define WINBUFSIZE   120           /* in milliseconds */
/* 
  YES!

  Finally, after a lot of trouble and silly mistakes my waveOutGetPosition()
  stuff works properly.
  
  However, according to the directX SDK waveOut has a latency of approx 100ms to
  150ms. So I expected to have to compensate that, but it looks better without, so
  i'm not sure what all the fuss is about.

  this is what it should be IMO (120 ms to compensate for waveOut latency):
#define LATENCY    441*2*2*12

  -- <warp-tmt@dds.nl>
*/
#define LATENCY    0

#endif

extern ulong getperiod (uchar note, char finetune);
extern ulong getfreq (ulong period);
extern uchar globalvolume;
extern panel pantable[256];

int  dsp_init ();
void dsp_soundout (void *buf, int len);
void dsp_deinit ();
int  dsp_get_bytes(void);

#ifndef EIGHTBITS
extern sshort *soundbuffer;
#else
extern schar *soundbuffer;
#endif

extern ulong sbpos;

extern driver dsp;

#endif /* __DRV_DSP_H */
