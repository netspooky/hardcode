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

#include "gettime.h"
#include "bob_game.h"
#include "bob_data.h"
#include "typeface.h"

#ifdef _WIN32
#include "bob_dx7.h"
#else
#include "bob_ggi.h"
#include <string.h>
#endif

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <math.h>

#ifndef M_PI
#define M_PI        3.14159265358979323846
#endif

/*
   ____ some globals ________________________________________________
   __________________________________________________________________
*/
int  table_clipbuffer[GAME_CLIPBUFFER_HEIGHT];
int  table_video[GAME_CLIPBUFFER_HEIGHT];
char table_sin_x[SIN_X_LOOP_SIZE];
char table_sin_y[SIN_Y_LOOP_SIZE];

#define MUL_CLIP_WIDTH(x) table_clipbuffer[x]
#define MUL_VID_WIDTH(x) table_video[x]
#define SIN_X(x) table_sin_x[x]
#define SIN_Y(x) table_sin_y[x]

char * msg_powerup_reverse = "reverse!";
char * msg_powerup_bars = "bars!";
char * msg_powerup_food = "food!";
char * msg_powerup_drug = "drug!";
char * msg_powerup_zoom = "zoom!";
char * msg_powerup_gravity = "gravity!";
char * msg_powerup_prison = "prison!";
char * msg_powerup_speedup = "speedup!";
char * msg_eat = "cookie";
char * msg_escape = "escape";
char * msg_dead = "dead";
char * msg_snow = "all snow";

/*
   ____ game ________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void 
game(unsigned char * vidmem, 
     player_options * p1_o, player_options * p2_o, int championship)
{
  unsigned char * data_dudes;
  char * endscreen;
  int time_old;
  int time_new;
  int player_count;
  int y;
  int y_tmp;
  int x;
  int game_count;

  player p1;
  player p2;
  player * px;
  player * po;

/* ____ init ______________________________________________________
   ________________________________________________________________ */
  srand((unsigned) time(NULL));
  time_old = gettime();

  game_init_player(&p1, p1_o);
  game_init_player(&p2, p2_o);
  data_dudes = game_init_sprites();

  game_init_tables();

  p1.clipbuffer = (unsigned char *) calloc(GAME_CLIPBUFFER_SIZE, 1);
  p2.clipbuffer = (unsigned char *) calloc(GAME_CLIPBUFFER_SIZE, 1);

  p1.clipbuffer += GAME_CLIPBUFFER_START;
  p2.clipbuffer += GAME_CLIPBUFFER_START;

  game_clear_clip(&p1, &p2);

/* ____ game_loop _________________________________________________
   ________________________________________________________________ */
  for(game_count = 0; game_count < championship; game_count++)
    {
      game_clear_player(&p1);
      game_clear_player(&p2);

      while( !(chkkey(p1.o->escape) || chkkey(p2.o->escape))
          && !(p1.gameover || p2.gameover) )
        {
          px = &p1;
          po = &p2;

          for(player_count = 0; player_count<2; player_count++)
            {
              if((px->death_anim == 0)
                  && (po->death_anim == 0))
                {
                  /* NOTE: due to some shortcuts in the AI game_loop_player_x 
                     should be called before game_loop_player_y. */
              
                  game_loop_bars(px);
                  game_loop_evil_mutants(px);
                  game_loop_player_x(px, po);
                  game_loop_player_y(px, po);
                  game_loop_get_item(px, po);
                  game_loop_put_item(px);
                  game_loop_game_over(px, po);
                }
              else
                game_loop_death_anim(px, po);

              game_loop_timer(px);

              px = &p2;
              po = &p1;
            }

          game_clear(&p1, &p2);
          game_items(DATA_ITEMS, &p1, &p2);
          game_score(DATA_ITEMS, &p1, &p2);

          if((p1.snow != GAME_DOTS_TOTAL)
	      && (p2.snow != GAME_DOTS_TOTAL))
            game_dudes_part2(data_dudes, &p1, &p2);

          game_dudes_part1(data_dudes, &p1, &p2);

          game_field(&p1, &p2);

          if((p1.snow == GAME_DOTS_TOTAL)
	      || (p2.snow == GAME_DOTS_TOTAL))
            game_dudes_part2(data_dudes, &p1, &p2);

          game_messages(&p1, &p2);

          game_visualfx(vidmem, &p1, &p2);
          flip(vidmem);

          time_new = gettime();
          while((time_new - time_old) < GAME_MIN_FRAME_TIME)
            {
#ifdef _WIN32
              Sleep(GAME_MIN_FRAME_TIME - (time_new - time_old));
#else
              sleep(GAME_MIN_FRAME_TIME - (time_new - time_old));
#endif
              time_new = gettime();
            }
          time_old = time_new;
        }

    /* ____ end game screen _______________________________________
       ____________________________________________________________ */
      if(p1.gameover || p2.gameover)
        {
          p1.total += p1.score;
          p2.total += p2.score;

          x = 2;

          /* wait for keys to be released */
          while(chkkey(p1.o->escape) || chkkey(p2.o->escape)
              || chkkey(p1.o->action) || chkkey(p2.o->action))
            {
              flip(vidmem);
            }

          memset(vidmem, 0x03, GAME_VIDEO_SIZE);

          endscreen = calloc(50, 1);

          if(p1.gameover)
            px = &p2;
          else
            px = &p1;

          strcpy(endscreen, "round ");
          *(game_itoa(endscreen + strlen(endscreen), game_count+1, 12, px->o->radix)) = '\0';
          strcat(endscreen, " of ");
          *(game_itoa(endscreen + strlen(endscreen), championship, 12, px->o->radix)) = '\0';
          strcat(endscreen, ".");

          y = render_text(vidmem, GAME_VIDEO_WIDTH, x, 2,
            DATA_FONT0, 0, 0, 0, endscreen);  

          y = render_text(vidmem, GAME_VIDEO_WIDTH, x, y,
            DATA_FONT1, 0, 0, 0, "GAME OVER\n");  

          px = &p1;

          for(player_count = 0; player_count<2; player_count++)
            {
              y_tmp = y;

              y_tmp = render_text(vidmem, GAME_VIDEO_WIDTH, x, y_tmp,
                DATA_FONT1, 0, 0, 0, px->o->name);  

              if(px->gameover)
                strcpy(endscreen, "is a loser!\n\n(score: ");
              else
                strcpy(endscreen, "has won!\n\n(score: ");

              *(game_itoa(endscreen + strlen(endscreen), px->score, 12, px->o->radix)) = '\0';
              strcat(endscreen, ").");

              y_tmp = render_text(vidmem, GAME_VIDEO_WIDTH, x, y_tmp,
                DATA_FONT0, 0, 0, 0, endscreen);  

              strcpy(endscreen, "total score: ");
              *(game_itoa(endscreen + strlen(endscreen), px->total, 12, px->o->radix)) = '\0';
              strcat(endscreen, ".");

              y_tmp = render_text(vidmem, GAME_VIDEO_WIDTH, x, y_tmp+12,
                DATA_FONT0, 0, 0, 0, endscreen);  

              px = &p2;
              x += GAME_SCREEN_WIDTH;
            }

          while( !(chkkey(p1.o->escape) || chkkey(p2.o->escape)
              || chkkey(p1.o->action) || chkkey(p2.o->action)))
            {
              flip(vidmem);
            }

          if((game_count + 1) == championship)
            {
              memset(vidmem, 0x03, GAME_VIDEO_SIZE);

              /* wait for keys to be released */
              while(chkkey(p1.o->escape) || chkkey(p2.o->escape)
                  || chkkey(p1.o->action) || chkkey(p2.o->action))
                {
                  flip(vidmem);
                }

              if(p1.total == p2.total)
                {
                  championship++;

                  y = render_text(vidmem, GAME_VIDEO_WIDTH, 2, 2,
                    DATA_FONT0, 0, 0, 0, "it's a tie, let's play another round...");  

                }
              else
                {
                  if(p1.total > p2.total)
                    {
                      px = &p1;
                      po = &p2;
                    }
                  else 
                    {
                      px = &p2;
                      po = &p1;
                    }

                  /* final results */
                  y = render_text(vidmem, GAME_VIDEO_WIDTH, 2, 100, 
                    DATA_FONT1, 0, 0, 0, "FINAL RESULTS\n");  

                  strcpy(endscreen, "victory to ");
                  strcat(endscreen, px->o->name);
                  strcat(endscreen, ",\nand ");
                  strcat(endscreen, po->o->name);
                  strcat(endscreen, " is a loser!");

                  y = render_text(vidmem, GAME_VIDEO_WIDTH, 2, y+12,
                    DATA_FONT0, 0, 0, 0, endscreen);  

                  strcpy(endscreen, "total score for ");
                  strcat(endscreen, p1.o->name);
                  strcat(endscreen, " is: ");
                  *(game_itoa(endscreen + strlen(endscreen), p1.total, 12, px->o->radix)) = '\0';
                  strcat(endscreen, ".");

                  y = render_text(vidmem, GAME_VIDEO_WIDTH, 2, y+12,
                    DATA_FONT0, 0, 0, 0, endscreen);  

                  strcpy(endscreen, "total score for ");
                  strcat(endscreen, p2.o->name);
                  strcat(endscreen, " is: ");
                  *(game_itoa(endscreen + strlen(endscreen), p2.total, 12, px->o->radix)) = '\0';
                  strcat(endscreen, ".");

                  y = render_text(vidmem, GAME_VIDEO_WIDTH, 2, y+12,
                    DATA_FONT0, 0, 0, 0, endscreen);  
                }

              while( !(chkkey(p1.o->escape) || chkkey(p2.o->escape)
                  || chkkey(p1.o->action) || chkkey(p2.o->action)))
                {
                  flip(vidmem);
                }
            }

          free(endscreen);
        }
      else
        {
          game_count = championship;
        }
      
    }

