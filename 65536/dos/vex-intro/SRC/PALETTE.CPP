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



// palette fade/interpolation functions
// uses palette information from .3ds file...

//#include <io.h>
#include "ovlio.h"
#include <mem.h>
#include "ints.h"
#include "colors2.h"
#include "matrix.h"
#include "vect.h"

static unsigned char (*srcpal)[3];
static unsigned char (*dstpal)[3];
static unsigned char (*curpal)[3];
static char *events;
static char *evptr;
#define MAXFADES 8
static unsigned char fadeoffs[MAXFADES];
static short fadenums[MAXFADES];
static long fadet0[MAXFADES];
static long fadet[MAXFADES];

#pragma argsused
short initpalette(short file)
{
  srcpal=new unsigned char[256][3];
  dstpal=new unsigned char[256][3];
  curpal=new unsigned char[256][3];
  if (!srcpal||!dstpal||!curpal)
    return 0;
  short buflen;
  oread(file, &buflen, 2);
  events=new char[buflen];
  if (!events)
    return 0;
  oread(file, events, buflen);
  evptr=events;
  return 1;
}

void setpalette()
{
  short i;
  for (i=0; i<MAXFADES; i++)
  {
    if (!fadenums[i])
      continue;
    if (fadet[i]+fadet0[i]<curtime)
    {
      memcpy(srcpal+fadeoffs[i], dstpal+fadeoffs[i], fadenums[i]*3);
      SetColors(srcpal+fadeoffs[i], fadeoffs[i], fadenums[i]);
      fadenums[i]=0;
    }
  }

  while (*(long*)evptr<=curtime)
  {
    long t0=*(long*)evptr;
    char cmd=evptr[4];
    evptr+=5;
    unsigned char c0;
    short n;
    long t;
    unsigned char crs, cgs, cbs, crd, cgd, cbd;
    switch (cmd)
    {
    case 0:
      c0=*evptr++;
      n=*(short*)evptr;
      evptr+=2;
      crs=*evptr++;
      cgs=*evptr++;
      cbs=*evptr++;
      crd=*evptr++;
      cgd=*evptr++;
      cbd=*evptr++;
      InterpolCols(srcpal+c0, n, crs, cgs, cbs, crd, cgd, cbd);
      SetColors(srcpal+c0, c0, n);
      break;
    case 1:
      for (i=0; i<(MAXFADES-1); i++)
        if (!fadenums[i])
          break;
      t=*(long*)evptr;
      evptr+=4;
      c0=*evptr++;
      n=*(short*)evptr;
      evptr+=2;
      crs=*evptr++;
      cgs=*evptr++;
      cbs=*evptr++;
      crd=*evptr++;
      cgd=*evptr++;
      cbd=*evptr++;
      InterpolCols(dstpal+c0, n, crs, cgs, cbs, crd, cgd, cbd);
      fadet0[i]=t0;
      fadet[i]=t;
      fadenums[i]=n;
      fadeoffs[i]=c0;
      break;
    }
  }

  for (i=0; i<MAXFADES; i++)
  {
    if (!fadenums[i])
      continue;
    if (fadet[i]+fadet0[i]<curtime)
    {
      memcpy(srcpal+fadeoffs[i], dstpal+fadeoffs[i], fadenums[i]*3);
      SetColors(srcpal+fadeoffs[i], fadeoffs[i], fadenums[i]);
      fadenums[i]=0;
    }
    else
    {
      MakeFadeStep(curpal+fadeoffs[i], srcpal+fadeoffs[i], dstpal+fadeoffs[i], fadenums[i], IntMulDiv(128, curtime-fadet0[i], fadet[i]));
      SetColors(curpal+fadeoffs[i], fadeoffs[i], fadenums[i]);
    }
  }
/*
  if (!evptr)
  {
    InterpolCols(curpal, 128, 0, 0, 0, 255, 255, 255);
    InterpolCols(curpal+128, 128, 128, 0, 0, 255, 0, 0);
    SetColors(curpal, 0, 256);
    evptr++;
  }
*/
}

void closepalette()
{
  delete srcpal;
  delete dstpal;
  delete curpal;
}
