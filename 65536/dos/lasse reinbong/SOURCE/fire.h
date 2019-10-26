// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __FIRE_H
#define __FIRE_H

extern "C"
{
unsigned long fireline(unsigned char *dest, unsigned char *src, int n, unsigned long carry);
  #pragma aux fireline parm [edi] [esi] [ecx] [ebx] value [ebx] modify [eax ebx ecx edx esi edi]
unsigned long fireline256(unsigned char *dest, unsigned char *src, int n, unsigned long carry);
  #pragma aux fireline256 parm [edi] [esi] [ecx] [ebx] value [ebx] modify [eax ebx ecx edx esi edi]
}

#endif
