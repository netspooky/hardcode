/*
  drv_seq.h - sequencer code for fxmp
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

#ifndef __DRV_SEQ_H__
#define __DRV_SEQ_H__

#include "fxmp.h"

void seq_reset ();
int seq_init (fxmp_player *p);
void seq_load_patches (fxmp_player *p);
void seq_test_patches (fxmp_module *xm);

void seq_set_patch (fxmp_channel *chan, int patch_nr);
void seq_set_note (fxmp_channel *chan, int note);
void seq_set_bend (fxmp_channel *chan, int pitchbend);
void seq_set_volume (fxmp_channel *chan, int volume);
void seq_wait_time (long time);
void seq_buf_dump ();
void seq_sync ();
void seq_start_timer ();

extern fxmp_driver fxmp_drv_seq;

#endif /* __DRV_SEQ_H__ */
