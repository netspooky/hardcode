#ifndef _Video_h_
#define _Video_h_

#include "Bitmap.h"

#define rgb(r,g,b) (((r)<<16) + ((g)<<8) + (b))

extern Bitmap *screen;
extern int showfps,quitrequest;
extern int mousex,mousey,mousebutton;
extern int videoxsize,videoysize;
extern int refreshleft, refreshright, refreshtop, refreshbottom;
extern int keydown;

void videoInit(int w,int h);
void videoDeinit();
void videoRefresh();
void videoSync();

#endif
