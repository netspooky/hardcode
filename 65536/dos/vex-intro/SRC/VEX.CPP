/*****************************************************************************
                                  ATTENTION!
                           this source is VOTEWARE,
              you may only use it to the conditions listed below:

  -You may modify it, or use parts of it in your own source as long as
    this header stays on top of all files containing this source.
  -You must give proper credit to the author, Niklas Beisert / pascal.
  -You may not use it in commercial productions without the written
    permission of the author.
  -AND MOST IMPORTANT: you have to buy an Assembly '94 CD-ROM
    by Sound Solutions (if you don't have it already) and vote for VEX-InTrO
    in the PC-64k-Intro-Compo! (if you have already sent your voting card,
    buy another one and fill it out CORRECTLY!!!)
*****************************************************************************/



// the main program / the scroller with lissajous figures / the "fire"-plasma

#include <alloc.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <dos.h>
#include <conio.h>
#include <io.h>
//#include <fcntl.h>
#include "ovlio.h"
#include "colors2.h"
#include "ints.h"
#include "matrix.h"
#include "vga13x2.h"
#include "polygons.h"
#include "timeruse.h"
#include "keyboard.h"
#include "draw3d.h"
#include "sinplasa.h"

#pragma startup tuInstall
#pragma exit tuClose
#pragma startup InstallZeroDivide
#pragma exit DeinstallZeroDivide
#pragma startup InitKey
#pragma exit CloseKey


extern long* SinTab;

#define STEPSIZE 2
#define NUMPOINTS (2048>>STEPSIZE)

unsigned scrpage;
long curtime=0;

short initscenery(short file);
void closescenery();
void getscenery();
short initpalette(short file);
void setpalette();
void closepalette();
short inittexture(short file);
void closetexture();
short initstars(short file);
void drawstars();
void closestars();

//unsigned _stklen=8192;
unsigned _stklen=16000;

vector *p3;

struct lissapar
{
  long a[3];
  int b[3];
  int c[3];
};
struct lissalist
{
  lissapar l;
  long tv, td;
};
lissalist list[]=
  {{{{dtol(0), dtol(0), dtol(0)}, {0, 0, 0}, {0, 0, 0}}, dtol(2), dtol(5)},
   {{{dtol(1), dtol(1), dtol(0)}, {0, 0, 0}, {512, 0, 0}}, dtol(2), dtol(5)},
   {{{dtol(1), dtol(1), dtol(10)}, {100, 100, 0}, {512, 0, 0}}, dtol(5), dtol(10)},
   {{{dtol(2), dtol(4), dtol(3)}, {123, 320, 12}, {0, 0, 0}}, dtol(5), dtol(5)},
   {{{dtol(7), dtol(7), dtol(8)}, {100, 100, 300}, {512, 0, 0}}, dtol(10), dtol(5)},
   {{{dtol(0), dtol(0), dtol(0)}, {0, 0, 0}, {0, 0, 0}}, dtol(0), dtol(3)},
   {{{dtol(0), dtol(7), dtol(13)}, {2048, -23, -234}, {0, 0, 0}}, dtol(5), dtol(3)},
   {{{dtol(17), dtol(23), dtol(40)}, {123, 234, 56}, {0, 0, 0}}, dtol(7), dtol(3)},
   {{{dtol(29), dtol(21), dtol(50)}, {243, 621, 334}, {0, 0, 0}}, dtol(7), dtol(3)},
   {{{dtol(22), dtol(25), dtol(20)}, {233, 312, 142}, {0, 0, 0}}, dtol(10), dtol(3)},
   {{{dtol(19), dtol(-20), dtol(28)}, {443, 121, 144}, {0, 0, 0}}, dtol(11), dtol(3)},
   {{{dtol(0), dtol(0), dtol(0)}, {0, 0, 0}, {0, 0, 0}}, dtol(0), dtol(0)}};

#define NUMLISSA (sizeof list/sizeof(lissalist))

void sett0(lissapar& p, long t)
{
  p.c[0]+=IntMul(t, p.b[0]);
  p.c[1]+=IntMul(t, p.b[1]);
  p.c[2]+=IntMul(t, p.b[2]);
}

