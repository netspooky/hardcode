/* There's a warning (frozen not used): IT'S FALSE; just ignore it */

/* Some includes */
#include <dos.h>;       /* Needed for getvect(), setvect() and int86() */
#include <fcntl.h>;     /* Needed for open modes */
#include <stdlib.h>;    /* Needed for rand() and srand() */
#include <time.h>;      /* Used time(0) for srand() */

/* Some boolean definitions */
typedef unsigned char boolean;
typedef unsigned char byte;
#define FALSE 0
#define TRUE !FALSE

/* Some constants */
#define ENDLEVEL 1
#define EXITED 2
#define DEAD 3
#define VELOCITY 2

/* Some struct variables */
struct point {
  int x;
  int y;
};

/* Colors used:
    colors[0] = background
    colors[1] = wall
    colors[2] = apples
    colors[3] = snake
    colors[4] = text
*/
int colors[] = {1, 12, 13, 14, 15};

/* Recommended lengths: when you eat the apple N you'll */
/* grow until you have length longs[N] */
int longs[] = {3, 6, 12, 21, 33, 48, 66, 87, 111, 138};

/* Global variables */
int timer;
int apples;
int length_we_have;
int length_growing_to;
struct point body[256];
boolean finished;
int direction;
int pret_direc;
int finish_type;
boolean frozen;
int level;
int screen[1200];
boolean paused;
int lives;

/* All prototypes of procedures used */
void interrupt (*old_timer_isr)();
void interrupt (*old_keyb_isr)();
void interrupt new_timer_isr();
void interrupt new_keyb_isr();
int get_mode();
void set_mode(int m);
int prepare_level(int level);
void draw_square(int x, int y, int c);
void init_snake();
void generate_apple();
void write_status();
void toggle_pause();
void str_print(int x, int y, char *str);
void hello();

void main() {
  boolean frozen; int old_mode;

  /* Init rand seed */
  srand(time(0));

  /* Some vars */
  frozen = TRUE;
  timer = 0;
  finished = FALSE;

  /* Save and set: keyb ISR, timer ISR, screen mode */
  old_timer_isr = getvect(8); old_keyb_isr = getvect(9);
  setvect(8, new_timer_isr); setvect(9,new_keyb_isr);
  old_mode = get_mode(); set_mode(0x12);

  /* Get the first level; error if not found */
  /* If done, screen is drawn */
  level = 0;
  if (prepare_level(level) < 0) {
    /* Error; restore, send error message and get away */
    set_mode(old_mode);
    setvect(8, old_timer_isr);
    setvect(9, old_keyb_isr);
    printf("File pant00.res not found!\n");
    hello();
    exit(-1);
  }

infinite_loop:          /* Until no more levels */

  /* Some vars */
  lives = 3;
  apples = 0;
  paused = FALSE; toggle_pause(); /* TRUE after all... */

  /* Put snake in screen, generate an apple, write useful data */
  init_snake(); generate_apple(); write_status();

  /* The main loop */
  frozen = FALSE;
  while (finished == FALSE) {}
  frozen = TRUE;
  /* Why have we finished? */
  switch (finish_type) {
    case EXITED:
      /* ESC has been pushed; restore, send message and get away */
      set_mode(old_mode);
      setvect(8, old_timer_isr);
      setvect(9, old_keyb_isr);
      printf("You exited the game! Come soon.\n");
      hello();
      exit(0);
    case DEAD:
      /* No more lives; restore, send message and get away */
      set_mode(old_mode);
      setvect(8, old_timer_isr);
      setvect(9, old_keyb_isr);
      printf("You are dead! Try again later.\n");
      hello();
      exit(0);
    case ENDLEVEL:
      /* Level has been finished */
      level++;
      if (prepare_level(level) < 0) {
        /* No more levels; restore, send error message and get away */
        set_mode(old_mode);
        setvect(8, old_timer_isr);
        setvect(9, old_keyb_isr);
        printf("Good work! You've passed all levels!\n");
        hello();
        exit(0);
      }

      /* If not exited, there's one more level to play (at least) */
      /* Let the Infinite_loop prepare THIS level */
      finished = FALSE;
      goto infinite_loop;
  }
}

