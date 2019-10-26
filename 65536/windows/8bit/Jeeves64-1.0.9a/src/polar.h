/* -*- mode: c++ -*-

  This file is part of Jeeves64, an application framework for 64k
  GNU/Linux and win32 intro development. 
  
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

#ifndef _POLAR_H_
#define _POLAR_H_

#include <math.h>
#include <malloc.h>

#ifdef _WIN32
#define HYPOT _hypot
#else
#define HYPOT hypotf
#endif

#ifndef M_PI
#define M_PI 3.1415926
#endif


#ifdef DEBUG
/*
void
gradient(Buffer &b)
{
  for(int y=0; y<b.y; y++)
    for(int x=0; x<b.x; x++)
      b.data[y*b.x+x] = (0xFF << 0x10) | (((y*0xFF)/b.y) << 0x08) | ((x*0xFF)/b.x);
}
*/
#endif DEBUG

void
zongradient(iBuffer &b, peli colour)
{
  for(int x=0; x<b.x; x++)
    {
      int h = (b.y>>3) + (rand()&0x0F);

      float prev = 0;
      float step = (float)colour / (float)(b.y-h);
      
      for(int y=h; y<b.y; y++)
        b.data[y*b.x+x] = (int)(prev+=step); 
    }
}

void
Zon(iBuffer &b, double t, peli colour, double r)
{
  for(int x=0; x<b.x; x++)
    {
      //      int h = (int)((b.y>>2) + (b.y>>2)*sin((x+t+(rand()&0xF))/14));
      //      int h = b.y - (int)(r*((b.y>>2)+(b.y>>1) + (b.y>>2)*sin((x+t+(rand()&0xF))/14)));
      int h = b.y - (int)(r*((b.y>>2)+(b.y>>1) + (b.y>>2)
                             *sin((x+t+(rand()&0x7))/14)
                             *cos((r+t+(rand()&0x7))/14)
                             ));

      float prev = 0;
      float step = (float)colour / (float)(b.y-h);
      
      for(int y=h; y<b.y; y++)
        b.data[y*b.x+x] = COL_START + (int)(prev+=step); 
    }
}

class Arctica
{
private:
  int y;
  int x;
  int width;
  int height;
  int size;
  int src_width;
  int src_height;
  int * radius;  // in pixels.
  int * angle;   // in pixels. 
public:
  Arctica(int w, int h, int source_width, int source_height) 
    : width(w), height(h), size(w*h), src_width(source_width), src_height(source_height)
  { 
    radius = (int *) malloc(size*sizeof(int));
    angle  = (int *) malloc(size*sizeof(int));

    int offset = 0;
    
    for(int y=0-(height>>1); y<(height>>1); y++)
      for(int x=0-(width>>1); x<(width>>1); x++)
        {
          angle [offset] = (int) ((atan2(y, x)+M_PI)/(M_PI+M_PI)*(src_width-1));
          radius[offset] = (int) (HYPOT(x, y)/HYPOT(width,height)*((src_height-1)<<1));
          offset++;
        }
  }

  ~Arctica(void) 
  { 
    free(radius);
    free(angle);
  }

  void
  Draw(iBuffer &b, iBuffer &s, int a, int r)
  {
#ifdef DEBUG
    if((s.x!=src_width) || (s.y!=src_height) || (b.x!=width) || (b.y!=height)) ERROR;
#endif
    for(y=0; y<height; y++)
      for(x=0; x<width; x++)
          b.data[y*b.x+x] =
            s.data[((radius[y*width+x]+r)%s.y)*s.x+(angle[y*width+x]+a)%s.x];

    // kludge, 'cause the center looks ugly otherwise.
    for(y=(height>>1)-3; y<(height>>1)+3; y++)
      for(x=(width>>1)-3; x<(width>>1)+3; x++)
        b.data[y*b.x+x] = b.data[(y-1)*b.x+x];
  }

  void
  Twirl(iBuffer &b, iBuffer &s, int a, int r, double t)
  {
#ifdef DEBUG
    if((s.x!=src_width) || (s.y!=src_height) || (b.x!=width) || (b.y!=height)) ERROR;
#endif

    for(y=0; y<height; y++)
      for(x=0; x<width; x++)
          b.data[y*b.x+x] = 
            s.data[((radius[y*width+x]+r)%s.y)*s.x
                  +(angle[y*width+x]+a+ (int)((radius[y*width+x]+r)*t) )%s.x];

    // kludge, 'cause the center looks ugly otherwise.
    for(y=(height>>1)-3; y<(height>>1)+3; y++)
      for(x=(width>>1)-3; x<(width>>1)+3; x++)
        b.data[y*b.x+x] = b.data[(y-1)*b.x+x];
  }

  void
  DrawR(iBuffer &b, iBuffer &s, int a, int r)
  {
#ifdef DEBUG
    if((s.x!=src_width) || (s.y!=src_height) || (b.x!=width) || (b.y!=height)) ERROR;
#endif

    for(y=0; y<height; y++)
      for(x=0; x<width; x++)
        b.data[y*b.x+x] =
          s.data[(s.y-((radius[y*width+x]+r)%s.y))*s.x+(angle[y*width+x]+a)%s.x];

    // kludge, 'cause the center looks ugly otherwise.
    for(int y=(height>>1)-3; y<(height>>1)+3; y++)
      for(int x=(width>>1)-3; x<(width>>1)+3; x++)
        b.data[y*b.x+x] = b.data[(y-1)*b.x+x];
  }

  void
  TwirlR(iBuffer &b, iBuffer &s, int a, int r, double t)
  {
#ifdef DEBUG
    if((s.x!=src_width) || (s.y!=src_height) || (b.x!=width) || (b.y!=height)) ERROR;
#endif

    for(y=0; y<height; y++)
      for(x=0; x<width; x++)
        {
          b.data[y*b.x+x] = 
            s.data[(s.y-((radius[y*width+x]+r)%s.y))*s.x
                  +(angle[y*width+x]+a+ (int)((radius[y*width+x]+r)*t) )%s.x];
        }

    // kludge, 'cause the center looks ugly otherwise.
    for(y=(height>>1)-3; y<(height>>1)+3; y++)
      for(x=(width>>1)-3; x<(width>>1)+3; x++)
        b.data[y*b.x+x] = b.data[(y-1)*b.x+x];
  }
};

#endif  // _POLAR_H_

