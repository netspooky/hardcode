#include "wrapper.h"

/** conio stuff **/

int clrscr()
{
  fprintf(stderr,"\033[2J\033[H");
}
int getch()
{
  return '.';
}
int kbhit()
{
  return 1;
}

/*****/

void loopflush()
{
  pwplib.loopflush();
}

void sound(int freq) /* beepsound */
{
}

void gbsound(int ch,int freq)
{
  if(freq)pwplib.sound(ch,freq<<8,pwplib.setup[SETUP_VOLUME]);
     else pwplib.sound(ch,0,0);
}

/** video stuff **/

void retracecheck(){}
void setvideo()
{
  fprintf(stderr,"setvideo\n");
}

/** timing stuff **/

int get_timerval()
{
  return pwplib_timer();
}
void timer_on(void(*player)())
{
  pwplib_init(); /* test if <48 ==> 25ize */
    pwplib.videobuf.width=80;
    pwplib.videobuf.height=50;

  pwplib.player=player;
  /* etc */
}
void timer_off()
{
  /* pwplib_exit(); */
}

/** fx stuff **/

/*************************************************/

void fillbuf(char*d,int w16,int lgt)  /* iku */
{
  short*dd=(short*)d;
  for(;lgt;lgt--)*dd++=w16;
}
void dump28025()  /* iku */
{
  fprintf(stderr,"dump28025\n");
}
void dump2buf(char*s0,char*s1,char*d,int lgt)  /* iku */
{
  char tmp[80*50*2];d=tmp;lgt=80*50;lgt<<=1;
  tmp[0]=tmp[1]=tmp[2]=tmp[3]=0;
  {int j=lgt;
  for(;j;j--){d[0]=176;d[1]=*s0++|*s1++;d+=2;}}
  
  pwplib.videobuf.d=tmp;
  pwplib.dump_ibm();
}
void dumpbuf(char*s,char*d,int lgt)  /* iku */
{
  {char*tmp=pwplib.videobuf.d;
   pwplib.videobuf.d=s;
   pwplib.dump_rast();
   pwplib.videobuf.d=tmp;
  }
/*  
  char tmp[80*50*2];d=tmp;lgt<<=1;
  tmp[0]=tmp[1]=tmp[2]=tmp[3]=0;
  {int j=lgt;
  for(;j;j--){d[0]=176;d[1]=*s++;d+=2;}}
  
  pwplib.videobuf.d=tmp;pwplib.dump_ibm();*/
}
void dump_attr(char*s)
{
  pwplib.videobuf.d=s;pwplib.dump_ibm();
}
void txtmode(int c)
{
  clrscr();
  pwplib.videobuf.height=c?50:25;
}

#define USE_RUUTU

/** uncrunch **/

/* thedraw uncrunch */

#ifdef USE_RUUTU
  extern char *ruutu;
#endif
void uncrunch(unsigned char*src,char*dst,int lgt)
{
  char attr=0x07,*nxtlin=dst+160;
  #ifdef USE_RUUTU
    int upd=((dst>=ruutu) && (dst<ruutu+80*25))?1:0;
  #endif  
  for(;lgt>0;lgt--){
    int c=*src++;
    if(c>=32){dst[0]=c;dst[1]=attr;dst+=2;}else
    if(c<16)attr=(attr&0xf0)|c;else
    if(c<24)attr=(attr&0x8f)|((c-16)<<4);else
    if(c==24){dst=nxtlin;nxtlin+=160;}else
    if(c==25){int i=1+*src++;
       for(;i;i--){dst[0]=32;dst[1]=attr;dst+=2;}lgt--;}else
    if(c==26){int i=1+src[0],t=src[1];src+=2;
      for(;i;i--){dst[0]=t;dst[1]=attr;dst+=2;}lgt-=2;}
    else if(c==27)attr^=0x80;
  }
  #ifdef USE_RUUTU
    if(upd)dump_attr(ruutu);
  #endif
}

/*
  char hou[80*56];d=hou;lgt<<=1;
  fprintf(stderr,"\033[1;1H");
  lgt-=(lgt>>3);
  for(;lgt;lgt--)*d++=32+(*s++&63);
  *d++=0;
  fprintf(stderr,hou);*/

