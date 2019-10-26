//----------------------------------------------------------------------------
//
//                            E L I T E G R O U P
//                             we are very good.
//
// MXMPlay/Win32 v0.9 (based on MXMPlay 1.6)
// (C) 1999 The Artist Formerly Known As Doctor Roole in 1999
//
// -> main include file for use with Watcom C/C++
//    (Sorry VC++ users, you'll have to rewrite the routines to __stdcall)
//
//----------------------------------------------------------------------------

#ifndef __MXMPLAY_H
#define __MXMPLAY_H

#ifdef __cplusplus
extern "C"
{
#endif

// Initialize MXMPlay
// mxmmem  : pointer to MXM data
// mxmheap : ptr to player workspace (alloc 64K, should work)

int xmpInit(void *mxmmem, void *mxmheap);
  #pragma aux xmpInit "*" parm [edi] [ebx] value [eax] modify [eax ebx ecx edx esi edi]



// Start playing
// startord : order to play from

void xmpPlay(unsigned int startord);
  #pragma aux xmpPlay "*" parm [eax] modify [eax ebx ecx edx esi edi]



// Render sample stream into buffer
// dest : ptr to 32bit (!!!) stereo output buffer (not clipped, u suckerz)
// n    : number of samples (that means: 2*dword) to render

void xmpRender (signed long *dest, int n);
  #pragma aux xmpRender "*" parm[edi][eax] modify exact []



// Stop playing

void xmpStop();
  #pragma aux xmpStop "*" modify [eax ebx ecx edx esi edi]



// Set main volume
// vol: main volume (0-64)

void xmpSetVolume(unsigned char vol);
  #pragma aux xmpSetVolume "*" parm [eax]



// Get sync value (set it with Zxx effects in the XM)

unsigned char xmpGetSync();
  #pragma aux xmpGetSync "*" value [al]


// Get position
// returns: position as 0xOORR, O is order, R is row

unsigned short xmpGetPos();
  #pragma aux xmpGetPos "*" value [ax]



#ifdef __cplusplus
};
#endif

#endif
