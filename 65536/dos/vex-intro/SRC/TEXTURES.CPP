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



// the texture read and calculate(sinplasma) funtions

#include <mem.h>
//#include <io.h>
#include "ovlio.h"
#include <stdlib.h>
#include "sinplasa.h"
#include "ints.h"
#include "matrix.h"
#include "vect.h"

extern long *SinTab;

struct sinplaspar
{
  long p;
  long f;
  long ft;
  short a;
  short w;
};

static struct
{
  short type;
  short x;
  short y;
  char *bmp;
  char oper;
  long lasttime;
  char *sptab;
  sinplaspar *sp;
} textures[32];
short texturenum;

void makeplasma(unsigned char *buf, short resbit, short xabits=0, short yabits=0, short colbits=8, short p=500, long seed=0x17091977);

short inittexture(short file)
{
  oread(file, &texturenum, 2);
  short i;
  for (i=0; i<texturenum; i++)
  {
    oread(file, &textures[i].type, 2);
    short resbit, xabits, yabits, colbits, p;
    long seed;
    switch (textures[i].type)
    {
    case 0:
      oread(file, &textures[i].x, 2);
      oread(file, &textures[i].y, 2);
      textures[i].bmp=new char[textures[i].x*textures[i].y];
      if (!textures[i].bmp)
        return 0;
      oread(file, textures[i].bmp, textures[i].x*textures[i].y);
      break;
    case 1:
      oread(file, &resbit, 2);
      oread(file, &xabits, 2);
      oread(file, &yabits, 2);
      oread(file, &colbits, 2);
      oread(file, &p, 2);
      oread(file, &seed, 4);
      textures[i].type=0;
      textures[i].x=1<<(resbit+xabits);
      textures[i].y=1<<(resbit+yabits);
      textures[i].bmp=new char[textures[i].x*textures[i].y];
      if (!textures[i].bmp)
        return 0;
      makeplasma((unsigned char*)textures[i].bmp, resbit, xabits, yabits, colbits, p, seed);
      break;
    case 2:
      oread(file, &textures[i].x, 2);
      oread(file, &textures[i].y, 2);
      textures[i].bmp=new char[textures[i].x*textures[i].y];
      if (!textures[i].bmp)
        return 0;
      unsigned char maxcol;
      oread(file, &maxcol, 1);
      oread(file, &textures[i].oper, 1);
      textures[i].sp=new sinplaspar[textures[i].oper];
      textures[i].sptab=new char[2048];
      oread(file, textures[i].sp, 16*textures[i].oper);
      textures[i].lasttime=-1;
      makesintab(textures[i].sptab, maxcol/textures[i].oper);
      break;
    }
  }
  return 1;
}

void closetexture()
{
  short i;
  for (i=0; i<texturenum; i++)
  switch (textures[i].type)
  {
  case 0:
    delete textures[i].bmp;
    break;
  case 2:
    delete textures[i].bmp;
    delete textures[i].sp;
    delete textures[i].sptab;
    break;
  }
}

#pragma argsused
void gettexture(short num, const texturespot *text, short n, long (*vert)[2], char *&bmp, unsigned short &wid)
{
  short i, x, y;
  char *bm;
  x=textures[num].x;
  y=textures[num].y;
  bm=textures[num].bmp;
  for (i=0; i<n; i++)
  {
    vert[i][0]=IntMul(itol(x), text[i].x);
    vert[i][1]=IntMul(itol(y), text[i].y);
  }
  bmp=bm;
  wid=x;
  if ((textures[num].type==2)&&(textures[num].lasttime!=curtime))
  {
    textures[num].lasttime=curtime;
    short nm=textures[num].oper;
    sinplaspar *par=textures[num].sp;
    char *ps=textures[num].sptab;
    memset(bm, 0, x*y);
    for (i=0; i<nm; i++)
    {
      char *scr=bm;
      short a=par->a+IntMul(par->w, curtime);
      long fx=IntMul(SinTab[(a+512)&2047], par->f);
      long fy=IntMul(SinTab[a&2047], par->f);
      long p=par->p+IntMul(par->ft, curtime)-(y>>1)*fy-(x>>1)*fx;
      short j;
      for (j=0; j<y; j++)
      {
        plasmaline(ps, scr, x, p, fx);
        p+=fy;
        scr+=x;
      }
      par++;
    }
  }
}
