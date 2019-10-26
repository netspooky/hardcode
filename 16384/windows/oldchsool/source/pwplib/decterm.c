/*
 *  PWPlib: VTxxx support, including VT220/320 charset customization
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"

#ifdef DRIVE_UNIX
#ifdef DRIVE_TTY_DEC

#include "tty.h"
#include "convert.h"

#define DECIMAL(x) \
{int n=(x); if(n>=100){*d++='0'+(n/100);n%=100; \
            *d++='0'+(n/10);} \
 else \
 if(n>=10)*d++='0'+(n/10); \
 *d++='0'+(n%10);}

/******************** vt2xx raster glyphs *************************/

/* move somewhere else */
void tty_putch(int ch)
{
   char c=ch;
   write(pwp_tty.fd,&c,sizeof(char));
}

#ifdef DRIVE_TTY_VT2XX
void vt2xx_loadglyphs(char*src,int width,int height,int howmany)
{
   if(pwp_tty.minor<300)
      tty_write("\33P0;1;2{P",-1);
      else
      tty_write("\33P0;1;2;0;0;2{P",-1);

   for(;howmany;howmany--)
   {
      int x,y,i;
      for(y=0;y<height;y+=6)
      {
        if(y)tty_putch('/');
        for(x=0;x<width;x++)
        {
           int sixel=0;
           for(i=0;i<6;i++)
              if(src[(i+y)*width+x])sixel|=(1<<i);
           tty_putch('?'+sixel);
        }
      }
      tty_putch(';');
      src+=width*height;
   }
   tty_write("\33\\",-1);
}

/*
int vt2xx_genchars(char*o,int width,int height)
{
   int u,d,x,y;

   for(u=0;u<8;u++)
   for(d=0;d<8;d++)
   {
      if(u|d)
      for(y=0;y<height;y++)
      for(x=0;x<width;x++)
         *o++=
         rastmatrix[16*(y<=(height>>1)?u:d)+4*(y&3)+(x&3)];
   }
}
*/
#endif

void tty_vt_prep_attr_40()
{
   int y=0;
   tty_write("\33[2J\33[H",-1);
   for(;y<24;y++)
   {
      if(y)tty_putch('\n');
      tty_write("\33#6",3);
   }
}

#ifdef DRIVE_TTY_VT2XX
/*
int vt2xx_convcalc()
{
   const char intens[16]=
   {
       0,1,6,7, 3,4,9,10,
       1,2,9,10,5,6,13,15
   };

   int up,dn;
   for(dn=0;dn<256;dn++)
   for(up=0;up<256;up++)
   {
      int dins=(intens[dn&15]+intens[(dn>>4)&15]*3);
      int uins=(intens[up&15]+intens[(up>>4)&15]*3);

      if(dins<7 && uins<7 && (dins|uins))
      {
         if(uins>dins)uins=7;else dins=7;
      }

      dins/=7;
      uins/=7;

      if(dins>7)dins=7;
      if(uins>7)uins=7;

      pwpconv.rasthalve[BYTES2(up,dn)]=
              BYTES2(32+(dins|(uins<<3)),0x10);
   }
}
*/
#endif

/**********************************************/

/*
   &1: inverse
   &8: bright
   &16: charset: P vs B
*/

