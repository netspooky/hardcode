#ifndef _Frustum_h_
#define _Frustum_h_

#include "Vector.h"

class Frustum
{
public:
  void init(class RayTracer *src,int w,int h);
  void prepare(class Camera *c);

  int width,height;

  Vector *wplanes,*hplanes;
  Vector *twplanes,*thplanes;
  float *wd,*hd; // Tasojen D:t
};

#endif
