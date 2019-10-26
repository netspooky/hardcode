/*
 *
 *      VecSys Definitions
 *
 *      - sis„isi„ apum„„rityksi„
 *
 */

#ifndef VEC_DEF_H
#define VEC_DEF_H

enum                                    //      Selkeytt„m„„n taulukoita
{
    Xi,Yi,Zi
};

#define VEC_INVISIBLE   -0x80000000     //      N„kym„t”n taso

#ifndef min
#define min(x,y) ((x)>(y) ? (y) : (x))
#endif
#ifndef max
#define max(x,y) ((x)<(y) ? (y) : (x))
#endif

#endif

