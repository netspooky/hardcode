// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

extern "C" void wobbletunnel(unsigned char *dst, const unsigned char *map, const unsigned short *remap, unsigned short *rotmap);
#pragma aux wobbletunnel parm [edi] [ebx] [esi] [edx] modify [eax ebx ecx edx esi edi]