/* ____ de_init ___________________________________________________
   ________________________________________________________________ */
  free(p1.clipbuffer - GAME_CLIPBUFFER_START);
  free(p2.clipbuffer - GAME_CLIPBUFFER_START);
  free(data_dudes);
}



/*
   ____ game_init_player ____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_init_player(player * px, player_options * px_o)
{
  memset(px, 0, sizeof(player));

  px->o = px_o;

  game_clear_player(px);
}

/*
   ____ game_clear_player ___________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_clear_player(player * px)
{
  int row;
  int item;

  px->row = (GAME_ROW_COUNT>>1);
  px->xpos = ((GAME_FIELD_WIDTH - GAME_DUDE_WIDTH)>>1);
  px->score = 0;
  px->snow = 0;
  px->xdir = 0;
  px->ydir = 0;
  px->xblock = 0;
  px->yblock = 0;
  px->xcount = 0;
  px->animcount = 0;
  px->death_anim = 0;
  px->y_winner_kludge = 0;
  px->gameover = 0;
  px->timer = 0;
  px->evilcount = 0;
  px->evilanimcount = 0; 
  if(px->message_countdown > GAME_MSG_COUNTDOWN1)
    px->message_countdown = GAME_MSG_COUNTDOWN1;

  memset(px->hole_inc, 2, sizeof(px->hole_inc));
  memset(px->evilanim, 0, sizeof(px->evilanim));
  memset(px->evil, 0, sizeof(px->evil)); 
  memset(px->evildir, 0, sizeof(px->evildir)); 
  memset(px->state, 0, GAME_POWERUP_COUNT); 

  px->hole[0] = 0;
  px->hole[1] = GAME_HOLE_SIZE;
  px->hole[2] = (GAME_FIELD_WIDTH + GAME_HOLE_SIZE)>>1;
  px->hole[3] = GAME_FIELD_WIDTH;
  px->hole[4] = (GAME_FIELD_WIDTH + GAME_HOLE_SIZE) - 1;

  for(row = 0; row<GAME_ROW_COUNT; row++)
    for(item = 0; item<GAME_DOTS_PER_ROW; item++)
        px->field[row][item] = game_dot;
}


/*
   ____ game_init_sprites ___________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
unsigned char *
game_init_sprites(void)
{
  int i;
  int j;
  unsigned char * data_dudes;

  /* prepare sprite data (mirror sprites) */
#define SPRITE_X	  DATA_SPRITES[4]
#define SPRITE_Y	  DATA_SPRITES[5]
#define SPRITE_COUNT      DATA_SPRITES[6]
#define SPRITE_FLAGS      DATA_SPRITES[7]
#define SPRITE_DATA	  DATA_SPRITES[8]

  i = SPRITE_X*SPRITE_Y*(SPRITE_COUNT>>1);
  data_dudes = malloc((i<<3) + 4);
  if(data_dudes == NULL)
    exit(23); /* FIXME: error handling. */

  data_dudes[0] = SPRITE_X;
  data_dudes[1] = SPRITE_Y;
  data_dudes[2] = SPRITE_COUNT<<2;
  data_dudes[3] = SPRITE_FLAGS;

  memcpy(data_dudes + 4, &SPRITE_DATA, (i<<1));

  /* rotate */
  for(j = 0; j < (SPRITE_COUNT>>1); j++)
    {
    game_45mirror(data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*2, data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*0, SPRITE_X, SPRITE_Y);
    game_hmirror (data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*4, data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*0, SPRITE_X, SPRITE_Y);
    game_hmirror (data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*3, data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*1, SPRITE_X, SPRITE_Y);
    game_45mirror(data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*7, data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*3, SPRITE_X, SPRITE_Y);
    game_hmirror (data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*5, data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*7, SPRITE_X, SPRITE_Y);
    game_45mirror(data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*6, data_dudes + 4 + SPRITE_X*SPRITE_Y*j + i*4, SPRITE_X, SPRITE_Y);
    }

#undef SPRITE_X
#undef SPRITE_Y
#undef SPRITE_COUNT
#undef SPRITE_FLAGS
#undef SPRITE_DATA
  
  return data_dudes;
}

