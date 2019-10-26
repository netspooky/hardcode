// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __TEXGEN_H
#define __TEXGEN_H

void txDecodeBWMap(unsigned char *dst, const unsigned char *src, int back, int fore);
void txHexagonMap(unsigned char *dest, int xn, int yn, int c1, int c2, int c3);
void txSeenMap(unsigned char *dst);
extern "C" void txTwirlify(unsigned char *dst, const unsigned char *src, const unsigned char *xmap, const unsigned char *ymap, const signed char *xfn, const signed char *yfn);
#pragma aux txTwirlify parm [edi] [ebx] [esi] [eax] [edx] [ecx]
extern "C" void txPlasmaMap(unsigned char *buf, int colbits, int p, long seed);
#pragma aux txPlasmaMap parm [ebx] [ecx] [edi] [eax] modify [eax ebx ecx edx esi edi]
extern "C" void txSmoothMap(unsigned char *dest, const unsigned char *src);
#pragma aux txSmoothMap parm [edi] [ebx] modify [eax ebx ecx edx esi edi]

#endif
