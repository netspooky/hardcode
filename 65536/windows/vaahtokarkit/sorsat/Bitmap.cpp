#include "Bitmap.h"
#include "SafeAlloc.h"
#include "Vector.h"

#include <string.h>
#include <stdlib.h>

Bitmap::Bitmap()
{
  width=height=0;
  data=0;
//  mask=0;
  blittype = BLIT;
}

Bitmap::Bitmap(int w,int h)
{
  width=height=0;
  data=0;  
//  mask=0;
  blittype = BLIT;
  create(w,h);
}

void Bitmap::create(int neww,int newh)
{
  free();

  if(neww <= 0 || newh < 0) return;

  width=neww;
  height=newh;

  data = (int **) safeAlloc(sizeof(int *)*height);
  data[0]= (int *) safeAlloc(4*width*height);

  for(int i=1; i<height; i++)
  {
    data[i]=data[0]+i*width;
  }
}
/*
void Bitmap::createMask()
{
  mask = (int **) safeAlloc(sizeof(int *)*height);
  mask[0]= (int *) safeAlloc(4*width*height);

  for(int i=1; i<height; i++)
  {
    mask[i]=mask[0]+i*width;
  }
}

void Bitmap::addMask(int c)
{
  if(!mask) createMask();

  for(int y=0; y<height; y++)
  {
    for(int x=0; x<width; x++)
    {
      if(data[y][x] == c)
      {
        mask[y][x] = 0xFFFFFF;
        data[y][x] = 0;
      }
    }
  }
}
*/
void Bitmap::free() {
  if(data) safeFree(data[0]);
  safeFree(data);
//  if(mask) safeFree(mask[0]);
//  safeFree(mask);

  data=0;
//  mask=0;
  width=height=0;
}

void Bitmap::clear(int c)
{
  int i=width*height, *d=&data[0][0];
  while(i--) *d++ = c;
}

void Bitmap::getBorders(int &l,int &r,int &t,int &b)
{
  int c = data[0][0];
  int x,y;
  l=0;
  r=width;
  t=0;
  b=height;

  for(x=0; x<width; x++)
  {
    for(y=0; y<height; y++)
    {
      if(data[y][x] != c) break;
    }
    if(y!=height)
    {
      l = x;
      break;
    }
  }

  for(x=width-1; x>=0; x--)
  {
    for(y=0; y<height; y++)
    {
      if(data[y][x] != c) break;
    }
    if(y!=height)
    {
      r = x;
      break;
    }
  }

  for(y=0; y<height; y++)
  {
    for(x=0; x<width;x ++)
    {
      if(data[y][x] != c) break;
    }
    if(x!=width)
    {
      t = y;
      break;
    }
  }

  for(y=height-1; y>=0; y--)
  {
    for(x=0; x<width;x ++)
    {
      if(data[y][x] != c) break;
    }
    if(x!=width)
    {
      b = y;
      break;
    }
  }

}

// Ei ole nopea ja kiva ja reaaliaikanen...
void Bitmap::smooth()
{
  int div = 256 / 9;

  for(int y=1; y<height-1; y++)
  {
    for(int x=1; x<width-1; x++)
    {
      int r = ((data[y][x]>>16)&255) + ((data[y][x-1]>>16)&255) + ((data[y][x+1]>>16)&255);
      r += ((data[y-1][x]>>16)&255) + ((data[y-1][x-1]>>16)&255) + ((data[y-1][x+1]>>16)&255);
      r += ((data[y+1][x]>>16)&255) + ((data[y+1][x-1]>>16)&255) + ((data[y+1][x+1]>>16)&255);
      r = (r * div) >> 8;

      int g = ((data[y][x]>>8)&255) + ((data[y][x-1]>>8)&255) + ((data[y][x+1]>>8)&255);
      g += ((data[y-1][x]>>8)&255) + ((data[y-1][x-1]>>8)&255) + ((data[y-1][x+1]>>8)&255);
      g += ((data[y+1][x]>>8)&255) + ((data[y+1][x-1]>>8)&255) + ((data[y+1][x+1]>>8)&255);
      g = (g * div) >> 8;

      int b = ((data[y][x])&255) + ((data[y][x-1])&255) + ((data[y][x+1])&255);
      b += ((data[y-1][x])&255) + ((data[y-1][x-1])&255) + ((data[y-1][x+1])&255);
      b += ((data[y+1][x])&255) + ((data[y+1][x-1])&255) + ((data[y+1][x+1])&255);
      b = (b * div) >> 8;

      data[y][x] = (r<<16) + (g<<8) + b;
    }
  }
}

