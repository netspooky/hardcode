#ifndef _Sphere_h_
#define _Sphere_h_

#include "Primitive.h"

class Sphere : public Primitive
{
public:
  Sphere();

  void vPrepare();
  void vPrecalculate(int rid,Vector *pos);

  int vGetPrecalcedIntersections(class Ray *ray,class ISList *islist);
  int vGetIntersections(class Ray *ray,class ISList *islist);
  void vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v);

  float radius2,radiusdiv;
  float precalcedc[9];
};

#endif