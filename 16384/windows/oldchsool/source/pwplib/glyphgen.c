/*
 *  PWPlib: glyph generator ('font fixer')
 *
 */

#ifdef DRIVE_UNIX

#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"

#include "tty.h"
#include "convert.h"

/*****************/

struct
{
   int w,h;
}
pwp_glyphgen;

   const char rastmatrix[8*4*4]=
   "    " "    " "    " "    "
   "x   " "    " "  x " "    "
   " x  " "    " " x x" "    "
   "x x " "    " " x x" "    "
   "x x " " x x" "x x " " x x"
   "x x " "xxxx" "x x " "xxxx"
   "xx x" "xxxx" " xxx" "xxxx"
   "xxxx" "xxxx" "xxxx" "xxxx";

/*
   #define MKB(a,b,c,d,e,f,g,h) \
     ((a<<7)|(b<<6)|(c<<5)|(d<<4)|(e<<3)|(f<<2)|(g<<1)|h)

   char rastmatrix[4*4]=
   {
     MKB(1,1,1,1,1,0,1,0),
     MKB(1,1,0,0,0,1,0,0),
     MKB(1,0,1,1,1,0,0,0),
     MKB(1,1,0,0,0,0,0,0),

     MKB(1,1,1,0,0,0,0,0),
     MKB(1,1,1,1,0,0,0,0),
     MKB(1,1,1,0,0,0,0,0),
     MKB(1,1,1,1,0,0,0,0),
   
     MKB(1,0,1,1,0,0,0,0),
     MKB(1,1,0,0,1,1,0,0),
     MKB(1,1,1,1,0,0,1,0),
     MKB(1,1,0,0,1,1,0,0),
   
     MKB(1,1,1,0,0,0,0,0),
     MKB(1,1,1,1,0,0,0,0),
     MKB(1,1,1,0,0,0,0,0),
     MKB(1,1,1,1,0,0,0,0)
   };
   
   #undef MKB
*/


char* glyphgen_raster(char*o,int ul,int ur,int dl,int dr)
{
   int x,y;

   for(y=0;y<pwp_glyphgen.h;y++)
   for(x=0;x<pwp_glyphgen.w;x++)
   {
      int lev=(y<=(pwp_glyphgen.h>>1)?
                  (x<=(pwp_glyphgen.w>>1)?ul:ur):
                  (x<=(pwp_glyphgen.w>>1)?dl:dr));

      /* another possiblity: interpolated rasters? */

      *o++=rastmatrix[16*lev+4*(y&3)+(x&3)]>32?1:0;

      /* (rastmatrix[4*(y&3)+(x&3)]>>lev)&1 */
   }

   return o;
}

char* glyphgen_64rast(char*o,int width,int height)
{
   int u,d;

   pwp_glyphgen.w=width;
   pwp_glyphgen.h=height;

   for(u=0;u<8;u++)
   for(d=u?0:1;d<8;d++)
      o=glyphgen_raster(o,u,u,d,d);

   return o;
}
/* 96rast (94rast?) will be more clever, designed for 2x2 resolution */

void glyphgen_fixtoibm(char*o,int width,int height)
{
   int c=width*height;
   
   pwp_glyphgen.w=width;
   pwp_glyphgen.h=height;

   o=glyphgen_raster(o+c*176,
                       2,2,2,2);
   o=glyphgen_raster(o,4,4,4,4);
     glyphgen_raster(o,6,6,6,6);

   o=glyphgen_raster(o+c*(219-178),
                       7,7,7,7);
   o=glyphgen_raster(o,0,0,7,7);
   o=glyphgen_raster(o,7,0,7,0);
   o=glyphgen_raster(o,0,7,0,7);
   
     glyphgen_raster(o,7,7,0,0);
}

/* fixtopwp: has 96rast set + enhancements for text art
             (ripoffs from petscii etc)
             ?

   linuxcon: loadpwpfont - loads a 8x8 (8x7?) font
*/

#endif