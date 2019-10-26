/* Schtroumpf - the intro - (c) 2004 Gautier Portet < kassoulet @ no-log . org >
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 */

/*
 * This file contains a C implementation of the Scale2x effect.
 * coded by Gautier Portet <kassoulet (at) no-log.org>
 * 
 * You can find an high level description of the effect at :
 * http://scale2x.sourceforge.net/
 *
 * Taken from my GIMP ScaleX plugin
 */

#include "introsystem.h"

/*
 * read one pixel in the given bpp
 * the result will be a 32bits uint
 */
static Uint32 read_pixel(Uint8 * src, int x, int y, unsigned int width, unsigned int height,
	    unsigned int bpp)
{
  int i;
  Uint32 pixel = 0;

  x = CLAMP (x, 0, width - 1);
  y = CLAMP (y, 0, height - 1);

  for (i = 0; i < bpp; i++)
    {
      pixel += (src[(x + y * width) * bpp + i]) << (i * 8);
    }

  return pixel;
}

/*
 * read the pixel matrix
 */
static void read_pixels (Uint32 pixels[3][3], Uint8 * src, int x, int y, unsigned int width,
	     unsigned int height, unsigned int bpp)
{
  int i, j;

  for (j = 0; j < 3; j++)
    for (i = 0; i < 3; i++)
      pixels[i][j] =
	read_pixel (src, x + i - 1, y + j - 1, width, height, bpp);
}

/* 
 * write one pixel in the given bpp
 */
static void write_pixel (Uint8 * dst, Uint32 pixel, int x, int y, unsigned int width,
	     unsigned int height, unsigned int bpp)
{
  int i;

  for (i = 0; i < bpp; i++)
    {
      dst[(x + y * width) * bpp + i] = (pixel) >> (i * 8);
    }
}

/* 
 * write the pixel matrix
 */
static void write_pixels (Uint8 * dst, Uint32 pixels[2][2], int x, int y, unsigned int width,
	      unsigned int height, unsigned int bpp)
{
  int i, j;

  for (j = 0; j < 2; j++)
    for (i = 0; i < 2; i++)
      write_pixel (dst, pixels[i][j], 2 * x + i, 2 * y + j, width, height,
		   bpp);
}

/*
ABC
DEF
GHI

E0E1
E2E3
*/

#define A src[0][0]
#define B src[1][0]
#define C src[2][0]
#define D src[0][1]
#define E src[1][1]
#define F src[2][1]
#define G src[0][2]
#define H src[1][2]
#define I src[2][2]

#define E0 dst[0][0]
#define E1 dst[1][0]
#define E2 dst[0][1]
#define E3 dst[1][1]

/* 
 * dst_buffer: a place to write
 * src_buffer: where we read the scanline
 * width: lenght of the line
 * height: height of the image
 * bpp: Bytes Per Pixel
 */
void scale2x_internal (Uint8 * dst_buffer, Uint8 * src_buffer, unsigned int y,
	 unsigned int width, unsigned int height, unsigned int bpp)
{
  Uint32 src[3][3];		/* source matrix */
  Uint32 dst[2][2];		/* destination matrix */
  int x;

  for (x = 0; x < width; x++)
    {
      read_pixels (src, src_buffer, x, y, width, height, bpp);

      E0 = D == B && B != F && D != H ? D : E;
      E1 = B == F && B != D && F != H ? F : E;
      E2 = D == H && D != B && H != F ? D : E;
      E3 = H == F && D != H && B != F ? F : E;
	    
      write_pixels (dst_buffer, dst, x, y, width * 2, height * 2, bpp);
    }
}

Surface * Scale2x(Surface * src)
{
	Surface * dst;
	int y;
	dst = CreateSurface(src->width*2, src->height*2,4);
	for (y=0; y<src->height; y++) {
		scale2x_internal(dst->pixels,src->pixels, y, src->width, src->height, 4);
	}
	return dst;
}

Surface * Scale4x(Surface * src)
{
	Surface * tmp;
	Surface * dst;
	tmp = Scale2x(src);
	dst = Scale2x(tmp);
	FreeSurface(tmp);
	return dst;
}

Surface * Scale8x(Surface * src)
{
	Surface * tmp;
	Surface * dst;
	tmp = Scale4x(src);
	dst = Scale2x(tmp);
	FreeSurface(tmp);
	return dst;
}



