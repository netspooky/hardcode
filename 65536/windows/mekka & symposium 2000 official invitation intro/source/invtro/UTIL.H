#ifndef __util_h
#define __util_h

#include "ficken3d.h"

void          HeapInit   (void);
void          HeapDone   (void);
void *        mymalloc   (const unsigned long size);
void *        zmymalloc  (const unsigned long size);
void          myfree     (const void * ptr);

void          MakePalBCW  (long *pal, int p1, int p2, unsigned long color);

void          mymemcpy   (void *d, void *s, unsigned long n);
#pragma aux mymemcpy "*" parm[edi][esi][ecx] modify exact []

int           bsearch32  (sU32 *ptr, int n, int v);
#pragma aux bsearch32 "*" parm[edi][ecx][esi] value[eax] modify exact [eax ebx ecx edx]

void          sort32  (sU32 *ptr, int n);
#pragma aux sort32 "*" parm[edi][ecx] modify exact []

int           equalvec (const tvector *a, const tvector *b);
#pragma aux equalvec "*" parm[esi][edi] value[eax] modify exact [eax]

void testdeform (tvector *vs, int n, float anim, float * amp);
void testdeform2 (tvector *vs, int n, float anim, float * amp);

extern float   trefoil_anim;
extern float   trefoil_amp;

float   trefoilpath           (tvector *v0, tvector *v1, float t);
float   toruspath             (tvector *v0, tvector *v1, float t);
void    spcGetToroidFaceList  (face *f, int ringseg, int cylseg);
void    spcGetToroidVerts     (tvector *verts, tvector *norms, int ringseg, int cylseg, float (*path)(tvector *, tvector *, float), float twist, float wrap);

void spcGetToroidVerts2(tvector *verts,
                        int ringseg, int cylseg,
                        float (*path)(tvector *, tvector *, float),
                        float twist, float wrap);


rawobject * gensphere (int level);
#pragma aux gensphere "*" parm[ecx] value[eax] modify exact [eax ebx ecx edx esi edi];


#endif
