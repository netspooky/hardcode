// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __SPACE_H
#define __SPACE_H

struct face
{
  unsigned short v[3];
  unsigned char mat;
  unsigned char back;
  float dist;
};

struct vert2d
{
  long v[2];
};

struct facelist
{
  int nfaces;
  face *faces;
};

struct vertlist
{
  int nverts;
  fvector *verts;
  fvector *norms;
  vert2d *mapping;
};

struct spaceparstruct
{
  int nverts;
  int nfaces;
  fvector *vertbuf;
  fvector *normbuf;
  vert2d *vert2dbuf;
  vert2d *phcoords;
  vert2d *mapcoords;
  char *vertuse;
  face *facebuf;
  face **drawlist;

  unsigned char (*phongbufs)[65536];
  unsigned char (*textbufs)[65536];

  float proj_zoomx;
  float proj_zoomy;
  float proj_midx;
  float proj_midy;
  float proj_clipxfac;
  float proj_clipyfac;
  float proj_clipnear;
  float proj_facx;
  float proj_facy;

  long phongofsx;
  long phongofsy;
};

extern "C"
{
extern spaceparstruct spcPar;

void putpolyverts(long (*polyverts)[3], const face &f, const vert2d *vertbuf, int wrapx, int wrapy);
  #pragma aux putpolyverts parm [edi] [edx] [esi] [ecx] [eax] modify [ebx]
};

void spcInit(int nverts, int nfaces);
void spcClose();
void spcSortFaces();
void spcProjectVerts();
void spcGetPhongCoords();
void spcPutFaces(const face *s, int fnum, int vnum, int opt);
float spcCalcCamMatrix(fmatrix &m, const fvector &pos, const fvector &target, const fvector &upvec, float roll);
void spcSetScreen(int x, int y, int aspect);
void spcInitScenery(float zoom, float clipnear);
void spcPutVerts(const vertlist &v, const fmatrix &cam, int mapped);
void spcPutMorfVerts(const vertlist &v0, const vertlist &v1, float morf, const fmatrix &cam, int mapped);
void spcPutObject(const facelist &f, const vertlist &v, const fmatrix &cam, int opt);
void spcDrawScenery();

#endif
