/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/



// oh my god.. this starfield is so slow...

//#include <io.h>
#include "ovlio.h"
#include <stdlib.h>
#include "ints.h"
#include "matrix.h"
#include "draw3d.h"
#include "vect.h"

#define NUMPOINTS 256

static vector *p3, *p2;
static char *p;
static long lasttime;
static transform *t;
static char *events;
static char *evptr;
static short active;
static long speed;
static long maxcolor;

short initstars(short file)
{
  p3=new vector[NUMPOINTS];
  p2=new vector[NUMPOINTS];
  p=new char[NUMPOINTS*3];
  if (!p3||!p2||!p)
    return 0;
  short i;
  for (i=0; i<NUMPOINTS; i++)
  {
    p2[i].v[0]=(long)rand()*2-32768;
    p2[i].v[1]=(long)rand()*2-32768;
    p2[i].v[2]=(long)rand()*2-32768;
  }
  lasttime=curtime;

  short buflen;
  oread(file, &buflen, 2);
  events=new char[buflen];
  oread(file, events, buflen);
  evptr=events;
  active=0;
  speed=dtol(0.25);
  maxcolor=dtol(32);

  t=new transform(file);

  return 1;
}

void closestars()
{
  delete p3;
  delete p2;
  delete p;
  delete events;
  delete t;
}

void drawstars()
{
  while (*(long*)evptr<=curtime)
  {
//    long t=*(long*)evptr;
    char cmd=evptr[4];
    evptr+=5;
    switch (cmd)
    {
    case 0:
      active=0;
      break;
    case 1:
      active=1;
      break;
    case 2:
      speed=*(long*)evptr;
      evptr+=4;
      break;
    case 3:
      maxcolor=*(long*)evptr;
      evptr+=4;
      break;
    }
  }

  if (!active)
    return;
  long tm=IntMul(curtime-lasttime, speed);

  short i;
  for (i=0; i<NUMPOINTS; i++)
    p2[i].v[2]=(short)(p2[i].v[2]+tm);

  matrix m;
  t->makexform(m);
  vecxform(p3, p2, m, NUMPOINTS);

  short n=calcpoints3d(p, p3, NUMPOINTS, dtol(200), dtol(180), dtol(1), maxcolor);
  rdrawpointlst(p, n, scrpage<<14);

  lasttime=curtime;
}
