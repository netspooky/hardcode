// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <string.h>
#include <conio.h>
#include "texgen.h"
#include "fire.h"
#include "roto.h"
#include "fmath.h"
#include "lrbfiles.h"
#include "pal.h"
#include "keyboard.h"
#include "fmatrix.h"
#include "wobble.h"

long gettimer();
extern long songpos100;
extern long songpos104;
extern long songpos106;
extern long songpos107;
extern long songpos108;
extern long songpos10C;
extern long songpos10E;
extern long songpos10F;
extern long songpos110;
extern long songpos200;
extern long songpos518;
extern long songpos600;
extern long songpos608;
extern long songpos610;
extern long songpos708;
extern long songpos710;
extern long songpos718;
extern long songpos800;
extern long songpos1100;
extern long songpos1D00;
extern long songposA00;
extern long songpos1400;


extern unsigned char *globalalignedpool;
extern unsigned char *globalscrptr;
void globalcopyscr();

void stonepal(unsigned char*);

static void firescr(unsigned char *dst, unsigned char *src)
{
  long i;
  long carry=0;
  for (i=1; i<199; i++)
    carry=fireline(dst+i*320+4, src+i*320+4, 39, carry);
}

void reversefire()
{
  unsigned char *bufptr=new unsigned char [0x10000*26];
  unsigned char *bufaligned=(unsigned char*)(((unsigned long)bufptr+0xFFFF)&~0xFFFF);
  unsigned char *bufptr2=bufaligned+0x10000*16;

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(bufaligned+23*0x10000);

  int i;
  txDecodeBWMap(maps[0], SVIK_RLE, 0, 32);
  txDecodeBWMap(maps[0], SLBONG_RLE, -1, 63);
  txSmoothMap(maps[1], maps[0]);
  memset(maps[0], 0, 65536);
  for (i=0; i<200; i++)
    memcpy(maps[0]+i*320+32, maps[1]+i*256, 256);

  memset(maps[1], 0, 64000);

  for (i=0; i<128; i++)
  {
    if (!(i&7))
      memcpy(bufptr+0x10000*(i/8), maps[i&1], 0x10000);
    if (i>=121)
      memcpy(bufptr2+0x10000*(i-121), maps[i&1], 0x10000);
    firescr(maps[(~i)&1], maps[i&1]);
  }

  unsigned char pal[192];
  palInterpolCols(pal, 0,0,0, 63,63,63, 64);

  palSetBlackness();

  while ((gettimer()<183500)&&!kbCheckESC());

//  while (inp(0x3da)&8);
//  while (!(inp(0x3da)&8));
  int j;
  for (j=0; (j<352)&&!kbCheckESC(); j++)
  {
//    long nextframetime=xmpGetTimer()+33000;
    long nextframetime=gettimer()+1872;

    if (j<128)
    {
      if (j<64)
        palFadeBlack(pal, 0, 64, j+1);

      i=127-j;
      if (i&7)
      {
        unsigned char *curframe;
        if (i&8)
          curframe=bufptr2+0x10000*((i&7)-1);
        else
          curframe=bufptr2+0x10000*(7-(i&7));
        memcpy((char*)0xA0000, curframe, 64000);
        if (i>8)
        {
          if ((i&7)==7)
            firescr(curframe, bufptr+0x10000*(i/8-1));
          else
            if (i&8)
              firescr(curframe, bufptr2+0x10000*(i&7));
            else
              firescr(curframe, bufptr2+0x10000*(6-(i&7)));
        }
        else
          firescr(maps[0], maps[1]);
      }
      else
      {
        memcpy((void*)0xA0000, bufptr+0x10000*(i/8), 64000);
        firescr(maps[0], maps[1]);
      }
    }
    else
    if (j==128)
      memcpy(maps[0], bufptr, 64000);
    else
    if (j>=224)
    {
      memcpy((char*)(0xA0000), maps[j&1], 64000);
      firescr(maps[(~j)&1], maps[j&1]);
      if (j>=288)
        palFadeWhite(pal, 0, 64, 64+288-j);
    }

    while (gettimer()<nextframetime);

//    _disable();
//    while (inp(0x3da)&8);
//    while (!(inp(0x3da)&8));
//    _enable();
  }
  delete bufptr;

  memset((void*)0xA0000, 0, 64000);
}


