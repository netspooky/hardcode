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

#define INITGUID

#include <ggi/ggi.h>
#include <ggi/misc.h>

#include "bob_ggi.h"

/*
   ____ globals _____________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/

int window_bpp;
int window_fullscreen;
int window_width;
int window_height;

#define KEYBOARD_STATE_SIZE 0xffff
char keyboard_state[KEYBOARD_STATE_SIZE];
char palette[0x300];

#ifdef DEBUG

#define ERROR_MAX_SIZE 0x80
char * ERROR_CAPTION = "bob error: ";

#endif

void
warning (char* msg)
{
#ifdef WARNING
  printf ("*WARNING* %s\n", msg);
#endif /* WARNING */
}

/*
   ____ error _______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
#ifdef DEBUG
void
error(char * e)
{
  fprintf(stderr, "error: %s.\n", e); 

  exit(1);
}
#endif

ggi_visual_t ggi_visual;

/*
   ____ init ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
init(int width, int height, int fullscreen, char * appname)
{
  int i;
  
  ggiInit ();
  ggi_visual = ggiOpen (NULL);
  ggiSetGraphMode (ggi_visual, width, height, width, height, GT_8BIT);

  for (i = 0; i < KEYBOARD_STATE_SIZE; i++)
    keyboard_state[i] = 0;
}

/*
   ____ quit ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
quit(void)
{
  ggiClose (ggi_visual);
}


/*
   ____ setpal ______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
setpal(char * pal, int pal_size)
{
  int i;
  ggi_color ggi_pal[256];
  
  for ( i = 0; i < pal_size; i++ )
    {
      ggi_pal[i].r = (pal[i*3]) << 8;
      ggi_pal[i].g = (pal[i*3+1]) << 8;
      ggi_pal[i].b = (pal[i*3+2]) << 8;
    }
  ggiSetPalette ( ggi_visual, 0, pal_size, ggi_pal );
}

/*
   ____ chkkey ______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
chkkey(int key)
{
  if (keyboard_state[key] > 0)
    printf ("check %d is now %d\n",key,keyboard_state[key]);
  return keyboard_state[key] & 0x80;
}

/*
   ____ getkey_dvorak _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char
getkey_dvorak(void)
{
  int i;

  for(i = 0; i<0x100; i++)
    if(keyboard_state[i] & 0x80)
      switch(i)
        {
        case GIIUC_Space: return ' ';
        case GIIUC_0: return '0';
        case GIIUC_1: return '1';
        case GIIUC_2: return '2';
        case GIIUC_3: return '3';
        case GIIUC_4: return '4';
        case GIIUC_5: return '5';
        case GIIUC_6: return '6';
        case GIIUC_7: return '7';
        case GIIUC_8: return '8';
        case GIIUC_9: return '9';
        case GIIUC_a: return 'a';
        case GIIUC_n: return 'b';
        case GIIUC_i: return 'c';
        case GIIUC_h: return 'd';
        case GIIUC_d: return 'e';
        case GIIUC_y: return 'f';
        case GIIUC_u: return 'g';
        case GIIUC_j: return 'h';
        case GIIUC_g: return 'i';
        case GIIUC_c: return 'j';
        case GIIUC_v: return 'k';
        case GIIUC_p: return 'l';
        case GIIUC_m: return 'm';
        case GIIUC_l: return 'n';
        case GIIUC_s: return 'o';
        case GIIUC_r: return 'p';
        case GIIUC_x: return 'q';
        case GIIUC_o: return 'r';
        case GIIUC_Semicolon: return 's';
        case GIIUC_k: return 't';
        case GIIUC_f: return 'u';
        case GIIUC_Period: return 'v';
        case GIIUC_Comma: return 'w';
        case GIIUC_b: return 'x';
        case GIIUC_t: return 'y';
        case GIIUC_Slash: return 'z';
        }

  return 0;
}

/*
   ____ getkey_qwerty _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char
getkey_qwerty(void)
{
  int i;

  for(i = 0; i<0x100; i++)
    if(keyboard_state[i] & 0x80)
      switch(i)
        {
        case GIIUC_Space: return ' ';
        case GIIUC_0: return '0';
        case GIIUC_1: return '1';
        case GIIUC_2: return '2';
        case GIIUC_3: return '3';
        case GIIUC_4: return '4';
        case GIIUC_5: return '5';
        case GIIUC_6: return '6';
        case GIIUC_7: return '7';
        case GIIUC_8: return '8';
        case GIIUC_9: return '9';
        case GIIUC_a: return 'a';
        case GIIUC_b: return 'b';
        case GIIUC_c: return 'c';
        case GIIUC_d: return 'd';
        case GIIUC_e: return 'e';
        case GIIUC_f: return 'f';
        case GIIUC_g: return 'g';
        case GIIUC_h: return 'h';
        case GIIUC_i: return 'i';
        case GIIUC_j: return 'j';
        case GIIUC_k: return 'k';
        case GIIUC_l: return 'l';
        case GIIUC_m: return 'm';
        case GIIUC_n: return 'n';
        case GIIUC_o: return 'o';
        case GIIUC_p: return 'p';
        case GIIUC_q: return 'q';
        case GIIUC_r: return 'r';
        case GIIUC_s: return 's';
        case GIIUC_t: return 't';
        case GIIUC_u: return 'u';
        case GIIUC_v: return 'v';
        case GIIUC_w: return 'w';
        case GIIUC_x: return 'x';
        case GIIUC_y: return 'y';
        case GIIUC_z: return 'z';
        }

  return 0;
}

void
read_keys ()
{
  struct timeval t = { 0, 0 };
  ggi_event ggi_ev;
  ggi_event_mask evmask;
  int key;
  
  evmask = (ggi_event_mask) (emKeyPress|emKeyRelease);

  while (ggiEventPoll (ggi_visual, evmask, &t))
    {
      ggiEventRead (ggi_visual, &ggi_ev, evmask);
      switch (ggi_ev.any.type)
        {
        case evKeyPress:
          key = ggi_ev.key.sym;
          if ((key > 0) && (key < KEYBOARD_STATE_SIZE))
            keyboard_state [key] = 0x80;
          break;
        case evKeyRelease:
          key = ggi_ev.key.sym;
          if ((key > 0) && (key < KEYBOARD_STATE_SIZE))
            keyboard_state [key] = 0;
          break;
        default:
        }
    }
}

/*
   ____ getkey ______________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char
getkey(int map)
{
  char key;

  /* FIXME: seems to work, except if you use a dvorak map allready,
     there's no need to remap and BOB_DVORAK will just be wrong :)

     printf ("FIXME this does not work yet\n");
  */
  if(map == BOB_DVORAK)
    {
      key = getkey_dvorak();
      return key;
    }
  else
    {
      key = getkey_qwerty();
      return key;
    }
}

/*
   ____ flip ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
flip(char * src)
{
  read_keys ();
  ggiPutBox (ggi_visual, 0, 0, 400, 300, src);
  ggiFlush (ggi_visual);
}
