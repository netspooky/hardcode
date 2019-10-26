/*
 *  PlayPVP - a player for PWP Video Phormat
 *
 *  The format is still in a very early stage of development.
 *  Ask viznut for test videos (mpegs converted to pvp)
 *
 *  Separate pwplib => separate player
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "pwplib/pwplib.h"

struct
{
   int fd;
   u8 buf[50*80+128]; /* should be dynamic */
}playpvp;

void playpvp_rasterframe(char*d,int lgt)
{
   int ptr=0;
   while(lgt>0)
   {
      if(*d&128)
      {
         ptr+=(*d&127)+1;
         d++;lgt--;
      }
       else
      {
         int i=(*d++);
         lgt-=(i+1);
         for(;i;i--)
            playpvp.buf[ptr++]=*d++;
      }
      if(ptr>80*50)return;
   }
   return;
}

int playpvp_frame()
{
   u8 header[6],*data;
   int lgt;
   
   if(read(0,header,6)<0)return 0;

   if(header[0]!='p' || header[1]!='V' || header[2]!='P')
   {
      fprintf(stderr,"not adjusted to frame! should skip bytes\n");
   }

   /* header[0..2] should be "pVP". if not, skip bytes */

   lgt=header[4]+(header[5]<<8);

   if(!lgt)return;

   data=malloc(lgt);
   read(0,data,lgt);

   switch((int)header[3])
   {
      case('R'):
         memset(playpvp.buf,0,50*80*sizeof(u8));
      case('r'):
         playpvp_rasterframe(data,lgt);
         break;
      default:
         fprintf(stderr,"unknown frametype 0x%x\n",header[3]);
         break;
   }
   free(data);
   return 1;
}

void playpvp_run()
{
   int nextframe=0;

   pwpwrite("playing pvp stream from stdin\n");
   
   pwplib_startup();

    /* should get these from settings */

   pwplib.videobuf.width=80;
   pwplib.videobuf.height=50;
   pwplib.videobuf.d=playpvp.buf;

   for(;;)
   {int thisframe=pwplib_timer();
    
    if(thisframe>=nextframe)
    {
       playpvp_frame();
       nextframe+=5;    /* get framerate from settings */
    }
     else
       pwplib.dump_rast();
   }
   
   pwplib_end();
}

int main(int argc,char**argv)
{
   if(!pwplib_init(&argc,argv))return 1;
   playpvp_run();
   
   return 0;
}