lissapar getmiddle(const lissapar& p1, const lissapar& p2, long t, long T)
{
  lissapar lp=p1;
  long smooth=(SinTab[(IntMulDiv(1024, t, T)-512)&2047]+65536)>>1;
  lp.a[0]+=IntMul(p2.a[0]-p1.a[0], smooth);
  lp.a[1]+=IntMul(p2.a[1]-p1.a[1], smooth);
  lp.a[2]+=IntMul(p2.a[2]-p1.a[2], smooth);
  lp.b[0]+=IntMul(p2.b[0]-p1.b[0], smooth);
  lp.b[1]+=IntMul(p2.b[1]-p1.b[1], smooth);
  lp.b[2]+=IntMul(p2.b[2]-p1.b[2], smooth);
  lp.c[0]+=IntMul(p2.c[0]-p1.c[0], smooth)-IntMul(p2.b[0], IntMul(smooth, T));
  lp.c[1]+=IntMul(p2.c[1]-p1.c[1], smooth)-IntMul(p2.b[1], IntMul(smooth, T));
  lp.c[2]+=IntMul(p2.c[2]-p1.c[2], smooth)-IntMul(p2.b[2], IntMul(smooth, T));
  return lp;
}

extern "C" void calclissapoints(vector *, short, long, long, long, long, long, long);

void makelissa(const lissapar& p, long t)
{
  long a,b,c,d,e,f;
  a=p.a[0]<<STEPSIZE;
  b=p.a[1]<<STEPSIZE;
  c=p.a[2]<<STEPSIZE;
  d=t*p.b[0]+itol(p.c[0])-1024*p.a[0];
  e=t*p.b[1]+itol(p.c[1])-1024*p.a[1];
  f=t*p.b[2]+itol(p.c[2])-1024*p.a[2];
  calclissapoints(p3, NUMPOINTS, a, b, c, d, e, f);
}

void memcpybyte(void *dst, void *src, short n)
{
  asm push ds
  asm cld
  asm mov cx,n
  asm lds si,src
  asm les di,dst
  asm rep movsb
  asm pop ds
}

void vgaViewLine(unsigned short l)
{
  outp(0x3d4, 0x0d);
  outp(0x3d5, l);
  outp(0x3d4, 0x0c);
  outp(0x3d5, (l>>8));
}

char *text;

unsigned short curtextline[20];

void getnextline()
{
  short i,j;
  for (i=0; i<20; i++)
    if (!text[i]||text[i]=='\r')
      break;
  memset(curtextline, 0, 40);
  for (j=0; j<i; j++)
    curtextline[j+((20-i)>>1)]=(toupper(*text++)-0x20)<<2;
  if (*text=='\r')
    text++;
  while (*text=='\n')
    text++;
}

void plotline(long l)
{
  char *p=(char*)0xA0000000+(l%204)*80;
  outpw(0x3c4, 0x0f02);
  outpw(0x3ce, 0x4105);
  char lineofs=l%20;
  if (!lineofs)
    getnextline();
  for (int i=0; i<20; i++)
    memcpybyte(p+i*4, (char*)0xA000C000+curtextline[i]+lineofs*256, 4);
  memcpybyte(p+16320, p, 80);
  memcpybyte(p+32640, p, 80);
  outpw(0x3ce, 0x4005);
}

struct plaspar
{
  long p;
  long ft;
  long f;
  short alpha;
  short omega;
};

plaspar par[8]=
  {{dtol(600), dtol(2121.12384), dtol(23.72346), 0, 44},
   {dtol(30), dtol(1032.321234), dtol(7.45923), 512, -24},
   {dtol(100), dtol(923.5741), dtol(66.247345), 1024, 13},
   {dtol(30), dtol(-1014.321234), dtol(23.54023), 52, -43},
   {dtol(123), dtol(-2465.4741), dtol(38.27345), 104, -49},
   {dtol(46), dtol(-1126.321234), dtol(12.92123), 51, 28},
   {dtol(1314), dtol(2217.5741), dtol(42.27445), 124, -40},
   {dtol(70), dtol(-1838.2234), dtol(12.21323485), 1536, 10}};



static void SplitView(unsigned v, unsigned s)
{
  disable();
  outp(0x3d4, 0x0C);
  outp(0x3d5, (((v&~15)*5)>>8));
  outp(0x3d4, 0x0D);
  outp(0x3d5, (v&~15)*5);
  vgaWaitRetrace();
  outp(0x3d4, 0x08);
  outp(0x3d5, inp(0x3d5)&0xE0|(v&15));

  outp(0x3d4, 0x18);
  outp(0x3d5, s);
  outp(0x3d4, 0x07);
  outp(0x3d5, inp(0x3d5)&~0x10|((s>>4)&0x10));
  outp(0x3d4, 0x09);
  outp(0x3d5, inp(0x3d5)&~0x40);
  enable();
  tuUpdate();
}

#define linebyte(l) ((l)*160)
#define scr(l) MK_FP(0xb800, linebyte(l))



