#ifndef _NormalMap_h_
#define _NormalMap_h_

#include "Vector.h"
#include "Bitmap.h"

class NormalMap
{
public:
  void init();
  void getFromBitmap(Bitmap *bm);
  void affectNormal(Vector *normal,Vector *xdir,Vector *ydir,int u,int v);

  float *xd,*yd;
};

#endif