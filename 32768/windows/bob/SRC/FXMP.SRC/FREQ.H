/*
  freq.h - freq/period routines
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

#ifndef __FREQ_H__
#define __FREQ_H__

int fxmp_note_to_period (int note, int finetune);
int fxmp_period_to_bend (int period, int note, int finetune);
ulong fxmp_get_period (uchar note, char finetune);
ulong fxmp_get_freq (ulong period);

#endif
