/* -*- mode: c++ -*-

  This file is part of Jeeves64, an application framework for 64k
  GNU/Linux and win32 intro development. 
  
  Jeeves64 makes use of fxmp by Spectre of Flare and tinyptc by 
  Gaffer, consult the README for urls. 
  This file is Copyright (c) 2000 Kuno Woudt <warp-tmt@dds.nl>.

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.
  
  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; see the file COPYING; if not, write to
  the Free Software Foundation, Inc., 59 Temple Place, Suite 330,
  Boston, MA  02111-1307  USA

*/

#ifndef _JEEVES64_H_
#define _JEEVES64_H_

#define _JEEVES64_p_ "Jeeves64"
#define _JEEVES64_v_ "0.9.6"

/* Jeeves64 configuration.*/

// ------------------------------------ 
// #define MIRROR         // include vmirror() and hmirror() 
// ------------------------------------ 

/*
  Hi!

 [intro]

  This file is  intended to  provide some of the  objects i've  gotten 
  used to  while messing with  c++. These objects have been  rewritten
  with code size in  mind, and thus all  non-essential methods will be
  removed.
  
 [so, what is in this file anyway?]

  Almost anything provided by Jeeves which makes sense in a 64k should
  be provided eventually. Currently there's only a iBuffer class for 8
  bit indexed-mode buffers, and not much else.

  toc:
    - iBuffer          // indexed-mode Buffer class
    - vierkant         // rectangle draw smurf.
    - i2a              // integer to ascii (only hex currently).

 [iBuffer]

  The iBuffer class provides a few methods and members, which are
  described here:
 
  members:
    peli* data;        // pointer to a buffer containing (x*y) pixels.
    int   size;        // x*y*sizeof(peli)
    int   x;           // width of buffer
    int   y;           // height of buffer

  methods:
    void clear(void);  // memset the buffer to 0.
    void fill(peli c); // fill the buffer with specified colour.

    iBuffer box(int X, int Y, int width, int height);
    iBuffer& operator=(const iBuffer& s);
    
  .box() and =() deserve a little more attention, here goes:

  The operator=() method is used to copy the data from one buffer into
  another, like this:

      iBuffer Black(320, 200);  Black.clear();
      iBuffer White(320, 200);  White.fill(0x00FFFFFF);

      Black = White;

  The .box() method can be used to copy only a part of a buffer into 
  another buffer using operator=(), like these examples:

      iBuffer Black(640, 200);  Black.clear();
      iBuffer White(320, 200);  White.fill(0x00FFFFFF);

      // right half of Black becomes white.
      Black.box(320, 0, White.x, White.y) = White;

      // White buffer is made completely black.
      White = Black.box(0, 0, White.x, White.y);

      // copies a 10*10 square of white pixels from Black to 
      // the bottom-right corner of White.
      White.box(White.x - 10, White.y - 10, 10, 10) = 
        Black.box(320, 0, 10, 10);

 [i2a]

  i2a() renders a hexidecimal representation of an integer into a 
  c-style string.

  char * ctoa(char c);

 [end]

  That's it for now, don't hesitate to contact me if there's any
  problem.

     -- Kuno Woudt <warp-tmt@dds.nl>
*/

#include <stdlib.h>

#ifdef _WIN32
#include <memory.h>
#include <mmsystem.h>  // for timeGetTime(); 
#else
#include <sys/time.h>  // for gettimeofday();
#endif

/* But first, let me start off with some defines from Jeeves/Buffer.h,
   pel (PixEL) is used for 32bit graphic modes */
#include <climits>

#if USHRT_MAX == 0xFFFFFFFF
typedef unsigned short pel;
#elif UINT_MAX == 0xFFFFFFFF
typedef unsigned int pel;
#elif ULONG_MAX == 0xFFFFFFFF
typedef unsigned long pel;
#else
#error "Cannot determine 32-bit integer"
#endif

/* peli = index-mode pixel, 'cause unsigned char is rather cumbersome */
typedef unsigned char peli;

#define RED(v)         (v<<0x10)
#define GREEN(v)       (v<<0x08)
#define BLUE(v)        (v)

#define GETRED(p)      ((p>>0x10) & 0xFF)
#define GETGREEN(p)    ((p>>0x08) & 0xFF)
#define GETBLUE(p)     (p & 0xFF)


// integer to ascii (hex)
char * 
i2a(int i, char * s)
{
#if UINT_MAX > 0xFFFFFFFF
#warning "-----------------------------------------"
#warning "eeek!, large integer smurf not supported."
#warning "-----------------------------------------"
#endif
  
#define I2A_RADIX 0x10

  int pos=0;
  int t;

  if(i==0)
    {
      s[0] = '0';
      s[1] = 0;
      return s;
    }

  // extract digits.
  while(i>0)
    {
      s[pos++] = i%I2A_RADIX; 
      i=i/I2A_RADIX;
    }

  // reverse string.
  for(t=0; t<(pos>>1); t++)
    {
      s[pos] = s[t];
      s[t] = s[pos-(t+1)];
      s[pos-(t+1)] = s[pos];
    }

  // convert digits to proper digits.
  for(t=0; t<pos; t++)
    {
      if(s[t]>9)
        s[t]+=('a'-10);
      else
        s[t]+='0';
    }

  s[pos]=0; // is this the proper way to terminate a c-style string?

  return s;
}


// 8bit peli buffer.  
class iBuffer 
{
public:
  ~iBuffer(void)
  {
    if(local) free(data);
  }

  iBuffer(int w, int h, peli* p=NULL)
    : data(p), size(w*h*sizeof(peli)), x(w), y(h), local(false), 
    box_x(0), box_y(0), box_w(0), box_h(0)
  {
    if(data==NULL) data = (peli*) calloc(size, sizeof(peli));
    if(data==NULL) ERROR;
  }