static void writetext(int y, int x, const char *text, const unsigned char *font)
{
  unsigned char *scr=(unsigned char*)0xA0000+y*320+x;
  while (*text)
  {
    int i;
    for (i=0; i<16; i++)
      memcpy(scr+i*320, font+i*256+(*text>>4)*256*16+(*text&15)*16, 16);
    text++;
    scr+=16;
  }
}

static void fadecubseen(int left, int top, int wid, int hgt, const unsigned char *tex)
{
  unsigned char *scr=(unsigned char*)0xA0000+top*320+left+32;
  tex+=top*256+left;
  int i,j;
  for (j=0; j<hgt; j++)
  {
    memcpy(scr, tex, wid);
    scr+=320;
    tex+=256;
  }
}


void showpresent()
{
  unsigned char *mempool=new unsigned char [7*65536];
  unsigned char *alignedpool=(unsigned char *)(((unsigned long)mempool+65535)&~65535);

  unsigned char (*textbufs)[65536]=(unsigned char (*)[65536])(alignedpool+0x00000);
  unsigned char (*tempbufs)[65536]=(unsigned char (*)[65536])(alignedpool+0x20000);

  txDecodeBWMap(textbufs[0], FONT_RLE, 0, 1);

  outp(0x3c8,0);
  outp(0x3c9,63);
  outp(0x3c9,63);
  outp(0x3c9,63);
  outp(0x3c9,0);
  outp(0x3c9,0);
  outp(0x3c9,0);

  while (gettimer()<songpos100);

  while (!kbCheckESC())
  {
    if (gettimer()>=songpos100)
      writetext(50, 50, "SPECIAL", textbufs[0]);
    if (gettimer()>=songpos104)
      writetext(70, 70, "DEMO", textbufs[0]);
    if (gettimer()>=songpos106)
      writetext(90, 110, "EDITION", textbufs[0]);
    if (gettimer()>=songpos107)
      writetext(110, 130, "FOR", textbufs[0]);
    if (gettimer()>=songpos108)
      break;
  }

  long starttime=songpos108;
  while (1)
  {
    long t=(gettimer()-starttime)/100;
    if (t>63)
      break;
    outp(0x3c8,0);
    outp(0x3c9,63-t);
    outp(0x3c9,63-t);
    outp(0x3c9,63-t);
  }

//  palSetBlackness();
  memset((void*)0xA0000, 0, 64000);

  // this code generates marble textures that look better, than they
  // ought to...

  int i,j;

  txPlasmaMap(tempbufs[0],4,500,0x17091977);
  txPlasmaMap(tempbufs[1],8,500,1235);
  txPlasmaMap(tempbufs[2],8,500,1143);
  for (i=0; i<65536; i++)
    tempbufs[0][i]=(tempbufs[0][i]>0x0B)?0x07:(tempbufs[0][i]<0x04)?0x00:(tempbufs[0][i]-4);
//  for (i=0; i<65536; i++)
//    tempbufs[0][i]<<=5;

  txDecodeBWMap(tempbufs[3], CUBSEEN_RLE, 0, 18);
  txSmoothMap(textbufs[0], tempbufs[3]);

  signed char fns[768];
  signed char *xfn=(signed char*)(((unsigned long)fns+0xFF)&~0xFF);
  signed char *yfn=(signed char*)(((unsigned long)fns+0x1FF)&~0xFF);
  for (i=0; i<256; i++)
  {
    xfn[i]=-150*fsin(i*0.04);
    yfn[i]=150*fcos(i*0.04);
  }
  txTwirlify(textbufs[1], tempbufs[0], tempbufs[1], tempbufs[2], xfn, yfn);

  for (i=0; i<0x10000; i++)
    tempbufs[3][i]=textbufs[0][i]+textbufs[1][i];

  unsigned char pal[768];
  stonepal(pal);
  palSetPal(pal, 0, 256);

  while (!kbCheckESC())
  {
    if (gettimer()>=songpos10C)
      fadecubseen(0, 0, 256, 115, tempbufs[3]);
    if (gettimer()>=songpos10E)
      fadecubseen(0, 115, 120, 85, tempbufs[3]);
    if (gettimer()>=songpos10F)
      fadecubseen(120, 115, 136, 85, tempbufs[3]);
    if (gettimer()>=songpos110)
      break;
  }

  starttime=songpos110;
  while (!kbCheckESC())
  {
    float frametime=(gettimer()-starttime)*(1.0/65536);
    float fac=170-(fcos(frametime)*20);
    float fac2=0.04+(frametime*frametime)*0.0002;

    for (i=0; i<256; i++)
    {
      xfn[i]=-fac*fsin(i*fac2);
      yfn[i]=fac*fcos(i*fac2);
    }

    txTwirlify(textbufs[1], tempbufs[0], tempbufs[1], tempbufs[2], xfn, yfn);

    unsigned char *scrp=(unsigned char*)0xA0000+32;
    unsigned char *texp0=textbufs[0];
    unsigned char *texp1=textbufs[1];
    for (j=0; j<200; j++)
    {
      for (i=0; i<256; i++)
        *scrp++=*texp0++ +*texp1++;
      scrp+=64;
    }

/*
    float frametime=(xmpGetTimer()-starttime)/1193046.0;
    long xmid=160;
    long ymid=100;
    long zoom=0x8000*(2+fsin(frametime/2));
    float angle=frametime*0.3;

    long zoomx=zoom*fcos(angle);
    long zoomy=zoom*fsin(angle);
    long zoomxd=-zoom*fsin(angle);
    long zoomyd=zoom*fcos(angle);
    long curx=-xmid*zoomx-ymid*zoomxd+32768+128*65536;
    long cury=-xmid*zoomy-ymid*zoomyd+32768+100*65536;

    texturescreen((unsigned char*)0xA0000, tempbufs[3], curx, cury, zoomx, zoomy, zoomxd, zoomyd, 40, 25, 320, ROTO_MOV);
*/
    if (gettimer()>=songpos200)
      break;
  }

  delete mempool;
}