/*
   ____ game_init_tables ____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_init_tables()
{
  int i;
  double d;
  double e;


  for(i = 0; i<GAME_CLIPBUFFER_HEIGHT; i++)
    {
      table_clipbuffer[i] = i*GAME_CLIPBUFFER_WIDTH;
      table_video[i] = i*GAME_VIDEO_WIDTH;
    }  


#ifdef SIN_WOBBLE_X
  for(i = 0; i<SIN_X_LOOP_SIZE; i++)
    {
      d = i;
      e = sin(M_PI * (d / (SIN_X_LOOP_SIZE>>1)));
      table_sin_x[i] = (char) (e * SIN_X_AMPLITUDE);    
    }
#else
    memset(table_sin_x, 0, GAME_SCREEN_WIDTH); 
#endif

#ifdef SIN_WOBBLE_Y
  for(i = 0; i<SIN_Y_LOOP_SIZE; i++)
    {
      d = i;
      e = sin(M_PI * (d / (SIN_Y_LOOP_SIZE>>1)));
      table_sin_y[i] = (char) (e * SIN_Y_AMPLITUDE);    
    }
#else
    memset(table_sin_y, 0, GAME_SCREEN_HEIGHT);
#endif
}

  

/*
   ____ game_loop_bars ______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_bars(player * px)
{
  int i;

  for(i = 0; i<GAME_BAR_COUNT; i++)
    {
           if(px->hole[i] <= 0) px->hole[i] = 0;
      else if(px->hole[i] > GAME_MAX_HOLE_POS) px->hole[i] = GAME_MAX_HOLE_POS;
      else px->hole[i] += px->hole_inc[i];

      /* FIXME: implement a more efficient use of rand() */          
      if((rand() & 0x0F) == 3)
        {
          if((rand() & 0x01) == 1)
            {
              if(px->hole[i] == 0) px->hole_inc[i] = -px->hole_inc[i];
              if(px->hole[i] == GAME_MAX_HOLE_POS) px->hole_inc[i] = -px->hole_inc[i];
            }
          else
            {
              if(px->hole[i] == 0) px->hole[i] = GAME_MAX_HOLE_POS;
              if(px->hole[i] == GAME_MAX_HOLE_POS) px->hole[i] = 0;
            }

          if((px->hole[i] == 0) || (px->hole[i] == GAME_MAX_HOLE_POS))
            px->hole[i] += px->hole_inc[i];
        }
    }
}



/*
   ____ game_loop_evil_mutants ______________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_evil_mutants(player * px)
{
  int i;

  px->evilcount++;
  px->evilanimcount++;

  if(px->evilcount > GAME_EVIL_FRAMES)
    {
      px->evilcount = 0;

      if(px->evilanimcount > GAME_EVIL_ANIM_FRAMES)
        for(i = 0; i<GAME_ROW_COUNT; i++)
          {
            px->evilanim[i] -= px->evildir[i];
            px->evilanimcount = 0;

            if(px->evilanim[i] < 0) px->evilanim[i] = GAME_DUDE_FRAMECOUNT - 1;
            if(px->evilanim[i] > GAME_DUDE_FRAMECOUNT - 1) px->evilanim[i] = 0;
          }

      for(i = 0; i<GAME_ROW_COUNT; i++)
        {
          px->evil[i] += px->evildir[i];

          if(px->evil[i] > GAME_FIELD_WIDTH)
            px->evildir[i] = 0;
          if(px->evil[i] < -GAME_DUDE_WIDTH)
            px->evildir[i] = 0;

          if(px->evildir[i] == 0)
            {
              /* create new mutants */
              if((rand() & 0x3FF) == 3)
                {
                  if(rand() & 0x1)
                    {
                      px->evildir[i] = 1;
                      px->evil[i] = -GAME_DUDE_WIDTH;
                    }
                  else
                    {
                      px->evildir[i] = -1;
                      px->evil[i] = GAME_FIELD_WIDTH;
                    }
                }
            }
          else
            {
              if(px->row == i)
                {
                  if(px->xpos > px->evil[i])
                    px->evildir[i] = px->state[game_food] ? -1 : 1;
                  else
                    px->evildir[i] = px->state[game_food] ? 1 : -1;
                }
            }
        }
    }
}


/*
   ____ game_loop_death_anim ________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void 
game_loop_death_anim(player * px, player * po)
{
  /* there's two death anim's here:
     1. player dies.
     2. player gets all snow.
   */
  if(px->snow == GAME_DOTS_TOTAL)
    {
      /* player won anim */
      px->anim = 0;

      px->animcount+=3;

      px->y_winner_kludge = SIN_X(px->animcount | 0x80);

      if((chkkey(px->o->escape) || chkkey(po->o->escape)
         || chkkey(px->o->action) || chkkey(po->o->action)))
        po->gameover = 1;
    }
  else
    if(px->death_anim > 0)
      {
        /* player died */
        px->animcount++;
        if(px->animcount > GAME_ANIM_FRAMES)
          {
	    px->anim++;
            px->animcount = 0;
          }
  
        if(px->anim < 0) px->anim = GAME_DUDE_FRAMECOUNT - 1;
        if(px->anim > GAME_DUDE_FRAMECOUNT - 1) px->anim = 0;

//        if(--px->death_animcount == 0)
        if((chkkey(px->o->escape) || chkkey(po->o->escape)
           || chkkey(px->o->action) || chkkey(po->o->action)))
          px->gameover = 1;
      }
}


/*
   ____ game_loop_player_x __________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_player_x(player * px, player * po)
{
  int inc = px->state[game_speedup] ? 2 : 1;

  if(!px->o->cpu)
    {
      if(!px->xblock)
        {
          if(chkkey(px->o->left))
            {
              px->xdir = (px->xdir < 0) ?  0 : (0 - inc);
              px->xblock = 1;
              px->ydir = 0;
            }

          if(chkkey(px->o->right))  
            {
              px->xdir = (px->xdir >  0) ?  0 : inc;
              px->xblock = 1;
              px->ydir = 0;
            }
        }
      else
        if(!chkkey(px->o->left))
          if(!chkkey(px->o->right))
            px->xblock = 0;
    }
  else // AI, cpu player.
    {
      if(game_ai_snow_on_this_row(px, po)) /* !snow_on_this_row gets handled in y */
        {
          if(!game_ai_evil_on_this_row(px)) /* evil_on_this_row gets handled in y */
            {
              if(game_ai_snow_left(px, po))
                {
                  px->xdir = (0 - inc);
                  px->ydir = 0;
                }
              else // snow_right
                {
                  px->xdir = inc;
                  px->ydir = 0;
                }
            }
          else
            {
              if(game_ai_evil_left(px))
                {
                  px->xdir = inc;
                  px->ydir = 0;                
                }
              else 
                {
                  px->xdir = (0 - inc);
                  px->ydir = 0;
                }
            }
        }
      else
        {
          px->xdir = 0;
        }
    }
      
  px->xcount++;
  px->animcount++;
  if(px->xcount > GAME_X_FRAMES)
    {
      px->xpos += px->xdir;
      px->xcount = 0;

      if(px->animcount > GAME_ANIM_FRAMES)
        {
          px->anim -= px->xdir;
          px->animcount = 0;
        }
      }

  if(px->anim < 0) px->anim = GAME_DUDE_FRAMECOUNT - 1;
  if(px->anim > GAME_DUDE_FRAMECOUNT - 1) px->anim = 0;

  if(px->xpos <= 0)
    {
      px->xpos = 0;
      px->xdir = 0;
    }

  if(px->xpos >= GAME_FIELD_WIDTH - GAME_DUDE_WIDTH)
    {
      px->xpos = GAME_FIELD_WIDTH - GAME_DUDE_WIDTH;
      px->xdir = 0;
    }
}

