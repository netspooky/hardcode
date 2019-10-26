/*
 *  PWPlib: PWP Video Phormat
 *
 *  not very functional yet :)
 *
 */

#include "config.h"

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "pwplib.h"

void pvp_calcframe(u8*s,int lgtnew,int flags)
{

   static int lgt=0;
   static u8*prev=NULL;

   u8 buf[lgtnew*2],*d=buf;

   int accum=0;

   if(lgtnew!=lgt)
   {
      if(prev!=NULL)free(prev);
      lgt=lgtnew;
      prev=malloc(lgt*sizeof(u8));
      flags|=1;
   }

   if(flags&1)memset(s,0,lgt*sizeof(u8)); /* support other consts as well? */

   {int i=0,skip=0;
   for(;i<lgt;i++)
   {
      if(s[i]!=prev[i])
      {
         while(skip>0)
         {
            if(skip<128){*d++=128|((skip-1)&127);skip=0;}
                   else {*d++=128|127;skip-=128;}
         }

         {u8*cntp=d;
          int gap=0;

          while(gap<2 && i<lgt && (d-cntp<126))
          {
             d++;
             *d=s[i];

             if(s[i]==prev[i])gap++;
                         else gap=0;
             i++;
          }
          d[1]=s[i];
          d[2]=s[i+1];
          d+=2-gap;skip+=gap-1;i--;
          *cntp=(d-cntp-1)&127;
         }
      }
       else skip++;
   }}
   memcpy(prev,s,sizeof(u8)*lgt);

   /* header */
   
   {u8 head[6];
    head[0]='p';head[1]='V';head[2]='P';
    if(flags&1)head[3]='R';else head[3]='r';
    head[4]=(d-buf)&255;
    head[5]=(d-buf)>>8;
    write(1,head,6);
   }

   write(1,buf,d-buf);
}



/*
   pvp (pwp video phormat) stream:

   for each frame:
     'pVP'   signature (used by synch routines etc)
     u8      frame type
     u16     frame length, in bytes

   r-frame (lossless rasterdata)

     stored: changes to the previous display frame, rle+huffman compression?

     time delta to the previous frame (in second/256's)

     index=0;

       command
         - 1xxxxxxx  skip 0..127 bytes
         - 0xxxxxxx  0..127 bytes of data follow

   R-frame (lossless raster keyframe)

     stored as delta to a constant (zero) table

   i/I-frames == like r/R but for ibm char/attribute-pair screendump

   we need some kind of compression for the lossless frames.

   we also need a low-bandwidth lossy compression for longer movies and
   tv streams.

   g-frame (gsm audio in 8kHz)  for moviez

   b-frame (beep audio)  
     (B-frame == update everything?  write a B-frame when every channel
      changes or when above given threshold)

     length of output (in second/256's)
     chan# (8bit), freq(16bit), vol(8bit), pulsestat(8bit)

   c-frame (commentary)

     first byte==importance level (signed byte, 0==for names, copyrights etc)
     rest==ascii string

     may also contain things like stupid irclog, subtitles, textual
     descriptions of the video etc

*/

void pvp_sound(int ch,int note,int vol)
{
   
}

void pvp_loopflush()
{
/*
   timer_counter();
   pwplib.player();

   save b-frames
*/
}

void pvp_dump_rast()
{
  if(pwplib.setup[SETUP_LOSSY])
  conv_losestuff(pwplib.videobuf.d,
    pwplib.videobuf.height*pwplib.videobuf.width,1);

   pvp_calcframe(pwplib.videobuf.d,
     pwplib.videobuf.width*pwplib.videobuf.height,0);
}

void pvp_dump_ibm()
{
   pvp_calcframe(pwplib.videobuf.d,
     pwplib.videobuf.width*pwplib.videobuf.height*2,0);
}

void pvp_init()
{
   pwplib.videobuf.height=50;
   pwplib.videobuf.width=80;
   
   pwplib.dump_ibm=&pvp_dump_ibm;
   pwplib.dump_rast=&pvp_dump_rast;
   pwplib.sound=&pvp_sound;
   pwplib.loopflush=&pvp_loopflush;
}
