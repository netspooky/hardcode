#ifndef _Cylinder_h_
#define _Cylinder_h_

#include "Primitive.h"

class Cylinder : public Primitive
{
public:
  Cylinder();

  void vPrepare();
  void vPrecalculate(int rid,Vector *pos);
  void vClone(Object *dest);

  int vGetPrecalcedIntersections(class Ray *ray,ISList *islist);
  int vGetIntersections(class Ray *ray,ISList *islist);
  void vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v);

  float radius,height;
  float radius2,radiusdiv,heightdiv;

  int backside;

  class Plane *plane1,*plane2;

  float precalcedc[9];
  Vector precalcedpos[9];
};

#endif