#include "config.h"

#ifdef DRIVE_LINUXCON

#include <sys/stat.h>
#include <sys/ioctl.h>
#include <linux/kd.h>

#include "pwplib.h"

#include "tty.h"

/******************** vcsa code ********************/

struct{
   int fd;
   int width,height;

   int fontw,fonth;
   u8*fontd;
   char*fontd_tab;
   
   /* add cfd (control fd) or something */
}pwp_linuxcon;

void vcsa_dump_attr()
{
   char*buf=pwplib.videobuf.d;
   int ptr=4+pwp_linuxcon.width*
           ((pwp_linuxcon.height-pwplib.videobuf.height)&~1);
   if(ptr<4)ptr=4;

   if(pwp_linuxcon.width==pwplib.videobuf.width)
   {
      lseek(pwp_linuxcon.fd,ptr,SEEK_SET);
      write(pwp_linuxcon.fd,buf,
            pwplib.videobuf.width*pwplib.videobuf.height*2);
   }else
   {
      int y=0,y1=pwplib.videobuf.height,w=pwplib.videobuf.width;
      ptr+=((pwp_linuxcon.width-pwplib.videobuf.width)&~1);
      if(y1>pwp_linuxcon.height)y1=pwp_linuxcon.height;
      if(w>pwp_linuxcon.width)w=pwp_linuxcon.width;
      w<<=1;
      for(;y<y1;y++)
      {
         lseek(pwp_linuxcon.fd,ptr,SEEK_SET);
         write(pwp_linuxcon.fd,buf,w);
         buf+=pwplib.videobuf.width*2;
         ptr+=pwp_linuxcon.width*2;
      }
   }

   pwplib.timer_counter+=pwp_linuxcon.width*pwp_linuxcon.height*2;
}

int vcsa_get()
{
   int vcsa;
   int majmin;

   { struct stat sbuf;
     int stderr2=dup(fileno(stderr));
     fstat(stderr2,&sbuf);
     majmin=sbuf.st_rdev;
     close(stderr2);
   }

   if((majmin&~0x63)==4*256)
   {
      char buf[20];
      sprintf(buf,"/dev/vcsa%i",majmin&63);
      vcsa=open(buf,O_RDWR);
      if(vcsa>=0)return vcsa;
   }
   vcsa=open("/dev/vcsa",O_RDWR);
   if(vcsa>=0)return vcsa;

   return -1;
}

int vcsa_init() /* init vcsa device */
{
   unsigned char vcsahdr[4];
   int vcsa=vcsa_get();
   if(vcsa<0)return 0;

   read(vcsa,vcsahdr,4);
   pwp_linuxcon.fd=vcsa;
   pwplib.videobuf.height=pwp_linuxcon.height=vcsahdr[0];
   pwplib.videobuf.width=pwp_linuxcon.width=vcsahdr[1];

   pwpwrite("* using vcsa device\n");

   pwplib.dump_attr=vcsa_dump_attr;
   return 1;
}


/********************************************************/

/*** some people are lazy to update their headers ... ***/

#ifndef KDFONTOP
#define KDFONTOP        0x4B72

struct console_font_op {
        unsigned int op;
        unsigned int flags;
        unsigned int width, height;
        unsigned int charcount;
        unsigned char *data;
};

#define KD_FONT_OP_SET          0
#define KD_FONT_OP_GET          1
#define KD_FONT_OP_SET_DEFAULT  2
#define KD_FONT_OP_COPY         3

#define KD_FONT_FLAG_DONT_RECALC        1
#endif

/********************************************/

enum
{
   GLY_CRAP=0,
   GLY_BLANK,
   GLY_FULL,
   GLY_TOP,
   GLY_BOTTOM,
   GLY_LEFT,
   GLY_RIGHT,
};

int tty_linux_setfont(char*fontd,int w,int h)
{
   struct console_font_op fontop;
   fontop.op=KD_FONT_OP_SET;
   fontop.flags=0;
   fontop.data=fontd;
   fontop.charcount=256;
   fontop.width=w;
   fontop.height=h;

   return ioctl(2,KDFONTOP,&fontop);
}

int tty_linux_setfont_tab()
{
   char*font=malloc(pwp_linuxcon.fontw*32*sizeof(char));
   char*f=font,
       *s=pwp_linuxcon.fontd_tab;

    int i,x,y;

    for(i=0;i<256;i++)
      for(y=0;y<32;y++)
      {
         int b=0,x1=(pwp_linuxcon.fontw+7)&~7;
         for(x=0;x<x1;x++)
         {
            int pix;

            if(y<pwp_linuxcon.fonth &&
               x<pwp_linuxcon.fontw)
               pix=*s++?1:0;else pix=0;
               
            b<<=1;
            b|=pix;

            if((x&7)==7)
            {
               *f++=b;
               b=0;
            }
         }
      }

   return tty_linux_setfont(font,pwp_linuxcon.fontw,pwp_linuxcon.fonth);
}

void tty_linux_restorefont()
{
   tty_linux_setfont(
     pwp_linuxcon.fontd,
     pwp_linuxcon.fontw,
     pwp_linuxcon.fonth);
}

int tty_linux_fixfont()
{
#if 0
   char newfont[pwp_linuxcon.fontw*
                pwp_linuxcon.fonth*sizeof(char)];

   glyphgen_fixtoibm(
      pwp_linuxcon.fontd_tab,
      pwp_linuxcon.fontw,
      pwp_linuxcon.fonth);

   return tty_linux_setfont_tab();
#endif

   return 0;
}

