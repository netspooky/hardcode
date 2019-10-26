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
  memset(pwpconv.col,(parms&1)?0x00:0x07,256*sizeof(u8));
}

void convcalc_monotab_attr(int parms)
{
   u8 attrmo[2][2]=  /* &1: 0=ansicol_dump, 1=vt_dump */
   {
      0x00,0x01,
      0x07,0x70
   };

   const char intens[16]=
   {
       0,1,6,7, 3,4,9,10,
       1,2,9,10,5,6,13,15
   };

   int i=0;
   for(;i<256;i++)
     pwpconv.col[i]=
      attrmo[parms&1][intens[i&15]>intens[(i>>4)&15]?0:1];
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

#   ifndef BIG_ENDIAN   
    for(at=0;at<256;at++)
    for(ch=0;ch<256;ch++)
#   else
    for(ch=0;ch<256;ch++)
    for(at=0;at<256;at++)
#   endif
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


void conv_dump_ibm_megatab()
{
   TEMPMALL(u16,tmp,pwplib.videobuf.height*pwplib.videobuf.width*2),
       *s=(u16*)pwplib.videobuf.d,*d=tmp;

   int i=pwplib.videobuf.height*pwplib.videobuf.width;
   for(;i;i--)*d++=pwpconv.megatab[*s++];
   
   {u8*pushed=pwplib.videobuf.d;
    pwplib.videobuf.d=(u8*)tmp;
    pwpconv.orig_dump_attr();
    pwplib.videobuf.d=pushed;
   }

   TEMPFREE(tmp);
}

void conv_fromibm_double()
{
   int lgt=pwplib.videobuf.width*pwplib.videobuf.height;

   TEMPMALL(u8,tmp,lgt*2*2);

   conv_1to12(tmp,pwplib.videobuf.d,pwplib.videobuf.width,pwplib.videobuf.height);

   {char*save=pwplib.videobuf.d;
    pwplib.videobuf.d=tmp;
    pwplib.videobuf.height<<=1;
    conv_dump_ibm_megatab();
    pwplib.videobuf.height>>=1;
    pwplib.videobuf.d=save;
   }

   TEMPFREE(tmp);
}

void conv_fromibm_half()
{
   TEMPMALL(u8,tmp,pwplib.videobuf.width*pwplib.videobuf.height),
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
   pwpconv.orig_dump_attr();
   pwplib.videobuf.d=save;
   pwplib.videobuf.height<<=1;
  }

  TEMPFREE(tmp);
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
