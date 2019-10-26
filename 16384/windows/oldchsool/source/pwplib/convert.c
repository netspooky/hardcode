#define __CONVERT_C

#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"
#include "convert.h"

extern void conv_dump_ibm();
extern void conv_dump_rast();

void conv_init(int colors,int chars,int rasters)
{
   int i=0;

   if(pwplib.setup[SETUP_COLORS]>=0)
      colors=pwplib.setup[SETUP_COLORS];

   if(pwplib.setup[SETUP_TRANS]>=0)
      chars=pwplib.setup[SETUP_TRANS];

   if(pwplib.setup[SETUP_RASTER]>=0)
      rasters=pwplib.setup[SETUP_RASTER];

   /*********************************************/

   if(rasters<0)rasters=0;
   if(colors<0)colors=0;
   if(chars<0)chars=0;

   for(;i<256;i++)
     pwpconv.font[i]=pwpconv.col[i]=i;
   convcalc_termsafe();

   /*********************************************/

   pwpwrite("* character conversion: ");

   if(chars&2)
   {
     pwpwrite("ascii");
     if(chars&1)pwpwrite(" (no invert)");
     convcalc_ascii(chars);
   }else
     pwpwrite("native ibm");

   /*********************************************/

   if(!(colors&~7))
   {
     char tmp[60];
     int fgcols=(colors&1)?8:16,bgcols=(colors&2)?8:16;
     sprintf(tmp,"; %i fg and %i bg colors\n",fgcols,bgcols);
     pwpwrite(tmp);
   }else
   {
     pwpwrite("; monochrome\n");
   }

   if(colors&8)
      convcalc_monotab(colors);
      else
      convcalc_colortab(colors);  /* 1==8colfg, 2==8colbg, 4==ansibits */


   /*********************************************/

   {int flags=8;
   convcalc_megatab_finish(flags);
   }
   /*
      inverse supported, 178/219 not in charset: |1  (vt100, xterm-mono)
      fullsize, no halfblocks                    |2  (xterm)
      no colors or no bgcolors                   |4  (all mono stuphos)
      bg&fg supported; no bg brightlite          |8  (8x16 textmodes)
   */


   /*********************************************/

   pwpwrite("* raster conversion: ");
   if(rasters==0)
   {
      pwpwrite("coloured ibm-style\n");
      convcalc_rast_ibmcol();
   }
   if(rasters==1)
   {
      pwpwrite("coloured\n");
      convcalc_rast_col();
   }
   if(rasters==2)
   {
      pwpwrite("monochrome\n");
      convcalc_rast_mono();
   }
   
   pwplib.dump_rast=conv_dump_rast;

   /*********************************************/

   convcalc_1to12();
   pwpconv.orig_dump_attr=pwplib.dump_attr;
   pwplib.dump_attr=conv_dump_ibm;
}
