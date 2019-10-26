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

#ifndef TYPEFACE_H
#define TYPEFACE_H

int
render_text(unsigned char * buffer, int buf_width, int xpos, int ypos, 
	    unsigned char * font, int hspacing, int vspacing, int col,
            const char * msg);

#define MENU_MAX_DEPTH 5

typedef struct menu_item_struct
{
  int action;
  void * submenu;
  char * menutext;
} menu_item;

typedef enum menu_action_enum 
{ 
  menu_nop,
  menu_enter, 
  menu_next, 
  menu_prev, 
  menu_back 
} menu_action;

int
menu(unsigned char * buffer, int buf_width, int xpos, int ypos, 
     int align, unsigned char * font_selected, unsigned char * font,
     menu_item ** menu_main, menu_action movement);

#endif TYPEFACE_H
