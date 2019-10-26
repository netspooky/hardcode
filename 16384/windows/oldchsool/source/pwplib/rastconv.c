#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"
#include "convert.h"
#include "tty.h"

/*** funx ***/

int conv_rast2rgb(int i)
{
   int r=0,g=0,b=0;

   {int a=(i&8)?6:3;
   if(i&4)r+=a;
   if(i&2)g+=a;
   if(i&1)b+=a;
   if((i&15)==8)
   {
      r=2;
      g=2;
      b=2;
   }
   }

   {int a=(i&128)?9:4;
   if(i&64)r+=a;
   if(i&32)g+=a;
   if(i&16)b+=a;
   if((i&0xf0)==128)
   {
      r+=3;
      g+=3;
      b+=3;
   }
   }

   return (r<<8)|(g<<4)|b;
}

int conv_rgbdiff(int a,int b)
{
   int rd=((a>>8)&15)-((b>>8)&15);
   int gd=((a>>4)&15)-((b>>4)&15);
   int bd=(a&15)-(b&15);

   return abs(rd)*3+abs(gd)*6+abs(bd);  /* max diff 150 */
}

/*** table generators ***/

void convcalc_rast_ibmcol()
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
      int ch=176,at=dn|up;
      int dins=intens[dn&15]+intens[(dn>>4)&15]*3;
      int uins=intens[up&15]+intens[(up>>4)&15]*3;

      if(uins>=(dins<<1))
      {
         ch=223;
         at=((up>>4)&15)|(dn&0xf0);
      }
       else
      if(dins>=(uins<<1))
      {
         ch=220;
         at=((dn>>4)&15)|(up&0xf0);
      }
   
      pwpconv.rasthalve[BYTES2(up,dn)]=
              pwpconv.megatab[BYTES2(ch,at)];
   }
}

void convcalc_rast_col()
{
   const char convtab[8*8]=
      " .,%xuow"
      " :;%xhbw"
      "';?%UJdm"
     "\";?%OO66"
      "~^?TXS6W"
      "^qqTS8WW"
      "^?pYNNN@"
      "^?q9MM@@";

   int up,dn;
   for(dn=0;dn<256;dn++)
   for(up=0;up<256;up++)
   {
      int fg=((dn|up)|((dn|up)>>4))&15,
          bg=((dn&up)&((dn&up)>>4))&15;

      /* if limcols: bg == constant background or sumthing */

      int dnbg=
          conv_rgbdiff(conv_rast2rgb(bg*0x11),
                       conv_rast2rgb(dn)),
          dnfg=
          conv_rgbdiff(conv_rast2rgb(fg*0x11),
                       conv_rast2rgb(dn)),
          upbg=
          conv_rgbdiff(conv_rast2rgb(bg*0x11),
                       conv_rast2rgb(up)),
          upfg=
          conv_rgbdiff(conv_rast2rgb(fg*0x11),
                       conv_rast2rgb(up));

      int dnpart=(dnfg*8)/(dnbg+dnfg+1),
          uppart=(upfg*8)/(upbg+upfg+1);
      
      if(dnpart>7)dnpart=7;
      if(uppart>7)uppart=7;

      pwpconv.rasthalve[BYTES2(dn,up)]=
              pwpconv.megatab[
              BYTES2(convtab[dnpart|(uppart<<3)],
                     (fg|(bg<<4)))&0xffff];
   }
}

extern void tty_vt_dump_attr();

void convcalc_rast_mono()
{
   const char intens[16]=
   {
       0,1,6,7, 3,4,9,10,
       1,2,9,10,5,6,13,15
   };

   const char convtab[8*8]=
      " .,%xuow"
      " :;%xhbw"
      "';?%UJdm"
     "\";?%OO66"
      "~^?TXS6W"
      "^qqTS8WW"
      "^?pYNNN@"
      "^?q9MM@@";

   /* kludge.. */
#ifndef __POSIX__
   int col=0x07;
#else
   int col=(pwplib.dump_attr==tty_vt_dump_attr)?0x00:0x07;
#endif
   int up,dn;

   for(dn=0;dn<256;dn++)
   for(up=0;up<256;up++)
   {
      int dins=(intens[dn&15]+intens[(dn>>4)&15]*3);
      int uins=(intens[up&15]+intens[(up>>4)&15]*3);

      if(dins<7 && uins<7 && (dins|uins))
      {
         if(uins>=dins)uins=7;
         if(uins<=dins)dins=7;
      }
      
      dins/=7;
      uins/=7;

         if(dins>7)dins=7;
         if(uins>7)uins=7;

#ifdef __POSIX__
      if(pwp_tty.type==TTY_VT2XX)
      pwpconv.rasthalve[BYTES2(up,dn)]=
              BYTES2(32+(dins|(uins<<3)),0x10);
              else
#endif
      pwpconv.rasthalve[BYTES2(up,dn)]=
              BYTES2(convtab[dins|(uins<<3)],col);
   }
}

/******** conv_fromrast ***********/

void conv_fromrast_half(u8*d,u8*s,int hgt,int wdt)
{
   u16*dd=(u16*)d;
   for(hgt>>=1;hgt;hgt--)
   {
      int x=wdt;
      for(;x;x--)
      {
         *dd++=pwpconv.rasthalve[BYTES2(s[0],s[wdt])];
         s++;
      }
      s+=wdt;
   }
}

void conv_fromrast_full(u8*d,u8*s,int lgt)
{
  u16*dd=(u16*)d;s++;
  for(;lgt;lgt--)
  {
    *d++=pwpconv.rasthalve[BYTES2(s[0],s[0])];
    s++;
  }
}

/*********************************/

void conv_dump_rast()
{
  TEMPMALL(u8,tmp,pwplib.videobuf.height*pwplib.videobuf.width*2);

/*
  if(pwplib.setup[SETUP_LOSSY])
  conv_losestuff(pwplib.videobuf.d,
    pwplib.videobuf.height*pwplib.videobuf.width,1);
*/
  if(pwplib.setup[SETUP_HALVE])
  {
     u8*push=pwplib.videobuf.d;
     conv_fromrast_half(tmp,pwplib.videobuf.d,
       pwplib.videobuf.height,pwplib.videobuf.width);
       
       pwplib.videobuf.d=tmp;
       pwplib.videobuf.height>>=1;
       pwpconv.orig_dump_attr();
       pwplib.videobuf.height<<=1;
       pwplib.videobuf.d=push;
  }
   else
  {u8*push=pwplib.videobuf.d;

   conv_fromrast_full(tmp,pwplib.videobuf.d,
                 pwplib.videobuf.height*pwplib.videobuf.width);

   pwplib.videobuf.d=tmp;
   pwpconv.orig_dump_attr();
   pwplib.videobuf.d=push;
  }

  TEMPFREE(tmp);
}
