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

#ifndef BOB_DX7_H
#define BOB_DX7_H

#define DEBUG

#include "win32cfg.h"
#include <windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <ddraw.h>
#include <dinput.h>
#include <mmsystem.h>

#if DIRECTDRAW_VERSION < 0x0700
#warning This project has only been tested with the DirectX SDK 
#warning for DirectX 7 - earlier might not work.
#endif 

#define BOB_QWERTY 0
#define BOB_DVORAK 1

#define BOB_KEY_ESCAPE	        DIK_ESCAPE

#define BOB_KEY_UP		DIK_UP
#define BOB_KEY_LEFT		DIK_LEFT
#define BOB_KEY_RIGHT		DIK_RIGHT
#define BOB_KEY_DOWN		DIK_DOWN
#define BOB_KEY_ENTER		DIK_RETURN

#define BOB_KEY_E		DIK_E
#define BOB_KEY_D		DIK_D
#define BOB_KEY_S		DIK_S
#define BOB_KEY_F		DIK_F
#define BOB_KEY_SPACE		DIK_SPACE

/*
#include <basetsd.h>
#include <windowsx.h>
#include <mmsystem.h>
*/

void init(int width, int height, int fullscreen, char * appname);
void quit(void);
int  chkkey(int key);
char getkey(int map);
void flip(char * src);
void paint_primary();


void setpal(char * pal, int pal_size);

#ifdef DEBUG
void error(char * e);
#else
#define error(e)	{ quit(); exit(2); }
#endif

LRESULT CALLBACK
window_proc(HWND window_handle, UINT message, WPARAM wparam, LPARAM lparam);

#endif BOB_DX7_H
