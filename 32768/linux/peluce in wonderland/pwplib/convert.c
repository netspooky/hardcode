/*
 *  Misc converters. Clean this up.
 *
 */

#define __CONVERT_C

#include "config.h"

#include <stdio.h>
#include <stdlib.h>

#include "pwplib.h"
#include "convert.h"

/*
 *  Doubleheight IBM
 *
 */

void convcalc_1to12()  /* &1 == ibm2ibm, */
{
   u8 tabsrc[]=
   {
     '\"', '\"',' ',
     '/',  '|','/',
     '\'', '\'',' ',
     '/',  '|', '/',
     
     '\\', '\\','|',
     '^',  '^', ' ',

     '`',  '`', ' ',

     '|',  '|', '|',
     '~',  '~', ' ',

     176,  176, 176,
     177,  177, 177,
     178,  178, 178,

     179,  179, 179,
     180,  179, 180,
     181,  179, 181,
     182,  186, 182,
     185,  186, 185,
     186,  186, 186,
     188,  186, 188,
     189,  186, 189,
     190,  179, 190,
     192,  179, 192,
     193,  179, 193,
     195,  179, 195,
     197,  179, 197,
     198,  179, 198,
     199,  186, 199,
     200,  186, 200,
     202,  186, 202,
     204,  186, 204,
     206,  186, 206,
     207,  179, 207,
     208,  186, 208,
     211,  186, 211,
     212,  179, 212,
     215,  186, 215,
     216,  179, 216,
     217,  179, 217,

     219,  219, 219,
     220,  32,  219,
     221,  221, 221,
     222,  222, 222,
     223,  219, 32,
     0
   };
   u8*t=tabsrc;

   int i=0;

   for(;i<256;i++)
   {
      pwpconv.tab1to12[i]=BYTES2(pwpconv.font[i],32);
   }

   while(*t)
   {
      pwpconv.tab1to12[*t]=BYTES2(pwpconv.font[t[2]],pwpconv.font[t[1]]);
      t+=3;
   }
}

void conv_1to12(u8*d,u8*s,int w,int h)
{
   w<<=1;
   for(;h;h--)
   {   
     int x=w>>1;
     for(;x;x--)
     {
        int a=pwpconv.tab1to12[*s];

        d[0]=SECONDBYTE(a);
        d[w]=FIRSTBYTE(a);
        d[1]=d[w+1]=s[1];

        d+=2;
        s+=2;
     }
     d+=w;
   }
} 
/*   conv_1to12(d,s,pwplib.videobuf.width,pwplib.videobuf.height);*/

/*
 *  Rasthalvetab (raster 1x2 => ibmchar/attr pair)
 *
 */

void convcalc_rasthalve()
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

void convcalc_rasthalve_mono()
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
              BYTES2(convtab[dins|(uins<<3)],0x07);
   }
}

/* convcalc_rasthalve_limcols(); ? */

/*
 *  Megatab (ibm color16x16 => any) initialization
 *
 *
 */

/*
 *  purely font/charset related
 */

void convcalc_ascii()
{
  memcpy(pwpconv.font,
  /*00*/ " OOwoxAoooo6qrn*" 
  /*10*/ "><8!PS_8^v><L-^v" 
  /*20*/ " !\"#$%&'()*+,-./"
  /*30*/ "0123456789:;<=>?"
  /*40*/ "@ABCDEFGHIJKLMNO"
  /*50*/ "PQRSTUVWXYZ[\\]^_"
  /*60*/ "`abcdefghijklmno"
  /*70*/ "pqrstuvwxyz{|}~A"
  /*80*/ "CueaaaaceeeiiiAA"
  /*90*/ "E&&ooouuyOUcEVPf"
  /*A0*/ "aiounNao?--%%!<>"
  /*B0*/ "%#M||||..||.'''."
  /*C0*/ "`--|-+||`.--|-+-"
  /*D0*/ "---``-.++'.8opd^"
  /*E0*/ "aBrhEouiO0Od-%EA"
  /*F0*/ "=+><|J%~o-.Vn2o ",256*sizeof(char));
}

void convcalc_termsafe()
{
   int i=256;u8*s=pwpconv.font;
   for(;i;i--)
   {
     if(*s<32 || *s==127)*s=32;
     s++;
   }
}

/*
 *  purely colortab related
 */

void convcalc_monotab(int parms)
{
  memset(pwpconv.col,0x07,256*sizeof(u8));

  /* &1: normal(0x07), inverse(0x70), bold(0x0f), dim(0x03)
     colors 8 => use a different tty rendering rtn
  */
}