void addtex(float angle, int zoom, int xmid, int ymid, unsigned char *map, int first)
{
  unsigned long zoomx=zoom*fcos(angle)/1.2;
  unsigned long zoomy=zoom*fsin(angle)/1.2;
  unsigned long zoomxd=-zoom*fsin(angle);
  unsigned long zoomyd=zoom*fcos(angle);
  unsigned long curx=-xmid*zoomx-ymid*zoomxd;
  unsigned long cury=-xmid*zoomy-ymid*zoomyd;
  texturescreen(globalscrptr, map, curx, cury, zoomx, zoomy, zoomxd, zoomyd, 40, 25, 320, first?ROTO_MOV:ROTO_ADD);
}

void multimap()
{
//  if (xmpGetPos()>=0x800)
//    return;

  int i,j;
/*
  unsigned char pal[192];
  palInterpolCols(pal+0,0,0,0,0x3F,0x18,0x28,8);
  palInterpolCols(pal+24,0x3F,0x18,0x28,0,0,0,8);
  palInterpolCols(pal+48,0,0,0,0x3F,0x38,0x10,8);
  palInterpolCols(pal+72,0x3F,0x38,0x10,0,0,0,8);
  palInterpolCols(pal+96,0,0,0,0x10,0x3F,0x25,8);
  palInterpolCols(pal+120,0x10,0x3F,0x25,0,0,0,8);
  palInterpolCols(pal+144,0,0,0,0x28,0x30,0x3F,8);
  palInterpolCols(pal+168,0x28,0x30,0x3F,0,0,0,8);
*/

  unsigned char *mempool=new unsigned char [5*65536];
  unsigned char (*alignedpool2)[65536]=(unsigned char (*)[65536])(((unsigned long)mempool+65535)&~65535);

  unsigned char (*maps)[65536]=alignedpool2;


  memcpy(maps[0], globalalignedpool+18*65536, 65536);

  txDecodeBWMap(maps[3], SVIK_RLE, 0, 8);
  txDecodeBWMap(maps[3], SLBONG_RLE, -1, 15);
  txSmoothMap(maps[2], maps[3]);

  txHexagonMap(maps[3], 5, 8, 9, 12, 15);
  txSmoothMap(maps[1], maps[3]);

  palSetBlackness();

  while (gettimer()<songpos518);

  long starttime=songpos518;

  while (!kbCheckESC())
  {
    if (gettimer()>=songpos800)
      break;

    float frametime=(gettimer()-starttime)/(65536.0*0.681818);
    long xmpos=gettimer();

    addtex(1.5*(ffabs(fprem(frametime, 2)-1)-0.5), -65536/2, 160, 100, maps[1], 1);
    if ((xmpos>=songpos600)&&(xmpos<songpos710))
      addtex(frametime/12, 65536*2, 60+fcos(frametime/4)*80, 100+fsin(frametime/5)*80, maps[2], 0);
    if ((xmpos>=songpos608)&&(xmpos<songpos718))
      addtex(-frametime*0.5, -50000+30000*fsin(frametime*0.3+2), 160+fsin(frametime*0.78+1)*50, 100+fsin(frametime+4)*40, maps[0], 0);
    if ((xmpos>=songpos610)&&(xmpos<songpos708))
      addtex(frametime*0.3, 30000+15000*fsin(frametime), 200, 80, maps[0], 0);

    int fpos=fprem(frametime,1)*96+32;
    palFadeWhite(TEST_PAL, 0, 64, (fpos>64)?64:fpos);
    long carry=0;
    for (i=1; i<199; i++)
      carry=fireline((unsigned char*)0xA0000+i*320+4, globalscrptr+i*320+4, 39, carry);
  }
  palSetWhiteness();

  delete mempool;
}




