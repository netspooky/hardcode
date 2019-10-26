/*
 *  pwplib tty driver: dumb ascii output
 *
 */

#include "config.h"

#ifdef HAVE_TTYSTUFF

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "pwplib.h"
#include "tty.h"

struct
{
   char*newframe;
   char*newline_;
   int lgt_newline_;

   unsigned char*buf;

   int frame;
}
 pwp_tty_dumb;

void tty_dumb_dump_attr()
{
   u8 *s=pwplib.videobuf.d;
   unsigned char *d=pwp_tty_dumb.buf;
   int i=pwplib.videobuf.height,j;

#ifndef FUCK1
   d+=sprintf((char*)d,(char*)pwp_tty_dumb.newframe,pwp_tty_dumb.frame++);
#else
   sprintf((char*)d,(char*)pwp_tty_dumb.newframe,pwp_tty_dumb.frame++);
   d+=strlen(d);
#endif

   for(;i;i--)
   {
      for(j=pwplib.videobuf.width;j;j--)
      {
         *d++=*s;
         s+=2;
      }
      memcpy(d,pwp_tty_dumb.newline_,pwp_tty_dumb.lgt_newline_*sizeof(char));
      d+=pwp_tty_dumb.lgt_newline_;
   }

   fwrite(pwp_tty_dumb.buf,(d-pwp_tty_dumb.buf),sizeof(char),stdout);

   if(pwplib.set.framedelay)
   usleep(pwplib.set.framedelay*1000);
}

void tty_dumb_prep_attr()
{
   if(pwp_tty_dumb.buf!=NULL)
      free(pwp_tty_dumb.buf);

   pwp_tty_dumb.buf=malloc((
      (pwp_tty_dumb.lgt_newline_+pwplib.videobuf.width)*pwplib.videobuf.height
      )+strlen(pwp_tty_dumb.newframe));
}

int tty_dumb_init() /*int argc,char**argv) */
{
   pwplib.prep_attr=tty_dumb_prep_attr;
   pwplib.dump_attr=tty_dumb_dump_attr;

   pwp_tty_dumb.newframe="\22";
   pwp_tty_dumb.newline_="\n";

   /* ... get options */

   pwp_tty_dumb.lgt_newline_=strlen(pwp_tty_dumb.newline_);
   pwp_tty_dumb.frame=0;

   conv_init(8,3,2);

   return 1;
}


/*
   options to be included:

   newline_ "string"	set newline_ string
   newframe "string"	set newframe string
   optimize none	no optimization
   optimize blank	skip spaces at end of line  (default)
   optimize video	skip unchanged lines && non-changed areas at eol

*/

#endif
