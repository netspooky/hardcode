/*
  This file is part of bob, a 32k game for Mekka Symposium 2001.
  Copyright 2001 Kuno Woudt <warp-tmt@dds.nl>

  This program uses Flare XM Player (fxmp), which is
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
  along with this program (see the file copying.txt); if not, write 
  to the Free Software Foundation, Inc., 
  59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include <stdio.h>
#include <stdlib.h>

#ifdef LINUX
#include <pthread.h>
#include <sys/resource.h>
#include <string.h>
#endif

#ifdef _WIN32
#include "bob_dx7.h"
#else 
#include "bob_ggi.h"
#endif

#include "bob_game.h"
#include "bob_text.h"
#include "bob_data.h"
#include "typeface.h"
#include "../fxmp.src/fxmp.h"

#ifdef _WIN32
#include "../fxmp.src/drv_win.h"
#else
#include "../fxmp.src/drv_dsp.h"
#endif

char * PACKAGE = "bob";
char * VERSION = "0.1.20";
char * CFG_FILE = "bob.cfg";
unsigned char volatile music;

#ifdef _WIN32
#define FXMP_DRV fxmp_drv_win
#define sleep(a) Sleep(a)
#else
#define FXMP_DRV fxmp_drv_dsp
#define sleep(a) usleep(1000 * a)
#endif

/*
   ____ pollthread __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
#ifdef _WIN32
DWORD WINAPI 
pollthread(LPVOID player)
#else
void*
pollthread(void * player)
#endif
{
  while (!fxmp_poll((fxmp_player *) player))
    {
      while(!music);
    }

  return 0;
}


/*
   ____ main ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
main(int argc, char ** argv)
{
#ifdef _WIN32
  DWORD threadid;
  HANDLE threadhandle;
#else
  pthread_t fxmpthread;
#endif

  fxmp_player player;
  FILE * file_cfg;
  char * vidmem;
  int y = 0;
  int i;
  char c;
  int back = 0;

  menu_action selection = menu_nop;

  int action;
  int key_prev;
  int key_down;
  int keyb_phase;  
  int name_count;
  char * press_key_text;

  player_options p1;
  player_options p2;
  player_options * px;

  char championship;
  char fullscreen;
   

/* ____ setup _____________________________________________________
   ________________________________________________________________ */

  /* default settings */
  fullscreen = 1;
  music = 1;
  championship = 4;

  /* setup players */
  strcpy(&p1.name[0], "cpu bob");
  p1.escape = BOB_KEY_ESCAPE;
  p1.action = BOB_KEY_SPACE; 
  p1.up     = BOB_KEY_E;
  p1.down   = BOB_KEY_D;
  p1.left   = BOB_KEY_S;
  p1.right  = BOB_KEY_F;
  p1.radix  = 10;
  p1.keymap = BOB_QWERTY;
  p1.cpu    = 1;

  strcpy(&p2.name[0], "bob");
  memcpy(&p2, &p1, sizeof(player_options));
  p2.action = BOB_KEY_ENTER; 
  p2.up     = BOB_KEY_UP;
  p2.down   = BOB_KEY_DOWN;
  p2.left   = BOB_KEY_LEFT;
  p2.right  = BOB_KEY_RIGHT;
  p2.cpu    = 0;

  /* load player setup from file */
  file_cfg = fopen(CFG_FILE, "rb");
  if(file_cfg != NULL)
    {
      for(i = 0; i<4; i++)
        fgetc(file_cfg);

      championship = fgetc(file_cfg);
      music = fgetc(file_cfg);
      fullscreen = fgetc(file_cfg);     

      px = &p1;
      for(i=0; i<2; i++)
        {
          fread(px->name, 1, GAME_MAX_NAME_SIZE, file_cfg);
          px->name[GAME_MAX_NAME_SIZE] = '\0';
          px->up = fgetc(file_cfg) | (fgetc(file_cfg) << 8);
          px->down = fgetc(file_cfg) | (fgetc(file_cfg) << 8);
          px->left = fgetc(file_cfg) | (fgetc(file_cfg) << 8);
          px->right = fgetc(file_cfg) | (fgetc(file_cfg) << 8);
          px->action = fgetc(file_cfg)  | (fgetc(file_cfg) << 8);
          px->escape = fgetc(file_cfg) | (fgetc(file_cfg) << 8);
          px->radix = fgetc(file_cfg);
          px->keymap = fgetc(file_cfg);
          px->cpu = fgetc(file_cfg);

          px = &p2;
        }

      fclose(file_cfg);
    }

  /* parse command line options */
  for(i = 0; i < argc; i++)
    {
      if(strstr(argv[i], "window"))
        fullscreen = 0;

      if(strstr(argv[i], "quiet"))
        music = 0;
    }

