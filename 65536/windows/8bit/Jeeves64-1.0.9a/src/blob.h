/* -*- mode: c++ -*-

  This file is part of Jeeves64, an application framework for 64k
  GNU/Linux and win32 intro development. 
  
  This file is Copyright (c) 2000 Wim Yedema.

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

#ifndef _BLOB_H_
#define _BLOB_H_

/* 
  Originally written by Wim Yedema, adapted by Kuno Woudt (2000/08/08)
  for Jeeves64 and hopefully a Bliss 64k intro compo entry at Bizarre 2000.
*/

#include <math.h>

#define DRAW1_EDGE COL_START + 0x42 // 0x008C0836
#define DRAW1_EXT  COL_START + 0x00 // 0x00000000
#define DRAW2_EDGE COL_START + 0x40 // 0x00FE4A26
#define DRAW2_EXT  COL_START + 0x41 // 0x00AC0A46

// This is completely undocumented cause it has to be done in a much 
// more elegant way anyway.

class Blob {
public:
  Blob(void)
  {
    int x,y;
    dist=new float[maximum*maximum];
    for(y=0;y<maximum;y++) {
      for(x=0;x<maximum;x++) {
        double d=sqrt(x*x+y*y);  // try x+y here too, it gives squares
        dist[x+y*maximum]=d*d;  
        //        dist[x+y*maximum]=(x*x+y+y);
      }
    }
  }
  ~Blob(void)
  {
    delete[] dist;
  }
  
  void Draw(iBuffer &buffer, int bx[], int by[], int bn)
  {
    int x,y,b,dx,dy;
    float D,bds;
    const float R=100.0; // Radius of blob
      
    for(y=0;y<buffer.y;y++) {
      for(x=0;x<buffer.x;x++) {
        D=0;
        for(b=0;b<bn;b++) {
          dx=abs(bx[b]-x);
          dy=abs(by[b]-y);
          if(dx<maximum && dy<maximum) {
            bds=dist[dx+maximum*dy];
            if(bds<R*R) {
              D++;
              D-=((22/9)/(R*R))*bds;
              D+=((17/9)/(R*R*R*R))*bds*bds;
              D-=((4/9)/(R*R*R*R*R*R))*bds*bds*bds;
            }
          }
        }
        // Use this for a "fuzzy" edge
        //        D=D+(D*0.2*rand())/(RAND_MAX);
        //        D=D+y/800.0; 
        //        D=D+(x*y)/160000.0; 
        if(bn*D>0.65) {
          // interior
        } else if(bn*D>0.5) {
          // edge
          //          buffer.data[(x+y*buffer.x)]=DRAW1_EDGE;
          buffer.data[(x+y*buffer.x)]=COL_START+((buffer.data[(x+y*buffer.x)]-COL_START)>>1);
        } else {
          // exterior
          buffer.data[(x+y*buffer.x)]=DRAW1_EXT;
        }
      }
    }
  }
  
  void Draw2(iBuffer &buffer, int bx[], int by[], int bn)
  {
    int x,y,b,dx,dy;
    float D,bds;
    const float R=100.0; // Radius of blob
      
    for(y=0;y<buffer.y;y++) {
      for(x=0;x<buffer.x;x++) {
        D=0;
        for(b=0;b<bn;b++) {
          dx=abs(bx[b]-x);
          dy=abs(by[b]-y);
          if(dx<maximum && dy<maximum) {
            bds=dist[dx+maximum*dy];
            if(bds<R*R) {
              D++;
              D-=((22/9)/(R*R))*bds;
              D+=((17/9)/(R*R*R*R))*bds*bds;
              D-=((4/9)/(R*R*R*R*R*R))*bds*bds*bds;
            }
          }
        }
        // Use this for a "fuzzy" edge
        //        D=D+(D*0.2*rand())/(RAND_MAX);
        //        D=D+y/800.0; 
        D=D+(x*y)/160000.0; 
        if(bn*D>0.65) {
          // interior
        } else if(bn*D>0.5) {
          // edge
          buffer.data[(x+y*buffer.x)]=DRAW2_EDGE;
        } else {
          // exterior
          buffer.data[(x+y*buffer.x)]=DRAW2_EXT;
        }
      }
    }
  }

private:
  static const int maximum;
  float *dist;
};

const int Blob::maximum = 256;

#endif 