void interrupt new_keyb_isr() {
  byte port; int temp_direction;
  port = inportb(0x60); temp_direction = pret_direc;
  /* We don't need to see if there's a MAKE or a BREAK: */
  /* If is a MAKE (bit 7 = 0) -> b = bits 6-0 (scancode) */
  /* If is a BREAK (bit 7 = 1) -> b = bits 6-0 (scancode) + 128 */
  if (frozen != TRUE) {
    /* frozen = TRUE -> we can't do anything */
	if (port == 57) {
      /* If frozen = TRUE -> we can toggle pause */
      toggle_pause();
    }
    if (paused != TRUE) {
      /* If frozen = TRUE and paused = FALSE -> ESC and directions work */
	  switch (port) {
        case 1:             /* ESC */
          finished = TRUE;
          finish_type = EXITED;
          break;
        case 72:            /* UP */
          temp_direction = 1; break;
        case 77:            /* RIGHT */
          temp_direction = 2; break;
        case 75:            /* LEFT */
          temp_direction = 3; break;
        case 80:            /* DOWN */
          temp_direction = 4; break;
      }
      /* If the directions are not opposite, set new direction */
      if (temp_direction + direction != 5) {
        pret_direc = temp_direction;
      }
    }
  }

  /* End of interruption */
  outportb(0x20, 0x20);
}

void set_mode(int m) {
  /* BIOS call */
  union REGS r;
  r.x.ax = m;
  int86(0x10, &r, &r);
}

int get_mode() {
  /* BIOS call */
  union REGS r;
  r.h.ah = 15;
  int86(0x10, &r, &r);
  return (r.h.al);
}

int prepare_level(int level) {
  int handle; char filename[20];
  int d1, d2; byte buffer[150];
  int i ,j; byte value;

  /* Put in filename pantXY.res; XY = level */
  d1 = (level % 100) / 10; d2 = level % 10;
  sprintf(filename, "pant%d%d.res", d1, d2);

  /* Open, read and close it */
  handle = open(filename, O_RDONLY);
  if (handle < 0) { return -1; }
  read(handle, buffer, 150);
  close(handle);

  /* Expand data in screen[] */
  for (i = 0; i < 150; i++) {
    value = buffer[i];
    for (j = 0; j < 8; j++) {
      screen[i*8 + (7-j)] = value % 2;
      value /= 2;
    }
  }

  /* Draw screen */
  for (i = 0; i < 1200; i++) {
    draw_square(i%40, i/40, colors[screen[i]]);
  }

  return(0);
}

void draw_square(int x, int y, int c) {
  byte far *vga; int i;
  vga = (byte far *)0xA0000000;
  for (i = 0; i < 16; i++) {
    /* Set color 15 and fill with 0's; this will clear the 8-pixel line */
    outport(0x3C4, 0x0F02);
    vga[80*(16*y+i) + 2*x] = 0; vga[80*(16*y+i) + 2*x + 1] = 0;
	/* Set my color and fill positions with it */
    outport(0x3C4, (c*256)+2);
    vga[80*(16*y+i) + 2*x] = 0xFF; vga[80*(16*y+i) + 2*x + 1] = 0xFF;
  }
}

void init_snake() {
  int i;
  /* Sets direction and lengths */
  direction = 2; pret_direc = 2;
  length_we_have = 3; length_growing_to = 3;
  /* Sets in screen[] body pieces */
  screen[40*15+18] = 3; screen[40*15+19] = 3; screen[40*15+20] = 3;
  /* Sets points in the body array */
  body[0].x = 20; body[1].x = 19; body[2].x = 18;
  body[0].y = 15; body[1].y = 15; body[2].y = 15;
  /* Draw the snake */
  for (i = 0; i < length_we_have; i++) {
    draw_square(body[i].x, body[i].y, colors[3]);
  }
}

void generate_apple() {
  int x, y;
  x = rand() % 40;
  y = rand() % 30;
  /* If screen has nothing in x,y OK; rerand if not */
  while (screen[y * 40 + x] != 0) {
    x = rand() % 40;
    y = rand() % 30;
  }
  /* Modify screen[] and draw the apple */
  screen[y * 40 + x] = 2;
  draw_square(x, y, colors[2]);
}

void write_status() {
  char msg[10];

  /* Need to draw squares to hide previous status; see WARNING */
  /* in str_print(). Also prepares the messages to be printed */

  draw_square(0, 0, colors[1]); draw_square(1, 0, colors[1]);
  sprintf(msg, "L %d", lives); str_print(0, 0, msg);

  draw_square(38, 0, colors[1]); draw_square(39, 0, colors[1]);
  sprintf(msg, "A %d", apples); str_print(77, 0, msg);
}