void convcalc_monotab_attr(int parms)
{
   const char intens[16]=
   {
       0,1,6,7, 3,4,9,10,
       1,2,9,10,5,6,13,15
   };

   /* ... also support other vt100 attributes when stuff is ready */

   int i=0;
   for(;i<256;i++)
     pwpconv.col[i]=(intens[i&15]>intens[(i>>4)&15])?0x07:0x70;
}

void convcalc_colortab(int parms)
{
  int i;
  char tabs[32];
  
  for(i=0;i<32;i++)tabs[i]=i&15;

  if(parms&1){ /* 8 colors in foreground, else 16 */
     memcpy(tabs+8,  "\003\003\002\003\004\005\006\007",8);
  }

  if(parms&2)  /* 8 colors in background, else 16 */
     memcpy(tabs+24, "\003\003\002\003\004\005\006\007",8);

  if(parms&4)  /* ansi color order (bgr) instead of cga (rgb) */
     for(i=0;i<32;i++)
       tabs[i]=(tabs[i]&~7)|
       "\000\004\002\006\001\005\003\007"[tabs[i]&7];

  for(i=0;i<256;i++)
    pwpconv.col[i]=tabs[i&15]|(tabs[16+((i>>4)&15)]<<4);
}

/*
 *  finishing the megatab
 */

/*
   1: eliminate 178/219        (if inverse supported & 178/219 doesnt exist)
   2: eliminate halfblocks      (if chars, preferably if we have rasterchar && fullres)
   4: replace rasters            (if no bgcolors or no colors at all? smwhr else?)
   8: sometimes repl 176 with 177 (if only 8 colors at bg - dont use with &4)

   normal ascii rasterchars: 176='%', 177='@'
   in vt100, both 176&177 are replaced with halfraster
*/
void convcalc_megatab_finish(int flags)
{
   const char intens[16]=
   {
       0,1,6,7, 3,4,9,10,
       1,2,9,10,5,6,13,15
   };

   int ch,at;
   u8*s=(u8*)pwpconv.megatab;

   #ifndef BIG_ENDIAN   
    for(at=0;at<256;at++)
    for(ch=0;ch<256;ch++)
   #else
    for(ch=0;ch<256;ch++)
    for(at=0;at<256;at++)
   #endif
   {
      int fg=at&15,bg=(at>>4)&15,at1=at,ch1=ch;

      if(ch==32 || ch==0 || ch==255)fg=bg;else
      if(ch==219)bg=fg;
      
      if(fg==bg)
      {
         if(fg&8)
         {
            ch1=219;at1=fg;
         }
          else
         {
            ch1=32;at1=fg<<4;
         }
      }
       else
      if(ch>=220 && ch<=223)
      {
         if((at1&128) && intens[bg]>intens[fg])
         {
            ch1=223-(ch1-220);
            at1=((at1>>4)&15)|((at1<<4)&0xf0);
         }
         if(flags&2)ch1=177;
      }
       else
      if(ch>=176 && ch<=178)
      {
         if((at1&128) || intens[bg]>intens[fg])
         {
            if(ch1==176)ch1=178; else
            if(ch1==178)ch1=176;
            
            at1=((at1>>4)&15)|((at1<<4)&0xf0);

              /* flags&8: use 177 when 176 with doublebright */
            if((at1&128) && (flags&8) && (ch1==176))
                ch1=177;
         }
      }

        /* flags&1: eliminate 178/219 */      
      if((ch1==178 || (ch1==219)) && (flags&1))
      {
         ch1=(ch1==178)?176:32;
         at1=((at1>>4)&15)|((at1<<4)&0xf0);
      }

      /* flags&4: replace rasters (32/176/177) with something else
         (replace color info with char stuff
      */

      s[0]=pwpconv.font[ch1];
      s[1]=pwpconv.col[at1];
      
      s+=2;
   }
}

/*******************************/

/*
void conv_doinverse(u8*d,int lgt)
{
  for(;lgt;lgt--)
  {
    if(*d&128)
    {
       d[1]=(d[1]>>4)|(d[1]<<4);
       *d&=127;
    }
    d+=2;
  }
}

void conv_doattr(u8*d,int lgt)
{
  d++;
  for(;lgt;lgt--)
  {
    *d=pwpconv.col[*d];
    d+=2;
  }
}
*/

void conv_dump_ibm_megatab()
{
   u16 tmp[pwplib.videobuf.height*pwplib.videobuf.width*2],
       *s=(u16*)pwplib.videobuf.d,*d=tmp;

   int i=pwplib.videobuf.height*pwplib.videobuf.width;
   for(;i;i--)*d++=pwpconv.megatab[*s++];
   
   {u8*pushed=pwplib.videobuf.d;
    pwplib.videobuf.d=(u8*)tmp;
    pwpconv.orig_dump_ibm();
    pwplib.videobuf.d=pushed;
   }
}