void Bitmap::smooth256x256()
{
  int div = 256 / 9;

  for(int y=0; y<256; y++)
  {
    for(int x=0; x<256; x++)
    {
      int r=0,g=0,b=0;

      r += (data[y][x]&0xFF0000) + (data[y][(x-1)&255]&0xFF0000) + (data[y][(x+1)&255]&0xFF0000);
      r += (data[(y-1)&255][x]&0xFF0000) + (data[(y-1)&255][(x-1)&255]&0xFF0000) + (data[(y-1)&255][(x+1)&255]&0xFF0000);
      r += (data[(y+1)&255][x]&0xFF0000) + (data[(y+1)&255][(x-1)&255]&0xFF0000) + (data[(y+1)&255][(x+1)&255]&0xFF0000);
      r = r >> 16;
      g += (data[y][x]&0xFF00) + (data[y][(x-1)&255]&0xFF00) + (data[y][(x+1)&255]&0xFF00);
      g += (data[(y-1)&255][x]&0xFF00) + (data[(y-1)&255][(x-1)&255]&0xFF00) + (data[(y-1)&255][(x+1)&255]&0xFF00);
      g += (data[(y+1)&255][x]&0xFF00) + (data[(y+1)&255][(x-1)&255]&0xFF00) + (data[(y+1)&255][(x+1)&255]&0xFF00);
      g = g >> 8;
      b += (data[y][x]&0xFF) + (data[y][(x-1)&255]&0xFF) + (data[y][(x+1)&255]&0xFF);
      b += (data[(y-1)&255][x]&0xFF) + (data[(y-1)&255][(x-1)&255]&0xFF) + (data[(y-1)&255][(x+1)&255]&0xFF);
      b += (data[(y+1)&255][x]&0xFF) + (data[(y+1)&255][(x-1)&255]&0xFF) + (data[(y+1)&255][(x+1)&255]&0xFF);
      data[y][x] = ((r*div<<8)&0xFF0000) + ((g*div)&0xFF00) + ((b*div)>>8);
    }
  }
}

void Bitmap::addNoise(int m)
{
  int *s = &data[0][0];
  for(int y=0; y<height; y++)
  {
    for(int x=0; x<width; x++)
    {
      int a = rand()&m;
      int r = ((*s >> 16)&255) + a;
      if(r>255) r=255;
      int g = ((*s >> 8)&255) + a;
      if(g>255) g=255;
      int b = ((*s)&255) + a;
      if(b>255) b=255;
      *s++ = (r<<16) + (g<<8) + b;
    }
  }
}

void Bitmap::filter(int t)
{
  int *d=&data[0][0];
  int i=width*height;

  if(t==0) return;

  int rr = abs(t) * 256 * 256;
  int gg = abs(t) * 256;
  int bb = abs(t);

  if(t>0)
  {
    while(i--)
    {
      int r = (*d & 0xFF0000) + rr;
      if(r>0xFF0000) r=0xFF0000;
      int g = (*d & 0xFF00) + gg;
      if(g>0xFF00) g=0xFF00;
      int b = (*d & 0xFF) + bb;
      if(b>0xFF) b=0xFF;
      *d++ = r + g + b;
    }
  }
  else
  {
    while(i--)
    {
      int r = (*d & 0xFF0000) - rr;
      if(r<0xFFFF) r=0;
      int g = (*d & 0xFF00) - gg;
      if(g<0xFF) g=0;
      int b = (*d & 0xFF) - bb;
      if(b<0) b=0;
      *d++ = r + g + b;
    }
  }
}

void Bitmap::filterColors(float r,float g,float b)
{
  int i=width*height,*d = &data[0][0];

  while(i--)
  {
    float rr = ((*d >> 16) & 0xFF) * r;
    float gg = ((*d >> 8) & 0xFF) * g;
    float bb = (*d & 0xFF) * b;
    if(rr>255) rr = 255;
    if(gg>255) gg = 255;
    if(bb>255) bb = 255;
    *d++ = ((int)bb) + ((int)gg)*256 + ((int)rr)*256*256;
  }
}

void Bitmap::grayScale()
{
  int i=width*height,*d = &data[0][0];

  while(i--)
  {
    float c = (((*d >> 16) & 0xFF) + ((*d >> 8) & 0xFF) + (*d & 0xFF)) / 3.0f;
    float r = c * 0.9f;
    float g = c * 0.8f;
    float b = c * 1.9f;
    if(r>255) r = 255;
    if(g>255) g = 255;
    if(b>255) b = 255;
    *d++ = ((int)b) + ((int)g)*256 + ((int)r)*256*256;
  }
}

