// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <string.h>
#include "fmath.h"
#include "texgen.h"
#include "fmatrix.h"

void mymemmove(void *, void *, unsigned long);
#pragma aux mymemmove parm [edi] [esi] [ecx] = "rep movsb"
void mymemset(void *, char, unsigned long);
#pragma aux mymemset parm [edi] [eax] [ecx] = "rep stosb"

void txDecodeBWMap(unsigned char *dst, const unsigned char *src, int back, int fore)
{
  unsigned char *end=dst+0x10000;

  while (dst<end)
  {
    if (back!=-1)
      mymemset(dst, back, *src);
    dst+=*src++;
    if (fore!=-1)
      mymemset(dst, fore, *src);
    dst+=*src++;
  }
}
/*
void txSmoothMap(unsigned char *dest, const unsigned char *src)
{
  int j,i,l,k,c;
  for (j=0; j<256; j++)
    for (i=0; i<256; i++)
    {
      c=0;
      for (l=-1; l<=1; l++)
        for (k=-1; k<=1; k++)
          c+=src[((j+l)&255)*256+((i+k)&255)];
      *dest++=c/9;
    }
}
*/
void txHexagonMap(unsigned char *dest, int xn, int yn, int c1, int c2, int c3)
{
  int i,j;
  for (j=0; j<256; j++)
    for (i=0; i<256; i++)
    {
      int x=i*xn;
      int y=j*yn;
      y&=255;
      if (y&128)
        x+=128;
      y&=127;
      y*=3;
      x*=3;
      int c=x>>8;
      x&=255;
      if ((x+y)<128)
        c++;
      if ((x-y)>=128)
        c+=2;
      c%=3;
      *dest++=(c==0)?c1:(c==1)?c2:c3;
    }
}

void txSeenMap(unsigned char *dst)
{
  int x,y,i;
  for (y=-100; y<156; y++)
    for (x=-160; x<96; x++)
    {
      fvector t,turb,v;
      t.set(1.0/6*(fcos(0.7+y*2*M_PI/256*3)+3)*fcos(1+x*2*M_PI/256), 1.0/6*(fsin(0.7+y*2*M_PI/256*3)), 1.0/6*(fcos(0.7+y*2*M_PI/256*3)+3)*fsin(1+x*2*M_PI/256));
      turb.set(t.v[2],t.v[0],t.v[1]);

      float scl=0.2;
      for (i=0; i<4; i++)
      {
        fvecxmul(v, t, turb);
        fvecscl(v, v, scl);
        fvecadd(t, t, v);
        turb.v[2]*=-1;
        turb.v[1]*=-1;
        scl/=2;
      }

      *dst++=(char)((fsin(t.v[0]*2.0*M_PI)+fcos(t.v[1]*2.0*M_PI)+fsin(t.v[2]*4.0*M_PI))/3*128)/16;
    }
}
