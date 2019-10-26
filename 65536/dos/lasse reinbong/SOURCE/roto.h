// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __ROTO_H
#define __ROTO_H

extern "C"
{
void texturescreen(unsigned char *dst, unsigned char *src, long x0, long y0, long xx, long xy, long yx, long yy, long xblocks, long yblocks, long scrwid, unsigned char op);
  #pragma aux texturescreen parm [] caller modify [eax ebx ecx edx esi edi]
  #define ROTO_MOV 0x89
  #define ROTO_ADD 0x01
}

#endif