void writestr(char *s)
{
  short a=strlen(s);
  asm mov ah,40h
  asm mov bx,1
  asm mov cx,a
  asm push ds
  asm lds dx,s
  asm int 21h
  asm pop ds
}

void main()
{
  writestr("VEX v1.1s. DO NOT SPREAD THIS VERSION!\r\n\r\n\a");

  if (coreleft()<450000)
  {
    writestr("you should have at least 512k of free dos-mem to run this intro\r\n");
    writestr("maybe a bit more than that...\r\n");
    return;
  }

// load the scenery
  short file=oopen("vexintro.3ds");
  if (file<0)
  {
    writestr("file error\r\n");
    return;
  }
  if (!initscenery(file))
    return;
  if (!inittexture(file))
    return;
  if (!initstars(file))
    return;
  if (!initpalette(file))
    return;
  long endtime;
  oread(file, &endtime, 4);
  oclose(file);

  asm mov ah,15
  asm int 0x10
  asm cmp al,3
  asm je modeok
  asm jmp modewrong
modeok:

  asm mov ah,2
  asm xor bh,bh
  asm mov dx,0x1900
  asm int 0x10
  memcpy(scr(50), scr(0), linebyte(25));
  SplitView(800, 400);
  memcpy(scr(0), scr(63), linebyte(12));
  memcpy(scr(12), scr(50), linebyte(13));
  int f=oopen("offwego.bin");
  oread(f, scr(25), linebyte(25));
  oclose(f);
  *((char*)scr(25)+1)=0;
#define imaxa 100
  short i;
  for (i=0; i<=imaxa; i++)
    SplitView(208L*i*i/(imaxa*imaxa)+192, 208L*i*i/(imaxa*imaxa)+208);

modewrong:

  unsigned char (*pals)[256][3]=new unsigned char [3][256][3];

  GetColors(pals[0], 0, 256);
  memset(pals[1], 0, 768);
  for (i=0; i<128; i+=4)
  {
    MakeFadeStep(pals[2], pals[0], pals[1], 256, i);
    tuDisable();
    vgaWaitRetrace();
    SetColors(pals[2], 0, 256);
    tuEnable();
    tuUpdate();
  }

  asm mov ax,0x13
  asm int 0x10

// load the crossfadepic in screen mem
  SetColors(pals[1], 0, 256);
  f=oopen("pdpres.scr");
  oread(f, (char*)0xA0000000, 64000);
  oclose(f);

  pals[0][0][0]=pals[0][0][1]=pals[0][0][2]=0x00;
  pals[0][1][0]=pals[0][1][1]=pals[0][1][2]=0x40;
  pals[0][2][0]=pals[0][2][1]=pals[0][2][2]=0x80;
  pals[0][3][0]=pals[0][3][1]=pals[0][3][2]=0xC0;
  memcpy(pals[0][4], pals[0][0], 12);
  memcpy(pals[0][8], pals[0][0], 12);
  memcpy(pals[0][12], pals[0][0], 12);

// wait
  tuResetTimer();
  while (tuGetTimer()<dtol(3.8));

// fade in
  for (i=0; i<128; i++)
  {
    MakeFadeStep(pals[2], pals[1], pals[0], 256, i);
    tuDisable();
    vgaWaitRetrace();
    tuEnable();
    tuUpdate();
    SetColors(pals[2], 0, 256);
  }

  memset(pals[1][0], 0x00, 12);
  memset(pals[1][4], 0x40, 12);
  memset(pals[1][8], 0x80, 12);
  memset(pals[1][12], 0xC0, 12);

// wait
  while (tuGetTimer()<dtol(9.7));
// crossfade
  for (i=0; i<128; i++)
  {
    MakeFadeStep(pals[2], pals[0], pals[1], 256, i);
    tuDisable();
    vgaWaitRetrace();
    SetColors(pals[2], 0, 256);
    tuEnable();
    tuUpdate();
  }

//wait
  while (tuGetTimer()<dtol(15.5));

  vgaWaitRetrace();
  vgaInit();
  memset(pals[0], 255, 768);
  SetColors(pals[2], 0, 256);
  outp(0x3c4, 0xf02);
  memset((char*)0xA0000000, 0, 32768);
  memset((char*)0xA0008000, 0, 32768);

// display the scenery
  tuResetTimer();
  scrpage=0;
  short frames=1;
  long lasttime=0;
  while (endtime>curtime)
  {
    curtime=lasttime;
//    curtime+=((70*tuGetTimer()+dtol(0.1))&0xFFFF0000)/70;
//    tuResetTimer();

// update the sound buf... (actually there is none in this version ;)
    tuUpdate();

    scrpage=(scrpage+1)&3;

    vgaFillScreen(scrpage, 0);

    drawstars();
    getscenery();

// don't update the soundbuf now
    tuDisable();
    vgaViewPage(scrpage);
    vgaWaitRetrace();
    lasttime=tuGetTimer();
    setpalette();
// soundbuf may be updated again
    tuEnable();
    frames++;
  }

// free some mem
  closetexture();
  closepalette();
  closescenery();
  closestars();

  outpw(0x3c4, 0xf02);
  memset((char*)0xA0000000, 0, 32768);
  vgaViewPage(0);

  char *scr=new char[4000];
  char *ps=new char[2048];
  makesintab(ps, 31);

// 80*50 graphics
  outp(0x3d4, 9);
  outp(0x3d5, (inp(0x3d5)&0xE0|0x07));
  short c, cb;
// firepalette
  InterpolCols(pals[0], 256, 255, 128, 0, 255, 128, 0);
  InterpolCols(pals[1]+0, 128, 0, 0, 128, 255, 128, 0);
  InterpolCols(pals[1]+128, 128, 255, 128, 0, 255, 255, 0);

  tuResetTimer();
  unsigned short page=0;
  curtime=0;
  frames=0;
  while (1)
  {
    page=1-page;
    long p;
    long fx;
    long fy;
    memset(scr, 0, 4000);  // 80*50 = 4000 ;)
    short k;
    for (k=0; k<8; k++)  // 8 operator sine plasma
    {
      short a=par[k].alpha+IntMul(par[k].omega, curtime);
      fx=IntMul(SinTab[(a+512)&2047], par[k].f);
      fy=IntMul(SinTab[a&2047], par[k].f);
      p=par[k].p+IntMul(par[k].ft, curtime)-25*fy-40*fx;
      char *scrp=scr;
      for (i=0; i<50; i++)
      {
        plasmaline(ps, scrp, 80, p, fx);
        p+=fy;
        scrp+=80;
      }
    }
    memcpy((char*)0xA0000000+(page<<14), scr, 4000);
    tuDisable();
    vgaViewPage(page);
    vgaWaitRetrace();
    curtime=tuGetTimer();
    if (frames<=128)
    {
    // fade in
      MakeFadeStep(pals[2], pals[0], pals[1], 256, frames);
      SetColors(pals[2], 0, 256);
      frames++;
    }
    if (curtime>dtol(15))
    {
    // fade out
      if (frames>256)
        break;
      if (frames==129)
        memset(pals[0], 0, 768);
      MakeFadeStep(pals[2], pals[0], pals[1], 256, 256-frames);
      SetColors(pals[2], 0, 256);
      frames++;
    }
    tuEnable();
    tuUpdate();
  }
  tuEnable();
  tuUpdate();
  while (tuGetTimer()<dtol(18));
  delete ps;
  delete scr;

  SetColorsBlack();
  outpw(0x3c4, 0xf02);
  memset((char*)0xA0000000, 0, 32768);
  vgaViewPage(0);

  outp(0x3d4, 9);
  outp(0x3d5, (inp(0x3d5)&0xE0|0x01));

  p3=new vector[NUMPOINTS];
  char *p[2];
  p[0]=new char[NUMPOINTS*3];
  p[1]=new char[NUMPOINTS*3];
  short n[2];
  unsigned short pos[2];
  if (!p3||!p[0]||!p[1])
    return;

  unsigned char c2[8][3]={0,0,0,0x70,0x70,0x70,0x9a,0x9a,0x9a,0xc0,0xc0,0xc0,
                          0,0xca,0,0x30,0xc4,0x2c,0x5c,0xc4,0x58,0x84,0xc0,0x84};

  char *fnt=new char[20480];
  f=oopen("hooks.fnt");
  oread(f, fnt, 20480);
  oclose(f);

  f=oopen("scroll.txt");
  short len=oseek(f, 0, SEEK_END);
  oseek(f, 0, SEEK_SET);
  char *otext=new char[len+1];
  text=otext;
  oread(f, text, len);
  text[len]=0;
  oclose(f);

  short j;
  outp(0x3c4, 0x02);
  for (i=0; i<20480; i++)
  {
    outp(0x3c5, (1<<(i&3)));
    *(char*)(0xA000C000+(i>>2))=fnt[i]<<5;
  }
  delete fnt;

  memset(pals[0], 0, 768);

  for (i=0; i<8; i++)
    for (j=0; j<32; j++)
    {
      if (c2[i][0]+(int)j*4>255)
        pals[1][i*32+j][0]=255;
      else
        pals[1][i*32+j][0]=c2[i][0]+(int)j*4;
      if (c2[i][1]+(int)j*8>255)
        pals[1][i*32+j][1]=255;
      else
        pals[1][i*32+j][1]=c2[i][1]+(int)j*8;
      if (c2[i][2]+(int)j*12>255)
        pals[1][i*32+j][2]=255;
      else
        pals[1][i*32+j][2]=c2[i][2]+(int)j*12;
    }

  for (i=0; i<202; i++)
    plotline(i);
  long scrpos=0;

  n[0]=n[1]=0;
  page=0;
  tuResetTimer();
  long tm=0;
  int xform=0;
  int curlis=0;
  curtime=0;
  long nexttime=0;
  long lastscroll=0;
  short frmfad=0;
  while (1)
  {
    page=1-page;
    curtime=nexttime;
    tuUpdate();

    unsigned short newpos=((scrpos+page*204)%408)*80;
    rdrawpointlst(p[page], n[page], pos[page]);

    if ((curtime-lastscroll)>dtol(1/50.0))
    {
      plotline(scrpos+202);
      scrpos++;
      lastscroll=curtime;
    }

    curtime-=tm;

    lissapar lp;
    if (!xform)
    {
      // do interpolate
      if (list[curlis].tv<=curtime)
      {
        xform=1;
        sett0(list[curlis].l, list[curlis].tv);
        tm+=list[curlis].tv;
        curtime-=list[curlis].tv;
        if ((curlis+1)==NUMLISSA)
          break;
      }
    }
    else
    {
      // do not interpolate
      if (list[curlis].td<=curtime)
      {
        xform=0;
        tm+=list[curlis].td;
        curtime-=list[curlis].td;
        curlis++;
      }
    }
    if (!xform)
      // normal lissajous operation
      lp=list[curlis].l;
    else
      // interpolate between two figures
      lp=getmiddle(list[curlis].l, list[curlis+1].l, curtime, list[curlis].td);

    // calc the points
    makelissa(lp, curtime);
    curtime+=tm;
    matrix m,x;
    makematroty(m, IntMul(curtime, 178));
    makematrotz(x, IntMul(curtime, 80));
    matmul(m, x, m);
    makematrotx(x, IntMul(curtime, -50));
    matmul(m, x, m);
    vector xv={0,0,dtol(3)};
    matxlate(m, xv);
    vecxform(p3, p3, m, NUMPOINTS);

    pos[page]=newpos;

    // project the points
    n[page]=calcpoints3d(p[page], p3, NUMPOINTS, dtol(200), dtol(180), dtol(5), dtol(8));
    outpw(0x3ce, 0x1003);
    // replace the old lissajous points by the new ones
    xchgpointlst(p[page], n[page], pos[page]);
    outpw(0x3ce, 0x0003);

    tuDisable();
    vgaViewLine(pos[page]);
    vgaWaitRetrace();
    nexttime=tuGetTimer();
    if (frmfad<=128)
    {
    // fade in
      MakeFadeStep(pals[2], pals[0], pals[1], 256, frmfad);
      SetColors(pals[2], 0, 256);
      frmfad+=2;
    }

    tuEnable();
  }

  for (i=64; i>=0; i--)
  {
  // fade out
    MakeFadeStep(pals[2], pals[0], pals[1], 256, i*2);
    tuDisable();
    vgaWaitRetrace();
    SetColors(pals[2], 0, 256);
    tuEnable();
    tuUpdate();
  }

  vgaClose();
  asm mov ax,3
  asm int 0x10


  delete pals;
  delete p3;
  delete text;
  delete p[0];
  delete p[1];

  memset(scr(25), 0, linebyte(25));
  asm mov ah,2
  asm xor bh,bh
  asm mov dx,0x1900
  asm int 0x10
  SplitView(400, 400);
  f=oopen("vexansi.bin");
  oread(f, scr(50), linebyte(25));
  oclose(f);
  memcpy(scr(0), scr(65), linebyte(10));
  memcpy(scr(10), scr(50), linebyte(15));
#define imaxb 70
  for (i=imaxb; i>=0; i--)
    SplitView(240L*i*i/(imaxb*imaxb)+160, 240L*i*i/(imaxb*imaxb)+240);
  SplitView(800, 400);
  memcpy(scr(0), scr(50), linebyte(25));
  SplitView(0, 400);
  asm mov ah,2
  asm xor bh,bh
  asm mov dx,0x1742
  asm int 0x10
}
