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

#ifndef __DRV_WIN_H__
#define __DRV_WIN_H__

#include "types.h"
#include "config.h"
#include "fxmp.h"

int win_init (fxmp_player *p);
void win_deinit (fxmp_player *p);
void win_soundout (int fd, void *buf, int len);

extern fxmp_driver fxmp_drv_win;

#endif /* __DRV_WIN_H__ */
