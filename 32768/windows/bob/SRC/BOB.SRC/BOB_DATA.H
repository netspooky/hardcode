/*
  This file is part of bob, a 32k game for Mekka Symposium 2001.
  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program (see the file copying.txt); if not, write 
  to the Free Software Foundation, Inc., 
  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef BOB_DATA_H
#define BOB_DATA_H

extern unsigned char game_xm_data[];
extern unsigned char menu_xm_data[];

extern unsigned char drbob2_pal_data[];
extern unsigned char drbob20_jrs_data[];
extern unsigned char drbob21_jrs_data[];
extern unsigned char drbob20_jtf_data[];
extern unsigned char drbob21_jtf_data[];

#define DATA_PAL drbob2_pal_data
#define DATA_SPRITES drbob20_jrs_data
#define DATA_ITEMS drbob21_jrs_data
#define DATA_FONT0 drbob20_jtf_data
#define DATA_FONT1 drbob21_jtf_data

#endif BOB_DATA_H