/*
   ____ game_loop_player_y __________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_player_y(player * px, player * po)
{
  if(!px->o->cpu)
    {
      if(!px->yblock)
        {
          if(chkkey(px->o->up))
            {
              px->ydir = -1;
              px->yblock = 1;
              px->xdir = 0;
            }

          if(chkkey(px->o->down))  
            {
              px->ydir = 1;
              px->yblock = 1;
              px->xdir = 0;
            }
        }
      else
        if(!chkkey(px->o->up))
          if(!chkkey(px->o->down))
            px->yblock = 0;
    }
  else // AI, cpu player.
    {
      px->ydir = 0;
      
      if(!game_ai_snow_on_this_row(px, po)) /* snow_on_this_row gets handled in x */
        {
          if(game_ai_snow_above_this_row(px))
            {
              if(!game_ai_evil_above(px))
                {
                  px->ydir = -1;
                  px->xdir = 0;
                }
            }
          else
            {
              if(!game_ai_evil_below(px))
                {
                  px->ydir = 1;
                  px->xdir = 0;
                }
            }
        }

      if(game_ai_evil_on_this_row(px)) /* !evil_on_this_row gets handled in x */
        {
/*
          if((px->xpos <= 0) || (px->xpos >= (GAME_FIELD_WIDTH - GAME_DUDE_WIDTH)))
            {
*/
              if(!game_ai_evil_above(px)
                  && !game_ai_evil_below(px))
                {
                  if(game_ai_snow_above_this_row(px))
                    {
                      px->ydir = -1;
                      px->xdir = 0;
                    }
                  else
                    {
                      px->ydir = 1;
                      px->xdir = 0;
                    }
                }
              else
                if(!game_ai_evil_above(px))
                  {
                    px->ydir = -1;
                    px->xdir = 0;
                  }
                else
                  {
                    px->ydir = 1;
                    px->xdir = 0;
                  }
/*
            }
*/
        }
    }

  if(px->state[game_gravity])
    px->ydir = 1;

  if(px->row <= 0) 
    {
      px->ydir = (px->ydir == -1) ?  0 : px->ydir;
      px->row = 0;
    }

  if(px->row >= GAME_ROW_COUNT-1)
    {
      px->ydir = (px->ydir ==  1) ?  0 : px->ydir;
      px->row = GAME_ROW_COUNT-1;
    }

  if(px->ydir == 1)
    {
      if(((px->hole[px->row] - GAME_HOLE_SIZE > px->xpos - GAME_MARGIN)
          && (px->hole[px->row] - GAME_HOLE_SIZE < px->xpos + GAME_MARGIN)
          && !px->state[game_prison])
          || px->state[game_bars])
        {
          if((px->evildir[px->row])
              && (px->evil[px->row] > px->xpos - GAME_DUDE_WIDTH)
              && (px->evil[px->row] < px->xpos + GAME_DUDE_WIDTH)
              && (!px->state[game_food]))
            {
              px->score += GAME_SCORE_ESCAPE;
              game_message_add(px, msg_escape);
            }

          px->row++;
          px->ydir = 0;
        }
    }
  else if(px->ydir == -1)
    {
      if(((px->hole[px->row-1] - GAME_HOLE_SIZE > px->xpos - GAME_MARGIN)
          && (px->hole[px->row-1] - GAME_HOLE_SIZE < px->xpos + GAME_MARGIN)
          && !px->state[game_prison])
          || px->state[game_bars])
        {
          if((px->evildir[px->row])
              && (px->evil[px->row] > px->xpos - GAME_DUDE_WIDTH)
              && (px->evil[px->row] < px->xpos + GAME_DUDE_WIDTH)
              && (!px->state[game_food]))
            {
              px->score += GAME_SCORE_ESCAPE;
              game_message_add(px, msg_escape);
            }

          px->row--;
          px->ydir = 0;
        }
    }
}


/*
   ____ game_ai_snow_on_this_row ____________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
game_ai_snow_on_this_row(player * px, player * po)
{
  int i;
  int snow = 0;

  for(i = 0; i <GAME_DOTS_PER_ROW; i++)
    {
      switch(px->field[px->row][i])
        {
        case game_dot: snow++; break;
        case game_reverse: 
        case game_drug:     
        case game_zoom:     
        case game_gravity:  
        case game_prison:  if(po->timer == 0) snow++; break; 
        case game_bars:    
        case game_food:     
        case game_speedup: if(px->timer == 0) snow++; break;
        default:
	  ;
        }
    }

  return snow;
}

/*
   ____ game_ai_evil_on_this_row ____________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
game_ai_evil_on_this_row(player * px)
{
  return (px->evildir[px->row] != 0);
}

/*
   ____ game_ai_snow_left ___________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
game_ai_snow_left(player * px, player * po)
{
  int i;
  int snow = 0;

  for(i = 0; i < ((px->xpos + GAME_DUDE_WIDTH) / GAME_DOT_DISTANCE); i++)
    {
      switch(px->field[px->row][i])
        {
        case game_dot: snow++; break;
        case game_reverse: 
        case game_drug:     
        case game_zoom:     
        case game_gravity:  
        case game_prison:  if(po->timer == 0) snow++; break; 
        case game_bars:    
        case game_food:     
        case game_speedup: if(px->timer == 0) snow++; break;
        default:
	  ;
        }
    }

  return snow;
}

/*
   ____ game_ai_snow_above_this_row _________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
game_ai_snow_above_this_row(player * px)
{
  int i;
  int row;
  int snow = 0;

  for(row = 0; row < px->row; row++)
    for(i = 0; i <GAME_DOTS_PER_ROW; i++)
      snow = snow || (px->field[row][i] == game_dot);

  return snow;
}

/*
   ____ game_ai_evil_above __________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int 
game_ai_evil_above(player * px)
{
  int row = (px->row > 0) ? px->row - 1 : 0;

  return (px->evildir[row] != 0);
}

/*
   ____ game_ai_evil_below __________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int 
game_ai_evil_below(player * px)
{
  int row = (px->row < GAME_ROW_COUNT) ? px->row + 1 : GAME_ROW_COUNT;

  return (px->evildir[row] != 0);
}

/*
   ____ game_ai_evil_left ___________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int 
game_ai_evil_left(player * px)
{
  return (px->evil[px->row] < px->xpos);
}

/*
   ____ game_loop_get_item __________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_get_item(player * px, player * po)
{
  int j;
  game_powerup powerup;

  j = (px->xpos  + (GAME_DUDE_WIDTH>>1)) / GAME_DOT_DISTANCE;
    powerup = px->field[px->row][j];

  switch(powerup)
    {
    case game_dot: 
      px->field[px->row][j] = game_nop;
      px->score++; 
      px->snow++; 
      /* fall through! */
    case game_nop: break;
    default:
      px->field[px->row][j] = game_use_item(px, po, powerup);
    }

  if(px->snow > GAME_DOTS_TOTAL)
    px->snow = GAME_DOTS_TOTAL;
}