  //  .box not yet supported.
  iBuffer(int w, int h, int b_x, int b_y, int b_w, int b_h, peli* p)
    : data(p), size(w*h*sizeof(peli)), x(w), y(h), local(false), 
    box_x(b_x), box_y(b_y), box_w(b_w), box_h(b_h)
  {
    if(p==NULL) ERROR;
  }

  void clear(void) { memset(data, 0, size); }
  void fill(peli c) { for(int i=0; i<x*y; data[i++]=c); }

  iBuffer box(int X, int Y, int width, int height)
  {
    iBuffer Box(x, y, X, Y, width, height, data);
    return Box;
  }
  
  // here's where the magic happens for .box()ed buffers.
  iBuffer& operator=(const iBuffer& s)
  {
    if((box_w==0) && (s.box_w==0) && (size==s.size))
      {
        memcpy(data, s.data, size);
        return *this;
      }
    else
      {
        int sx = s.box_w ? s.box_x :   0;
        int sy = s.box_w ? s.box_y :   0;
        int sw = s.box_w ? s.box_w : s.x;
        int sh = s.box_w ? s.box_h : s.y;
        int dx =   box_w ?   box_x :   0;
        int dy =   box_w ?   box_y :   0;
        int dw =   box_w ?   box_w :   x;
        int dh =   box_w ?   box_h :   y;

        if((sw==dw)
           && (sh==dh)
           && ((sx+sw)<=s.x)
           && ((sy+sh)<=s.y)
           && ((dx+dw)<=x)
           && ((dy+dh)<=y)
           )
          {
            for(int Y=0; Y<sh; Y++)
              memcpy(&data[(dy+Y)*x+dx], &s.data[(sy+Y)*s.x+sx], sw*sizeof(peli));
            return *this;
          }
        else
          {
            ERROR
            return *this; // this line is only to prevent a warning from gcc.
          }
      }
  }

  peli* data;
  int size;
  int x;
  int y;
  bool local;
  int box_x;
  int box_y;
  int box_w;
  int box_h;
};

#ifdef MIRROR

/* vmirror (Kuno Woudt, 2000/08/20, for Jeeves64)
   
     ...//   I don't think this works properly... need testing :)

*/
// FIXME: I don't think the consts should be there, but g++ insists.
void
vmirror(const Buffer &d, const Buffer &s)
{
  int sx = s.box_w ? s.box_x :   0;
  int sy = s.box_w ? s.box_y :   0;
  int sw = s.box_w ? s.box_w : s.x;
  int sh = s.box_w ? s.box_h : s.y;
  int dx = d.box_w ? d.box_x :   0;
  int dy = d.box_w ? d.box_y :   0;
  int dw = d.box_w ? d.box_w : d.x;
  int dh = d.box_w ? d.box_h : d.y;

  if((sw==dw) 
     && (sh==dh)
     && ((sx+sw)<=s.x)
     && ((sy+sh)<=s.y)
     && ((dx+dw)<=d.x)
     && ((dy+dh)<=d.y))
    for(int Y=0; Y<sh; Y++)
      for(int X=0; X<sw; X++)
        d.data[(dy+dh-(Y+1))*(d.x)+dx+X] = s.data[(sy+Y)*(s.x)+sx+X];
  else
    ERROR;
}

/* hmirror (Kuno Woudt, 2000/08/20, for Jeeves64) 
   
     ...//   I don't think this works properly... need testing :)

*/
// FIXME: I don't think the consts should be there, but g++ insists.
void
hmirror(const Buffer &d, const Buffer &s)
{
  int sx = s.box_w ? s.box_x :   0;
  int sy = s.box_w ? s.box_y :   0;
  int sw = s.box_w ? s.box_w : s.x;
  int sh = s.box_w ? s.box_h : s.y;
  int dx = d.box_w ? d.box_x :   0;
  int dy = d.box_w ? d.box_y :   0;
  int dw = d.box_w ? d.box_w : d.x;
  int dh = d.box_w ? d.box_h : d.y;

  if((sw==dw) 
     && (sh==dh)
     && ((sx+sw)<=s.x)
     && ((sy+sh)<=s.y)
     && ((dx+dw)<=d.x)
     && ((dy+dh)<=d.y))
    for(int Y=0; Y<sh; Y++)
      for(int X=0; X<sw; X++)
        d.data[(dy+Y)*(d.x)+dx+dw-(X+1)] = s.data[(sy+Y)*(s.x)+sx+X];
  else
    ERROR;
}

#endif


#ifdef _WIN32
int
GetTime(void)
{
  return timeGetTime(); // time in milliseconds since windows startup.
}
#else // !_WIN32
int
GetTime(void)
{
  struct timeval t;

  gettimeofday(&t, NULL); 

  return (t.tv_sec * 1000 + t.tv_usec / 1000);
}
#endif // _WIN32


// rectangle draw smurf.
void
vierkant(iBuffer &b, int xstart, int ystart, int width, int height, peli border, peli filladd)
{
  int x;
  int y;

  // fill.
  for(y=ystart; y<(ystart+height); y++)
    for(x=xstart; x<(xstart+width); x++)
      b.data[y*b.x+x] = b.data[y*b.x+x]+filladd;

  // border.
  for(x=xstart; x<=(xstart+width);  b.data[ ystart        *b.x+(x++)] = border);
  for(x=xstart; x<=(xstart+width);  b.data[(ystart+height)*b.x+(x++)] = border);
  for(y=ystart; y<=(ystart+height); b.data[(y++)*b.x + xstart       ] = border);
  for(y=ystart; y<=(ystart+height); b.data[(y++)*b.x +(xstart+width)] = border);
  
}

#endif // _JEEVES64_H_ 