/* ____ init ______________________________________________________
   ________________________________________________________________ */
  vidmem = (char *) calloc(GAME_VIDEO_SIZE, 1);
  init(GAME_VIDEO_WIDTH, GAME_VIDEO_HEIGHT, fullscreen, PACKAGE);

/* music */
  if(music)
    {
      if(fxmp_init(&player, &FXMP_DRV, 0))
        error("initializing music failed");
      if(NULL == fxmp_load(&player, menu_xm_data))
        error("failed to load music");

      fxmp_load_patches(&player);
      fxmp_play(&player);

  /* music thread */

  /* some of this code was copied from Bliss-8bit and is therefore
  prepared for linux and win32 both, i've decided to keep the linux
  stuff as i probably will port this some day. */
#ifdef LINUX
      setpriority(PRIO_PROCESS, 0, PRIO_MIN);
#endif

      sleep(200);

#ifdef _WIN32
      if(NULL == (threadhandle = 
          CreateThread(NULL, 0, &pollthread, &player, 0, &threadid)))
        error("cannot create a new thread");

      SetThreadPriority(threadhandle,       THREAD_PRIORITY_HIGHEST);
      SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_ABOVE_NORMAL);
#else
      if(0 != pthread_create(&fxmpthread, NULL, pollthread, &player))
        error("cannot create a new thread");

  /* the priority of fxmpthread is either 0 or -20 (if a super user
     is running this), to make sure it gets as much CPU time as 
     possible without slowing this thread to a crawl - the priority of
     this thread is reniced with two `notches'. */
      setpriority (PRIO_PROCESS, 0, getpriority (PRIO_PROCESS, 0) + 2);
#endif

    } /* if(music) */


  /* setup palette. */
  flip(vidmem);
  setpal(DATA_PAL, 0x100);

  /* menu */
  menu(NULL, 0, 0, 0, 0, NULL, NULL, menu_quit, menu_nop);

  /* select the main menu from the quit menu */
  menu(vidmem, GAME_VIDEO_WIDTH, 0, 0, 0, 
    DATA_FONT0, DATA_FONT0, NULL, menu_next);
  menu(vidmem, GAME_VIDEO_WIDTH, 0, 0, 0, 
    DATA_FONT0, DATA_FONT0, NULL, menu_next);
  menu(vidmem, GAME_VIDEO_WIDTH, 0, 0, 0, 
    DATA_FONT0, DATA_FONT0, NULL, menu_enter);

  action = ACTION_NOP;

/* ____ menu loop _________________________________________________
   ________________________________________________________________ */
  while(action != ACTION_QUIT)
    {
      /* back a menu for some selections */
      if(back)
        menu(vidmem, GAME_VIDEO_WIDTH, 0, 0, 0, 
          DATA_FONT0, DATA_FONT0, NULL, menu_back);

      /* wait for keys to be released before accepting new keypresses */
      key_prev = 1; 
      action = ACTION_NOP;

      while(action == ACTION_NOP)
        {   
               if(chkkey(p1.escape) || chkkey(p2.escape)) { selection = menu_back;  key_down = 1; }
          else if(chkkey(p1.action) || chkkey(p2.action)) { selection = menu_enter; key_down = 1; }
          else if(chkkey(p1.up)     || chkkey(p2.up))     { selection = menu_prev;  key_down = 1; }
          else if(chkkey(p1.down)   || chkkey(p2.down))   { selection = menu_next;  key_down = 1; }
          else key_down = 0;

          /* don't accept keypresses until all keys have been released. */
          if(key_prev == 1) selection = menu_nop;
          key_prev = key_down;

          memset(vidmem, 0x03, GAME_VIDEO_SIZE);

          action = menu(vidmem, GAME_VIDEO_WIDTH, 4, 4, 0, 
            DATA_FONT1, DATA_FONT0, NULL, selection);

          /* FIXME: align right. */
          render_text(vidmem, GAME_VIDEO_WIDTH, GAME_VIDEO_WIDTH - 60, GAME_VIDEO_HEIGHT - 12,
	      DATA_FONT0, 0, 0, 0, VERSION);

          flip(vidmem);
        }

      back = 0;

      /* clear selection keypresses and screen */
      memset(vidmem, 0x03, GAME_VIDEO_SIZE);
      while(chkkey(p1.escape) || chkkey(p2.escape)
          || chkkey(p1.action) || chkkey(p2.action))
        flip(vidmem);

      /* reset default player to player 2. 
        (for ACTION_KEYBx and ACTION_NAMEx) */
      px = &p2;

      switch(action)
        {
#ifdef MENU_INFO
        case ACTION_STORY: /* story */
          while(!(chkkey(p1.action) || chkkey(p2.action)
            || chkkey(p1.escape) || chkkey(p2.escape)))
          {
            render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
	      DATA_FONT0, 0, 0, 0, STORY);

            flip(vidmem);
          }
          break;
#endif

#ifdef MENU_INFO
        case ACTION_DISC: /* disclaimer  */
          while(!(chkkey(p1.action) || chkkey(p2.action)
            || chkkey(p1.escape) || chkkey(p2.escape)))
          {
            render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
	      DATA_FONT0, 0, 0, 0, DISCLAIMER);

            flip(vidmem);
          }
          break;
