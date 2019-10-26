// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __POLYGONS_H
#define __POLYGONS_H

extern "C"
{
void fillpolygon(long *yc, long *xc, unsigned long n, unsigned char col);
#pragma aux fillpolygon parm [] caller modify [eax ebx ecx edx esi edi]

void drawtrigon2C();
#pragma aux drawtrigon2C modify [eax ebx ecx edx esi edi]
void drawtrigon4C();
#pragma aux drawtrigon4C modify [eax ebx ecx edx esi edi]
void textureline();
#pragma aux textureline
void tex2sumline();
#pragma aux tex2sumline


struct polyparstruct
{
  void *scrptr;
  unsigned long scrwid;
  unsigned long minx,maxx,miny,maxy;
  void (*drawline)();
  long (*coords)[3];
  void *txtptr;
  void *txt2ptr;
};

extern polyparstruct polyPar;
}

#endif
