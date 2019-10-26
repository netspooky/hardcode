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

#ifndef BOB_TEXT_H
#define BOB_TEXT_H

#include "typeface.h" 

#define MENU_INFO

#define ACTION_NOP   0x00
#define ACTION_BACK  0x01
#define ACTION_QUIT  0x02
#define ACTION_STORY 0x03
#define ACTION_DISC  0x04
#define ACTION_CRED  0x05
#define ACTION_HIGH  0x06
#define ACTION_GAME  0x07
#define ACTION_SAVE  0x08
#define ACTION_GAME4 0x10
#define ACTION_GAME8 0x11
#define ACTION_GAM16 0x12
#define ACTION_GAM32 0x13
#define ACTION_GAM64 0x14
#define ACTION_NAME1 0x20
#define ACTION_NAME2 0x30
#define ACTION_KEYB1 0x21
#define ACTION_KEYB2 0x31
#define ACTION_R1_B  0x22
#define ACTION_R2_B  0x32
#define ACTION_R1_O  0x23
#define ACTION_R2_O  0x33
#define ACTION_R1_D  0x24
#define ACTION_R2_D  0x34
#define ACTION_R1_H  0x25
#define ACTION_R2_H  0x35
#define ACTION_QWER1 0x26
#define ACTION_QWER2 0x36
#define ACTION_DVOR1 0x27
#define ACTION_DVOR2 0x37
#define ACTION_CPU1  0x28
#define ACTION_CPU2  0x38
#define ACTION_MAN1  0x29
#define ACTION_MAN2  0x39




extern menu_item * menu_quit[];
#ifdef MENU_INFO
extern char * DISCLAIMER;
extern char * STORY;
extern char * CREDITS;
extern char * HIGHSCORES;
#endif

extern int PRESS_KEY_OFFSET;
extern char * PRESS_TEXT;
extern char * PRESS_UP;
extern char * PRESS_DOWN;
extern char * PRESS_LEFT;
extern char * PRESS_RIGHT;
extern char * PRESS_ACTION;
extern char * PRESS_ESCAPE;

extern char * ENTER_NAME;
extern char * CONTINUE;
extern char * SAVE_ERROR;
extern char * SAVED;

#endif BOB_TEXT_H
