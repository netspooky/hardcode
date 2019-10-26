#ifndef _Plane_h_
#define _Plane_h_

#include "Primitive.h"

class Plane : public Primitive
{
public:
  Plane();

  void vPrepare();
  void vPrecalculate(int rid,Vector *pos);

  int vGetPrecalcedIntersections(class Ray *ray,class ISList *islist);
  int vGetIntersections(class Ray *ray,class ISList *islist);
  void vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v);

  float vGetPrecalcedIntersection(class Ray *r);
  float vGetIntersection(class Ray *r);

  float d;
  Vector dir; // a,b,c
  Vector xdir,ydir; // Tekstuurille
  float precalc[9];
};

#endif