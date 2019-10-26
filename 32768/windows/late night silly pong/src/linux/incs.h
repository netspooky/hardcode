#include <stdio.h>
#include <stdlib.h>
#include <SDL/SDL.h>
#include <math.h>
#include <string.h>

#define FONT_STD_BITMAP		"lnpfont.bmp"
#define PAD_HEIGHT 80
#define PAD_WIDTH 20
#define PAD_LEFT 40
#define PAD_RIGHT 600

#define BALL_HEIGHT 10
#define BALL_WIDTH 10
#define BALL_MOVEXP 3
#define BALL_MOVEYP 1
#define BALL_MOVEXM -3
#define BALL_MOVEYM -1


#define WINDOW_WIDTH 640
#define WINDOW_HEIGHT 480
#define WINDOW_BPP 32

/* graphics.cpp */
int DrawString(SDL_Surface *screen, int x, int y, char *message);


