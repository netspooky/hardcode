// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __WOBBLE_H
#define __WOBBLE_H

extern "C" void gtexturewobbler(unsigned char *dst, const unsigned char *src, long (*map)[41][3], const unsigned char *colmap);
#pragma aux gtexturewobbler parm [eax] [ebx] [ecx] [edx] modify [eax ebx ecx edx esi edi]
extern "C" void wobblemorfer(long (*dst)[41][3], long (*s1)[41][3], long (*s2)[41][3], long fac1, long fac2);
#pragma aux wobblemorfer parm [edi] [esi] [ebx] [eax] [edx] modify [eax ebx ecx edx esi edi]

#endif
