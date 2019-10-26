// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __FMATRIX_H
#define __FMATRIX_H

struct fvector;
struct fmatrix;

extern "C"
{
float fvecmul(const fvector &v1, const fvector &v2);
  #pragma aux fvecmul parm [esi] [ebx] value [8087] modify [8087]
float fvecsqr(const fvector &v);
  #pragma aux fvecsqr parm [esi] value [8087] modify [8087]
fvector &fvecadd(fvector &d, const fvector &v1, const fvector &v2);
  #pragma aux fvecadd parm [edi] [esi] [ebx] value [edi] modify [8087]
fvector &fvecsub(fvector &d, const fvector &v1, const fvector &v2);
  #pragma aux fvecsub parm [edi] [esi] [ebx] value [edi] modify [8087]
fvector &fvecscl(fvector &d, const fvector &s, float x);
  #pragma aux fvecscl parm [edi] [esi] [8087] value [edi] modify [8087]
fvector &fvecxmul(fvector &d, const fvector &v1, const fvector &v2);
  #pragma aux fvecxmul parm [edi] [esi] [ebx] value [edi] modify [8087]
fvector &fvecspin(fvector &d, const fvector &v1, const fvector &v2, float a);
  #pragma aux fvecspin parm [edi] [esi] [ebx] [8087] value [edi] modify [8087]
float fvecdet(const fvector &v1, const fvector &v2, const fvector &v3);
  #pragma aux fvecdet parm [esi] [ebx] [edi] value [8087] modify [8087]
fvector &fvecnorm(fvector &vd, const fvector &vs);
  #pragma aux fvecnorm parm [edi] [esi] value [edi] modify [8087]

fvector *fvectransformv(fvector *vr, const fmatrix &m, const fvector *v, int n);
  #pragma aux fvectransformv parm [edi] [ebx] [esi] [ecx] value [eax] modify [8087]
fvector *fvectransformn(fvector *vr, const fmatrix &m, const fvector *v, int n);
  #pragma aux fvectransformn parm [edi] [ebx] [esi] [ecx] value [eax] modify [8087]
fvector *fvecintermediate(fvector *vr, const fvector *v1, const fvector *v2, int n, float deg);
  #pragma aux fvecintermediate parm [edi] [esi] [ebx] [ecx] [8087] value [eax] modify [8087]

fmatrix &fmatmakenorm(fmatrix &m);
  #pragma aux fmatmakenorm parm [edi] value [edi] modify [eax ecx]
fmatrix &fmatmakemove(fmatrix &m, const fvector &v);
  #pragma aux fmatmakemove parm [edi] [esi] value [edi] modify [eax ecx]
fmatrix &fmatmakerot(fmatrix &m, const fvector &ax, float a);
  #pragma aux fmatmakerot parm [edi] [esi] [8087] value [edi] modify [eax 8087]

fmatrix &fmatmove(fmatrix &m, const fvector &v);
  #pragma aux fmatmove parm [edi] [esi] value [edi] modify [8087]
fmatrix &fmatmul(fmatrix &mr, const fmatrix &m1, const fmatrix &m2);
  #pragma aux fmatmul parm [edi] [esi] [ebx] value [edi] modify [eax ecx edx 8087]
};


struct fvector
{
  float v[3];
  float operator [](int n) const { return v[n]; }
  float &operator [](int n) { return v[n]; }

  fvector &set(float x, float y, float z) { v[0]=x; v[1]=y; v[2]=z; return *this; }
};

struct fmatrix
{
  float m[3][4];
  const float *operator [](int n) const { return m[n]; }
  float *operator [](int n) { return m[n]; }
};

#endif