void toggle_pause() {
  int i;
  paused = !paused;

  if (paused == TRUE) {
    /* There's nothing written here; no problem to WARNING in str_print() */
	str_print(37, 29, "PAUSED");
  } else {
    /* Need to clear the previous PAUSED message; done with draw_square() */
    for (i = 18; i < 22; i++) { draw_square(i, 29, colors[1]); }
  }
}

void str_print(int x, int y, char *str) {
  int i; union REGS r; int c;
  /* c = "color need to put XORed (bit 7 = 1 or c = c | 0x80 */
  /* or c = c + 0x80) if I have colors[1] and I want colors[4] */
  /* Result: c xor background (colors[1]) = (a xor b) xor b = a */
  c = (colors[1] ^ colors[4]) + 0x80;
  /* For all the chars int str */
  for (i = 0; i < strlen(str); i++) {

    /* BIOS gotoxy */
    r.h.ah = 2; r.h.bh = 0; r.h.dh = y;
    r.h.dl = x + i; int86(0x10, &r, &r);

    /* BIOS putchar */
    r.h.ah = 9; r.h.al = str[i]; r.x.bx = c;
    r.x.cx = 1; int86(0x10, &r, &r);

    /* WARNING: this metod assumes there's only background color */
    /* where you print the string; I could clear this space in */
    /* this method, simply drawing ascii(219) in colors[1], before */
    /* printing str[i]; but I don't know why the third call to int86() */
    /* is ignored in my PC; Please tell me if you correct this! */
  }
}

void hello() {
  printf("\n\tProgrammed by: Gerard Monells\n\tChico_GMB@hotmail.com\n");
}

void interrupt new_timer_isr() {
  int x, y; int i;
  /* Do nothing if paused=TRUE or frozen=TRUE */
  if (frozen == FALSE && paused == FALSE) {
    timer++;
    /* Do a movement only every VELOCITY interruptions */
    if (timer == VELOCITY) {
      timer = 0;
      direction = pret_direc;
      /* Get snake head and calculate where to go */
      x = body[0].x; y = body[0].y;
      switch (direction) {
        case 1:             /* UP */
          y--; break;
        case 2:             /* RIGHT */
          x++; break;
        case 3:             /* LEFT */
          x--; break;
        case 4:             /* DOWN */
          y++; break;
      }

      /* ¨What's here? */
      if (screen[40 * y + x] == 0 || screen[40 * y + x] == 2) {
        /* NOTHING or APPLE */
        if (screen[40 * y + x] == 2) {
          /* If apple, count one more apple; if ten finish level */
          /* If not, generate another one and let snake grow */
          apples++;
          if (apples == 10) {
            finished = TRUE;
            finish_type = ENDLEVEL;
          } else {
            generate_apple();
            write_status();
            length_growing_to = longs[apples];
          }
        }
        /* There's snake in this new position */
        screen[40 * y + x] = 3; draw_square(x, y, colors[3]);
        /* Put in body[] new head */
        for (i = length_we_have; i > 0; i--) {
          body[i].x = body[i-1].x; body[i].y = body[i-1].y;
        }
        body[0].x = x; body[0].y = y;
        /* Growing? */
        if (length_we_have != length_growing_to) {
          /* Yes; increment length_we_have; do not remove snake tail */
          length_we_have++;
        } else {
          /* No; erase tail */
          i = length_we_have;
          draw_square(body[i].x, body[i].y, colors[0]);
          screen[40 * body[i].y + body[i].x] = 0;
        }
      } else {
        /* WALL or SNAKE */
        /* Collided; decrement lives; is zero? */
        lives--;
        if (lives == 0) {
          /* Yes; let's finish the game */
          finished = TRUE; finish_type = DEAD;
        } else {
          /* No; re-prepare level; I KNOW pantXY.res exists; because */
          /* you are playing it! There's no control about it exists */
          frozen = TRUE; apples = 0;
          prepare_level(level);
          init_snake(); generate_apple(); write_status();
          frozen = FALSE; paused = FALSE; toggle_pause();
        }
      }

    }
  }
  /* End of interruption */
  outportb(0x20, 0x20);
}
