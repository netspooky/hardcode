//This file contains declarations of all global vars

#ifndef __GLOBALS_H_
#define __GLOBALS_H_

#include "base.h"
#include "color.h"

//a fixed width for scaling coefs
#define DEMO_FIXED_WIDTH 640
#define DEMO_FIXED_HEIGHT 480

extern int DEMO_WIDTH;
extern int DEMO_HEIGHT;
#define DEMO_CODENAME "hydrogeN"

extern int   DEMO_BB_WIDTH;
extern int   DEMO_BB_HEIGHT;

extern int   bpp;

extern int    needframes;
extern int    currentframe;
extern int    demostarted;
extern unsigned char bitmap[];
extern unsigned char bubble_pic[];
extern int    FullScreen;
extern int    ResizeToFullScreen;
extern int    soundfreq;

void TimeLine();

#endif