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

#ifndef BOB_GAME_H
#define BOB_GAME_H

/* colours in drbob*.pal.h */
#define GAME_P1_COL 0x10
#define GAME_P2_COL 0x30

#define GAME_COL_BG 0x00
#define GAME_COL_BORDER 0x01
#define GAME_COL_BOB 0x02
#define GAME_COL_DOT 0x03
#define GAME_COL_EVIL 0x04
#define GAME_COL_EVIL_FOOD 0x05
#define GAME_COL_SCORE_BG 0x06
#define GAME_COL_INVENTORY_BORDER 0x07
#define GAME_COL_POWERUP_BORDER 0x10

/* game screen for 1 player - not both. */
#define GAME_VIDEO_WIDTH  400
#define GAME_VIDEO_HEIGHT 300
#define GAME_VIDEO_SIZE (GAME_VIDEO_WIDTH * GAME_VIDEO_HEIGHT)

#define GAME_SCREEN_WIDTH (GAME_VIDEO_WIDTH>>1)
#define GAME_BORDER_WIDTH 8
#define GAME_FIELD_WIDTH (GAME_SCREEN_WIDTH - (GAME_BORDER_WIDTH<<1))

#define GAME_SCREEN_HEIGHT GAME_VIDEO_HEIGHT
#define GAME_BORDER_HEIGHT 8
#define GAME_ROW_HEIGHT 30
#define GAME_ROW_COUNT 7
#define GAME_BAR_COUNT (GAME_ROW_COUNT-1)
#define GAME_FIELD_HEIGHT (GAME_ROW_COUNT * (GAME_ROW_HEIGHT + GAME_BORDER_HEIGHT) + GAME_BORDER_HEIGHT)
#define GAME_SCORE_HEIGHT (GAME_SCREEN_HEIGHT - GAME_FIELD_HEIGHT)

/* use a massive border so i don't need to clip. */
#define GAME_CLIPBUFFER_X_BORDER 0x80
#define GAME_CLIPBUFFER_Y_BORDER 0x100 /* zoom should fit in 0x80 i think, but i'm not sure. */
#define GAME_CLIPBUFFER_WIDTH ((GAME_CLIPBUFFER_X_BORDER<<1) + GAME_SCREEN_WIDTH)
#define GAME_CLIPBUFFER_HEIGHT ((GAME_CLIPBUFFER_Y_BORDER<<1) + GAME_SCREEN_HEIGHT)
#define GAME_CLIPBUFFER_SIZE (GAME_CLIPBUFFER_WIDTH * GAME_CLIPBUFFER_HEIGHT)
#define GAME_CLIPBUFFER_START (GAME_CLIPBUFFER_WIDTH * GAME_CLIPBUFFER_Y_BORDER + GAME_CLIPBUFFER_X_BORDER)

#define GAME_HOLE_SIZE 32
/* HOLE_POS is end of hole, so start of hole is at -32 if
   HOLE_POS is 0. max HOLE_POS is therefore field width + 32.
   (the extra +1 prevents a graphical glitch).
 */
#define GAME_MAX_HOLE_POS (GAME_FIELD_WIDTH + GAME_HOLE_SIZE + 1)

#define GAME_DOTS_PER_ROW 10
#define GAME_DOT_DISTANCE (GAME_FIELD_WIDTH / GAME_DOTS_PER_ROW)

#define GAME_DOTS_TOTAL (GAME_DOTS_PER_ROW * GAME_ROW_COUNT)

#define GAME_SCORE_ESCAPE 10
#define GAME_SCORE_MUTANT 10
#define GAME_SCORE_WIN 30
#define GAME_SCORE_DIE 20

#define GAME_DUDE_WIDTH  32
#define GAME_DUDE_HEIGHT 32
#define GAME_DUDE_FRAMECOUNT 8
#define GAME_EVIL_FRAMECOUNT 8

#define GAME_X_FRAMES 0
#define GAME_ANIM_FRAMES 4
#define GAME_MARGIN 2

#define GAME_EVIL_FRAMES 1
#define GAME_EVIL_ANIM_FRAMES 6

#define GAME_SHIFT_TIMER 4

/* limit framerate if it is faster then 76 hz */
#define GAME_MIN_FRAME_TIME (1000 / 76)

#define GAME_TIMER_1_SECOND   76

// #define GAME_DEATH_ANIMCOUNT (10 * GAME_TIMER_1_SECOND)

#define GAME_TIMER_REVERSE  (10 * GAME_TIMER_1_SECOND)
#define GAME_TIMER_BARS     ( 5 * GAME_TIMER_1_SECOND)
#define GAME_TIMER_FOOD     (15 * GAME_TIMER_1_SECOND)
#define GAME_TIMER_DRUG     (10 * GAME_TIMER_1_SECOND)
#define GAME_TIMER_ZOOM     (10 * GAME_TIMER_1_SECOND)
#define GAME_TIMER_PRISON   ( 5 * GAME_TIMER_1_SECOND)
#define GAME_TIMER_SPEEDUP  (10 * GAME_TIMER_1_SECOND)

#define GAME_MAX_MSG_COUNT 8
#define GAME_MSG_COUNTDOWN1 ( 5 * GAME_TIMER_1_SECOND)
#define GAME_MSG_COUNTDOWN2 ( 7 * GAME_TIMER_1_SECOND)

