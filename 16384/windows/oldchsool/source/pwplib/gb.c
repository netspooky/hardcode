/*
 *  PWP Generic Beep (PWPbeep) engine for digital audio.
 *
 */

#include "config.h"

#ifdef DRIVE_GB

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#include "pwplib.h"

struct {
  struct {
     int wvlgt;
     int wvleft;
     int wvphase;
     int wvlgt1;
  }ch[3];
  int freq;
}pwpgb;

void gb_sound(int chan,int freq,int volume,int ratio)
{
  if(volume&&freq){
    int wvlgt=
      ((double)(pwpgb.freq*12)/pow(1.059465,freq/256.0));

    if(ratio<1)ratio=1;else if(ratio>255)ratio=255;

    pwpgb.ch[chan].wvlgt=(wvlgt*ratio)>>7;
    pwpgb.ch[chan].wvlgt1=2*pwpgb.ch[chan].wvlgt-wvlgt;

    pwpgb.ch[chan].wvleft=pwpgb.ch[chan].wvlgt/(chan+2);
    pwpgb.ch[chan].wvphase=volume;
  }else{
    pwpgb.ch[chan].wvphase=0;
    pwpgb.ch[chan].wvleft=pwpgb.ch[chan].wvlgt=32123;
  }
}

void gb_init(int freq)
{
  pwpgb.freq=freq;
  {int i=0;for(;i<3;i++)gb_sound(i,0,0,0);}
}

void gb_gen1chan(char*d,int l,int freq)
{
  int ph=128*256;
  while(l--){
    *d++=64+((ph>>8)&0x80);
    ph+=freq;
  }
}

#define CH pwpgb.ch

void gb_beepemu(char*d,int l)
{
  static int pf=0;
  int
    fq0=CH[0].wvlgt,
    fq1=CH[1].wvlgt,
    fq2=CH[2].wvlgt,fq;
  if(CH[0].wvphase==0)fq0=32768;
  if(CH[1].wvphase==0)fq1=32768;
  if(CH[2].wvphase==0)fq2=32768;

  if(fq0>fq1){int tmp=fq0;fq0=fq1;fq1=tmp;}
  if(fq0>fq2){int tmp=fq0;fq0=fq2;fq2=tmp;}
  if(fq1>fq2){int tmp=fq1;fq1=fq2;fq2=tmp;}

  if(pf&1){
    if(pf&2)fq=fq1;else fq=fq2;
    if(!fq)fq=fq0;
  }else{
    fq=fq0;
    if(fq==32768){fq=fq1;
      if(fq==32768)fq=fq2;}
  }
  if(fq==32768)memset(d,128,l);else
  {
    fq=(65536*256)/fq; 
    gb_gen1chan(d,l,fq);
  }
  pf++;
}

void gb_genwave(char*d,int l)
{
   int remain=0;

   l<<=8;
   while(l)
   {
      int min=CH[0].wvleft,w,sum;
          w=CH[1].wvleft;if(w<min)min=w;
          w=CH[2].wvleft;if(w<min)min=w;

      sum=CH[0].wvphase+CH[1].wvphase+CH[2].wvphase+128;
      if(sum<0)sum=0;else if(sum>255)sum=255;

      if(min>l)min=l; l-=min;
      memset(d,sum,(min+remain)>>8);
        d+=((min+remain)>>8);
        remain=(min+remain)&255;

      {int i=0;
      for(;i<3;i++){
         w=CH[i].wvleft-=min;
         if(!w)
         {
           CH[i].wvleft=CH[i].wvlgt1;
           CH[i].wvlgt1=CH[i].wvlgt;
           CH[i].wvlgt=CH[i].wvleft;
           CH[i].wvphase=0-CH[i].wvphase;
         }
       }
      }
    }
}

/* my_memset, ... */

