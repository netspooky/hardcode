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

#ifndef _PLASMA_H_
#define _PLASMA_H_

#include <math.h>
#include <malloc.h>

#ifndef M_PI
#define M_PI 3.141596
#endif

#ifdef _WIN32
#define HYPOT _hypot
#else
#define HYPOT hypotf
#endif

// --------------------
// #define CRAP_CIRCLES       // ugly circles.
// --------------------

void
zeshoek(iBuffer &b, int x, int y, int r, peli c)
{
  unsigned int * left  = (unsigned int *) malloc((r<<1)*sizeof(unsigned int));
  unsigned int * right = (unsigned int *) malloc((r<<1)*sizeof(unsigned int));
  int i;

  // start & end points of the lines in the zeshoek.
  // (what's a six-sided thingy called in enklish?)
  for(i=0; i<r; i++)
    {
      int a = r - (i>>1) + 3; 

      int    top = i;
      int bottom = (r<<1) - 1 - i;

      int ysubi = (y-i)>0   ? (y-i) : 0;
      int yaddi = (y+i)<b.y ? (y+i) : b.y;
      int xsuba = (x-a)>0   ? (x-a) : 0;
      int xadda = (x+a)<b.x ? (x+a) : b.x;

      left [   top] = (ysubi)*b.x+(xsuba);
      left [bottom] = (yaddi)*b.x+(xsuba);
      right[   top] = (ysubi)*b.x+(xadda);
      right[bottom] = (yaddi)*b.x+(xadda);
      
    }

  // plot smurf
  for(i=0; i<(r<<1); i++)
    for(unsigned int p=left[i]; p<right[i]; p++)
      if(p < (unsigned int)(b.x*b.y)) // how can this be?  this is checked for above!
        b.data[p] = c;

  free(left);
  free(right);
}

#define ZES_NOFLAG                  0 // zero, nil, null, nothing, etc...
#define ZES_RESIZE                  1 // resize based on colour of source pixel
#define ZES_SETCOL                  2 // set colour to specified colour in stead of source pixel colour
#define ZES_BORDER                  4 // leave a 1 pixel border
#define ZES_COLOUR(c)       ((flags&ZES_SETCOL) ? colour : c)
#define ZES_RADIUS(c)       ((flags&ZES_RESIZE) ? ((c-col_start) / (0x40 / r2)) : r2)   // phew. what a mess.

/*
  I don't feel like writing docs for this. try something like this:
    zeshoekbehang(vid, plasma, ZES_RESIZE | ZES_SETCOL, 0xFF0080);

  although it probably looks best without flags:
    zeshoekbehang(vid, plasma, ZES_NOFLAG);

  contact me for more information -- <warp-tmt@dds.nl>
 */
void
zeshoekbehang(iBuffer &b, iBuffer &s, int flags, peli col_start, peli colour = 0)
{
  int r = (b.x / (s.x-1)) >> 1;
  int r2 = (flags&ZES_BORDER) ? r : (int)(r*1.15);

  for(int y=0; y<(s.y); y++)
    for(int x=0; x<(s.x); x+=2)
      {
        if(y&1)
          zeshoek(b, x*(r<<1)+(2*r), y*r,
                  ZES_RADIUS(s.data[y*s.x+x+1]),
                  ZES_COLOUR(s.data[y*s.x+x+1]));
        else
          zeshoek(b, x*(r<<1), y*r,
                  ZES_RADIUS(s.data[y*s.x+x]),
                  ZES_COLOUR(s.data[y*s.x+x]));
      }
}


#ifdef CRAP_CIRCLES

void
crap_circle_h(Buffer &b, int x, int y, int r, pel c)
{
  int * left = (int *) alloca((r<<1)*sizeof(int));
  int * right = (int *) alloca((r<<1)*sizeof(int));
  int i;

  // start & end points of most lines in the circle.
  for(i=0; i<r; i++)
    {
      int a = (int) sqrt((r*r) - (i*i));

      int    top = i;
      int bottom = (r<<1) - 1 - i;

      left[   top] = (y-a)*b.x+(x - top);
      left[bottom] = (y+a)*b.x+(x - top);
      right[   top] = (y-a)*b.x+(x + top);
      right[bottom] = (y+a)*b.x+(x + top);
    }

  // plot circle
  for(i=0; i<(r<<1); i++)
    for(int p=left[i]; p<right[i]; p++)
      b.data[p] = c;
}

void
crap_circle_v(Buffer &b, int x, int y, int r, pel c)
{
  int *   top = (int *) alloca((r<<1)*sizeof(int));
  int * bottom = (int *) alloca((r<<1)*sizeof(int));
  int i;

  // start & end points of most lines in the circle.
  for(i=0; i<r; i++)
    {
      int a = (int) sqrt((r*r) - (i*i));

      int  left = i;
      int right = (r<<1) - 1 - i;

      top[ left] = (y - left)*b.x+(x - a);
      top[right] = (y - left)*b.x+(x + a);
      bottom[ left] = (y + left)*b.x+(x - a);
      bottom[right] = (y + left)*b.x+(x + a);
    }

  // plot circle
  for(i=0; i<(r<<1); i++)
    for(int p=top[i]; p<bottom[i]; p+=b.x)
      b.data[p] = c;
}

void
crap_circle(Buffer &b, int x, int y, int r, pel fg, pel bg)
{
  crap_circle_v(b, x, y, r, bg);
  crap_circle_h(b, x, y, r, fg);
}