/*
   ____ game_use_item _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
game_powerup 
game_use_item(player * px, player * po, game_powerup powerup)
{
  switch(powerup)
    {
    case game_food:    
      if(px->timer == 0)
        {
          px->state[game_food] = 1;
          px->timer = GAME_TIMER_FOOD;
          game_message_add(px, msg_powerup_food);
          return game_nop;
        }
      break;

    case game_bars:    
      if(px->timer == 0)
        {
          px->state[game_bars] = 1;
          px->timer = GAME_TIMER_BARS;
          game_message_add(px, msg_powerup_bars);
          return game_nop;
        }
      break;

    case game_gravity: 
      if(po->timer == 0)
        {
          po->state[game_gravity] = 1;
          po->timer = (GAME_ROW_COUNT - po->row - 1);
          game_message_add(po, msg_powerup_gravity);
          return game_nop;
        }
      break;

    case game_prison:  
      if(po->timer == 0)
        {
          po->state[game_prison] = 1;
          po->timer = GAME_TIMER_PRISON;
          game_message_add(po, msg_powerup_prison);
          return game_nop;
        }
      break;

    case game_drug:    
      if(po->timer == 0)
        {
          po->state[game_drug] = 1;
          po->timer = GAME_TIMER_DRUG;
          game_message_add(po, msg_powerup_drug);
          return game_nop;
        }
      break;

    case game_zoom:    
      if(po->timer == 0)
        {
          po->state[game_zoom] = 1;
          po->timer = GAME_TIMER_ZOOM;
          game_message_add(po, msg_powerup_zoom);
          return game_nop;
        }
      break;

    case game_reverse:
      if(po->timer == 0)
        {
          po->state[game_reverse] = 1;
          po->timer = GAME_TIMER_REVERSE;
          game_message_add(po, msg_powerup_reverse);
          return game_nop;
        }
      break;

    case game_speedup:   
      if(px->timer == 0)
        {
          px->state[game_speedup] = 1;
          px->timer = GAME_TIMER_SPEEDUP;
          game_message_add(px, msg_powerup_speedup);
          return game_nop;
        }
      break;

    default:
    break;
  }

  return powerup;
}



/*
   ____ game_loop_put_item __________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_put_item(player * px)
{
  int row;
  int item;
  int i;
  game_powerup powerup;

  for(row = 0; row<GAME_ROW_COUNT; row++)
    {
      /* no evil mutant cheat! :) */
//      px->evildir[row] = 0;

      i = 0;
      for(item = 0; item<GAME_DOTS_PER_ROW; item++)
        if((px->field[row][item] != game_nop)
            && (px->field[row][item] != game_dot))
          i = 1;

      if(!i)
      for(item = 0; item<GAME_DOTS_PER_ROW; item++)
        {
          if(((rand() & 0x3FFF) == 3) 
              && (px->field[row][item] == game_nop))
            {
              powerup = (rand() % GAME_POWERUP_COUNT) + 1;
              if(powerup != game_dot)
                px->field[row][item] = powerup;
              /* powerup cheat! */
            }
        }
    }
}



/*
   ____ game_loop_timer _____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_timer(player * px)
{
  int i;

  if(px->timer > 0) 
    px->timer--;
  else
    for(i = 0; i < GAME_POWERUP_COUNT+1; i++)
      px->state[i] = 0;

  if(px->state[game_gravity])
    px->timer = (GAME_ROW_COUNT-px->row-1) << GAME_SHIFT_TIMER;
}

/*
   ____ game_loop_game_over _________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_loop_game_over(player * px, player * po)
{
  if(px->evildir[px->row] != 0)
    if((px->evil[px->row] > px->xpos - (GAME_DUDE_WIDTH>>1))
        && (px->evil[px->row] < px->xpos + (GAME_DUDE_WIDTH>>1)))
      {
        if(px->state[game_food])
          {
            px->evildir[px->row] = 0;
            px->score += GAME_SCORE_MUTANT;
            game_message_add(px, msg_eat);
          }
        else
          {
            po->score += GAME_SCORE_DIE;
            px->death_anim = 1;
            game_message_add(px, msg_dead);
          }
      }

  if(px->snow == GAME_DOTS_TOTAL)
    {
      px->score += GAME_SCORE_WIN;
      px->death_anim = 1;
      game_message_add(px, msg_snow);
    }
}

/*
   ____ game_clear_clip _____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_clear_clip(player * p1, player * p2)
{
  int player_count;
  int i;
  int col = GAME_P1_COL;

  player * px = p1;

  for(player_count = 0; player_count<2; player_count++)
    {
      unsigned char * vidptr = px->clipbuffer - GAME_CLIPBUFFER_START;

      for(i = 0; i<GAME_FIELD_HEIGHT + GAME_CLIPBUFFER_Y_BORDER; i++)
        {
          memset(vidptr, col + GAME_COL_BORDER, GAME_CLIPBUFFER_WIDTH);
          vidptr+=GAME_CLIPBUFFER_WIDTH;
        }

      for(; i<GAME_CLIPBUFFER_HEIGHT; i++)
        {
          memset(vidptr, col + GAME_COL_SCORE_BG, GAME_CLIPBUFFER_WIDTH);
          vidptr+=GAME_CLIPBUFFER_WIDTH;
        }

      col = GAME_P2_COL;
      px = p2;
    }
}


/*
   ____ game_clear __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_clear(player * p1, player * p2)
{
  int player_count;
  int i;
  int col = GAME_P1_COL;

  player * px = p1;
//  player * po = p2;


  for(player_count = 0; player_count<2; player_count++)
    {
      unsigned char * vidptr = px->clipbuffer;

      for(i = 0; i<GAME_FIELD_HEIGHT; i++)
        {
          memset(vidptr, col, GAME_SCREEN_WIDTH);
          vidptr+=GAME_CLIPBUFFER_WIDTH;
        }

      for(; i<GAME_SCREEN_HEIGHT; i++)
        {
          memset(vidptr, col + GAME_COL_SCORE_BG, GAME_SCREEN_WIDTH);
          vidptr+=GAME_CLIPBUFFER_WIDTH;
        }

      col = GAME_P2_COL;
      px = p2;
    }
}

/*
   ____ game_field __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_field(player * p1, player * p2)
{
  int width;
  int height;
  int hole;
  int i;
  int y;
  int x;
  int player_count;

  unsigned char col = GAME_P1_COL + GAME_COL_BORDER;
  player * px = p1;

  for(player_count = 0; player_count < 2; player_count++)
    {
      /* first draw both columns and the top and bottom rows */
      game_rect(px->clipbuffer, 0, 0, GAME_BORDER_WIDTH, GAME_FIELD_HEIGHT, col);
      game_rect(px->clipbuffer, 0, 0, GAME_SCREEN_WIDTH, GAME_BORDER_HEIGHT, col);
      game_rect(px->clipbuffer, 0, GAME_FIELD_HEIGHT - GAME_BORDER_HEIGHT, GAME_SCREEN_WIDTH, GAME_BORDER_HEIGHT, col);
      game_rect(px->clipbuffer, 0 + GAME_SCREEN_WIDTH - GAME_BORDER_WIDTH, 0, GAME_BORDER_WIDTH, GAME_FIELD_HEIGHT, col); 

      /* then draw the borders on the borders */
      col += (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER);
      game_hline(px->clipbuffer, 0 + GAME_BORDER_WIDTH - 1, GAME_BORDER_HEIGHT - 1, GAME_FIELD_WIDTH + 2, col);
      game_hline(px->clipbuffer, 0 + GAME_BORDER_WIDTH - 1, GAME_FIELD_HEIGHT  - GAME_BORDER_HEIGHT, GAME_FIELD_WIDTH + 2, col);
      game_vline(px->clipbuffer, 0 + GAME_BORDER_WIDTH - 1, GAME_BORDER_HEIGHT - 1, GAME_FIELD_HEIGHT - (GAME_BORDER_HEIGHT<<1) + 2, col);
      game_vline(px->clipbuffer, 0 + GAME_SCREEN_WIDTH - GAME_BORDER_WIDTH, GAME_BORDER_HEIGHT - 1, GAME_FIELD_HEIGHT - (GAME_BORDER_HEIGHT<<1) + 2, col);

      /* border above score box */
      game_hline(px->clipbuffer, 0, GAME_FIELD_HEIGHT - 1, GAME_SCREEN_WIDTH, col);

      col -= (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER);

      /* then if [bars!] isn't active, draw the rows. */
      if(!px->state[game_bars])
        for(i = 0; i<GAME_BAR_COUNT; i++)
          {
            hole = px->state[game_prison] ? 0 : px->hole[i];

            y = (GAME_BORDER_HEIGHT + GAME_ROW_HEIGHT) * (i+1);
            width = GAME_BORDER_WIDTH + hole - GAME_HOLE_SIZE;
            height = GAME_BORDER_HEIGHT;

            if(width>0)
              {
                game_rect(px->clipbuffer, 0, y, width, height, col);
                game_hline(px->clipbuffer, 0 + GAME_BORDER_WIDTH - 1, y, width - GAME_BORDER_WIDTH, (unsigned char) (col + (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER)));
                game_hline(px->clipbuffer, 0 + GAME_BORDER_WIDTH - 1, y + GAME_BORDER_HEIGHT - 1, width - GAME_BORDER_WIDTH, (unsigned char) (col + (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER)));
                if((width > GAME_BORDER_WIDTH) && (width < (GAME_BORDER_WIDTH + GAME_FIELD_WIDTH - 1)))
                  game_vline(px->clipbuffer, 0 + width - 1, y, GAME_BORDER_HEIGHT, (unsigned char) (col + (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER)));
              }

            x = GAME_BORDER_WIDTH - 1 + hole;
            width = GAME_SCREEN_WIDTH - x;

            if(width>0)
              {
                game_rect(px->clipbuffer, x, y, width, height, col);
                game_hline(px->clipbuffer, x, y, width - GAME_BORDER_WIDTH, (unsigned char) (col + (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER)));
                game_hline(px->clipbuffer, x, y + GAME_BORDER_HEIGHT - 1, width - GAME_BORDER_WIDTH, (unsigned char) (col + (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER)));

                if((x > GAME_BORDER_WIDTH) && (x < (GAME_BORDER_WIDTH + GAME_FIELD_WIDTH - 1)))
                  game_vline(px->clipbuffer, x, y, GAME_BORDER_HEIGHT, (unsigned char) (col + (GAME_COL_POWERUP_BORDER - GAME_COL_BORDER)));
              }
          }

      col = GAME_P2_COL + GAME_COL_BORDER;
      px = p2;
    }
}


