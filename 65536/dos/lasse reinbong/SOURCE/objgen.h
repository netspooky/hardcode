// (c) 1995-1997 Niklas Beisert / pascal
// lasse reinboeng source
// this header must stay on top of this file
// free for non-commercial use of any kind as long as proper credits are given.

#ifndef __OBJGEN_H
#define __OBJGEN_H

void spcReadVerts(vertlist &v, const unsigned char *filebuf);
void spcCopyVerts(vertlist &vd, const vertlist &vs);
void spcReadFaces(facelist &f, const unsigned char *filebuf);
void spcCalcNorms(vertlist &v, const facelist &fc);
void spcGetPlanarMapping(vertlist &v, const fmatrix &m, long scale);
void spcFreeFaceList(facelist &f);
void spcFreeVertList(vertlist &v);
void spcGetToroidFaceList(facelist &f, int ringseg, int cylseg, int mat1, int mat2);
void spcGetToroidVerts(fvector *verts, fvector *norms, const fmatrix &m, int ringseg, int cylseg, float (*path)(fvector &, fvector &, float), float twist, float wrap);
void spcGetToroidMapping(vert2d *mapping, int ringseg, int cylseg, long scalex, long scaley);
void spcGetToroidVertList(vertlist &v, int ringseg, int cylseg, float (*path)(fvector &, fvector &, float), float twist, float wrap, long scalex, long scaley);

#endif
