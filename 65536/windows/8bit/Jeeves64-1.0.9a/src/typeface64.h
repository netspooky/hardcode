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

#ifndef _TYPEFACE64_H_
#define _TYPEFACE64_H_

#define _TYPEFACE64_p_ "typeface64"
#define _TYPEFACE64_v_ "0.4"

/*
  Out writes an asciiz string to coord (xpos, ypos), spacing is the 
  amount of pixels between characters and if the font is mono a pel 
  colour can be specified. please keep in mind that newline, tab and 
  similar characters are not currently supported. Also in this Jeeves64
  version 8bit buffers and multicoloured fonts haven been written (yet).
 
  UPDATE: Outp takes into account the width of characters. (yes, proportional fonts!).
  UPDATE: Outp now supports newline.
  UPDATE: Outc requires a count and ignores asciiz terminators.

  NOTE: currently there are 4 incarnations of Out, please update all of them
  when making changes.  --kuno <warp-tmt@dds.nl> 
*/
void
Out(char *font, iBuffer *b, int xpos, int ypos, const char* msg, int spacing = 1, peli col = 0)
{
  unsigned char x      = font[0];
  unsigned char y      = font[1];
  unsigned char count  = font[2];
  unsigned char mono   = font[3];
  unsigned char colour = font[4];
  unsigned char ascii  = font[5];
  //  unsigned char *width= (unsigned char *) font+6;
  unsigned char *data  = (unsigned char *) font+6+count;
  
  peli monocolour = (col==0) ? colour : col;
  //  peli monocolour = col;

  for(int rows=0; rows<y; rows++)
    for(int i=0; msg[i]!=0; i++)
      {
        int lptr = ((msg[i]-ascii)*x*y + (x*rows)) << 1;
        for(int column=0; column<x;)
          {
            if(mono)
              for(int run=0; run<data[lptr]; run++) 
                {
                  if(data[lptr+1]!=0)
                    b->data[(ypos+rows)*b->x+xpos+i*(x+spacing)+column] = monocolour;
                  column++;
                }
            else
              ERROR
            /*
              for(int run=0; run<data[lptr]; run++) 
              {
              if(data[lptr+1]!=0)
              b->data[(ypos+rows)*b->x+xpos+i*(x+spacing)+column] = p->Value(data[lptr+1]);
              column++;
              }
            */
            lptr+=2;
          }
      }
}

void
Outc(char *font, iBuffer *b, int xpos, int ypos, const char* msg, int msgcount, int spacing = 1, peli col = 0)
{
  unsigned char x      = font[0];
  unsigned char y      = font[1];
  unsigned char count  = font[2];
  unsigned char mono   = font[3];
  unsigned char colour = font[4];
  unsigned char ascii  = font[5];
  //  unsigned char *width= (unsigned char *) font+6;
  unsigned char *data  = (unsigned char *) font+6+count;
  
  //  pel monocolour = (col==0) ? p->Value(colour) : col;
  //  pel monocolour = col;
  peli monocolour = (col==0) ? colour : col;

  for(int rows=0; rows<y; rows++)
    for(int i=0; i<msgcount; i++)
      {
        int lptr = ((msg[i]-ascii)*x*y + (x*rows)) << 1;
        for(int column=0; column<x;)
          {
            if(mono)
              for(int run=0; run<data[lptr]; run++) 
                {
                  if(data[lptr+1]!=0)
                    b->data[(ypos+rows)*b->x+xpos+i*(x+spacing)+column] = monocolour;
                  column++;
                }
            else
              {
                for(int run=0; run<data[lptr]; run++) 
                  {
                    if(data[lptr+1]!=0)
                      b->data[(ypos+rows)*b->x+xpos+i*(x+spacing)+column] = data[lptr+1];
                    column++;
                  }
              }
            lptr+=2;
          }
      }
}

void
Outp(char* font, iBuffer *b, int xpos, int ypos, const char* msg, int spacing = 1, peli col = 0)
{
  unsigned char x      = font[0];
  unsigned char y      = font[1];
  unsigned char count  = font[2];
  unsigned char mono   = font[3];
  unsigned char colour = font[4];
  unsigned char ascii  = font[5];
  unsigned char *width = (unsigned char *) font+6;
  unsigned char *data  = (unsigned char *) font+6+count;
  
  //  pel monocolour = (col==0) ? p->Value(colour) : col;
  //  pel monocolour = col;
  peli monocolour = (col==0) ? colour : col;

  for(int rows=0; rows<y; rows++)
    {
      int tptr = (ypos+rows)*(b->x)+xpos;

      for(int i=0; msg[i]!=0; i++)
        {
          int charwidth = width[msg[i]-ascii];

          int lptr = ((msg[i]-ascii)*x*y + (x*rows)) << 1;
          tptr+=spacing;

          /* some characters need special treatment */

          // the width of space is incorrectly stored as zero (or some such) in my fonts.
          if(msg[i]==' ') 
            charwidth = charwidth>(width['M'-ascii] >> 1) ? charwidth : (width['M'-ascii] >> 1);

          // take care of newline.
          if(msg[i]=='\n') 
            tptr = (ypos+rows+y+spacing)*(b->x)+xpos;
          else
            for(int column=0; column<=charwidth;)
              {
                if(mono)
                  for(int run=0; (run<data[lptr]) && (column<=charwidth); run++) 
                    {
                      if(data[lptr+1]!=0)
                        b->data[tptr] = monocolour;
                      
                      column++;
                      tptr++;
                    }
                else
                  ERROR;
                
                //              for(int run=0; run<data[lptr]; run++) 
                //            {
                //              if(data[lptr+1]!=0)
                //                b->data[tptr] = p->Value(data[lptr+1]);
                //            column  ++;
                //            tptr++; 
                //          } 
                lptr+=2;
              }
        }
    }
}