/*
   ____ game_items __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_items(unsigned char * data, player * p1, player * p2)
{
  int x;
  int y;
  int y_tmp;
  int x_tmp;
  int row;
  int item;
  int i;
  int powerup = 0;

#define SPRITE_X	      data[4]
#define SPRITE_Y	      data[5]
#define SPRITE_COUNT      data[6]
#define SPRITE_FLAGS      data[7]
#define SPRITE_DATA	      data[8]

  unsigned char c;

  unsigned char col1 = GAME_P1_COL + GAME_COL_DOT;
  player * px = p1;

  for(i = 0; i<2; i++)
    {
      for(row = 0; row<GAME_ROW_COUNT; row++)
        for(item = 0; item<GAME_DOTS_PER_ROW; item++)
          {
            x = GAME_DOT_DISTANCE * item 
              + GAME_BORDER_WIDTH + (GAME_DOT_DISTANCE>>1);
            y = (GAME_BORDER_HEIGHT + GAME_ROW_HEIGHT)*row
              + GAME_BORDER_HEIGHT + (GAME_ROW_HEIGHT>>1);

            if(px->field[row][item] == game_dot)
              {
                game_rect(px->clipbuffer, x - 1, y - 1, 3, 3, col1);
/* the snow looks quite harsh with these lines - doesn't look nice at all.
                game_hline(vidmem, vid_width, x + x_org - 1, y - 2, 3, GAME_P1_COL + GAME_COL_POWERUP_BORDER);
                game_hline(vidmem, vid_width, x + x_org - 1, y + 2, 3, GAME_P1_COL + GAME_COL_POWERUP_BORDER);
                game_vline(vidmem, vid_width, x + x_org - 2, y - 1, 3, GAME_P1_COL + GAME_COL_POWERUP_BORDER);
                game_vline(vidmem, vid_width, x + x_org + 2, y - 1, 3, GAME_P1_COL + GAME_COL_POWERUP_BORDER);
*/
              }
            else if(px->field[row][item] != game_nop)
              {
                y = y - (SPRITE_Y>>1);
                x = x - (SPRITE_X>>1);

                switch(px->field[row][item])
                  {
                  case game_reverse:  powerup = 0; break;
                  case game_bars:     powerup = 1; break;
                  case game_food:     powerup = 2; break;
                  case game_drug:     powerup = 3; break;
                  case game_zoom:     powerup = 4; break;
                  case game_gravity:  powerup = 5; break;
                  case game_prison:   powerup = 6; break;
                  case game_speedup:  powerup = 7; break;
                  default:
		    ;
                  }

                for(y_tmp = 0; y_tmp < SPRITE_Y; y_tmp++)
                  for(x_tmp = 0; x_tmp < SPRITE_X; x_tmp++)
                    {
                      if(0 != (c=(&SPRITE_DATA)[(powerup*SPRITE_Y+y_tmp)*SPRITE_X+x_tmp]))
                        px->clipbuffer[MUL_CLIP_WIDTH(y+y_tmp) + x + x_tmp] = c;
                    }
              }
          }
      col1 = GAME_P2_COL + GAME_COL_DOT;
      px = p2;
    }

#undef SPRITE_X
#undef SPRITE_Y
#undef SPRITE_COUNT
#undef SPRITE_FLAGS
#undef SPRITE_DATA

}

/*
   ____ game_itoa ___________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
char *
game_itoa(char * dst, int src, int max, int radix)
{
                     
  static char t[30] = "000000000000000000000000000000";
  char * p = dst;
  char t_count = 0;
  int tmp = src;
  int i;

  /* not supported. */
  if(radix > 26) goto err;
  if(max < 3) goto err;

  switch(radix)
    {
    case 16: t[(int) t_count++] = 'h'; break;
    case 10: t[(int) t_count++] = 'd'; break;
    case 8:  t[(int) t_count++] = 'o'; break;
    case 2:  t[(int) t_count++] = 'b'; break;
    }

  if(tmp==0) 
    {
      t[(int) t_count++] = '0';
    }
  else
    while(tmp > 0)
      {
        if(t_count<30)
          {
            t[(int) t_count] = '0' + tmp % radix;
            if(t[(int) t_count] > '9')
              t[(int) t_count] += 'a'-'0'-10;
          }

        t_count++;

        tmp /= radix;
      }

  if(t_count > max) goto err;

