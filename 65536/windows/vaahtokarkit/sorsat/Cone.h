#ifndef _Cone_h_
#define _Cone_h_

#include "Primitive.h"

class Cone : public Primitive
{
public:
  Cone();

  void vPrepare();
  void vPrecalculate(int rid,Vector *pos);

  int vGetPrecalcedIntersections(class Ray *ray,ISList *islist);
  int vGetIntersections(class Ray *ray,ISList *islist);
  void vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v);
 
  float radius;
  float height;
  float heightdiv;

  float yscale;

  int backside;

  class Plane *plane1,*plane2;

  Vector position2;
  float precalcedc[9];
  Vector precalcedpos[9];
};

#endif