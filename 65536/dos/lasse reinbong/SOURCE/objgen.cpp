// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <string.h>
#include "fmatrix.h"
#include "fmath.h"
#include "space.h"

void spcReadFaces(facelist &f, const unsigned char *filebuf)
{
  f.nfaces=*(unsigned long*)filebuf;
  filebuf+=4;

  int nctrl;
  nctrl=*(unsigned long*)filebuf;
  filebuf+=4;
  int rnverts=2*nctrl+f.nfaces;
  f.faces=new face[f.nfaces];

  const unsigned char *ctrl=filebuf;
  const unsigned char *mat=ctrl+nctrl;
  const unsigned char *hivert=mat+nctrl;
  const unsigned char *lovert=hivert+rnverts;

  int i,j;

  unsigned char last=0;
  face *curfac=f.faces;
  for (j=0; j<nctrl; j++)
  {
    last+=*lovert++;
    curfac->v[0]=(*hivert++<<8)+last;
    last+=*lovert++;
    curfac->v[1]=(*hivert++<<8)+last;
    last+=*lovert++;
    curfac->v[2]=(*hivert++<<8)+last;
    curfac->mat=mat[j];
    curfac++;
    for (i=1; i<ctrl[j]; i++)
    {
      if (*hivert&0x80)
      {
        curfac->v[0]=curfac[-1].v[0];
        curfac->v[1]=curfac[-1].v[2];
      }
      else
      {
        curfac->v[0]=curfac[-1].v[2];
        curfac->v[1]=curfac[-1].v[1];
      }
      last+=*lovert++;
      curfac->v[2]=((*hivert++<<8)+last)&~0x8000;
      curfac->mat=mat[j];
      curfac++;
    }
  }
}

void spcReadVerts(vertlist &v, const unsigned char *filebuf)
{
  v.nverts=*(unsigned long*)filebuf;
  filebuf+=4;

  float size;
  size=*(float*)filebuf;
  filebuf+=4;

  v.verts=new fvector[v.nverts];
  v.norms=new fvector[v.nverts];
  v.mapping=new vert2d[v.nverts];

  int i,j;
  for (j=0; j<3; j++)
  {
    signed char last=0;
    for (i=0; i<v.nverts; i++)
    {
      last+=*(signed char*)filebuf++;
      v.verts[i].v[j]=last*size;
    }
  }
}

void spcCalcNorms(vertlist &v, const facelist &fc)
{
  int j;
  memset(v.norms, 0, v.nverts*12);

  for (j=0; j<fc.nfaces; j++)
  {
    fvector n;
    fvector &v0=v.verts[fc.faces[j].v[0]];
    fvector &v1=v.verts[fc.faces[j].v[1]];
    fvector &v2=v.verts[fc.faces[j].v[2]];
    fvector a,b;
    fvecsub(a, v1, v0);
    fvecsub(b, v2, v0);
    fvecxmul(n, a, b);

    if (fvecsqr(n)>0.001)
      fvecnorm(n, n);

    fvector &n0=v.norms[fc.faces[j].v[0]];
    fvector &n1=v.norms[fc.faces[j].v[1]];
    fvector &n2=v.norms[fc.faces[j].v[2]];
    fvecadd(n0, n0, n);
    fvecadd(n1, n1, n);
    fvecadd(n2, n2, n);
  }
  for (j=0; j<v.nverts; j++)
    if (fvecsqr(v.norms[j])>0.001)
      fvecnorm(v.norms[j], v.norms[j]);
}
/*
void spcGetPlanarMapping(vertlist &v, const fmatrix &m, long scale)
{
  int i;
  for (i=0; i<v.nverts; i++)
  {
    fvector mv;
    fvectransformv(&mv, m, v.verts+i, 1);
    v.mapping[i].v[0]=mv.v[0]*scale;
    v.mapping[i].v[1]=mv.v[1]*scale;
  }
}
*/

void spcCopyVerts(vertlist &vd, const vertlist &vs)
{
  vd.nverts=vs.nverts;
  vd.verts=new fvector[vd.nverts];
  vd.norms=new fvector[vd.nverts];
  vd.mapping=new vert2d[vd.nverts];
  memcpy(vd.verts, vs.verts, sizeof(*vd.verts)*vd.nverts);
  memcpy(vd.norms, vs.norms, sizeof(*vd.norms)*vd.nverts);
  memcpy(vd.mapping, vs.mapping, sizeof(*vd.mapping)*vd.nverts);
}

