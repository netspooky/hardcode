#include "Bitmap.h"
#include <math.h>
#include <stdlib.h>

void Bitmap::generateSin()
{
  for(int y=0; y<256; y++)
  {
    for(int x=0; x<256; x++)
    {
      float c;
      c =  sinf(3.141592f*2.0f*(x+sinf(3.141592f*2.0f*y/64.0f)*24.0f)/128.0f)*32.0f+92.0f;
      c += sinf(3.141592f*2.0f*(y+sinf(3.141592f*2.0f*x/64.0f)*16.0f)/128.0f)*32.0f+92.0f;
      data[y][x]=(int)c;

      c =  cosf(3.141592f*2.0f*(x+sinf(3.141592f*2.0f*y/64.0f)*24.0f)/128.0f)*32.0f+92.0f;
      c += sinf(3.141592f*2.0f*(y+sinf(3.141592f*2.0f*x/64.0f)*16.0f)/128.0f)*32.0f+92.0f;
      data[y][x]|=((int)c)<<8;

      c =  sinf(3.141592f*2.0f*(x+sinf(3.141592f*2.0f*y/64.0f)*24.0f)/128.0f)*32.0f+92.0f;
      c += sinf(3.141592f*2.0f*(y+cosf(3.141592f*2.0f*x/64.0f)*16.0f)/128.0f)*32.0f+92.0f;
      data[y][x]|=((int)c)<<16;
    }
  }
}

void Bitmap::generateNoise()
{
  for(int y=0; y<256; y++)
  {
    for(int x=0; x<256; x++)
    {
      data[y][x]=rgb(rand()&255,rand()&255,rand()&255);
    }
  }
  for(int i=0; i<10; i++)
  {
    smooth256x256();
  }
}

void genTex(Bitmap *bm,int x,int y,int s,int c1,int c2,int c3,int c4,int shift)
{
  if(s==1)
  {
    bm->data[y][x] |= c1<<shift;
  } else {

    int muu = s/2;
    if(muu<=0) muu=1;

    int ka = (c1+c2+c3+c4)/4 + rand()%muu;
    if(ka>255) ka=255;

    genTex(bm,x,y,s/2,         c1,(c1+c2)/2,(c1+c3)/2,ka,shift);
    genTex(bm,x+s/2,y,s/2,     (c1+c2)/2,c2,ka,(c2+c4)/2,shift);
    genTex(bm,x,y+s/2,s/2,     (c1+c3)/2,ka,c3,(c3+c4)/2,shift);
    genTex(bm,x+s/2,y+s/2,s/2, ka,(c2+c4)/2,(c3+c4)/2,c4,shift);
  }
}

void Bitmap::generateFractal()
{
  genTex(this,0,0,256,rand()&255,rand()&255,rand()&255,rand()&255,0);
  genTex(this,0,0,256,rand()&255,rand()&255,rand()&255,rand()&255,8);
  genTex(this,0,0,256,rand()&255,rand()&255,rand()&255,rand()&255,16);
}