#endif

#ifdef MENU_INFO
        case ACTION_CRED: /* credits */
          while(!(chkkey(p1.action) || chkkey(p2.action)
            || chkkey(p1.escape) || chkkey(p2.escape)))
          {
            render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
	      DATA_FONT0, 0, 0, 0, CREDITS);

            flip(vidmem);
          }
          break;
#endif

        case ACTION_GAME: /* game :) */
          if(music)
            {
              music = 0; /* stop the thread from polling. */
              sleep(1); 

              if(NULL == fxmp_load(&player, game_xm_data)) exit(3);
              fxmp_load_patches(&player);
              fxmp_play(&player);

              music = 1;
            }

          game(vidmem, &p1, &p2, championship);

          if(music)
            {
              music = 0; /* stop the thread from polling. */
              sleep(1); 

              if(NULL == fxmp_load(&player, menu_xm_data)) exit(3);
              fxmp_load_patches(&player);
              fxmp_play(&player);

              music = 1;
            }

          break;

        case ACTION_NAME1: 
          px = &p1;
          /* WARNING: fall-through :) */
        case ACTION_NAME2:
          key_down = 1;

          for(i = 0; i<GAME_MAX_NAME_SIZE+1; i++)
            px->name[i] = '\0';

          name_count = 0;
          while((name_count<GAME_MAX_NAME_SIZE) && (!chkkey(BOB_KEY_ENTER)))           
            {
              if(key_down)
                {
                  key_down = 0;
                  for(i = 0; i<0x100; i++)
                    key_down = key_down || chkkey(i);
                }
              else
                {
                  c = getkey(px->keymap);
                  if(c!=0)
                    {
                      px->name[name_count++] = c;
                      key_down = 1;
                    }
                }

              y = render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
	            DATA_FONT0, 0, 0, 0, ENTER_NAME);

              y = render_text(vidmem, GAME_VIDEO_WIDTH, 4, y,
	            DATA_FONT1, 0, 0, 0, px->name);

              flip(vidmem);
            }

          render_text(vidmem, GAME_VIDEO_WIDTH, 4, y,
            DATA_FONT0, 0, 0, 0, CONTINUE);

          /* clear keypresses */
          while(chkkey(p1.action) || chkkey(p2.action))
            flip(vidmem);

          /* clear wait for one */
          while(!(chkkey(p1.action) || chkkey(p2.action)))
            flip(vidmem);

          break;

        case ACTION_KEYB1: 
          px = &p1;
          /* WARNING: fall-through :) */
        case ACTION_KEYB2:
          key_down = 1;

          /* 0 = up, 1 = down, 2 = left, 3 = right, 4 = action, 5 = escape */
          keyb_phase = 0;

          press_key_text = PRESS_UP;

          y = render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
            DATA_FONT0, 0, 0, 0, press_key_text);

          while(keyb_phase<6)
            {
              if(key_down)
                {
                  key_down = 0;
                  for(i = 0; i<0x100; i++)
                    key_down = key_down || chkkey(i);
                }
              else
                {
                  for(i = 0; i<0x100; i++)
                    if(chkkey(i))
                    {
                      switch(keyb_phase)
                        {
                        case 0: 
                          px->up = i;
                          press_key_text = PRESS_DOWN;
                          break;
                        case 1: 
                          px->down = i;
                          press_key_text = PRESS_LEFT;
                          break;
                        case 2: 
                          px->left = i;
                          press_key_text = PRESS_RIGHT;
                          break;
                        case 3: 
                          px->right = i;
                          press_key_text = PRESS_ACTION;
                          break;
                        case 4: 
                          px->action = i;
                          press_key_text = PRESS_ESCAPE;
                          break;
                        case 5: 
                          px->escape = i;
                          break;
                        }

                      i = 0x100;
                      key_down = 1;
                      keyb_phase++;

                      y = render_text(vidmem, GAME_VIDEO_WIDTH, 4, y,
                        DATA_FONT0, 0, 0, 0, press_key_text);
                    }
                }

              flip(vidmem);
            }
          break;

        case ACTION_R1_B:  back = 1; p1.radix = 2; break;
        case ACTION_R1_O:  back = 1; p1.radix = 8; break;
        case ACTION_R1_D:  back = 1; p1.radix = 10; break;
        case ACTION_R1_H:  back = 1; p1.radix = 16; break;
        case ACTION_QWER1: back = 1; p1.keymap = BOB_QWERTY; break;
        case ACTION_DVOR1: back = 1; p1.keymap = BOB_DVORAK; break;
        case ACTION_CPU1:  back = 1; p1.cpu = 1; break;
        case ACTION_MAN1:  back = 1; p1.cpu = 0; break;
        case ACTION_R2_B:  back = 1; p2.radix = 2; break;
        case ACTION_R2_O:  back = 1; p2.radix = 8; break;
        case ACTION_R2_D:  back = 1; p2.radix = 10; break;
        case ACTION_R2_H:  back = 1; p2.radix = 16; break;
        case ACTION_QWER2: back = 1; p2.keymap = BOB_QWERTY; break;
        case ACTION_DVOR2: back = 1; p2.keymap = BOB_DVORAK; break;
        case ACTION_CPU2:  back = 1; p2.cpu = 1; break;
        case ACTION_MAN2:  back = 1; p2.cpu = 0; break;

        case ACTION_GAME4: back = 1; championship =  4; break;
        case ACTION_GAME8: back = 1; championship =  8; break;
        case ACTION_GAM16: back = 1; championship = 16; break;
        case ACTION_GAM32: back = 1; championship = 32; break;
        case ACTION_GAM64: back = 1; championship = 64; break;
        
        case ACTION_SAVE: 
          file_cfg = fopen(CFG_FILE, "wb");
          if(file_cfg != NULL)
            {
              fputs("bob!", file_cfg);
              fputc(championship, file_cfg);
              fputc(music, file_cfg);
              fputc(fullscreen, file_cfg);

              px = &p1;
              for(i=0; i<2; i++)
                {
                  fwrite(px->name, 1, GAME_MAX_NAME_SIZE, file_cfg);

                  fputc(px->up, file_cfg);      fputc(px->up >> 8, file_cfg);
                  fputc(px->down, file_cfg);    fputc(px->down >> 8, file_cfg);
                  fputc(px->left, file_cfg);    fputc(px->left >> 8, file_cfg);
                  fputc(px->right, file_cfg);   fputc(px->right >> 8, file_cfg);
                  fputc(px->action, file_cfg);  fputc(px->action >> 8, file_cfg);
                  fputc(px->escape, file_cfg);  fputc(px->escape >> 8, file_cfg);
                  fputc(px->radix, file_cfg);
                  fputc(px->keymap, file_cfg);
                  fputc(px->cpu, file_cfg);

                  px = &p2;
                }

              fclose(file_cfg);

              y = render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
                    DATA_FONT0, 0, 0, 0, SAVED);
            }
          else
            {
              y = render_text(vidmem, GAME_VIDEO_WIDTH, 4, 2,
                    DATA_FONT0, 0, 0, 0, SAVE_ERROR);
            }

          render_text(vidmem, GAME_VIDEO_WIDTH, 4, y,
            DATA_FONT0, 0, 0, 0, CONTINUE);

          while(!(chkkey(p1.action) || chkkey(p2.action)
              || chkkey(p1.escape) || chkkey(p2.escape)))
          {
            flip(vidmem);
          }
          break;

        default:
          break;
        }
    }


/* ____ clean up __________________________________________________
   ________________________________________________________________ */
  if(music)
    {
#ifdef _WIN32
      TerminateThread(threadhandle, 0);
#else
      pthread_cancel(fxmpthread);
#endif 

      fxmp_deinit(&player);
    }

  free(vidmem);
  quit();
  return 0;
}