void conv_fromibm_double()
{
   int lgt=pwplib.videobuf.width*pwplib.videobuf.height;
   u8 tmp[lgt*2*2];

   conv_1to12(tmp,pwplib.videobuf.d,pwplib.videobuf.width,pwplib.videobuf.height);

   {char*save=pwplib.videobuf.d;
    pwplib.videobuf.d=tmp;
    pwplib.videobuf.height<<=1;
    conv_dump_ibm_megatab();
    pwplib.videobuf.height>>=1;
    pwplib.videobuf.d=save;
   }
}

void conv_fromibm_half()
{
   u8 tmp[pwplib.videobuf.width*pwplib.videobuf.height],
      *d=tmp,*s=pwplib.videobuf.d;

   int y;
   y=pwplib.videobuf.height>>1;

   for(;y;y--)
   {
      int x=pwplib.videobuf.width,
          w=x<<1;
      for(;x;x--)
      {
         d[0]=pwpconv.font[s[0]];
         d[1]=s[1]|s[1+w];
         s+=2;d+=2;
      }
      s+=w;
   }

  {char*save=pwplib.videobuf.d;
   pwplib.videobuf.d=tmp;
   pwplib.videobuf.height>>=1;
   conv_dump_ibm_megatab();
   pwpconv.orig_dump_ibm();
   pwplib.videobuf.d=save;
   pwplib.videobuf.height<<=1;
  }
}

/* dump_ibm_halved, dump_ibm_realsize */
void conv_dump_ibm()
{
   if(pwplib.setup[SETUP_HALVE])
   {
      if(pwplib.videobuf.height==50) /* kludge */
           conv_fromibm_half();
      else conv_dump_ibm_megatab();
   }
    else
   {
      if(pwplib.videobuf.height==50)
           conv_dump_ibm_megatab();
      else conv_fromibm_double();
   }
}

/*
 *   PWPColorRaster<tm> convertor
 *
 *
 */

void convcalc_rast2asc()
{
  char intens[16]={
    0,1,6,7, 3,4,9,10,
    1,2,9,10,5,6,13,15};

  int i=0;
  for(;i<256;i++)
  {
    pwpconv.rast[i*2+1]=0x07;
    pwpconv.rast[i*2]=" .:?%xcnoOXS8NW@@"[
      (intens[i&15]*12+intens[i>>4]*4)>>4 ];
  }
}

void convcalc_rast2colasc()
{
  int r,g,b;
  u8 rgb[16][16][16][2];
  
  for(r=0;r<16;r++)
  for(g=0;g<16;g++)
  for(b=0;b<16;b++)
  {
     int col=0,thr,i;

     thr=r;
     if(g>thr)thr=g;
     if(b>thr)thr=b;

     thr>>=1;

     if(r>thr)col|=4;
     if(g>thr)col|=2;
     if(b>thr)col|=1;
     
     i=(r*3+g*6+b)/"\1\1\6\7\3\4\11\12"[col];
     if(i>15)i=15;
     
     rgb[r][g][b][1]=col;
     rgb[r][g][b][0]=" .:?%xcnoOXS8NW@@"[i]; /* convtab */

     /* also support bold! (use bold convtab) */
  }

  {int i=0;
  for(;i<256;i++)
  {
    int r=0,g=0,b=0;

    {int a=(i&8)?6:3;
    if(i&4)r+=a;
    if(i&2)g+=a;
    if(i&1)b+=a;
    }

    {int a=(i&128)?9:4;
    if(i&64)r+=a;
    if(i&32)g+=a;
    if(i&16)b+=a;
    }

    pwpconv.rast[i*2+0]=rgb[r][g][b][0];
    pwpconv.rast[i*2+1]=rgb[r][g][b][1];
  }}
}

void convcalc_rast_limcols() /* 5 rasterchars; 16 fgcols. */
{
  int i=0;
  for(;i<256;i++)
  {
     int ch=176,attr=i&0x80;
     if((i&15)==((i>>4)&15))
     {
        attr=(i&16)?219:32;
     }
     else
     if(i&128)
     {
        if(i&16)
        {
           const char intens[16]=
           {
               0,1,6,7, 3,4,9,10,
               1,2,9,10,5,6,13,15
           };

           ch=177;
           if(intens[i&15]>intens[(i>>4)&15])
              attr=i&0x80;
            else
              attr=((i>>4)&15)|((i<<4)&0x80);
        }
         else
        {
           ch=178;
           attr=((i>>4)&15)|((i<<4)&0x80);
        }
     }
     pwpconv.rast[i*2+0]=ch;
     pwpconv.rast[i*2+1]=attr;
  }
}

