/*
 *  PWPlib: VTxxx support, including VT220/320 charset customization
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include "tty.h"
#include "convert.h"

/******************** vt220 raster glyphs *************************/

void vt220_loadglyphs(char*src,int width,int height,int howmany)
{
   for(;howmany;howmany--)
   {
      int x,y,i;
      for(y=0;y<height;y+=6)
      {
        if(y)putchar('/');
        for(x=0;x<width;x++)
        {
           int sixel=0;
           for(i=0;i<6;i++)
              if(src[(i+y)*width+x]>32)sixel|=(1<<i);
           putchar('?'+sixel);
        }
      }
      putchar(';');
      src+=width*height;
   }
   printf("\33\\");
}

   char rastmatrix[8*4*4]=
   "    " "    " "    " "    "
   "x   " "    " "  x " "    "
   " x  " "    " " x x" "    "
   "x x " "    " " x x" "    "
   "x x " " x x" "x x " " x x"
   "x x " "xxxx" "x x " "xxxx"
   "xx x" "xxxx" " xxx" "xxxx"
   "xxxx" "xxxx" "xxxx" "xxxx";

int vt220_genchars(char*o,int width,int height)
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

int vt220_dumprast_prepare()
{
   char blockie[15*12*64];
   vt220_genchars(blockie,15,12);
   vt220_loadglyphs(blockie,15,12,64);
}

int vt220_convcalc()
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

/*
    terminal-specific stuff:
       - dump_ibm, dump_rast
       - clrscr, setpalette etc

       internal:
       - charset info: raster chars available (8x8x8x8 metatab)
*/

/* vt220_dumprast: add new conversion table (rast8=>16bit)
*/

/**********************************************/

/*
   &1: dim
   &2: bright
   &4: inverse
   &16: charset: P vs B
*/

void tty_dump_vt(char*s,char*p,int x,int y)
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
                 if(a&8)*d++='2';
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

  memcpy(d,"\33[0m",4*sizeof(char));
  pwp_tty.att=0;d+=10;

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
