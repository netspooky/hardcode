/* haha, what? */
#include <stdio.h>
#include <stdlib.h>
#include "xliblib.h"
#include <mikmod.h>
#include "text.h"

float rut, tim;
char color[] = "#6eff00";

/* print Text */
int XPrint(double tx, double ty, char *str)
{
  XDrawString(dis, win, green_gc, tx, ty, str, strlen(str));
}

/* init the display */
void init(int x, int y)
{
  dis = XOpenDisplay(NULL);
  win = XCreateSimpleWindow(dis, RootWindow(dis, 0), 0, 0, x, y, 
			    0, 0, BlackPixel(dis, 0));
  XMapWindow(dis, win);
  colormap = DefaultColormap(dis, 0);
  green_gc = XCreateGC(dis, win, 0, 0);
  XParseColor(dis, colormap, color, &green_col);
  XAllocColor(dis, colormap, &green_col);
  XSetForeground(dis, green_gc, green_col.pixel);
}

void MikmodInit()
{
  MODULE *tjune;
  MikMod_RegisterAllDrivers();
  MikMod_RegisterAllLoaders();
  if(MikMod_Init("")) {
    fprintf(stderr, "MikMod: %s\n",MikMod_strerror(MikMod_errno));
    exit(1);
  }
  tjune = Player_Load("ting.mod", 128, 0);
  if(!tjune) {
    printf("MikMod Error: %s\n",MikMod_strerror(MikMod_errno));
    exit(1);
  }
  Player_Start(tjune);
}

int main() 
{
  init(300, 100);
  FontInit("12x24");
  MikmodInit();
  while (1) {
    XPrint(400-rut/2, 60+sin(rut/300)*20, dude);
    rut += 0.1;
    /* redraw every 50(!) frame */
    tim++;
    if(tim > 50) {
      XClearWindow(dis,win);
      tim = 0;
    }
    MikMod_Update();
  }
}