void convcalc_rast_monohalf()
{
   const char intens[16]=
   {
      0,1,6,7, 3,4,9,10,
      1,2,9,10,5,6,13,15
   };
   int i=0;
   for(;i<256;i++)
       pwpconv.rast[i]=(intens[i&15]+intens[(i>>4)&15]*3)/7;
}

/** halve **/

void conv_fromrast_halve(u8*d,u8*s,int hgt,int wdt)
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

/**/

void conv_fromrast(u8*d,u8*s,int lgt)
{
  u16*dd=(u16*)d;s++;
  for(;lgt;lgt--)
  {
    *dd++=((u16*)pwpconv.rast)[*s];
    s++;
  }
}

void conv_dump_rast()
{
  u8 tmp[pwplib.videobuf.height*pwplib.videobuf.width*2];

  if(pwplib.setup[SETUP_LOSSY])
  conv_losestuff(pwplib.videobuf.d,
    pwplib.videobuf.height*pwplib.videobuf.width,1);

/*  fprintf(stderr,"dump_rast\n");*/

  if(pwplib.setup[SETUP_HALVE])
  {
     u8*push=pwplib.videobuf.d;
     conv_fromrast_halve(tmp,pwplib.videobuf.d,
       pwplib.videobuf.height,pwplib.videobuf.width);
       
       pwplib.videobuf.d=tmp;
       pwplib.videobuf.height>>=1;
       pwpconv.orig_dump_ibm();
       pwplib.videobuf.height<<=1;
       pwplib.videobuf.d=push;
  }
   else
  {u8*push=pwplib.videobuf.d;
  
   conv_fromrast(tmp,pwplib.videobuf.d,
                 pwplib.videobuf.height*pwplib.videobuf.width);

   pwplib.videobuf.d=tmp;
   pwpconv.orig_dump_ibm();
   pwplib.videobuf.d=push;
  }
}

/*
 *  Initializer
 *
 */

void conv_init()
{
   int i=0;
   
   int colors =pwplib.setup[SETUP_COLORS];
   int chars  =pwplib.setup[SETUP_TRANS];
   int rasters=pwplib.setup[SETUP_RASTER];

   /* * * * */

   if(rasters<0)rasters=0;
   if(colors<0)colors=0;
   if(chars<0)chars=0;

   for(;i<256;i++)
     pwpconv.font[i]=pwpconv.col[i]=i;

   /* * * * */

   pwpwrite("character converter: ");

   if(chars&2)
   {
     pwpwrite("translating to ascii");
     if(chars&1)pwpwrite(" (no invert)");
     convcalc_ascii(chars);
   }else
     pwpwrite("no translation (native ibm)");

   /* * * * */

   if(!(colors&~7))
   {
     char tmp[60];
     int fgcols=(colors&1)?8:16,bgcols=(colors&2)?8:16;
     sprintf(tmp,"; %i fg and %i bg colors\n",fgcols,bgcols);
     pwpwrite(tmp);
   }else
   {
     pwpwrite("; monochrome\n");
   }

   if(colors&8)
      convcalc_monotab(colors);
      else
      convcalc_colortab(colors);  /* 1==8colfg, 2==8colbg, 4==ansibits */

   /* * * * misc stuff, move somewhere * */

   if(pwplib.setup[SETUP_TTY])convcalc_termsafe();

   convcalc_1to12();

   pwpconv.orig_dump_ibm=pwplib.dump_ibm;
   pwplib.dump_ibm=conv_dump_ibm;

   /* * * * */

   {int flags=8;
   convcalc_megatab_finish(flags);
   }
   /*
      inverse supported, 178/219 not in charset: |1  (vt100, xterm-mono)
      fullsize, no halfblocks                    |2  (xterm)
      no colors or no bgcolors                   |4  (all mono stuphos)
      bg&fg supported; no bg brightlite          |8  (8x16 textmodes)
   */

   /* * * * */

   pwpwrite("raster conversion: ");
   if(rasters)
   {
      if(rasters==2)
      {
         pwpwrite("monochrome ascii\n");
         if(pwplib.setup[SETUP_HALVE])
            convcalc_rasthalve_mono();
          else
            convcalc_rast2asc();
      }
       else
      {
         pwpwrite("color ascii (8 fg colors, black bg)\n");
         convcalc_rast2colasc();
      }
      
      pwplib.dump_rast=conv_dump_rast;
   }
   else
   {
      if(pwplib.setup[SETUP_HALVE])
      {
         convcalc_rasthalve();
         pwplib.dump_rast=conv_dump_rast;
      }

      pwpwrite("none\n"); /* (using native character 176 (37) */
   }
}

/*
	dump_ibm	80x50
	dump_ibm_double	80x25
	dump_raster	80x50
*/