/*
  if(radix==8) 
    t[t_count++] = '0';

  if(radix==16) 
    {
      t[t_count++] = 'x';
      t[t_count++] = '0';
    }
*/

  for(i = 0; i<t_count; i++)
    {
      *p++ = t[(t_count-1) - i];
    }

  return p;

err:
  *p++ = 'e';
  *p++ = 'r';
  *p++ = 'r';

  return p;
}

/*
   ____ game_score __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_score(unsigned char * data, player * p1, player * p2)
{
  char * score = calloc(30, 1);
  int player_count;
  int y;

  unsigned char col = GAME_P1_COL;
  player * px = p1;

  for(player_count = 0; player_count<2; player_count++)
    {
      /* player name + score */
      y = render_text(px->clipbuffer, GAME_CLIPBUFFER_WIDTH, 2, GAME_FIELD_HEIGHT+2,
        DATA_FONT0, 0, 0, 0, px->o->name);  

      strcpy(score, "score: ");
      *(game_itoa(score+7, px->score, 12, px->o->radix)) = '\0';

      y = render_text(px->clipbuffer, GAME_CLIPBUFFER_WIDTH, 2, y,
        DATA_FONT0, 0, 0, 0, score);  

      /* timer */
      if(px->timer > 0)
        {
          strcpy(score, "t.");
          *(game_itoa(score+2, px->timer >> GAME_SHIFT_TIMER, 12, px->o->radix)) = '\0';

          y = render_text(px->clipbuffer, GAME_CLIPBUFFER_WIDTH, 120, GAME_FIELD_HEIGHT+2,
            DATA_FONT0, 0, 0, 0, score);  
        }

      px = p2;
      col = GAME_P2_COL;
    }
}


/*
   ____ game_frame __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
int
game_frame(int anim, int snow)
{
  /* the animation data is stored like this:

  frames in memory:

     ________ anim.
   /      ___ snow.
  |     /
  |    |
       0   1     2    3    4    5    6    7
  0 [oo] <oo> (oo)  (|)   ()    O    o    .   
  1 [oO] <oO> (oO)  (\)   ()    O    o    .
  -----------------------------------------
  2 [8-] <8-> (8-)  (-)   ()    O    o    .   
  3 [Oo] <Oo> (Oo)  (/)   ()    O    o    .
  -----------------------------------------
  4 [oo] <oo> (oo)  (|)   ()    O    o    .   
  5 [oO] <oO> (oO)  (\)   ()    O    o    .
  -----------------------------------------
  6 [-8] <-8> (-8)  (-)   ()    O    o    .   
  7 [Oo] <Oo> (Oo)  (/)   ()    O    o    .
    \__/ \__/  \____________________________/
      \_   \_               \______________________ bob
        \_   \_____________________________________ evil mutant
          \________________________________________ food mutant

  */

  return anim * 8 + 7 - ((snow+10) / (GAME_DOTS_PER_ROW * GAME_ROW_COUNT / 5));
}

/*
   ____ game_dudes_part1 ____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_dudes_part1(unsigned char * data, player * p1, player * p2)
{
  int player_count;
  int dude_frame;

  int x_start;
  int y_start;
  int x_tmp;
  int y_tmp;

  int i;
  char c;

  player * px = p1;

#define SPRITE_X	  data[0]
#define SPRITE_Y	  data[1]
#define SPRITE_COUNT      data[2]
#define SPRITE_FLAGS      data[3]
#define SPRITE_DATA	  data[4]

  for(player_count = 0; player_count<2; player_count++)
    {
      /* evil mutants */
      for(i = 0; i<GAME_ROW_COUNT; i++)
        if(px->evildir[i] != 0)
          {
            y_start = i * (GAME_ROW_HEIGHT + GAME_BORDER_HEIGHT)
              + GAME_BORDER_HEIGHT - ((GAME_DUDE_HEIGHT - GAME_ROW_HEIGHT)>>1);
            x_start = px->evil[i] + GAME_BORDER_WIDTH;

            if(px->state[game_food])
              dude_frame = px->evilanim[i] * 8;
            else
              dude_frame = px->evilanim[i] * 8 + 1;

            for(y_tmp = 0; y_tmp < SPRITE_Y; y_tmp++)
              for(x_tmp = 0; x_tmp < SPRITE_X; x_tmp++)
            {
              if((x_start + x_tmp >= 0) && (x_start + x_tmp < GAME_SCREEN_WIDTH))
                if(0 != (c=(&SPRITE_DATA)[(dude_frame*SPRITE_Y+y_tmp)*SPRITE_X+x_tmp]))
                  px->clipbuffer[MUL_CLIP_WIDTH(y_start+y_tmp) + x_start + x_tmp] = c;
            }
          }

      px = p2;
    }

#undef SPRITE_X
#undef SPRITE_Y
#undef SPRITE_COUNT
#undef SPRITE_FLAGS
#undef SPRITE_DATA

}


/*
   ____ game_dudes_part2 ____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_dudes_part2(unsigned char * data, player * p1, player * p2)
{
  int player_count;
  int dude_frame;

  int x_start;
  int y_start;
  int x_tmp;
  int y_tmp;

  char c;

  player * px = p1;
  unsigned char * clipbuf;

#define SPRITE_X	  data[0]
#define SPRITE_Y	  data[1]
#define SPRITE_COUNT      data[2]
#define SPRITE_FLAGS      data[3]
#define SPRITE_DATA	  data[4]

  for(player_count = 0; player_count<2; player_count++)
    {
      /* player */
      clipbuf = px->clipbuffer - GAME_CLIPBUFFER_START;

      y_start = px->row * (GAME_ROW_HEIGHT + GAME_BORDER_HEIGHT)
        + GAME_BORDER_HEIGHT - ((GAME_DUDE_HEIGHT - GAME_ROW_HEIGHT)>>1)
	+ GAME_CLIPBUFFER_Y_BORDER;
      x_start = px->xpos + GAME_BORDER_WIDTH
	+ GAME_CLIPBUFFER_X_BORDER;

      dude_frame = game_frame(px->anim, px->snow);

      for(y_tmp = 0; y_tmp < SPRITE_Y; y_tmp++)
        for(x_tmp = 0; x_tmp < SPRITE_X; x_tmp++)
          {
            if(0 != (c=(&SPRITE_DATA)[(dude_frame*SPRITE_Y+y_tmp)*SPRITE_X+x_tmp]))
              clipbuf[MUL_CLIP_WIDTH((y_start+y_tmp+px->y_winner_kludge)) + x_start + x_tmp] = c;
          }

      px = p2;
    }

#undef SPRITE_X
#undef SPRITE_Y
#undef SPRITE_COUNT
#undef SPRITE_FLAGS
#undef SPRITE_DATA

}