void
Outp2x(char* font, iBuffer *b, int xpos, int ypos, const char* msg, int spacing = 1, peli col = 0)
{
  unsigned char x      = font[0];
  unsigned char y      = font[1];
  unsigned char count  = font[2];
  unsigned char mono   = font[3];
  unsigned char colour = font[4];
  unsigned char ascii  = font[5];
  unsigned char *width = (unsigned char *) font+6;
  unsigned char *data  = (unsigned char *) font+6+count;

  //  pel monocolour = (col==0) ? p->Value(colour) : col;
  //  pel monocolour = col;
  peli monocolour = (col==0) ? colour : col;

  for(int rows=0; rows<(y<<1); rows++)
    {
      int tptr = (ypos+rows)*(b->x)+xpos;

      for(int i=0; msg[i]!=0; i++)
        {
          int charwidth = (width[msg[i]-ascii]<<1)+1;

          int lptr = ((msg[i]-ascii)*x*y + (x*(rows>>1))) << 1;
          tptr+=spacing;

          /* some characters need special treatment */

          // the width of space is incorrectly stored as zero (or some such) in my fonts.
          if(msg[i]==' ') 
            charwidth = charwidth>(width['M'-ascii]) ? charwidth : (width['M'-ascii]);

          // take care of newline.
          if(msg[i]=='\n') 
            tptr = (ypos+rows+(y<<1)+spacing)*(b->x)+xpos;
          else
            for(int column=0; column<=charwidth;)
              {
                if(mono)
                  for(int run=0; (run<(data[lptr]<<1)) && (column<=charwidth); run++) 
                    {
                      if(data[lptr+1]!=0)
                        b->data[tptr] = monocolour;
                      
                      column++;
                      tptr++;
                    }
                else
                  ERROR;

                //            for(int run=0; run<data[lptr]; run++) 
                //            {
                //            if  (data[lptr+1]!=0)
                //              b->d  ata[tptr] = p->Value(data[lptr+1]);
                //            column++;   
                //            tptr++; 
                //          } 
                lptr+=2;
              }
        }
    }
}


void
Tile(char* font, iBuffer *b, int xpos, int ypos, const char* tiles, int tile_x, int tile_y)
{
  unsigned char height = font[1];

  for(int i=0; i<tile_y; i++)
    Outc(font, b, xpos, ypos+(i*height), tiles+(tile_x*i), tile_x, 0, 0);
}

void
Anim(char* font, iBuffer *b, int xpos, int ypos, const char* anim, int frame)
{
  unsigned char x = (font[0]>>1);
  unsigned char y = (font[1]>>1);

  if(frame<anim[0])
    Outc(font, b, xpos+(anim[3*frame+1]*x), ypos+(anim[3*frame+2]*y), &anim[3*frame+3], 1, 0, 0);
}

void
Blackout(char* font, iBuffer *b, int xpos, int ypos, const char* tiles, int frame, int tile_x, int tile_y)
{
  unsigned char width = font[0];
  unsigned char height = font[1];

  for(int i=0; i<tile_y; i++)
    for(int j=0; j<tile_x; j++)
      if(tiles[i*tile_x+j]>frame)
        {
          int y_start = ypos+(i*height);
          int x_start = xpos+(j*width);
          for(int y=y_start; y<y_start+height; y++)
            for(int x=x_start; x<x_start+width; x++)
              b->data[y*b->x+x] = 0x00;
        }
}

/* FIXME: needs to be revised. looks ugly now. and not flexible enough. */
/*
void
Blackout(char* font, Buffer *b, int xpos, int ypos, int tile_x, int tile_y, int start, int end)
{
  unsigned char width  = font[0];
  unsigned char height = font[1];

  int count = 0;
  for(int y=0; y<tile_y; y++)
    for(int x=0; x<tile_x; x++)
      {
        if((count>=start) && (count<=end))
          for(int y2=0; y2<height; y2++)
            memset(b->data + (ypos+y2+y*height)*b->x + xpos+(x*width), 0, width*sizeof(pel));
        count++;
      }
}
*/

#endif // _TYPEFACE64_H_