static void writetexty(int x, const char *text, const unsigned char *font)
{
  unsigned char *scr=(unsigned char*)0xA0000+x;
  while (*text)
  {
    int i;
    for (i=0; i<15; i++)
      memcpy(scr+i*320, font+i*256+(*text>>4)*256*16+(*text&15)*16, 16);
    text++;
    scr+=320*15;
  }
}

static void writetext256(unsigned char *dest, int y, const char *text, const unsigned char *font)
{
  dest+=y*256+128-strlen(text)*8;
  while (*text)
  {
    int i,j;
    const unsigned char *src=font+(*text>>4)*256*16+(*text&15)*16;
    for (i=0; i<16; i++)
      for (j=0; j<16; j++)
        if (src[i*256+j])
          dest[i*256+j]=src[i*256+j];
    text++;
    dest+=16;
  }
}


static char texttodisplay[][14]=
{
  "ICH BIN  DOCH",
  "   NICHT BLOD",
  "DU  BIST DOCH",
  "   NICHT BLOD",
  "ER  IST  DOCH",
  "   NICHT BLOD",
  "             ",
  "             ",
  "WIR SIND DOCH",
  "   NICHT BLOD",
  "IHR SEID DOCH",
  "   NICHT BLOD",
  "SIE SIND DOCH",
  "   NICHT BLOD",
  "             ",
  "             ",
  "CREDITS:     ",
  "       PASCAL",
  "        ?HOOK",
  "   -CENSORED-",
  "          SUX",
  "      SCHOLAR",
  "             ",
  "             ",
  "       PASCAL",
  "          ASS",
  "        ?HOOK",
  "        CHAOS",
  "       PASCAL",
  "   -CENSORED-",
  "             ",
  "             ",
  "         DUMM",
  "        ?HOOK",
  "        CHAOS",
  "      SCHOLAR",
  "       PASCAL",
  "          ASS",
  "             ",
  "             ",
  "   GREETS    ",
  "     GO      ",
  "     TO      ",
  "             ",
  "GOTO TEN     ",
  " EX TRITON   ",
  "             ",
  "             ",
  "    NOOON    ",
  "LEGEND DESIGN",
  "FUTURE CREW  ",
  "    SIMPLE   ",
  "  WILDLIGHT  ",
  "       ORANGE",
  "             ",
  "             ",
  "COMPLEX      ",
  "   ACME      ",
  "    LIOZ     ",
  " VACUUM      ",
  "       KLF   ",
  " PURGE       ",
  "             ",
  "             ",
  "   ABSENCE   ",
  "  REALTECH   ",
  "PSYCHIC LINK ",
  "  VALHALLA   ",
  " IGUANA      ",
  " GREEN APPLE ",
  "             ",
  "             ",
  "  ELECTRA    ",
  "        COMA ",
  "      HALCYON",
  "    PULSE    ",
  "  HAZARD     ",
  "RR           ",
  "             ",
  "             ",
  "  KFMF       ",
  "       PLANT ",
  "DAREDEVIL AND",
  "   TRAN FOR  ",
  "PMODE/W      ",
  "    LIGHT    ",
  "             ",
  "             ",
  "MOGAR SLAYER ",
  " MOKU        ",
  "  PINK       ",
  " ALL VISITORS",
  " OF          ",
  "   MCSYM 97  ",
  "             ",
  "             ",
  "   MOM       ",
  "SCREAMAGER   ",
  "   FSE       ",
  "    FEB      ",
  "   FUNK      ",
  "AMABLE       ",
  "             ",
  "             ",
  "        BLANK",
  " STIGMA      ",
  "!!SANCTION!!!",
  "!!SANCTION!!!",
  "  FIVE MUS   ",
  "   XOGRAPHY  ",
  "             ",
  "             "
};

