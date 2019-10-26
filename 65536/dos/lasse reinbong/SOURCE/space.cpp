// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#include <string.h>
#include "fmatrix.h"
#include "fmath.h"
#include "space.h"
#include "polygons.h"

spaceparstruct spcPar;

extern "C"
{
void sortfaces(const void *start, const void *end);
  #pragma aux sortfaces parm [] modify [esi edi eax ebx ecx]
};

static spaceparstruct &spcGetPar()
{
  return spcPar;
}

void spcInit(int nverts, int nfaces)
{
  spaceparstruct &p=spcGetPar();
  p.vertbuf=new fvector [nverts];
  p.normbuf=new fvector [nverts];
  p.vert2dbuf=new vert2d [nverts];
  p.phcoords=new vert2d [nverts];
  p.mapcoords=new vert2d [nverts];
  p.vertuse=new char [nverts];
  p.facebuf=new face [nfaces];
  p.drawlist=new face *[nfaces];
}

void spcClose()
{
  spaceparstruct &p=spcGetPar();
  delete p.vertbuf;
  delete p.normbuf;
  delete p.vert2dbuf;
  delete p.phcoords;
  delete p.mapcoords;
  delete p.vertuse;
  delete p.facebuf;
  delete p.drawlist;
  p.vertbuf=0;
  p.normbuf=0;
  p.vert2dbuf=0;
  p.phcoords=0;
  p.mapcoords=0;
  p.vertuse=0;
  p.facebuf=0;
  p.drawlist=0;
}

void spcPutFaces(const face *s, int fnum, int vnum, int opt)
{
  spaceparstruct &p=spcGetPar();
  face **dp=p.drawlist+p.nfaces;
  face *d=p.facebuf+p.nfaces;
  int vofs=p.nverts;
  memset(p.vertuse+vofs, 0, vnum);
  p.nverts+=vnum;
  int i;
  for (i=0; i<fnum; i++, s++)
  {
    face f;
    f.v[0]=s->v[0]+vofs;
    f.v[1]=s->v[1]+vofs;
    f.v[2]=s->v[2]+vofs;
    float faceori=fvecdet(p.vertbuf[f.v[0]], spcPar.vertbuf[f.v[1]], spcPar.vertbuf[f.v[2]]);
    if (faceori==0)
      continue;
    f.back=faceori>0;
    if (!(opt&1)&&f.back)
      continue;
    f.mat=s->mat;
    f.dist=fvecsqr(p.vertbuf[f.v[0]])+fvecsqr(p.vertbuf[f.v[1]])+fvecsqr(p.vertbuf[f.v[2]]);
    if (opt&14)
    {
      fvector &v0=p.vertbuf[f.v[0]];
      fvector &v1=p.vertbuf[f.v[1]];
      fvector &v2=p.vertbuf[f.v[2]];
      if (opt&4)     // das ist mll!!!!
        if (ffabs(p.proj_clipxfac*v0.v[0])>v0.v[1])
        if (ffabs(p.proj_clipxfac*v1.v[0])>v1.v[1])
        if (ffabs(p.proj_clipxfac*v2.v[0])>v2.v[1])
          continue;
      if (opt&8)     // das ist mll!!!!
        if (ffabs(p.proj_clipyfac*v0.v[2])>v0.v[1])
        if (ffabs(p.proj_clipyfac*v1.v[2])>v1.v[1])
        if (ffabs(p.proj_clipyfac*v2.v[2])>v2.v[1])
          continue;
      if (opt&2)
      {
        int which=0;
        if (p.proj_clipnear>v0.v[1])
          which|=1;
        if (p.proj_clipnear>v1.v[1])
          which|=2;
        if (p.proj_clipnear>v2.v[1])
          which|=4;
        if (which!=0)
        {
          if (which==7)
            continue;
          int xa,xb,xc,xd;
          switch (which)
          {
          case 1: xa=f.v[2]; xb=f.v[0]; xc=f.v[0]; xd=f.v[1]; break;
          case 2: xa=f.v[0]; xb=f.v[1]; xc=f.v[1]; xd=f.v[2]; break;
          case 4: xa=f.v[1]; xb=f.v[2]; xc=f.v[2]; xd=f.v[0]; break;
          case 3: xa=f.v[2]; xb=f.v[0]; xc=f.v[1]; xd=f.v[2]; break;
          case 6: xa=f.v[0]; xb=f.v[1]; xc=f.v[2]; xd=f.v[0]; break;
          case 5: xa=f.v[1]; xb=f.v[2]; xc=f.v[0]; xd=f.v[1]; break;
          }
          float t;
          t=(p.vertbuf[xb].v[1]-p.proj_clipnear)/(p.vertbuf[xb].v[1]-p.vertbuf[xa].v[1]);
          fvector va,vb;
          fvecscl(va, p.vertbuf[xb], 1-t);
          fvecscl(vb, p.vertbuf[xa], t);
          fvecadd(p.vertbuf[p.nverts], va, vb);
          fvecscl(va, p.normbuf[xb], 1-t);
          fvecscl(vb, p.normbuf[xa], t);
          fvecadd(p.normbuf[p.nverts], va, vb);
          t=(p.vertbuf[xc].v[1]-p.proj_clipnear)/(p.vertbuf[xc].v[1]-p.vertbuf[xd].v[1]);
          fvecscl(va, p.vertbuf[xc], 1-t);
          fvecscl(vb, p.vertbuf[xd], t);
          fvecadd(p.vertbuf[p.nverts+1], va, vb);
          fvecscl(va, p.normbuf[xc], 1-t);
          fvecscl(vb, p.normbuf[xd], t);
          fvecadd(p.normbuf[p.nverts+1], va, vb);
          switch (which)
          {
          case 1: case 2: case 4:
            f.v[0]=xa;
            f.v[1]=p.nverts+1;
            f.v[2]=xd;
            p.vertuse[xd]=1;
            *dp++=d;
            *d++=f;
            p.nfaces++;
            break;
          }
          f.v[0]=xa;
          f.v[1]=p.nverts;
          f.v[2]=p.nverts+1;
          p.nverts+=2;
        }
      }
    }
    p.vertuse[f.v[0]]=1;
    p.vertuse[f.v[1]]=1;
    p.vertuse[f.v[2]]=1;
    *dp++=d;
    *d++=f;
    p.nfaces++;
  }
}

