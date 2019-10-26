/*
 *  PWP music player. Uses /dev/dsp (8-bit unsigned raw)
 *
 *  compile: gcc zaxplay.c -o zaxplay -lm
 *
 *  run: zaxplay <tunenum 0..3>
 *
 */

#include <stdio.h>
#include <stdlib.h>

#include <string.h>
/* #include <linux/string.h> */

#include <unistd.h>
#include <fcntl.h>
#include <math.h>

typedef struct
{
  char*title;
  int numchans;
  int tempo;

  unsigned char*patord;
  unsigned char*tracks;
}pwpmusic;

#include "Final_Isi.h"
#include "Future_Moottori.h"
#include "Go_Mazzembly.h"
#include "Ikuisuus.h"

struct {
   int wvlgt;
   int wvleft;
   int wvphase;
}
gb_ch[3];
#define ch gb_ch

int fd;
int freq=8000;

pwpmusic*tune;
pwpmusic*tunes[]={&Final_Isi,&Future_Moottori,&Go_Mazzembly,&Ikuisuus};
#define NUMTUNES 4

gb_gen1chan(char*d,int l,int freq)
{
  int ph=128*256;
  while(l--){
    *d++=64+((ph>>8)&0x80);
    ph+=freq;
  }
}

gb_beepemu(char*d,int l)
{
  static int pf=0;
  int
    fq0=ch[0].wvlgt,
    fq1=ch[1].wvlgt,
    fq2=ch[2].wvlgt,fq;
  if(ch[0].wvphase==0)fq0=32768;
  if(ch[1].wvphase==0)fq1=32768;
  if(ch[2].wvphase==0)fq2=32768;

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

gb_genwave(char*d,int l)  /* tee oBtiMoITU versio joskus */
{
   int remain=0;

   l<<=8;
   while(l){
      int min=ch[0].wvleft,w,sum;
          w=ch[1].wvleft;if(w<min)min=w;
          w=ch[2].wvleft;if(w<min)min=w;

      /* tuon laskenta loppuun? */
      sum=ch[0].wvphase+ch[1].wvphase+ch[2].wvphase+128;
      if(sum<0)sum=0;else if(sum>255)sum=255;

      if(min>l)min=l; l-=min;
      memset(d,sum,(min+remain)>>8);
        d+=((min+remain)>>8);
        remain=(min+remain)&255;

      {int i=0;
      for(;i<3;i++){
         w=ch[i].wvleft-=min;
         if(!w){
           ch[i].wvleft=ch[i].wvlgt;	/* add pulseratio */
           ch[i].wvphase=0-ch[i].wvphase;
         }
      }}
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
      ch[a].wvphase=0-ch[a].wvphase;\
      sum+=(ch[a].wvphase)<<1;\
      w##a=ptr+ch[a].wvlgt;}
   #define HANDLE(s0,s1,s2) \
      {SETTILL(s0); \
      if(w##s0<=w##s1)goto w##s0##w##s1##w##s2;else \
      if(w##s0<=w##s2)goto w##s1##w##s0##w##s2;else \
                      goto w##s1##w##s2##w##s0;}

   int ptr=0,sum=ch[0].wvphase+
                 ch[1].wvphase+
                 ch[2].wvphase;

   int w0=ch[0].wvleft,
       w1=ch[1].wvleft,
       w2=ch[2].wvleft;

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

     ch[0].wvleft=w0-endptr;
     ch[1].wvleft=w1-endptr;
     ch[2].wvleft=w2-endptr;

   #undef SETTILL
}
*/

gb_genwave_opt(char*buf,int endptr)
{
   int ptr=0,sum=ch[0].wvphase+
                 ch[1].wvphase+
                 ch[2].wvphase;

   #define w0 ch[0].wvleft
   #define w1 ch[1].wvleft
   #define w2 ch[2].wvleft

/*   volatile int w0=ch[0].wvleft,
       w1=ch[1].wvleft,
       w2=ch[2].wvleft;*/

   endptr<<=8;

   #define SETTILL(a) \
     {int bord=w##a,rs;if(bord>endptr)goto last;\
      rs=sum;if(rs&~0xff){if(rs<0)rs=0;else rs=255;}\
      memset(buf+(ptr>>8),rs,2+((bord-(ptr&~0xff))>>8));ptr=bord;\
      ch[a].wvphase=0-ch[a].wvphase;\
      sum+=(ch[a].wvphase)<<1;\
      w##a=ptr+ch[a].wvlgt;}

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

     ch[0].wvleft=w0-endptr;
     ch[1].wvleft=w1-endptr;
     ch[2].wvleft=w2-endptr;

   #undef SETTILL
}
#define VOLUME 32

playnote(char*buf) /* ==> playtick */
{
  static int ord=0,row=0;
  int chan=0,pat=tune->patord[ord];

  for(;chan<tune->numchans;chan++){
    unsigned char b=tune->tracks[(pat*tune->numchans+chan)*64+row];

    if(b==254)gb_ch[chan].wvphase=0;else
    if(b!=255){
       b=(b>>4)*12+(b&15);
       gb_ch[chan].wvlgt=
         ((double)(400.0*256)/pow(1.059465,b));
         
       if(gb_ch[chan].wvlgt<512)
          gb_ch[chan].wvlgt=512;

       gb_ch[chan].wvleft=gb_ch[chan].wvlgt/(chan+2);
       gb_ch[chan].wvphase=VOLUME;
    }
  }

  gb_genwave(buf,tune->tempo*freq/73);
  write(fd,buf,tune->tempo*freq/73);

/*  {int j=4;for(;j;j--){
  gb_beepemu(buf,tune->tempo*freq/(73*4));
  write(fd,buf,tune->tempo*freq/(73*4));}}*/

  row++;if(row==64){
    row=0;pat=tune->patord[++ord];
    if(pat==255)ord=0;
  }
}

playzax()
{
  int i=0;
  char*buf=malloc(tune->tempo*freq/73);
  fd=open("/dev/dsp",O_WRONLY);

  for(;i<3;i++){
  gb_ch[i].wvlgt=gb_ch[i].wvleft=32000;gb_ch[i].wvphase=0;}

  for(;;){
    playnote(buf);
  }
}

int main(int argc,char**argv)
{
   if(argc!=2)
   {
      fprintf(stderr,"usage: %s <tunenum 0..%d>\n",
        argv[0],NUMTUNES-1);
      return 0;
   }

   {int i=argv[1][0]-'0';
    if(i<0 || i>=NUMTUNES)i=rand()%NUMTUNES;
    tune=tunes[i];
   }

   playzax();
   return 0;
}
