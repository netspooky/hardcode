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

#ifndef _TRANSITION_H_
#define _TRANSITION_H_

/*
  Hi!

 [transitions]

  This file contains transition effects. These transitions take
  the following parameters:

      void transition(Buffer &b, Buffer &s, unsigned char t);

  s should contain the `to'   effect buffer.
  b should contain the `from' effect buffer.
  t designates the how far the transition has progressed,
    e.g. 0x00 leaves the `from' buffer unaltered and 
    0xFF copies the complete `to' buffer to the from buffer.

  some transitions don't require a source buffer, and some
  transitions take some more options.
   
 */

/*

[    ] tr_h_random       / tr_v_random 
[DONE] tr_h_cheapstretch / tr_v_cheapstretch
[    ] tr_h_stuiter      / tr_v_stuiter

//    I see your pretty face smashed against the bathroom floor.
 */

void
tr_h_cheapstretch(iBuffer &b, unsigned char t)
{
  // this probably can be optimized a lot.
  int start = (t>b.x) ? b.x : t;

  for(int x=start; x>0; x--)
    for(int y=0; y<b.y; y++)
      b.data[y*b.x+x] = b.data[y*b.x+start];
}

void
tr_v_cheapstretch(iBuffer &b, unsigned char t)
{
  // this probably can be optimized a lot.
  int start = (t>b.y) ? b.y : t;

  for(int y=(b.y-start-1); y<(b.y-1); y++)
    {
      //      memcpy(b.data + (b.y-start)*b.x, b.data + y*b.x, b.x*sizeof(pel));
      memcpy(b.data + y*b.x, b.data + (b.y-start)*b.x, b.x*sizeof(peli));
    }
}


void
tr_circle(iBuffer &b, iBuffer &s, unsigned char t, int x_center, int y_center, 
          int border = 0, int border_colour = 0x00)
{
  int * left  = (int *) malloc(b.y*sizeof(int));
  int * right = (int *) malloc(b.y*sizeof(int));

  // FIXME: this should be made more accurate for framerates higher than 0x40 fps.
  int r = (b.x>b.y ? b.x : b.y) * t / 0x100;
  int y_counter;

  //  printf("|%x", t);

  for(y_counter=0; y_counter<y_center; y_counter++)
    {
      int y = y_center - y_counter;
      if(y>r)
        left[y_counter] = -1;
      else
        {
          int x = (int)sqrt( -(y*y)+(r*r) );
          left [y_counter] = (x_center - x)<0   ? 0   : (x_center - x);  // r*r = x*x+y*y;
          right[y_counter] = (x_center + x)>b.x ? b.x : (x_center + x);
        }
    }

  for(y_counter=y_center; y_counter<b.y; y_counter++)
    {
      int y = y_counter - y_center;
      if(y>r)
        left[y_counter] = -1;
      else
        {
          int x = (int)sqrt( -(y*y)+(r*r) );
          left [y_counter] = (x_center - x)<0   ? 0   : (x_center - x);  // r*r = x*x+y*y;
          right[y_counter] = (x_center + x)>b.x ? b.x : (x_center + x);
        }
    }

  if(!border)  // no border, that's easy.
    {
      for(y_counter=0; y_counter<b.y; y_counter++)
        if(left[y_counter] != -1)
          for(int x=left[y_counter]; x<right[y_counter]; x++)
            b.data[y_counter*b.x+x] = s.data[y_counter*b.x+x];
    }
  else
    {
      /* for a decent border the circle needs to be recalculated anyway, so
         we'll draw a black circle, and do a recursive call to draw its innards.
         FIXME: obviously this desperately needs optimizing :)
      */
      for(y_counter=0; y_counter<b.y; y_counter++)
        if(left[y_counter] != -1)
          for(int x=left[y_counter]; x<right[y_counter]; x++)
            b.data[y_counter*b.x+x] = border_colour;

      int t_border = 0x100 * border / (b.x>b.y ? b.x : b.y);
      if(t>t_border)
        tr_circle(b, s, t-t_border, x_center, y_center);
    }

  free(left);
  free(right);
}

/* FIXME: tr_h_random doesn't work. needs complete rewrite :) */
/*

int
countbits(int c)
{
  int r = 0;

  for(unsigned int i=0; i<(sizeof(int)*8); i++)
    r += (c>>i) & 1;
    
  return r;
}



void 
tr_h_random(Buffer &b, Buffer &s, unsigned char t)
{
#ifdef ASSERT            // I won't even try to reach the Quality Plateau (tm) in a 64k :)
  if((b.x != s.x) ||
     (b.y != s.y) ||
     (b.box_x != 0) ||
     (b.box_y != 0) ||
     (b.box_w != 0) ||
     (b.box_h != 0) ||
     (s.box_x != 0) ||
     (s.box_y != 0) ||
     (s.box_w != 0) ||
     (s.box_h != 0)) ERROR
#endif

  int y;
  int r = 0;

  for(y=0; y<b.y; y++)
    {
      if(!r) 
        {
          r = rand();
          while(countbits(r)<countbits(t)) r |= rand();
          while(countbits(r)>countbits(t)) r &= rand();
        }
      if(r&1) memcpy(b.data + y*b.x, s.data + y*b.x, b.x*sizeof(pel));
      r>>=1;
    }  
}
*/

#endif // _TRANSITION_H_