static long myrand()
{
  static seed=1;
  return ((seed=0x015a4e35*seed+1)>>16);
}

void firezoom()
{
//  if (xmpGetPos()>=0x1100)
//    return;

  long starttime=songposA00;

  unsigned char *mempool=new unsigned char [4*65536];
  unsigned char (*alignedpool2)[65536]=(unsigned char (*)[65536])(((unsigned long)mempool+65535)&~65535);

  unsigned char (*maps)[65536]=alignedpool2;

  float (*lissa)[5]=new float [100][5];

  long i;
  long seed=1;
  for (i=0; i<0x10000; i++)
  {
    maps[0][i]=myrand()&63;
    maps[1][i]=myrand()&63;
  }

  txPlasmaMap(maps[2], 6, 10000, 0x12313123);
  txDecodeBWMap(maps[2], FONT_RLE, 0, 63);

  txPlasmaMap(maps[0],6,30000,0x17091977);
  txPlasmaMap(maps[1],6,30000,0x17091977);

  unsigned char pal[192*2];

  palInterpolCols(pal,      0,  0,  0,   0,  0, 16,  16);
  palInterpolCols(pal+48,   0,  0, 16,   0, 16, 32,  16);
  palInterpolCols(pal+96,   0, 16, 32,  32, 48, 48,  16);
  palInterpolCols(pal+144, 32, 48, 48,  63, 63, 63,  16);

  palInterpolCols(pal+192,     25, 25, 25,   0,  0,  0,  16);
  palInterpolCols(pal+48+192,   0,  0,  0,  10, 10, 32,  16);
  palInterpolCols(pal+96+192,  10, 10, 32,  63,  0,  0,  16);
  palInterpolCols(pal+144+192, 63,  0,  0,  63, 63,  0,  16);
  palSetPal(pal, 0, 64);

  for (i=0; i<100; i++)
  {
    lissa[i][0]=myrand()/(float)32768/1.5;
    lissa[i][1]=myrand()/(float)32768;
    lissa[i][2]=myrand()/(float)32768*6;
    lissa[i][3]=myrand()/(float)32768*6;
    lissa[i][4]=32+(myrand()&31);
  }

  while (!kbCheckESC())
  {
    long nextframetime=gettimer()+824;
    float frametime=(gettimer()-starttime)/65536.0;

    if (gettimer()>=songpos1100)
      break;

    if ((frametime>16)&&(frametime<24))
      palFade2(pal, pal+192, 0, 64, (24-frametime)*8);

    unsigned short xmid=128+fsin(frametime/2.2+0.123)*110;
    unsigned short ymid=100+fsin(frametime/2.9+123)*85;
    float angle=0;
    float zoom=65536-frametime*2000;
    if (zoom<49000)
      zoom=49000;
    if (frametime>=15)
    {
      angle=fsin((frametime-15)/10)*M_PI*2/5;
      zoom=49000+(frametime-15)*1600;
    }
    if (frametime>=20)
    {
      zoom=62000-fcos((frametime-20)/2)*5000;
      angle=fsin((frametime-20)/3.5+0.5)*M_PI*2/5;
    }

    if (fprem(frametime/0.34090909+0.9,1)>=0.33333)
      maps[0][256*ymid+xmid]=0;
    else
      maps[0][256*ymid+xmid]=63;
    for (i=0; i<100; i++)
    {
      int x,y,col;
      x=fsin(lissa[i][0]*frametime+lissa[i][2])*120+128;
      y=fsin(lissa[i][1]*frametime+lissa[i][3])*90+100;
      col=lissa[i][4];
      maps[0][x+y*256]=col;
      maps[0][-1+x+y*256]=col;
      maps[0][1+x+y*256]=col;
      maps[0][-256+x+y*256]=col;
      maps[0][+256+x+y*256]=col;
    }

    int msgline=(frametime/0.34090909)-fprem(frametime/0.34090909,1);
    if (msgline<(sizeof(texttodisplay)/14))
      writetexty((msgline&1)?296:8, texttodisplay[msgline], maps[2]);

    if (fprem(frametime/16/0.34090909, 1)<0.5)
      writetext256(maps[0], 160, "INDOOR MUSICSYS", maps[2]);
    else
      writetext256(maps[0], 160, "LASSE REINBONG", maps[2]);

    long carry=0;
    for (i=1; i<199; i++)
      carry=fireline256(maps[1]+i*256+4, maps[0]+i*256+4, 31, carry);

    for (i=0; i<200; i++)
    {
      *(long*)&(maps[1][256*i])=0;
      *(long*)&(maps[1][256*i+252])=0;
    }
    memset(maps[1], 0, 256*2);
    memset(maps[1]+256*198, 0, 256*2);

    unsigned long zoomx=zoom*fcos(angle);
    unsigned long zoomy=zoom*fsin(angle);
    unsigned long zoomxd=-zoom*fsin(angle);
    unsigned long zoomyd=zoom*fcos(angle);
    unsigned long curx=xmid*(65536-zoomx)-ymid*zoomxd+32768;
    unsigned long cury=ymid*(65536-zoomyd)-xmid*zoomy+32768;

    texturescreen(maps[0], maps[1], curx, cury, zoomx, zoomy, zoomxd, zoomyd, 32, 25, 256, ROTO_MOV);

    for (i=1; i<199; i++)
      memcpy((char*)0xA0000+32+i*320, maps[1]+i*256, 256);

    while (gettimer()<nextframetime);
  }

  delete lissa;
  delete mempool;
}