void Bitmap::antialias(Bitmap &src)
{
  int *d = &data[0][0];
  int *s = &src.data[src.height/2 - height][src.width/2 - width];
  int w2 = src.width*2 - width*2, w21 = src.width+1;

  for(int y=0; y<height; y++)
  {
    for(int x=0; x<width; x++)
    {
      int r = ((*s>>16)&0xFF) + ((*(s+1)>>16)&0xFF) + ((*(s+src.width)>>16)&0xFF) + ((*(s+w21)>>16)&0xFF);
      int g = ((*s>>8)&0xFF) + ((*(s+1)>>8)&0xFF) + ((*(s+src.width)>>8)&0xFF) + ((*(s+w21)>>8)&0xFF);
      int b = ((*s)&0xFF) + ((*(s+1))&0xFF) + ((*(s+src.width))&0xFF) + ((*(s+w21))&0xFF);
      *d++ = ((r*256*256/4)&0xFF0000) + ((g*256/4)&0xFF00) + ((b/4)&0xFF);

      s+=2;
    }
    s+=w2;
  }
}

void Bitmap::putPixel(int x,int y,int c)
{
  if(x >= 0 && x < width && y >= 0 && y < height) data[y][x] = c;
}

int Bitmap::getPixel(int x,int y)
{
  if(x >= 0 && x < width && y >= 0 && y < height) return data[y][x];
  else return -1;
}

void Bitmap::circle(int ox,int oy,int r1,int r2,int c)
{
  int sx = ox-r1;
  int ex = ox+r1;
  int sy = oy-r1;
  int ey = oy+r1;

  if(sx < 0) sx = 0;
  if(sy < 0) sy = 0;
  if(ex > width) ex = width;
  if(ey > height) ey = height;

  int r12 = r1*r1, r22 = r2*r2;

  for(int y=sy; y<ey; y++)
  {
    int yy = (y-oy)*(y-oy);
    for(int x=sx; x<ex; x++)
    {
      int d = yy + (x-ox)*(x-ox);
      if(d <= r12 && d >= r22) data[y][x] = c;
    }
  }
}

/* Blitit */

void Bitmap::copy(Bitmap &dest)
{
  if(width != dest.width || (height != dest.height)) blit(dest,0,0);
  else {
    memcpy(&dest.data[0][0],&data[0][0],width*height*4);
  }
}

int Bitmap::clip(const Bitmap &dest,int &x,int &y,int &left,int &right,int &top,int &bottom)
{
  if(x+width <= 0) return 1;
  if(y+height <= 0) return 1;
  if(x >= dest.width) return 1;
  if(y >= dest.height) return 1;

  if(x+width > dest.width)
  {
    right = x + width - dest.width;
  } else {
    right = 0;
  }

  if(y+height > dest.height)
  {
    bottom = y + height - dest.height;
  } else {
    bottom = 0;
  }

  if(x < 0)
  {
    left = 0-x;
    x=0;
  } else {
    left = 0;
  }

  if(y < 0)
  {
    top = 0-y;
    y=0;
  } else {
    top = 0;
  }

  return 0;
}

/*
void Bitmap::blitex(Bitmap &dest,int x,int y)
{
  switch(blittype)
  {
    case BLIT:
      blit(dest,x,y);
      break;

    case BLIT_MASK:
      maskedBlit(dest,x,y);
      break;

    case BLIT_MIX:
      mixBlit(dest,x,y);
      break;

    case BLIT_ADD:
      addBlit(dest,x,y);
      break;
  }
}
*/

void Bitmap::blit(Bitmap &dest,int x,int y)
{
  int left,right,top,bottom;

  if(clip(dest,x,y,left,right,top,bottom)) return;

  int ww = width - right - left;
  int hh = height - top - bottom;

  int *destdata = &dest.data[y][x];
  int *srcdata = &data[top][left];

  int srcadd = right + left;
  int destadd = dest.width - ww;

  while(hh--)
  {
    int w2=ww;
    while(w2--)
    {
      *destdata++ = *srcdata++;
    }
    srcdata += srcadd;
    destdata += destadd;
  }
}

