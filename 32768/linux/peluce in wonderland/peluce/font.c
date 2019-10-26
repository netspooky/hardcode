#include "pwpdemo.h"
#include "font.h"

typedef struct
{
   int width,height;
   u8*pict;
   u8*mask;
}sprite;

u8*fontbuf_mask,
  *fontbuf_pict;
sprite fontbuf;

struct
{
   int zoomsince,
       zoomfrom,
       zoomstep,
       zoomto;
}texter;

void initfontbuf()
{
   fontbuf.width=80;
   fontbuf.height=25;
   fontbuf.mask=malloc(80*25*4*sizeof(u8));
   fontbuf.pict=malloc(80*25*4*sizeof(u8));
   memset(fontbuf.mask,0xff,80*25*4*sizeof(u8));
}

void setfontbuf(char*txt,int blend)
{
   int x=0,y=0;

   memset(fontbuf.pict,0,80*25*sizeof(u8));
   
   while(*txt)
   {
      if(*txt>='@')
      {
         int yy=0,xx;u8*s=pwpfont[*txt-'@'];
         for(;yy<5;yy++)
         for(xx=0;xx<7;xx++)
         {
            fontbuf.pict
              [(y+yy)*80+
               (x+xx)]=*s++&blend;
         }
         x+=8;
      }
      else
      {
         x=0;y+=6;
      }
      txt++;
   }
}

void textoff(int t)
{
   texter.zoomfrom=texter.zoomto=2048;
   texter.zoomstep=0;
}

void textshow(int t)
{
   int z=texter.zoomfrom+(t-texter.zoomsince)*texter.zoomstep;

   if(texter.zoomfrom<texter.zoomto)
   {
      if(z>texter.zoomto)z=texter.zoomto;
   }
    else
      if(z<texter.zoomto)z=texter.zoomto;

   if(z>=32 && z<=960)
   zoomsprite_gen(0,0,&fontbuf,z);
}

void justshowtext(char*txt,int col)
{
   texter.zoomsince=texter.zoomstep=0;
   texter.zoomto=texter.zoomfrom=80;
   setfontbuf(txt,col);
}

void textzoomin(int start,char*txt)
{
   setfontbuf(txt,0xff);

   texter.zoomsince=start;
   texter.zoomfrom=32;
   texter.zoomto=80;
   texter.zoomstep=4;
}

void textzoomout(int start)
{
   texter.zoomfrom=80;
   texter.zoomsince=start;
   texter.zoomstep=16;
   texter.zoomto=1024;
}