void fadebuf(char*b,char*tab,int lgt)  /* iku */
{
  for(lgt<<=1;lgt;lgt--){*b=tab[*b];b++;}
}
void drawsym(char*d,int*symt,char*bm,int off,int lgt)  /* iku */
{
  for(;lgt;lgt--)*d++=bm[(off+*symt++)&1023];
}

#define SENTINEL 32123
void drawjulia(char*d,int*c2tab,int cmod)  /* iku */
{
/*  int i=80*50,*c2=c2tab;
  for(;i;i--){
    int c=*c2++;
    if(c==SENTINEL){d++;goto boh;}
        c=c2tab[(c+cmod)&65535];
    if(c==SENTINEL){*d++|=0x01;goto boh;}
        c=c2tab[(c+cmod)&8191];
    if(c==SENTINEL){*d++|=0x10;goto boh;}
        c=c2tab[(c+cmod)&8191];
    if(c==SENTINEL){*d++|=0x11;goto boh;}
        c=c2tab[(c+cmod)&8191];
    if(c==SENTINEL){*d++|=0x19;goto boh;}
        *d++|=0x91;
    boh:
  }*/
}
#undef SENTINEL

void addzbmapL(char*d,char*s,int xcount,int xadd,int ycount,
               int yadd,int fixcount)  /* iku */
{
  for(;ycount>0;ycount--){
  {int i=0,x=xcount;char*dd=d;char*ss=&s[32*(fixcount>>8)];
   for(;x;x--){*dd++|=ss[i>>8];i+=xadd;}}
  d+=80;
  fixcount+=yadd;}
}
void addzbmapR(char*d,char*s,int xcount,int xadd,int ycount,
               int yadd,int fixcount)  /* iku */
{
  for(;ycount>0;ycount--){
  {int i=0,x=xcount;char*dd=d;char*ss=&s[32*(fixcount>>8)];
   for(;x;x--){*dd--|=ss[i>>8];i+=xadd;}}
  d+=80;
  fixcount+=yadd;}
}
void dump8025(){
  fprintf(stderr,"dump8025\n");
}

/* taimeri => gettimer(); */

/*int taimeri=0;*/

/***/

void textcolor(int c){}
void picmov(){}
void memfill(){}

int mul32(int a,int b)
{
  return (a*b)>>16;
}

int attr2dump(char*s0,char*s1,char*d,int lgt,int ander)  /* fisi */
{
  char tmp[80*50];d=tmp;lgt=80*50;
  tmp[0]=tmp[1]=tmp[2]=tmp[3]=0;
  {int j=lgt;
  for(;j;j--)*d++=(*s0++&ander)|*s1++;
  }
  pwplib.videobuf.d=tmp;
  pwplib.dump_rast();
}

int attrdump(char*s,char*d,int howmany)  /* fisi */
{
  dumpbuf(s,d,howmany>>1);
}

int dump16()  /* fisi */
{
  fprintf(stderr,"dump16\n");  /* fisi */
}
int dump216()
{
  fprintf(stderr,"dump216\n");  /* fisi */
}

int dumphybrid(uchar*a,uchar*b,uchar*d)  /* fisi */
{
  char tmp[80*50*2];int y=25;d=tmp;
  
  for(;y;y--){int x=80;
  for(;x;x--)
  {
    if(*a!=253){d[0]=*a;d[1]=a[1];}else
               {int z=(b[0]&0xf0)|(b[80]>>4);
                d[0]=z?220:32;d[1]=z;}
    a+=2;d+=2;b++;
  }b+=80;}

  pwplib.videobuf.d=tmp;pwplib.dump_ibm();
}

int gotoxy()  /* fisi */
{}
int polytxloop(sint h,char*di,uint x1,sint dx0,sint dx1,char*txr,
               sint dv,sint du)  /* fisi */
{
  int x0=0,u=0,tpv=0;
  for(;h>0;h--){
  {char*d=di+(x0>>8);int c=(x1>>8)&127,tp=(tpv<<4)&0xf000;
                     if(c>0)for(;c;c--){*d++=txr[(tp>>8)&0xff];tp+=du;}}
  x0+=dx0;x1+=dx1;di+=80;tpv+=dv;/*dv*/}
}