void spcFreeFaceList(facelist &f)
{
  delete f.faces;
  f.faces=0;
  f.nfaces=0;
}

void spcFreeVertList(vertlist &v)
{
  delete v.verts;
  delete v.norms;
  delete v.mapping;
  v.verts=0;
  v.norms=0;
  v.mapping=0;
  v.nverts=0;
}

void spcGetToroidFaceList(facelist &f, int ringseg, int cylseg, int mat1, int mat2)
{
  f.nfaces=ringseg*cylseg*2;
  f.faces=new face[f.nfaces];
  int j,i;
  face *fp0=f.faces;
  face *fp1=f.faces+ringseg*cylseg;
  for (j=0; j<ringseg; j++)
    for (i=0; i<cylseg; i++)
    {
      fp0->v[0]=fp1->v[0]=j*cylseg+i;
      fp0->v[1]=j*cylseg+(i+1)%cylseg;
      fp1->v[2]=((j+1)%ringseg)*cylseg+(i+cylseg-(j&1))%cylseg;
      fp0->v[2]=fp1->v[1]=((j+1)%ringseg)*cylseg+(i+1-(j&1))%cylseg;
      fp0->mat=mat1;
      fp1->mat=mat2;
      fp0++;
      fp1++;
    }
}

void spcGetToroidVerts(fvector *verts, fvector *norms, const fmatrix &m, int ringseg, int cylseg, float (*path)(fvector &, fvector &, float), float twist, float wrap)
{
  int i,j;
  fvector lastup={0,0,1};
  fvector lastdir={0,1,0};

  for (j=0; j<ringseg; j++)
  {
    fvector pos,dir,up,right;

    float rad=path(pos, dir, 2*M_PI*j/ringseg);
    fvecnorm(dir, dir);

    fvector x;
    float v,v2;

    fvecxmul(x, lastdir, dir);
    v=fvecmul(lastdir, dir);
    v2=1+v;
    if (v2<1e-4)
      v2=1e-4;
    v2=fvecmul(x, lastup)/v2;

    fvector y;
    fvecxmul(up, x, lastup);
    fvecscl(y, lastup, v);
    fvecadd(up, up, y);
    fvecscl(y, x, v2);
    fvecadd(up, up, y);

    fvecxmul(right, dir, up);
    fvecxmul(up, right, dir);
    fvecnorm(up, up);
    fvecnorm(right, right);

    lastup=up;
    lastdir=dir;

    fvectransformn(&up, m, &up, 1);
    fvectransformn(&right, m, &right, 1);
    fvectransformv(&pos, m, &pos, 1);

    for (i=0; i<cylseg; i++)
    {
      fvecspin(*norms, up, right, wrap+2*M_PI*(i-(j&1)/2.0)/cylseg+j*twist/ringseg);
      fvecscl(*verts, *norms, rad);
      fvecadd(*verts, *verts, pos);
      verts++;
      norms++;
    }
  }
}

void spcGetToroidMapping(vert2d *mapping, int ringseg, int cylseg, long scalex, long scaley)
{
  int j,i;
  for (j=0; j<ringseg; j++)
    for (i=0; i<cylseg; i++)
    {
      mapping->v[0]=((scalex>>8)*(2*i-(j&1))/cylseg/2)<<8;
      mapping->v[1]=((scaley>>8)*j/ringseg)<<8;
      mapping++;
    }
}

void spcGetToroidVertList(vertlist &v, int ringseg, int cylseg, float (*path)(fvector &, fvector &, float), float twist, float wrap, long scalex, long scaley)
{
  v.nverts=ringseg*cylseg;
  v.verts=new fvector[v.nverts];
  v.norms=new fvector[v.nverts];
  v.mapping=new vert2d[v.nverts];

  fmatrix n;
  fmatmakenorm(n);
  spcGetToroidVerts(v.verts, v.norms, n, ringseg, cylseg, path, twist, wrap);
  spcGetToroidMapping(v.mapping, ringseg, cylseg, scalex, scaley);
}