/*
void Bitmap::maskedBlit(Bitmap &dest,int x,int y)
{
  if(!mask)
  {
    blit(dest,x,y);
    return;
  }

  int left,right,top,bottom;

  if(clip(dest,x,y,left,right,top,bottom)) return;

  int ww = width - right - left;
  int hh = height - top - bottom;

  int *destdata = &dest.data[y][x];
  int *srcdata = &data[top][left];
  int *maskdata = &mask[top][left];

  int srcadd = right + left;
  int destadd = dest.width - ww;

  while(hh--)
  {
    int w2=ww;
    while(w2--)
    {
      *destdata = ((*destdata++) & (*maskdata++)) | (*srcdata++);
    }
    srcdata += srcadd;
    maskdata += srcadd;
    destdata += destadd;
  }
}

void Bitmap::mixBlit(Bitmap &dest,int x,int y)
{
  int left,right,top,bottom;

  if(clip(dest,x,y,left,right,top,bottom)) return;

  int ww = width - right - left;
  int hh = height - top - bottom;

  int *destdata = &dest.data[y][x];
  int *srcdata = &data[top][left];

  int srcadd = right + left;
  int destadd = dest.width - ww;

  while(hh--)
  {
    int w2=ww;
    while(w2--)
    {
      *destdata++ = (*destdata>>1 & 0x7F7F7F) + (*srcdata++>>1 & 0x7F7F7F);
    }
    srcdata += srcadd;
    destdata += destadd;
  }
}
*/

void Bitmap::addBlit(Bitmap &dest,int x,int y)
{
  int left,right,top,bottom;

  if(clip(dest,x,y,left,right,top,bottom)) return;

  int ww = width - right - left;
  int hh = height - top - bottom;

  int *destdata = &dest.data[y][x];
  int *srcdata = &data[top][left];

  int srcadd = right + left;
  int destadd = dest.width - ww;

  while(hh--)
  {
    int w2=ww;
    while(w2--)
    {
      int r=(*destdata & 0xFF0000) + (*srcdata & 0xFF0000);
      if(r>0xFF0000) r=0xFF0000;
      int g=(*destdata & 0xFF00) + (*srcdata & 0xFF00);
      if(g>0xFF00) g=0xFF00;
      int b=(*destdata & 0xFF) + (*srcdata & 0xFF);
      if(b>0xFF) b=0xFF;

      srcdata++;
      *destdata++ = r | g | b;
    }
    srcdata += srcadd;
    destdata += destadd;
  }
}

void Bitmap::transparencyBlit(Bitmap &dest,int t,int x,int y)
{
  if(t==0)
  {
    addBlit(dest,x,y);
    return;
  }

  int left,right,top,bottom;

  if(clip(dest,x,y,left,right,top,bottom)) return;

  int ww = width - right - left;
  int hh = height - top - bottom;

  int *destdata = &dest.data[y][x];
  int *srcdata = &data[top][left];

  int srcadd = right + left;
  int destadd = dest.width - ww;

  int tr = t * 256 * 256;
  int tg = t * 256;

  while(hh--)
  {
    int w2=ww;
    while(w2--)
    {
      int r=(*srcdata & 0xFF0000) - tr;
      if(r<0x00FFFF) r=0x000000;
      r+=(*destdata & 0xFF0000);
      if(r>0xFF0000) r=0xFF0000;
      int g=(*srcdata & 0xFF00) - tg;
      if(g<0x00FF) g=0x0000;
      g+=(*destdata & 0xFF00);
      if(g>0xFF00) g=0xFF00;
      int b=(*srcdata & 0xFF) - t;
      if(b<0x00) b=0x00;
      b+=(*destdata & 0xFF);
      if(b>0xFF) b=0xFF;

      srcdata++;
      *destdata++ = r | g | b;
    }
    srcdata += srcadd;
    destdata += destadd;
  }
}

void Bitmap::line(int x1,int y1,int x2,int y2,int w1,int w2,int c)
{
  float ww1 = w1 * 0.5f, ww2 = w2 * 0.5f;

  Vector a;
  a.x = (float)(y2-y1);
  a.y = (float)-(x2-x1);
  a.z = 0;
  vectorNormalize(&a);

  Triangle2D t;

  t.v1.r = (c>>16) & 0xFF;
  t.v1.g = (c>>8) & 0xFF;
  t.v1.b = (c) & 0xFF;

  t.v1.x = (int)(x1 + a.x*ww1);
  t.v1.y = (int)(y1 + a.y*ww1);
  t.v2.x = (int)(x1 - a.x*ww1);
  t.v2.y = (int)(y1 - a.y*ww1);
  t.v3.x = (int)(x2 + a.x*ww2);
  t.v3.y = (int)(y2 + a.y*ww2);
  flatTriangle(&t);

  t.v1.x = (int)(x1 - a.x*ww1);
  t.v1.y = (int)(y1 - a.y*ww1);
  t.v2.x = (int)(x2 - a.x*ww2);
  t.v2.y = (int)(y2 - a.y*ww2);
  t.v3.x = (int)(x2 + a.x*ww2);
  t.v3.y = (int)(y2 + a.y*ww2);
  flatTriangle(&t);
}

