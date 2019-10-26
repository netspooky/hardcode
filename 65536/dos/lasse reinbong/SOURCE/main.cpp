// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <conio.h>
#include <string.h>
#include <bios.h>
#include "lrbfiles.h"
#include "keyboard.h"
#include "fmath.h"
#include "xmplay.h"
#include "binfmem.h"
#include "ims.h"
#include "mcp.h"

unsigned char *globalalignedpool;
unsigned char *globalscrptr;

void setsmode(unsigned short);
#pragma aux setsmode parm [ax] = "int 10h"

void reversefire();
void showpresent();
void vectorface();
void vectorfacepre();
void multimap();
void trefoilknot();
void firezoom();
void THEBRAID();
void wobbler();
void ente();

void globalcopyscr()
{
  memcpy((char*)0xA0000, globalscrptr, 64000);
}

long mulshr16(long,long);
#pragma aux mulshr16 parm [eax] [edx] value [eax] = "imul edx" "shrd eax,edx,16"

long gettimer()
{
  return mcpGet(-1, mcpGTimer);
}

long songpos100;
long songpos104;
long songpos106;
long songpos107;
long songpos108;
long songpos10C;
long songpos10E;
long songpos10F;
long songpos110;
long songpos200;
long songpos518;
long songpos600;
long songpos608;
long songpos610;
long songpos708;
long songpos710;
long songpos718;
long songpos800;
long songpos1100;
long songpos1D00;
long songposA00;
long songpos1400;

void main()
{
  imsinitstruct is;
  imsFillDefaults(is);
  is.bufsize=32768;
  is.reverb=25;
  is.chorus=50;
  if (!imsInit(is))
  {
    cputs("could not init sound\r\n");
    return;
  }

  xmodule xmod;
  mbinfile fil;
  fil.open(SONG_XM, SONG_XM_LEN, fil.openro);
  if (xmpLoadModule(xmod, fil))
  {
    cputs("could not load module\r\n");
    return;
  }
  fil.close();

  const int nsongpos=22;
  int songpostab[nsongpos][2];
  songpostab[0][0]=0x10000;  // this sux! one should make a function
  songpostab[1][0]=0x10400;  // that does all this automatically.
  songpostab[2][0]=0x10600;
  songpostab[3][0]=0x10700;  // but this is the only way to get good sync.
  songpostab[4][0]=0x10800;
  songpostab[5][0]=0x10C00;
  songpostab[6][0]=0x10E00;
  songpostab[7][0]=0x10F00;
  songpostab[8][0]=0x11000;
  songpostab[9][0]=0x20000;
  songpostab[10][0]=0x51800;
  songpostab[11][0]=0x60000;
  songpostab[12][0]=0x60800;
  songpostab[13][0]=0x61000;
  songpostab[14][0]=0x70800;
  songpostab[15][0]=0x71000;
  songpostab[16][0]=0x71800;
  songpostab[17][0]=0x80000;
  songpostab[18][0]=0x110000;
  songpostab[19][0]=0x1D0000;
  songpostab[20][0]=0xA0000;
  songpostab[21][0]=0x140000;
  int i;
  for (i=0; i<nsongpos; i++)
    songpostab[i][1]=-1;
  xmpPrecalcTime(xmod, 0, songpostab, nsongpos, 100000);
  songpos100=songpostab[0][1];
  songpos104=songpostab[1][1];
  songpos106=songpostab[2][1];
  songpos107=songpostab[3][1];
  songpos108=songpostab[4][1];
  songpos10C=songpostab[5][1];
  songpos10E=songpostab[6][1];
  songpos10F=songpostab[7][1];
  songpos110=songpostab[8][1];
  songpos200=songpostab[9][1];
  songpos518=songpostab[10][1];
  songpos600=songpostab[11][1];
  songpos608=songpostab[12][1];
  songpos610=songpostab[13][1];
  songpos708=songpostab[14][1];
  songpos710=songpostab[15][1];
  songpos718=songpostab[16][1];
  songpos800=songpostab[17][1];
  songpos1100=songpostab[18][1];
  songpos1D00=songpostab[19][1];
  songposA00=songpostab[20][1];
  songpos1400=songpostab[21][1];

  cputs("LASSE REINB™NG 4 IMS, (c) '97 pascal\r\n");

  finit();

  unsigned char *testmem=new unsigned char [4*1024*1024];
  if (!testmem)
  {
    cputs("you need more than 4mb to run this intro.\r\n");
    return;
  }
  delete testmem;

  cputs("please wait while precalculating...\r\n");

  unsigned char *mempool=new unsigned char [22*65536];
  globalscrptr=(unsigned char *)(((unsigned long)mempool+0x10000)&~0xFFFF);
  globalalignedpool=(unsigned char *)(((unsigned long)mempool+0x20000)&~0xFFFF);

  vectorfacepre();

  if (!xmpLoadSamples(xmod))
  {
    cputs("could not upload samples\r\n");
    return;
  }

  if (!xmpPlayModule(xmod))
  {
    cputs("could not play module\r\n");
    return;
  }

  kbInit();

  setsmode(0x13);

  if (!kbCheckESC())
    reversefire();
  if (!kbCheckESC())
    showpresent();
  if (!kbCheckESC())
    vectorface();
  if (!kbCheckESC())
    multimap();
  if (!kbCheckESC())
    trefoilknot();
  if (!kbCheckESC())
    firezoom();
  if (!kbCheckESC())
    THEBRAID();
  if (!kbCheckESC())
    wobbler();
  if (!kbCheckESC())
    ente();

  setsmode(0x03);
  kbClose();

  xmpStopModule();
  xmpFreeModule(xmod);

  imsClose();
}