void spcSortFaces()
{
  if (spcPar.nfaces)
    sortfaces(spcPar.drawlist, spcPar.drawlist+spcPar.nfaces-1);
}

void spcProjectVerts()
{
  spaceparstruct &p=spcGetPar();
  int i;
  vert2d *vert2dbuf=p.vert2dbuf;
  fvector *vertbuf=p.vertbuf;
  char *vertuse=p.vertuse;
  for (i=0; i<p.nverts; i++,vertbuf++,vert2dbuf++,vertuse++)
  {
    if (!*vertuse)
      continue;
    vert2dbuf->v[0]=p.proj_midy-p.proj_zoomy*vertbuf->v[2]/vertbuf->v[1];
    vert2dbuf->v[1]=p.proj_midx+p.proj_zoomx*vertbuf->v[0]/vertbuf->v[1];
  }
}

void spcGetPhongCoords()
{
  spaceparstruct &p=spcGetPar();
  int i;
  vert2d *phcoords=p.phcoords;
  fvector *normbuf=p.normbuf;
  char *vertuse=p.vertuse;
  for (i=0; i<p.nverts; i++,normbuf++,phcoords++,vertuse++)
  {
    if (!*vertuse)
      continue;
    phcoords->v[0]=normbuf->v[0]*127*65536+128*65536;
    phcoords->v[1]=normbuf->v[2]*127*65536+128*65536;
  }
}

float spcCalcCamMatrix(fmatrix &m, const fvector &pos, const fvector &target, const fvector &upvec, float roll)
{
  fvector dir,up,right;
  fvecsub(dir, target, pos);
  fvecxmul(right, dir, upvec);
  fvecxmul(up, right, dir);

  fvecnorm(*(fvector*)m.m[0], right);
  fvecnorm(*(fvector*)m.m[1], dir);
  fvecnorm(*(fvector*)m.m[2], up);
  fmatrix mr;
  fvector uy={0,1,0};
  fmatmakerot(mr, uy, roll);
  fmatmul(m, mr, m);

  fvector xpos;
  fvectransformn(&xpos, m, &pos, 1);
  m.m[0][3]=-xpos.v[0];
  m.m[1][3]=-xpos.v[1];
  m.m[2][3]=-xpos.v[2];

  return fvecsqr(dir);
}

void spcSetScreen(int x, int y, int aspect)
{
  spaceparstruct &p=spcGetPar();
  p.proj_facx=32768*aspect;
  p.proj_facy=32768*y;
  p.proj_midx=32768*x;
  p.proj_midy=32768*y;
  polyparstruct &pp=polyPar;
  pp.minx=0;
  pp.maxx=x;
  pp.miny=0;
  pp.maxy=y;
  pp.scrwid=x;
}