#endif


#define PLASMA_X_MOVEMENT_SPEED ((float) 0x20)
#define PLASMA_Y_MOVEMENT_SPEED ((float) 0x20)
#define PLASMA_MAX_COLOUR_VALUE         (0x40/3)
//#define PLASMA_MAX_COLOUR_VALUE         (0x40)
#define P_MUL(f)                ((unsigned char) ((PLASMA_MAX_COLOUR_VALUE>>1) + ((PLASMA_MAX_COLOUR_VALUE>>1)-1) * f))

#define P_80h                   (float)(width/5)
#define P_40h                   (P_80h/2)
#define P_20h                   (P_40h/2)
#define P_10h                   (P_20h/2)

class Plasma 
{
public:
  Plasma(int w, int h) : buph1_t1(0), buph1_t2(0), buph2_t1(0), buph2_t2(0), width(w), height(h)
  { 
    // wee, heavy memory usage! :)
    buph1 = (unsigned char *) malloc(width*height);
    buph2 = (unsigned char *) malloc(width*height);
    buph3 = (unsigned char *) malloc(width*height);

    for(int y=0; y<height; y++)
      for(int x=0; x<width; x++)
        {
          buph1[y*width+x] = P_MUL(  (sin(x/(P_20h+P_10h*cos(y/P_80h))) * cos(y/(P_20h+P_10h*sin(x/P_40h))))  );
          buph2[y*width+x] = P_MUL(  (sin(x/(P_20h+P_10h*cos((x+y)/P_80h))) * cos(y/P_40h))                   );
          buph3[y*width+x] = P_MUL(  (sin(HYPOT((height>>1)-y, (width>>1)-x)/P_10h))                          );
        }
  }

  ~Plasma(void) 
  { 
    free(buph1);
    free(buph2);
    free(buph3);
  }

  void
  Draw(iBuffer &b, float t, peli col_start)
  {
    buph1_t1+=0.8f * t;
    buph1_t2+=1.2f * t;
    buph2_t1+=1.2f * t;
    buph2_t2+=0.8f * t;
    buph3_t1+=1.1f * t;
    buph3_t2+=0.9f * t;

    int x_off_max = width - b.x;
    int y_off_max = height - b.y;

    int x_offset1 = (int)((x_off_max>>1) + ((x_off_max>>1)-1)*(sin(buph1_t1/PLASMA_X_MOVEMENT_SPEED)));
    int y_offset1 = (int)((y_off_max>>1) + ((y_off_max>>1)-1)*(sin(buph1_t2/PLASMA_Y_MOVEMENT_SPEED)));
    int x_offset2 = (int)((x_off_max>>1) + ((x_off_max>>1)-1)*(sin(buph2_t1/PLASMA_X_MOVEMENT_SPEED)));
    int y_offset2 = (int)((y_off_max>>1) + ((y_off_max>>1)-1)*(sin(buph2_t2/PLASMA_Y_MOVEMENT_SPEED)));
    int x_offset3 = (int)((x_off_max>>1) + ((x_off_max>>1)-1)*(sin(buph3_t1/PLASMA_X_MOVEMENT_SPEED)));
    int y_offset3 = (int)((y_off_max>>1) + ((y_off_max>>1)-1)*(sin(buph3_t2/PLASMA_Y_MOVEMENT_SPEED)));

    for(int y=0; y<b.y; y++)
      for(int x=0; x<b.x; x++)
        {
          /*
          unsigned char c = buph1[(y_offset1+y)*width+(x_offset1+x)] 
            + buph3[(y_offset3+y)*width+(x_offset3+x)];
          unsigned char d = buph2[(y_offset2+y)*width+(x_offset2+x)] 
            + buph3[(y_offset3+y)*width+(x_offset3+x)];
          */

          // remember to set MAX_COLOUR_VALUE to (0x100/3) or something.
          unsigned char c = buph1[(y_offset1+y)*width+(x_offset1+x)] +
                            buph2[(y_offset2+y)*width+(x_offset2+x)] +
                            buph3[(y_offset3+y)*width+(x_offset3+x)];

          // remember to set MAX_COLOUR_VALUE to 0x100 or something.
          /*
            unsigned char red = buph1[(y_offset1+y)*width+(x_offset1+x)];
            unsigned char grn = buph2[(y_offset2+y)*width+(x_offset2+x)];
            unsigned char blu = buph3[(y_offset3+y)*width+(x_offset3+x)];
            unsigned char c = (grn | blu>>2);
          */

          //          b.data[y*b.x+x] = (((c+red)&0xFE) << 0x0F | red << 0x08 | c);
          //          b.data[y*b.x+x] = (d   << 0x10 | 0   << 0x08 | c);
          //          b.data[y*b.x+x] = (red << 0x10 | grn << 0x08 | blu);
          //          b.data[y*b.x+x] = (c << 0x10 | c << 0x08 | c);

          b.data[y*b.x+x] = col_start + c;
        }
  }

private:
  float buph1_t1;
  float buph1_t2;
  float buph2_t1;
  float buph2_t2;
  float buph3_t1;
  float buph3_t2;
  int width;  // width * height is the size of the precalc buffers, 
  int height; // they are NOT the width+height of the target buffer.
  unsigned char * buph1;
  unsigned char * buph2;
  unsigned char * buph3;
};

#endif  // _PLASMA_H_