static void maketunnel(long (*map)[41][3], float rose, float zoom, float phase, unsigned long xofs, unsigned long yofs, float roseamp)
{
  float fzoom=zoom*0.4;
  rose*=2*M_PI/(256*4096);
  long *mapp=(long*)map;
  int i,j;
  for (j=0; j<=25; j++)
    for (i=0; i<=40; i++)
    {
      long x,y,intens;
      x=(fpatan(i-20.5,j-12.5)*256/(2*M_PI)+128)*4096;
      float rsqrt=4096/fsqrt(fsqr(i-20.5)+fsqr(j-12.5))*(1+roseamp*fsin(phase+x*rose));
      y=zoom*rsqrt;
      intens=64*4096-fzoom*rsqrt;
      *mapp++=xofs+x;
      *mapp++=yofs+y;
      *mapp++=(intens<4096)?4096:(intens>=(63*4096))?63*4096:intens;
    }
}

static float cosinterpol(float t)
{
  if (t<0)
    t=0;
  if (t>1)
    t=1;
  return (1-fcos(t*M_PI))/2;
}

static float wavephong(float x)
{
  float c=fcos(x);
  return (c<0)?0:c;
}

void wobbler()
{
//  if (xmpGetPos()>=0x1D00)
//    return;

  long starttime=songpos1400;
  int i,j;

  unsigned char *mapptr=new unsigned char [65536*4];

  unsigned char (*maps)[65536]=(unsigned char (*)[65536])(((unsigned long)mapptr+0xFFFF)&~0xFFFF);

/*
  txPlasmaMap(maps[0], 8, 10000, 0x12345678);
  txPlasmaMap(maps[1],8,100,1235);
  txPlasmaMap(maps[2],8,400,1143);

  signed char fns[768];
  signed char *xfn=(signed char*)(((unsigned long)fns+0xFF)&~0xFF);
  signed char *yfn=(signed char*)(((unsigned long)fns+0x1FF)&~0xFF);
  for (i=0; i<256; i++)
  {
    xfn[i]=-70*fsin(i*0.05);
    yfn[i]=70*fcos(i*0.05);
  }
  txTwirlify(maps[1], maps[0], maps[1], maps[2], xfn, yfn);

  txDecodeBWMap(maps[2], CUBSEEN_RLE, 0, 255);
  txSmoothMap(maps[0], maps[2]);
  txSmoothMap(maps[2], maps[0]);
  txSmoothMap(maps[0], maps[2]);
  txSmoothMap(maps[2], maps[0]);

  for (i=0; i<256; i++)
  {
    xfn[i]=-10*fsin(i*0.05);
    yfn[i]=10*fcos(i*0.05);
  }
  txTwirlify(maps[0], maps[1], maps[2], maps[2], xfn, yfn);
*/

  memcpy(maps[0], globalalignedpool+19*0x10000, 0x10000);

  long (*mapposbuf)[26][41][3]=new long [3][26][41][3];

  for (j=0; j<=64; j++)
    for (i=0; i<256; i++)
    {
//      maps[1][j*256+i]=((i*j)>>6)+128-j-j;
      float intens=fexp(1.5-(64-j)/13.0)-0.02;
      if (intens>1)
        intens=1;
      maps[1][j*256+i]=i*intens+128*(1-intens);
      maps[1][(j+65)*256+i]=i+(255-i)*j/64;
    }

  unsigned char pal[768];
  unsigned char pal2[768];
  unsigned char pal3[768];
  palInterpolCols(pal,     5,8,1, 6,3,30, 64);
  palInterpolCols(pal+192, 6,3,30, 10,35,60, 64);
  palInterpolCols(pal+384, 10,35,60, 0,0,0, 64);
  palInterpolCols(pal+576, 0,0,0, 63,0,0, 32);
  palInterpolCols(pal+576+32*3, 63,0,0, 63,63,0, 32);
  palInterpolCols(pal2, 0,0,0, 63,63,63, 256);
  palMakeBCW(pal3, 16, 32, 64, 128, 128);
  palSetWhiteness();

  while (!kbCheckESC())
  {
    if (gettimer()>=songpos1D00)
      break;

    float frametime=(gettimer()-starttime)/(65536.0*0.681818);

    if (frametime<0.5)
      palFadeWhite(pal2, 0, 256, frametime*2*64);
    else
    if (frametime<1.5)
      palFade2(pal3, pal2, 0, 256, (frametime-0.5)*64);

    if ((frametime>8)&&(frametime<12))
      palFade2(pal, pal3, 0, 256, (frametime-8)*16);

    if (frametime>68)
      palFadeBlack(pal, 0, 256, (72-frametime)*16);

    if (frametime<38)
    {
      int part=0;
      if (frametime>=12)
        part=1;

      if (frametime<12)
      {
        for (j=0; j<=25; j++)
          for (i=0; i<=40; i++)
          {
            float rad=fsqrt((i-20)*(i-20)+(j-12)*(j-12))-frametime*8;
            float amp=4096/2/(8-rad)*8;
            if (rad>0)
              amp=rad=0;
            float rad2=fsqrt((i-10)*(i-10)+(j-7)*(j-7))-frametime*8+10;
            float amp2=4096/1.5/(4-rad2)*4;
            if (rad2>0)
              amp2=rad2=0;
            float rad3=fsqrt((i-27)*(i-27)+(j-9)*(j-9))-frametime*8+18;
            float amp3=4096/1.5/(4-rad3)*4;
            if (rad3>0)
              amp3=rad3=0;
            float s1=fsin(rad)*amp;
            float s2=fsin(rad2)*amp2;
            float s3=fsin(rad3)*amp3;
            mapposbuf[0][j][i][0]=-32*4096+i*8*4096+(i-20)*s1+(i-10)*s2+(i-27)*s3;
            mapposbuf[0][j][i][1]=j*8*4096+(j-12)*s1+(j-7)*s2+(j-9)*s3;
            mapposbuf[0][j][i][2]=63*4096+50*amp*wavephong(rad)+50*amp2*wavephong(rad2)+50*amp3*wavephong(rad3);
          }
      }

      if ((frametime>8)&&(frametime<38))
      {
        float parttime=frametime-8;
        float fac1=parttime/10;
        if (fac1>0.5)
          fac1=0.5;
        float fac2=(parttime-10)/20;
         if (fac2>0.33)
        fac2=0.33;
        if (fac2<0)
          fac2=0;
        float fac3=(parttime-15)/20;
        if (fac3>0.2)
          fac3=0.2;
        if (fac3<0)
          fac3=0;
        for (j=0; j<=25; j++)
          for (i=0; i<=40; i++)
          {
            float cpt=fcos(parttime/2);
            float spt=fsin(parttime/2);
            float x=(i+4)*cpt-(j+4)*spt;
            float y=(j-4)*cpt+(i-4)*spt;
            x*=(1+fsin(y/6+parttime)*fac1);
            y*=(1+fsin(x/4+parttime/2)*fac2);
            x*=(1+fsin(y/3+parttime/3)*fac3);

            mapposbuf[1][j][i][0]=x*8*4096;
            mapposbuf[1][j][i][1]=y*8*4096;
            mapposbuf[1][j][i][2]=63*4096;
            float rad=fsqrt((i-20)*(i-20)+(j-12)*(j-12))-parttime*8+15;

            if ((rad<0)&&(rad>(-2*M_PI*6)))
            {
              float srd=fsin(rad)*4096;
              mapposbuf[1][j][i][0]+=x*srd;
              mapposbuf[1][j][i][1]+=y*srd;
            }
          }
      }
      if (frametime>33)
      {
        long xofs=(frametime-38)*4096*23.1234;
        long yofs=(frametime-38)*4096*70;
        maketunnel(mapposbuf[0], 5, 500, 0, xofs, yofs, 0);
      }

      float rat=0;
      if (frametime>8)
        rat=(1-fcos((frametime-8)/4*M_PI))/2;
      if (frametime>12)
        rat=1;
      if ((frametime>33)&&(frametime<38))
        rat=(1+fcos((frametime-33)/5*M_PI))/2;
      if (rat<0)
        rat=0;
      if (rat>1)
        rat=1;
      rat*=4096;
      wobblemorfer(mapposbuf[0], mapposbuf[0], mapposbuf[1], 4096-rat, rat);
    }
    else
    {
      long *mpp=(long*)(mapposbuf[0]);
      long xofs=(frametime-38)*4096*23.1234;
      long yofs=(frametime-38)*4096*70;
      float zoom=500;
      float rosephase=frametime*2;
      float roses=1;
      float roseamp=0;
      if (frametime>39)
        roseamp=0.8*cosinterpol((frametime-39)/2);
      if (frametime>42)
      {
        roses=(int)(frametime-41);
        roseamp=0.1*(50-frametime)*fcos((frametime-42)*M_PI);
      }
      if (frametime>46)
      {
        roses=5;
        roseamp=0.4-0.2*cosinterpol((frametime-46)*2);
        rosephase+=cosinterpol(frametime-46)*(frametime-46)*3;
      }
      if (frametime>48)
      {
        zoom=500*(1+0.8*cosinterpol((frametime-48)/8)*fsin((frametime-48)*M_PI));
      }
      if (frametime>55.5)
      {
        roses=3;
        roseamp=0.6;
        rosephase=frametime*2;
      }
      if (frametime>56)
      {
        zoom=500*(1+0.8*cosinterpol((60-frametime)/4)*fsin((frametime-48)*M_PI));
      }
      if (frametime>60)
        roseamp=0.6*fcos((frametime-60)*M_PI)*cosinterpol((66-frametime)/4);
      if (frametime>62)
        zoom=500*(1+cosinterpol((frametime-62))*0.85*fsin(frametime*1.5));

      maketunnel(mapposbuf[0], roses, zoom, rosephase, xofs, yofs, roseamp);
      for (i=0; i<(26*41*3); i++)
        *mpp++<<=12;
    }
    gtexturewobbler((unsigned char*)0xA0000, maps[0], mapposbuf[0], maps[1]);
  }
  memset((void*)0xA0000, 0, 64000);

  delete mapptr;
  delete mapposbuf;
}

