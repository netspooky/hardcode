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



// cool motion functions...
// this uses the compiled (makescn.cpp) "movelist"
// and can handle movement polynomes to the 3rd degree (???)
//            and rotation polynomes to the 2nd degree
// the coefficients are dumped to the .3ds file

#include <mem.h>
//#include <io.h>
#include "ovlio.h"
#include "ints.h"
#include "matrix.h"
#include "vect.h"

#define CMD_HOM 0
#define CMD_POS 1
#define CMD_MOV 2
#define CMD_ACC 3
#define CMD_AC3 4
#define CMD_AHM 5
#define CMD_ANG 6
#define CMD_ROT 7
#define CMD_AAC 8

#pragma argsused
transform::transform(int file)
{
  short buflen;
  oread(file, &buflen, 2);
  events=new char[buflen];
  oread(file, events, buflen);
  evptr=events;
  alev=plev=0;
}

transform::~transform()
{
  delete events;
}

void transform::parse()
{
  while (*(long*)evptr<=curtime)
  {
    long t=*(long*)evptr;
    char cmd=evptr[4];
    evptr+=5;
    vector v;
    switch (cmd)
    {
    case CMD_HOM: case CMD_POS: case CMD_MOV: case CMD_ACC: case CMD_AC3:
      pt0=t;
      plev=cmd-CMD_HOM;
      memcpy(pos, evptr, 12*plev);
      evptr+=12*plev;
      break;
    case CMD_AHM: case CMD_ANG: case CMD_ROT: case CMD_AAC:
      at0=t;
      alev=cmd-CMD_AHM;
      memcpy(ang, evptr, 12*alev);
      evptr+=12*alev;
      break;
    }
  }
}

void transform::makexform(matrix& m)
{
  parse();

  vector v;
  matrix t;

  vecmove(v, ang, curtime-at0, alev);
  if (v[0])
    makematrotx(m, v[0]);
  else
    makematnorm(m);
  if (v[1])
    matmul(m, makematroty(t, v[1]), m);
  if (v[2])
    matmul(m, makematrotz(t, v[2]), m);

  if (plev)
    matxlate(m, vecmove(v, pos, curtime-pt0, plev));
}