#define GAME_WOBBLE_Y_INC     3
#define GAME_WOBBLE_X_INC     4


/* the sine loops at 0x100, so I can use a char to traverse it */
#define SIN_X_LOOP_SIZE 0x100
#define SIN_Y_LOOP_SIZE 0x100

#define SIN_X_AMPLITUDE 20
#define SIN_Y_AMPLITUDE 20
#define SIN_WOBBLE_X
#define SIN_WOBBLE_Y

typedef enum game_powerup_enum
{ 
  game_nop,
  game_dot,
  game_reverse,
  game_bars,
  game_food,
  game_drug,
  game_zoom,
  game_gravity,
  game_prison,
  game_speedup,
} game_powerup;

#define GAME_POWERUP_COUNT game_speedup

extern unsigned char game_palette[];


#define GAME_MAX_NAME_SIZE 0x0A

typedef struct player_options_struct
{
  char name[GAME_MAX_NAME_SIZE+1]; /* +1 for a trailing \0 */
  unsigned short action;
  unsigned short escape;
  unsigned short up;
  unsigned short down;
  unsigned short left;
  unsigned short right;  
  unsigned char radix;  /* 2, 8, 10 or 16 */
  unsigned char keymap; /* 0 = qwerty, 1 = dvorak */
  unsigned char cpu; /* 0 = no, 1 = yes */
} player_options;

typedef struct player_struct
{
  player_options * o; /* options (name, radix, etc.) */

  unsigned short int score; /* score */
  unsigned short int total; /* total score */
  char anim;                /* current anim frame */
  char snow;                /* amount of snow (dots) gathered */
  int  row;                 /* current row (y) */
  short int xpos;           /* current pos (x) */
  char xdir;                /* horizontal (x) direction */
  char ydir;                /* vertical (y) direction */
  unsigned char xblock;     /* wait for keys to be released. */
  unsigned char yblock;     /* wait for keys to be released. */
  unsigned char xcount;     /* frame counter for x movement */
  unsigned char animcount;  /* frame counter for animation */
  unsigned char death_anim; /* game over anim busy? */
  char y_winner_kludge; /* kludge for winner anim */
  unsigned char gameover;   /* game over */
  unsigned short timer;     /* timer for powerups */

  char evilanim[GAME_ROW_COUNT];  /* current evil mutant anim frame */
  short int evil[GAME_ROW_COUNT]; /* current evil mutant pos */
  short int evildir[GAME_ROW_COUNT]; /* current evil mutant direction */
  unsigned char evilcount; /* frame counter for evil mutant movement */
  unsigned char evilanimcount; /* frame counter for evil mutant animation */

  int hole[GAME_BAR_COUNT]; /* positions of the hole in each bar */
  char hole_inc[GAME_BAR_COUNT]; /* direction of hole movemenent */


  char * message[GAME_MAX_MSG_COUNT]; /* message buffer (like quake console :) */
  int message_count;                 /* amount of messages in message buffer. */
  int message_countdown;             /* countdown before message is deleted. */

  unsigned char state[GAME_POWERUP_COUNT]; /* state */
  game_powerup field[GAME_ROW_COUNT][GAME_DOTS_PER_ROW]; /* items in the game world :) */

  unsigned char * clipbuffer; /* pointer to video buffer for this player. */
} player; 


/* call this for the game :) */
void game(unsigned char * vidmem, 
          player_options * p1, player_options * p2, int championship);



unsigned char * game_init_sprites(void);
void game_init_player(player *, player_options *);
void game_clear_player(player *);
void game_init_tables();

void game_loop_bars(player *);
void game_loop_timer(player *);
void game_loop_player_x(player *, player *);
void game_loop_player_y(player *, player *);
void game_loop_get_item(player *, player *);
void game_loop_put_item(player *);
void game_loop_game_over(player *, player *);
void game_loop_evil_mutants(player *);
void game_loop_death_anim(player *, player *);

game_powerup game_use_item(player *, player *, game_powerup);

int game_ai_snow_on_this_row(player *, player *);
int game_ai_evil_on_this_row(player *);
int game_ai_snow_left(player *, player *);
int game_ai_snow_above_this_row(player *);
int game_ai_evil_above(player *);
int game_ai_evil_below(player *);
int game_ai_evil_left(player *);


void game_clear_clip(player *, player *);
void game_clear(player *, player *);
void game_items(unsigned char *, player *, player *);
void game_score(unsigned char *, player *, player *);
void game_dudes_part1(unsigned char *, player *, player *);
void game_dudes_part2(unsigned char *, player *, player *);
void game_field(player *, player *);

void game_message_add(player *, char *);
void game_messages(player *, player *);
void game_visualfx(unsigned char *, player *, player *);

char * game_itoa(char *, int, int, int);
int game_frame(int, int);
void game_rect(unsigned char *, int, int, int, int, unsigned char);
void game_hline(unsigned char *, int, int, int, unsigned char);
void game_vline(unsigned char *, int, int, int, unsigned char);
void game_hmirror(unsigned char *, unsigned char *, int, int);
void game_45mirror(unsigned char *, unsigned char *, int, int);


#endif BOB_GAME_H