#define SWAP(a,b) { temp=a; a=b; b=temp; }

#define FLATHELPER(y1,y2) \
for(y=y1;y<y2;y++) \
{ \
  if(x1 < x2) { x1i=x1>>16; x2i=x2>>16; } \
  else { x1i=x2>>16; x2i=x1>>16; } \
  if(y >= 0) \
  { \
    if(y < height) \
    { \
      if(x1i<0) x1i=0; \
      if(x2i>width) x2i = width; \
      for(int x=x1i; x<x2i; x++) dest[x] = c; \
    } else break; \
  } \
  x1 += xadd1; \
  x2 += xadd2; \
  dest += width; \
}

void Bitmap::flatTriangle(Triangle2D *t) 
{
  Triangle2DVertex *v1,*v2,*v3,*temp;

  v1 = &t->v1;
  v2 = &t->v2;
  v3 = &t->v3;

  if(v2->y > v3->y) SWAP(v2,v3);
  if(v1->y > v3->y) SWAP(v1,v3);
  if(v1->y > v2->y) SWAP(v1,v2);
  if(v1->y >= height) return;
  if(v3->y <= 0) return;

  if(v1->y == v3->y) return;

  int xadd1, x1;
  xadd1 = (v1->x - v3->x)*65536 / (v1->y - v3->y);
  x1 = v1->x*65536;

  int xadd2, x2;
  if(v1->y==v2->y) xadd2=0;
  else xadd2 = (v1->x - v2->x)*65536 / (v1->y - v2->y);
  x2=x1;

  int x1i,x2i,y;

  int c = (t->v1.r<<16) + (t->v1.g<<8) + t->v1.b;
  int *dest = (int *)data[0];
  dest+=v1->y*width;

  FLATHELPER(v1->y,v2->y);
  if(v2->y != v3->y) 
  {
    xadd2=(v2->x - v3->x)*65536 / (v2->y - v3->y);
    x2=v2->x*65536;
    FLATHELPER(v2->y,v3->y);
  }
}

void Bitmap::drawBorders(int p)
{
  int c1,c2,c3,c4;

  if(p)
  {
    c1 = 0x000000;
    c2 = 0xFFFFFF;
    c3 = 0x404040;
    c4 = 0xC0C0C0;
  } else {
    c1 = 0xFFFFFF;
    c2 = 0x000000;
    c3 = 0xC0C0C0;
    c4 = 0x404040;
  }

  int xx,yy;

  for(xx=0; xx<width-1; xx++)
  {
    data[0][xx+1] = mix(data[0][xx+1], c1);
    data[height-1][xx] = mix(data[height-1][xx], c2);
  }
  for(yy=0; yy<height-1; yy++)
  {
    data[yy][0] = mix(data[yy][0], c1);
    data[yy+1][width-1] = mix(data[yy+1][width-1], c2);
  }
  for(xx=0; xx<width-3; xx++)
  {
    data[1][xx+1] = mix(data[1][xx+1], c3);
    data[height-2][xx+1] = mix(data[height-2][xx+1], c4);
  }
  for(yy=0; yy<height-3; yy++)
  {
    data[yy+1][1] = mix(data[yy+1][1], c3);
    data[yy+2][width-2] = mix(data[yy+2][width-2], c4);
  }
}

void Bitmap::drawRectangle(int x1,int y1,int x2,int y2)
{
  int temp;
  if(x2 < x1) SWAP(x1,x2);
  if(y2 < y1) SWAP(y1,y2);

  for(int x=x1; x<x2; x++)
  {
    if(y1 >= 0 && y1 < height && x >= 0 && x < width) data[y1][x] = mix(data[y1][x],0xffffff);
    if(y2 >= 0 && y2 < height && x >= 0 && x < width) data[y2][x] = mix(data[y2][x],0xffffff);
  }
  for(int y=y1; y<y2; y++)
  {
    if(y >= 0 && y < height && x1 >= 0 && x1 < width) data[y][x1] = mix(data[y][x1],0xffffff);
    if(y >= 0 && y < height && x2 >= 0 && x2 < width) data[y][x2] = mix(data[y][x2],0xffffff);
  }
}

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