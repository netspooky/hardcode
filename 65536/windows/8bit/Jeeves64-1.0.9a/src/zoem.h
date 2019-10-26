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

#ifndef _ZOEM_H_
#define _ZOEM_H_

#include <math.h>
#include <malloc.h>

class Zzzoem
{
private:
  int width;
  int height;
  int * scaleX;
  int * scaleY;
  iBuffer prev;
#ifdef DEBUG
  int count;
#endif
public:
  Zzzoem(int w, int h) : width(w), height(h), prev(w, h)
  { 
    scaleX = (int *) malloc(width *sizeof(int));
    scaleY = (int *) malloc(height*sizeof(int));

#ifdef DEBUG
    count = 0;
#endif
  }

  ~Zzzoem(void) 
  { 
    free(scaleY);
    free(scaleX);
  }

  void
  reset(peli col_start) { prev.fill(col_start); }

  void
  Draw(iBuffer &b, float t, peli col_start)
  {
    // recompute parameters for image rescaling
    int sx = (int)((width >>1)-(width >>2)*sin((float)t/55));
    int sy = (int)((height>>1)+(height>>2)*sin((float)t/61));
    int x;
    int y;

#ifdef DEBUG
    if((b.x!=width) | (b.y!=height)) ERROR;
#endif

    for (x=0; x<width ; x++) scaleX[x] = (int)(sx+(x-sx)*0.5f);
    for (y=0; y<height; y++) scaleY[y] = (int)(sy+(y-sy)*0.5f);

    for(y=0; y<height; y++)
      for(x=0; x<width; x++)
        b.data[y*width+x] = col_start +
          ((b.data[y*width+x]-col_start)>>1) +
          ((prev.data[scaleY[y]*width+scaleX[x]]-col_start)>>1);

    prev = b;
    //    memcpy(prev.data, b.data, (b.x*b.y*sizeof(peli)));
  }
};

#endif  // _ZOEM_H_