/**********************************/

int tty_linux_analyzefont()
{
   u8 analysis[256];

   u8*s=pwp_linuxcon.fontd;
   char*d=pwp_linuxcon.fontd_tab;
   int c=0;

/*   fprintf(stderr,"font analysis?\n");*/

   for(;c<256;c++)
   {
      int x0=33,x1=-1,y0=33,y1=-1,x,y;
      int dens=0;
      
      for(y=0;y<32;y++)
      {
         int byte;
         for(x=0;x<pwp_linuxcon.fontw;x++)
         {
            if(!(x&7))byte=*s++;

/*            if(y<pwp_linuxcon.fonth)*d++=byte&128;*/

            if(byte&128)
            {
               if(x<x0)x0=x;
               if(x>x1)x1=x+1;
               if(y<y0)y0=y;
               if(y>y1)y1=y+1;
               dens++;
            }
            byte<<=1;
         }
      }

      {int a=GLY_CRAP;
       int w=(x1-x0),h=(y1-y0);

       if(h<=0)a=GLY_BLANK; 
       else
       {
          if(w>=pwp_linuxcon.fontw-1)
          {
             if(h>=pwp_linuxcon.fontw-1)a=GLY_FULL;
             else
             if(y1>=pwp_linuxcon.fontw-2)a=GLY_BOTTOM;
             else
             if(!y0)a=GLY_TOP;
          }
           else
          if(h>=pwp_linuxcon.fonth-1)
          {
             if(x1>=pwp_linuxcon.fonth-2)a=GLY_RIGHT;
             else
             if(!x0)a=GLY_LEFT;
          }
       }
       analysis[c]=a;
/*       if(a)fprintf(stderr,"char %d: %d\n",c,a);*/
      }
     }
   
   if(analysis[176]==GLY_FULL &&
      analysis[177]==GLY_FULL &&
      analysis[178]==GLY_FULL &&
      analysis[219]==GLY_FULL &&
      analysis[220]==GLY_BOTTOM &&
      analysis[223]==GLY_TOP) return 2;

/*   fprintf(stderr,"done\n");*/

   return 1;
}

int tty_linux_getfont()
{
   {
      struct console_font_op fontop;
      fontop.op=KD_FONT_OP_GET;
      fontop.flags=0;
      fontop.data=NULL;
      fontop.charcount=0;

      /* if handle 2 doesn't work, try handles 1 and 0?
         also with vcsa */

      /* use this bitreverter somewhere (X11-1bpp code?) not here.
         replaces lookups in fast machines.

 	a=((a&0xf0f0f0f0)>>4)|((a&0x0f0f0f0f)<<4);
 	a=((a&0xcccccccc)>>2)|((a&0x33333333)<<2);
 	a=((a&0xaaaaaaaa)>>1)|((a&0x55555555)<<1);
      */

      ioctl(2,KDFONTOP,&fontop);
      if(fontop.charcount)
      {
         pwp_linuxcon.fontw=fontop.width;
         pwp_linuxcon.fonth=fontop.height;

         if(!fontop.data)
         {
            fontop.data=malloc(((pwp_linuxcon.fontw+7)>>3)*32*
                                fontop.charcount*sizeof(u8));
            fontop.op=KD_FONT_OP_GET;
            fontop.flags=KD_FONT_FLAG_DONT_RECALC;
            if(ioctl(2,KDFONTOP,&fontop)<0)
               goto oldcall;
         }

         pwp_linuxcon.fontd=fontop.data;
         goto gotfont;
      }
   }

   oldcall:
   {
      struct consolefontdesc fontx;
      fontx.chardata=malloc(512*32*sizeof(u8));

      if(ioctl(2,GIO_FONTX,&fontx)<0)return 0;

      pwp_linuxcon.fontw=8;
      pwp_linuxcon.fonth=fontx.charheight;
      pwp_linuxcon.fontd=fontx.chardata;
   }

   gotfont:
   
   pwp_linuxcon.fontd_tab=
       malloc(pwp_linuxcon.fontw*pwp_linuxcon.fonth*sizeof(char));
   
   return tty_linux_analyzefont();
}

/********************************************************/

extern void tty_ansicol_dump_attr();
extern void tty_ansicol_prep_attr();

int tty_linux_initstring()
{
   write(pwp_tty.fd,"\33[11m",5*sizeof(char)); /* select ibmpc charset */
   tty_vt_initstring();
}

int tty_linux_init()
{
   if(!vcsa_init())
   {
      pwplib.dump_attr=tty_ansicol_dump_attr;
      pwplib.prep_attr=tty_ansicol_prep_attr;
      pwpwrite("* no vcsa access - using tty\n");
      /* send init */
   }

   {int i=tty_linux_getfont();

    pwpwrite("* font analysis: ");
    
    if(i==0)pwpwrite("can't access - assuming ibm\n");else
    if(i==1)pwpwrite("no ibm rasters - using ascii\n");else
    if(i==2)pwpwrite("ibm rasters found - using ibm\n");

    if(i==0 || i==2) conv_init(2,0,0);
                else conv_init(2,2,1);
   }

   tty_linux_initstring();
}

#endif

/*
    additional stuff:

      - font customization:
        - save font
        - if evil: if font bigger than 8x8, change to 8x8
        - include rasterchars (64 chars as in vt220 driver)
        ...
        - restore old font
*/