/*
   ____ game_message_add ____________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_message_add(player * px, char * msg)
{
  int i;

  if(px->message_count == GAME_MAX_MSG_COUNT)
    {
      for(i = 0; i < GAME_MAX_MSG_COUNT-1; i++)
        px->message[i] = px->message[i+1];

      px->message_count--;
    }

  px->message[px->message_count++] = msg;
  px->message_countdown = GAME_MSG_COUNTDOWN2;
}


/*
   ____ game_messages _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_messages(player * p1, player * p2)
{
  int player_count;
  int i;
  int y;

  player * px = p1;

  for(player_count = 0; player_count<2; player_count++)
    {
      y = 2;

      /* render messages. */
      for(i = 0; i < px->message_count; i++)
          y = render_text(px->clipbuffer, GAME_CLIPBUFFER_WIDTH, 2, y,
            DATA_FONT0, 0, 0, 0, px->message[i]);  

      if((px->message_count > 0) 
          && (px->message_countdown > GAME_MSG_COUNTDOWN1))
        render_text(px->clipbuffer, GAME_CLIPBUFFER_WIDTH, 2, (GAME_FIELD_HEIGHT>>1),
            DATA_FONT1, 0, 0, 0, px->message[px->message_count-1]);  

      /* update messages. */
      px->message_countdown--;
      if((px->message_countdown == 0) && (px->message_count > 0))
        {
          px->message_countdown = GAME_MSG_COUNTDOWN1;
          px->message_count--;

          for(i = 0; i < GAME_MAX_MSG_COUNT-1; i++)
            px->message[i] = px->message[i+1];
        }

      px = p2;
    }
}


/*
   ____ game_visualfx _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_visualfx(unsigned char * dst, player * p1, player * p2)
{
  static unsigned char y_count;
  static unsigned char x_count;
  unsigned char * srcptr;
  unsigned char * vidptr;
  player * px = p1;
  int player_count;
  int y;
  int x;

  int y_src;
  int x_src;

  int y_tmp;

  int x_start = 0;

  x_count += GAME_WOBBLE_X_INC;
  y_count += GAME_WOBBLE_Y_INC;

  for(player_count = 0; player_count<2; player_count++)
    {    
      if(px->state[game_reverse])
        {
          for(y = 0; y<GAME_SCREEN_HEIGHT; y++)
            {
              vidptr = dst + MUL_VID_WIDTH(y)+x_start;
              y_tmp = MUL_CLIP_WIDTH(y);

              for(x = 0; x<GAME_SCREEN_WIDTH; x++)
                *(vidptr++) = px->clipbuffer[y_tmp+(GAME_SCREEN_WIDTH - 1 - x)];
            }
        }
      else if(px->state[game_zoom])
        {
/*
          LARGE_INTEGER stsc,etsc, freq;
          __int64 start_tsc, end_tsc, l_freq ;
          QueryPerformanceFrequency( &freq );
          l_freq = freq.QuadPart;

          QueryPerformanceCounter( &stsc );
          start_tsc = stsc.QuadPart;
*/
/*          for(y = 0; y<GAME_SCREEN_HEIGHT; y++)
            {
              y_tmp = MUL_CLIP_WIDTH((px->row) * GAME_ROW_HEIGHT + (y>>1));
              vidptr = dst + MUL_VID_WIDTH(y)+x_start;
              for(x = 0; x<GAME_SCREEN_WIDTH; x++)
                {
                  x_src = px->xpos - (GAME_FIELD_WIDTH>>3) + (x>>1);
                  *(vidptr++) = px->clipbuffer[y_tmp+x_src];
                }
            }
*/
          for(y = 0; y<GAME_SCREEN_HEIGHT; y++)
            {
              unsigned short *sbuf;
              unsigned char * readbuf;
              y_tmp = MUL_CLIP_WIDTH((px->row) * GAME_ROW_HEIGHT + (y>>1));
              vidptr = dst + MUL_VID_WIDTH(y)+x_start;
              sbuf = (unsigned short*) vidptr;
              readbuf = &px->clipbuffer[y_tmp+px->xpos - (GAME_FIELD_WIDTH>>3)];
              for(x = 0; x<(GAME_SCREEN_WIDTH>>1); x++)
                {
                    register unsigned char col = *readbuf++;
                    register unsigned short scol = col + (col<<8);
                    *(sbuf+(GAME_SCREEN_WIDTH)) = scol;
                    *sbuf++ = scol;                 
                }
              y++;
            }
/*
          QueryPerformanceCounter( &etsc );
          end_tsc = etsc.QuadPart;
          printf("CPU percentage used in zoom: %10.5f\n", 100.0*((double)end_tsc-(double)start_tsc)/(double)l_freq );
*/
        }
      else if(px->state[game_drug])
        {
          srcptr = px->clipbuffer - GAME_CLIPBUFFER_START + GAME_CLIPBUFFER_X_BORDER;

          for(y = 0; y<GAME_SCREEN_HEIGHT; y++)
            {
              vidptr = dst + MUL_VID_WIDTH(y)+x_start;
              y_tmp = y + GAME_CLIPBUFFER_Y_BORDER;

              for(x = 0; x<GAME_SCREEN_WIDTH; x++)
                {
                  x_src = x     + SIN_X((unsigned char) (y + y_count));
                  y_src = y_tmp + SIN_Y((unsigned char) (x + x_count));

                  *(vidptr++) = srcptr[MUL_CLIP_WIDTH(y_src)+x_src];
                }
            }
        }
      else
        {
          for(y = 0; y<GAME_SCREEN_HEIGHT; y++)
            memcpy(dst+MUL_VID_WIDTH(y)+x_start, 
              px->clipbuffer + MUL_CLIP_WIDTH(y), GAME_SCREEN_WIDTH);
        }

      px = p2;
      x_start = GAME_SCREEN_WIDTH;
    }

  /* as a finnishing touch, seperate both screens by a 2 pixel black line in the
     middle. (and on the other sides too to keep things symmetrical and cheap). */
/*
  game_rect(dst, width, (width>>1)-1, 0, 2, height, 0);
  game_rect(dst, width, 0, 0, 2, height, 0);
  game_rect(dst, width, width-1, 0, 2, height, 0);
*/
}


/*
   ____ game_rect ___________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_rect(unsigned char * buffer, 
          int x1, int y1, int x_width, int y_width,
          unsigned char col)
{
  int y;

  for(y=y1; y<(y_width+y1); y++)
    memset(buffer+MUL_CLIP_WIDTH(y)+x1, col, x_width);
}

/*
   ____ game_hline __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_hline(unsigned char * buffer,  
           int x1, int y1, int x_width, unsigned char col)
{
  if(x_width > 0)
    memset(buffer+MUL_CLIP_WIDTH(y1)+x1, col, x_width);
}

/*
   ____ game_vline __________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_vline(unsigned char * buffer,  
           int x1, int y1, int y_width, unsigned char col)
{
  int y;

  if(y_width > 0)
    for(y=y1; y<(y_width+y1); y++)
      buffer[MUL_CLIP_WIDTH(y)+x1] = col;
}



/*
   ____ game_hmirror ________________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_hmirror(unsigned char * dst, unsigned char * src, int x, int y)
{
  int j;
  int i;

  if(x==y)
    {
      for(i = 0; i < y; i++)
        for(j = 0; j < x; j++)
          dst[(y-1-i)*x+j] = src[i*x+j];
    }
}

/*
   ____ game_45mirror _______________________________________________
   __________________________________________________________________
   __________________________________________________________________
   __________________________________________________________________
*/
void
game_45mirror(unsigned char * dst, unsigned char * src, int x, int y)
{
  int j;
  int i;

  if(x==y)
    {
      for(i = 0; i < y; i++)
        for(j = 0; j < x; j++)
          dst[j*x+i] = src[i*x+j];
    }
}


