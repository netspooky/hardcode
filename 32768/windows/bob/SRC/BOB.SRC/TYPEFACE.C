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

#include "typeface.h"

#include <stdio.h>

#define MENU_MAX_DEPTH 5


/*
   ____ render_text _________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
render_text(unsigned char * buffer, int buf_width, int xpos, int ypos, 
	    unsigned char * font, int hspacing, int vspacing, int col,
	    const char * msg)
{	
	/* look at fontripper.c for more info on `jtf2' font file format */
#define RT_MONO	      1

#define RT_X	      font[4]
#define RT_Y	      font[5]
#define RT_COUNT      font[6]
#define RT_FLAGS      font[7]
#define RT_MONOCOL    font[8]
#define RT_ASCII      font[9]
#define RT_WIDTH      font[10]
#define RT_DATA	      font[10+RT_COUNT]
	
  unsigned char * width = &RT_WIDTH;
  unsigned char * data = &RT_DATA;

  int x = RT_X;
  int y = RT_Y;

  int charwidth;     
  int column;        
  int row;           
  int tptr;          
  int lptr;          
  int run;
  int i;
  int ch;
  int line = 0;   /*  '\n' support, each '\n' increases line */

  for(row=0; row<y; row++)
    {
      line = 0;
      tptr = (ypos+row)*buf_width+xpos;

      for(i=0; msg[i]!=0; i++)
	{
          if(msg[i]=='\n')
            {
              line++;
              tptr = ((ypos+line*y+vspacing)+row)*buf_width+xpos;
            }

          ch = msg[i]-RT_ASCII;

          /* revert to uppercase if there are no lowercase
             characters in the font. */
          if((ch>RT_COUNT) 
            && (ch>=('a'-RT_ASCII))
            && (ch<=('z'-RT_ASCII)))
            ch += ('A' - 'a');

          charwidth = width[ch];

          if((ch<RT_COUNT) && (ch>=0))
            {
	      lptr = (ch*x*y + (x*row)) << 1;
	      tptr+=hspacing;

	      for(column=0; column<=charwidth;)
                {
	          for(run=0; (run<data[lptr]) && (column<=charwidth); run++) 
	            {
		      if(data[lptr+1]!=0)
		        buffer[tptr] = (RT_FLAGS & RT_MONO) ? 
		          RT_MONOCOL : data[lptr+1];
		      column++;
		      tptr++;
	            }
	          lptr+=2;
                }
            }
	}
    }	

  return (ypos+(line+1)*y+vspacing);
}


/*
   ____ menu ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/


/*
  NOTE: predefined return actions are:
  0     no action.
  2     quit.

  which is in fact a subset of the values used in menus:  
  0     no action, or if submenu != NULL open submenu.
  1     back to previous menu (up 1 level).
  2     quit
  x     anything else is returned verbatim to the caller.

  A quit (2) is also issued if you press escape at the main
  menu.
*/
int
menu(unsigned char * buffer, int buf_width, int xpos, int ypos, 
     int align, unsigned char * font_selected, unsigned char * font,
     menu_item ** menu_main, menu_action movement)
{
  static menu_item ** current_menu;
  static menu_item ** prev_menus[MENU_MAX_DEPTH];
  static int prev_selected[MENU_MAX_DEPTH];
  static int depth;
  static int selected;
  
  menu_item * item;
  int submenu_y;
  int i;

  if(menu_main != NULL)
    {
      /* init call, no rendering will be done. */
      current_menu = menu_main;
      selected = 0;
      depth = 0;   
    }
  else
    {
      submenu_y = ypos;

      /* NOTE: the wrong menu is rendered here if another
         selection was made below, at anything above 30fps
         this shouldn't be a problem - and it makes the code
         below a little easier (there's some ugly switches
         featuring a nifty fall-through and some returns ;) */

      for(i=0; current_menu[i] != NULL; i++)
        {
          if(selected==i)
            {
              submenu_y = render_text(buffer, buf_width, xpos, submenu_y,
	        font_selected, 0, 0, 0, current_menu[i]->menutext);
            }
          else
            {
              submenu_y = render_text(buffer, buf_width, xpos, submenu_y,
	        font, 0, 0, 0, current_menu[i]->menutext);
            }
        }

      item = current_menu[selected];

      switch(movement)
        {
        case menu_enter:
          switch(item->action)
            {
            case 0:
              if((item->submenu != NULL) && (depth<MENU_MAX_DEPTH))
                {
                  prev_menus[depth] = current_menu;
                  prev_selected[depth] = selected;
                  current_menu = item->submenu;
                  selected = 0;
                  depth++;
                }
              return 0;
            case 1:
              /* break, and fall-through to menu_back. */
              break;
            default:
              return item->action;
            }
          /* WARNING: fall-through */
        case menu_back:
          if(depth>0)
            {
              depth--;
              current_menu = prev_menus[depth];
              selected = prev_selected[depth];
            }
          else
            return 2; // quit
          break;
        case menu_next: 
          if(current_menu[selected+1] != NULL) selected++;
          break;
        case menu_prev: 
          if(selected>0) selected--;
          break;
        case menu_nop:
          break;
        }
    }

  return 0;
}
