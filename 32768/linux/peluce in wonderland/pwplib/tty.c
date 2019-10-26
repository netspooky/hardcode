#include "config.h"
#ifdef DRIVE_TTY

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#include "pwplib.h"

#define __TTY_C

#include "tty.h"

/* also include dumpers for vt100-noparm, vt100code and dummy-ascii */
void tty_dump_ansi(char*s,char*p,int x,int y)
{
  u8 tmp[80*50*16],*d=tmp,skip=0,skipy=0;

  skipy=1;

  {int i=0;for(;i<y;i++)
   {int j=0;

   for(;j<x;j++)
   {
     if( (s[0]!=p[0]) || (s[1]!=p[1]) )
     {
       int attch=s[1]^pwp_tty.att;
       if(attch)
       {
         int a=s[1],semic=0;
         d[0]=27;d[1]='[';d+=2;
         if(attch&0x07)
         {
           d[0]='3';d[1]="04261537"[a&7];d+=2;semic=1;
         }
         if(attch&0x70)
         {
           if(semic)*d++=';';
           d[0]='4';d[1]="04261537"[(a>>4)&7];d+=2;semic=1;
         }
         if(attch&0x80)
         {
           if(semic)*d++=';';
           if(!(a&0x80))*d++='2';
           *d++='5';semic=1;
         }
         if(attch&0x08)
         {
           if(semic)*d++=';';
           if(!(a&0x08))*d++='2';
           *d++='1';
         }
         *d++='m';
         pwp_tty.att=s[1];
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
             if(skip>1)
             {int n=skip;if(n>=10)*d++='0'+(n/10);
              *d++='0'+(n%10);}
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
           {int n=i+1;if(n>=10)*d++='0'+(n/10);
            *d++='0'+(n%10);}
           *d++=';';
           {int n=j+1;if(n>=10)*d++='0'+(n/10);
            *d++='0'+(n%10);}
           *d++='H';
         }
         skip=skipy=0;
       }

       *d++=s[0];
     }else skip++;
     s+=2;p+=2;
   }skipy++;
   }
  }

  memcpy(d,"\33[0;37;40m",10*sizeof(char));
  pwp_tty.att=0x07;d+=10;

  if(d!=tmp)
  {
    write(pwp_tty.fd,tmp,d-tmp);
    pwplib.timer_counter+=d-tmp;
  }
  else
  /* for delaying animated output */
  if(pwplib.setup[SETUP_BPS])
  {
    int howmany=pwplib.setup[SETUP_BPS]/(72*2*3);
    for(;howmany;howmany--)
    {
      write(pwp_tty.fd,"\33[H",3);
      pwplib.timer_counter+=3;
    }
  }
}

/****************/

void tty_dump_ibm()
{
/*  fprintf(stderr,"\33[2JTTYDUMPIBM\n");*/

  tty_dump_ansi(pwplib.videobuf.d,pwp_tty.prevbuf,
                pwplib.videobuf.width,
                pwplib.videobuf.height);

  memcpy(pwp_tty.prevbuf,pwplib.videobuf.d,
         pwplib.videobuf.width*
         pwplib.videobuf.height*2);
}

/****************/

/*
   raster: 0=fg+bg, 1=fgonly, 2=mono
*/

void tty_init_termtype()
{
  int colors=2,trans=2,raster=1;

  char*tt=getenv("TERM");

  if(tt==NULL){
     /* unknown: assume ascii; rasterize=monoascii;  */
     trans=3;
     raster=2;
  }else switch((int)*tt)
  {
    case('x'):  /* xterm or rxvt: don't worry about low bandwith or blink */
    case('r'):
      colors=0;
      raster=1; /* it can be a mono xterm however */
      pwplib.setup[SETUP_TTY]=1; /* kludge: don't use vcsa */
      break;

    case('v'):  /* vt*, screen */
      /* vt: if the screen is big (>=48 lines), one can assume it's an xterm */
    case('s'):
      trans=2;
      raster=2;
    break;

    case('l'): /* linux/console */
    case('c'):
      trans=1;
      raster=0;
    break;

    case('a'): /* ansi (assume bbs/dos ansi and a slow line) */
      trans=1;
      raster=1;
    break;

    default:   /* unknown: assume ascii; rasterize=monoascii */
      trans=3;
      raster=2;
    break;
  }

  if(pwplib.setup[SETUP_TRANS]<0)
      pwplib.setup[SETUP_TRANS]=trans;

  if(pwplib.setup[SETUP_COLORS]<0)
      pwplib.setup[SETUP_COLORS]=colors;

  if(pwplib.setup[SETUP_RASTER]<0)
      pwplib.setup[SETUP_RASTER]=raster;
}

void tty_init_getwinsize()
{
  #ifdef TIOCGWINSZ
  {struct winsize wsz;
  if(ioctl(0,TIOCGWINSZ,&wsz)>=0){
     pwp_tty.width=wsz.ws_col;pwp_tty.height=wsz.ws_row;
     if(pwp_tty.width>0 && pwp_tty.height>0) return;
  }}
  #endif

  {char*tmp;
  pwp_tty.height=((tmp=getenv("LINES"))?atoi(tmp):0);
  pwp_tty.width=((tmp=getenv("COLUMNS"))?atoi(tmp):0);
  if(pwp_tty.height>0 && pwp_tty.width>0)return;}

  pwp_tty.height=24;
  pwp_tty.width=80;

     fprintf(stderr,"got from defaults: %d %d\n",pwp_tty.width,pwp_tty.height);
}

int tty_init()
{
  pwp_tty.fd=2; /* stderr */

  tty_init_getwinsize();
  tty_init_termtype();

  pwp_tty.att=0x07;

  pwpwrite("\rtext terminal at stdout\n");

  pwplib.dump_ibm=tty_dump_ibm;
  
  pwplib.videobuf.width=pwp_tty.width;
  pwplib.videobuf.height=pwp_tty.height;
  pwp_tty.prevbuf=malloc(80*50*2*10); /* kludged */

  return 1;
}

void tty_dump_mono(char*src,int x,int y)
{
  unsigned char tmp[81*25],*d=tmp;
  *d++=0x12;
  {int i=y;for(;i;i--)
   {int j=x;for(;j;j--){*d++=*src;src+=2;}*d++='\n';}
  }
  write(pwp_tty.fd,tmp,d-tmp);
}

#endif