/*
gb_genwave_opt(char*buf,int endptr)
{
   #define SETTILL(a) \
     {int bord=w##a,rs;if(bord>endptr)goto last;\
      rs=sum;if(rs&~0xff){if(rs<0)rs=0;else rs=255;}\
      memset(buf+(ptr>>8),rs,2+((bord-ptr)>>8));ptr=bord;\
      CH[a].wvphase=0-CH[a].wvphase;\
      sum+=(CH[a].wvphase)<<1;\
      w##a=ptr+CH[a].wvlgt;}
   #define HANDLE(s0,s1,s2) \
      {SETTILL(s0); \
      if(w##s0<=w##s1)goto w##s0##w##s1##w##s2;else \
      if(w##s0<=w##s2)goto w##s1##w##s0##w##s2;else \
                      goto w##s1##w##s2##w##s0;}

   int ptr=0,sum=CH[0].wvphase+
                 CH[1].wvphase+
                 CH[2].wvphase;

   int w0=CH[0].wvleft,
       w1=CH[1].wvleft,
       w2=CH[2].wvleft;

   endptr<<=8;

   w1w2w0:HANDLE(1,2,0);
   w2w1w0:HANDLE(2,1,0);
   w0w2w1:HANDLE(0,2,1);
   w2w0w1:HANDLE(2,0,1);
   w0w1w2:HANDLE(0,1,2);
   w1w0w2:HANDLE(1,0,2);

   last:
     {int rs=sum;
     if(rs&~0xff){if(rs<0)rs=0;else rs=255;}
     memset(buf+(ptr>>8),rs,(endptr-ptr)>>8);}

     CH[0].wvleft=w0-endptr;
     CH[1].wvleft=w1-endptr;
     CH[2].wvleft=w2-endptr;

   #undef SETTILL
}
*/

#if (0)
gb_genwave_opt(char*buf,int endptr)
{
   int ptr=0,sum=CH[0].wvphase+
                 CH[1].wvphase+
                 CH[2].wvphase;

   #define w0 CH[0].wvleft
   #define w1 CH[1].wvleft
   #define w2 CH[2].wvleft

/*   volatile int w0=CH[0].wvleft,
       w1=CH[1].wvleft,
       w2=CH[2].wvleft;*/

   endptr<<=8;

   #define SETTILL(a) \
     {int bord=w##a,rs;if(bord>endptr)goto last;\
      rs=sum;if(rs&~0xff){if(rs<0)rs=0;else rs=255;}\
      memset(buf+(ptr>>8),rs,2+((bord-(ptr&~0xff))>>8));ptr=bord;\
      CH[a].wvphase=0-CH[a].wvphase;\
      sum+=(CH[a].wvphase)<<1;\
      w##a=ptr+CH[a].wvlgt;}

   if(w0<=w1){
      if(w1<=w2)goto w0w1w2;else
      if(w2<=w0)goto w2w0w1;else
                goto w0w2w1;
   }else{
      if(w0<=w2)goto w1w0w2;else
      if(w2<=w1)goto w2w1w0;       //.. else w1w2w0 (next)
   }

   w1w2w0:
     SETTILL(1);
     if(w1<=w2)goto w1w2w0;else
     if(w1<=w0)goto w2w1w0;else   //.. if(w1>w0)goto w2w0w1;
               goto w2w0w1;
   w2w1w0:
     SETTILL(2);
     if(w2<=w1)goto w2w1w0;else
     if(w2<=w0)goto w1w2w0;else
               goto w1w0w2;

   w0w2w1:
     SETTILL(0);
     if(w0<=w2)goto w0w2w1;else
     if(w0<=w1)goto w2w0w1;else   //.. if(w0>w1)goto w2w1w0;
               goto w2w1w0;
   w2w0w1:
     SETTILL(2);
     if(w2<=w0)goto w2w0w1;else
     if(w2<=w1)goto w0w2w1;else
               goto w0w1w2;       //.. not reqd

   w0w1w2:
     SETTILL(0);
     if(w0<=w1)goto w0w1w2;else
     if(w0<=w2)goto w1w0w2;else   //.. if(w0>w2)goto w1w2w0;
               goto w1w2w0;

   w1w0w2:
     SETTILL(1);
     if(w1<=w0)goto w1w0w2;else
     if(w1<=w2)goto w0w1w2;else
               goto w0w2w1;

   last:
     {int rs=sum;
     if(rs&~0xff){if(rs<0)rs=0;else rs=255;}
     memset(buf+(ptr>>8),rs,2+((endptr-ptr)>>8));}

     CH[0].wvleft=w0-endptr;
     CH[1].wvleft=w1-endptr;
     CH[2].wvleft=w2-endptr;

   #undef SETTILL
}
#endif

#endif
