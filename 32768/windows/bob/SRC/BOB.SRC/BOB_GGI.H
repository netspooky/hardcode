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

#ifndef BOB_GGI_H
#define BOB_GGI_H

#define DEBUG

#include <ggi/ggi.h>

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define BOB_QWERTY 0
#define BOB_DVORAK 1

#define BOB_KEY_ESCAPE	        GIIUC_Escape

#define BOB_KEY_UP		GIIK_Up
#define BOB_KEY_LEFT		GIIK_Left
#define BOB_KEY_RIGHT		GIIK_Right
#define BOB_KEY_DOWN		GIIK_Down
#define BOB_KEY_ENTER		GIIUC_Return

#define BOB_KEY_E		GIIUC_e
#define BOB_KEY_D		GIIUC_d
#define BOB_KEY_S		GIIUC_s
#define BOB_KEY_F		GIIUC_f
#define BOB_KEY_SPACE		GIIUC_Space

void init(int width, int height, int fullscreen, char * appname);
void quit(void);
int  chkkey(int key);
char getkey(int map);
void flip(char * src);
void paint_primary();

void setpal(char * pal, int pal_size);

void warning(char* message);
#ifdef DEBUG
void error(char * e);
#else
#define error(e)	{ quit(); exit(2); }
#endif

#endif /* BOB_GGI_H */