int tty_vt_dump(char*s,char*p,int x,int y)
{
  TEMPMALL(u8,tmp,pwplib.videobuf.width*pwplib.videobuf.height*16),
  *d=tmp,skip=0,skipy=0;

  skipy=1;

  if(pwplib.frame&1)
  {
     p+=pwplib.videobuf.width*2;
     s+=pwplib.videobuf.width*2;
  }

  {int i=pwplib.frame&1;
   for(;i<y;i+=2)
   {int j=0;

   for(;j<x;j++)
   {
     if( (s[0]!=p[0]) || (s[1]!=p[1]) )
     {
       int attch=s[1]^pwp_tty.att;
       if(attch)
       {
         int a=s[1];
         d[0]=27;d[1]='[';d+=2;
         if(attch&0x0f)
         {
           d[0]=27;
           d[1]='[';
           d+=2;
           
           if(!(a&0xf))*d++='0';
           else
           {
              int semic=0;
              d+=2;
              if(attch&8)
              {
                 if(a&8)*d++='2';
                 *d++='1';
                 semic++;
              }
              if(attch&1)
              {
                 if(semic)*d++=';';
                 if(a&1)*d++='2';
                 *d++='7';
                 semic++;
              }
           }
           *d++='m';
         }
         if(attch&0xf0)
         {
           d[0]=27;
           d[1]='(';
           d[2]=(a&0x10)?'P':'B';
           d+=3;
         }
         pwp_tty.att=a;
       }

       if(skip||skipy)
       {
         if(!skipy)
         {
           int realskip=1;
           if(skip<4)
           {
              int i=0;
              realskip=0;
              for(;i<skip;i++)
                 if(s[-2*skip+2*i+1]!=pwp_tty.att)
                    {realskip++;break;}
           }
           if(realskip)
           {
             d[0]=27;d[1]='[';d+=2;
             if(skip>1)DECIMAL(skip);
             *d++='C';
           }
            else
           {
             int i=0;
             for(;i<skip;i++)
                *d++=s[-2*skip+2*i];
           }
         }
         
         else
         {
           d[0]=27;d[1]='[';d+=2;
           DECIMAL(i+1);
           *d++=';';
           DECIMAL(j+1);
           *d++='H';
         }
         skip=skipy=0;
       }

       *d++=s[0];
     }else skip++;
     s+=2;p+=2;
   }skipy++;

       memcpy(p-pwplib.videobuf.width*2,
              s-pwplib.videobuf.width*2,
              pwplib.videobuf.width*2*sizeof(u8));

       p+=pwplib.videobuf.width*2;
       s+=pwplib.videobuf.width*2;
   }
  }
  
  /* ^^^ joo: pistä tuo luuppi omaan mökeltimeensä. yhdistä vt- ja
     ansi-kamikset. */

  memcpy(d,"\33[0m",4*sizeof(char)); /* nuo framen alkuun */
  pwp_tty.att=0;d+=4;

  tty_write(tmp,d-tmp);
  TEMPFREE(tmp);
  return d-tmp;
}

/* combine this with corresponding ansicon stuff */
void tty_vt_dump_attr()
{
   int lgt=
   tty_vt_dump
      (pwplib.videobuf.d,pwp_tty.prevbuf,
       pwplib.videobuf.width,
       pwplib.videobuf.height);

   pwplib.frame++;

   if(lgt<pwplib.set.framebytes)
   {
      lgt+=tty_vt_dump
         (pwplib.videobuf.d,pwp_tty.prevbuf,
          pwplib.videobuf.width,
          pwplib.videobuf.height);
      pwplib.frame++;
   }

   if(lgt<pwplib.set.framebytes)
   if(pwplib.setup[SETUP_BPS])
   {
     int howmany=pwplib.setup[SETUP_BPS]/(72*2*3);
     for(;howmany;howmany--)
     {
       tty_write("\33[H",3);
     }
   }

   if(pwplib.set.framedelay)
   usleep(pwplib.set.framedelay*1000);
}

/*** generic initstrings for vt100+/compatibles ****/

void tty_vt_restore()
{
   if(pwp_tty.type==TTY_VT2XX)tty_write("\33(B",3); /* restore charset */
   tty_write(
      "\33[0m"        /* attributes off */
      "\33[?25h",     /* cursor on */
      -1);
}

void tty_vt_initstring()
{
   pwp_regdestr(tty_vt_restore);

   tty_write(
      "\33[0;37;40m"  /* attributes off, assert colors */
      "\33[?3l"       /* 80-column mode */
      "\33[?5l"       /* bright on dark */
      "\33[?25l"      /* cursor off */
      "\33[2J"        /* clear screen */
      "\33[H",        /* home cursor */
      -1);
}

/***************************************************/

void tty_ansicol_dump_attr();
void tty_ansicol_prep_attr();

void tty_vt1xx_init()
{
   pwplib.dump_attr=tty_vt_dump_attr;
/*   pwplib.prep_attr=tty_vt_prep_attr;*/

   conv_init(9,3,2);
   
   tty_vt_initstring();
}

#ifdef DRIVE_TTY_VT2XX
void tty_vt2xx_init()
{
   pwplib.dump_attr=tty_vt_dump_attr;
   pwplib.prep_attr=tty_vt_prep_attr_40;
   pwplib.videobuf.width>>=1;

   {int fw=8,fh=10;
   switch((int)pwp_tty.minor)
   {
      case(420):fw=10;fh=16;break;  /* 36 lines: fh=10, 48 lines: fh=8 */
      case(330):fw=10;fh=20;break;
      case(320):fw=15;fh=12;break;
   }

   conv_init(9,3,2);

   pwpwrite("* loading custom font\n");

   {
   TEMPMALL(char,tmp,fw*fh*64);
   glyphgen_64rast(tmp,fw,fh);
   vt2xx_loadglyphs(tmp,fw,fh,64);
   TEMPFREE(tmp);
   }}
   
   pwp_tty.maxframedata=500;

   tty_vt_initstring();
}
#endif

#endif
#endif

