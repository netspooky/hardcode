#include "config.h"
#ifdef DRIVE_UNIX
#ifdef DRIVE_TTY

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#include "pwplib.h"
#include "tty.h"

#ifdef howmany
#  undef howmany
#endif

#define DECIMAL(x) \
{int n=(x); if(n>=100){*d++='0'+(n/100);n%=100; \
            *d++='0'+(n/10);} \
 else \
 if(n>=10)*d++='0'+(n/10); \
 *d++='0'+(n%10);}

int tty_ansicol_dump(u8*s,u8*p,int x,int y)
{
  TEMPMALL(u8,tmp,x*y*16),
     *d=tmp,skip=0,skipy=0,att=0;

  skipy=1;

  memcpy(d,"\33[0;37;40m",10*sizeof(char));d+=10;
  att=0x07;

  if(pwplib.frame&1)
  {
     s+=pwplib.videobuf.width*2;
     p+=pwplib.videobuf.width*2;
  }
  
  {int i=pwplib.frame&1;for(;i<y;i+=2)
   {int j=0;
   
   for(;j<x;j++)
   {
     if( (s[0]!=p[0]) || (s[1]!=p[1]) )
     {
       int attch=s[1]^att;
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
         att=s[1];
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
                 if(s[-2*skip+2*i+1]!=att)
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

     s+=pwplib.videobuf.width*2;
     p+=pwplib.videobuf.width*2;
   }
  }

  tty_write(tmp,d-tmp);

  TEMPFREE(tmp);
  return d-tmp;
}

/****************/

/* ..do a generic tty_dump_attr that calls pwp_tty.indump or something */
void tty_ansicol_dump_attr()
{
   int lgt=
   tty_ansicol_dump
      (pwplib.videobuf.d,pwp_tty.prevbuf,
       pwplib.videobuf.width,
       pwplib.videobuf.height);

   pwplib.frame++;

   if(lgt<pwplib.set.framebytes)
   {
      lgt+=tty_ansicol_dump
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

void tty_ansicol_prep_attr()
{
   tty_write("\33[37;40m[2J\33[H",-1);
}

void tty_ansicol_init()
{
   pwplib.prep_attr=tty_ansicol_prep_attr;
   pwplib.dump_attr=tty_ansicol_dump_attr;

   conv_init(2,3,1);

   tty_vt_initstring();
}

void tty_ansisys_init()
{
   pwplib.prep_attr=tty_ansicol_prep_attr;
   pwplib.dump_attr=tty_ansicol_dump_attr;

   conv_init(2,0,0);   

   tty_vt_initstring();
}

#endif
#endif