void spcInitScenery(float zoom, float clipnear)
{
  spaceparstruct &p=spcGetPar();
  p.proj_zoomx=spcPar.proj_facx*zoom;
  p.proj_zoomy=spcPar.proj_facy*zoom;
  p.proj_clipxfac=spcPar.proj_zoomx/spcPar.proj_midx;
  p.proj_clipyfac=spcPar.proj_zoomy/spcPar.proj_midy;
  p.proj_clipnear=clipnear;
  p.nfaces=0;
  p.nverts=0;
}

void spcPutVerts(const vertlist &v, const fmatrix &cam, int mapped)
{
  spaceparstruct &p=spcGetPar();
  fvectransformv(p.vertbuf+p.nverts, cam, v.verts, v.nverts);
  fvectransformn(p.normbuf+p.nverts, cam, v.norms, v.nverts);
  if (mapped)
    memcpy(p.mapcoords+p.nverts, v.mapping, 8*v.nverts);
}

void spcPutMorfVerts(const vertlist &v0, const vertlist &v1, float morf, const fmatrix &cam, int mapped)
{
  spaceparstruct &p=spcGetPar();

  if (morf==0)
    spcPutVerts(v0, cam, mapped);
  else
  if (morf==1)
    spcPutVerts(v1, cam, mapped);
  else
  {
    fvecintermediate(p.vertbuf+p.nverts, v1.verts, v0.verts, v0.nverts, morf);
    fvecintermediate(p.normbuf+p.nverts, v1.norms, v0.norms, v0.nverts, morf);
    fvectransformv(p.vertbuf+p.nverts, cam, p.vertbuf+p.nverts, v0.nverts);
    fvectransformn(p.normbuf+p.nverts, cam, p.normbuf+p.nverts, v0.nverts);
    if (mapped) //HEY!!!!
      memcpy(p.mapcoords+p.nverts, v0.mapping, 8*v0.nverts);
  }
}

void spcPutObject(const facelist &f, const vertlist &v, const fmatrix &cam, int opt)
{
  spcPutVerts(v, cam, opt&16);
  spcPutFaces(f.faces, f.nfaces, v.nverts, opt);
}

void spcDrawScenery()
{
  spaceparstruct &p=spcGetPar();
  polyparstruct &pp=polyPar;

  spcSortFaces();
  spcProjectVerts();
  spcGetPhongCoords();

  int j;
  for (j=0; j<p.nfaces; j++)
  {
    face &fac=*p.drawlist[j];

    long coords[6][3];
    pp.coords=coords;

    putpolyverts(coords, fac, p.vert2dbuf, 0, 0);
    putpolyverts(coords+2, fac, p.phcoords, 0, 0);

    int mapped=0;
    switch (fac.mat)
    {
    case 1: // mira teal
    case 2: // chrome
      coords[2][0]+=p.phongofsx;
      coords[2][1]+=p.phongofsx;
      coords[2][2]+=p.phongofsx;
      coords[3][0]+=p.phongofsy;
      coords[3][1]+=p.phongofsy;
      coords[3][2]+=p.phongofsy;
      pp.txtptr=(fac.mat==1)?p.phongbufs[0]:p.phongbufs[1];
      break;
    case 3: // yellow plastic
      pp.txtptr=p.phongbufs[13];
      break;
    case 4: // black plastic
      pp.txtptr=p.phongbufs[14];
      break;
    case 5: // glove
      pp.txtptr=p.phongbufs[3];
      break;
    case 6: // glove text
      pp.txtptr=p.phongbufs[3];
      pp.txt2ptr=p.phongbufs[4];
      mapped=1;
      putpolyverts(coords+4, fac, p.mapcoords, 0, 0);
      break;
    case 20: // stone
      putpolyverts(coords+4, fac, p.mapcoords, 8, 8);
      pp.txtptr=p.phongbufs[6];
      pp.txt2ptr=p.phongbufs[7];
      mapped=1;
      break;
    case 30: // blue phong
      pp.txtptr=fac.back?p.phongbufs[11]:p.phongbufs[9];
      break;
    case 31: // black phong
      pp.txtptr=fac.back?p.phongbufs[11]:p.phongbufs[10];
      break;
    case 40: // white phong
      pp.txtptr=p.phongbufs[15];
      break;
    }

    if (!mapped)
    {
      pp.drawline=textureline;
      drawtrigon2C();
    }
    else
    {
      pp.drawline=tex2sumline;
      drawtrigon4C();
    }
  }
}
