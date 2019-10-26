#include "Frustum.h"
#include "RayTracer.h"
#include "SafeAlloc.h"
#include "Matrix.h"
#include "Camera.h"

void Frustum::init(RayTracer *src,int w,int h)
{
  width = w;
  height = h;

  wplanes = (Vector *)safeAlloc(width*sizeof(Vector));
  hplanes = (Vector *)safeAlloc(height*sizeof(Vector));
  twplanes = (Vector *)safeAlloc(width*sizeof(Vector));
  thplanes = (Vector *)safeAlloc(height*sizeof(Vector));
  wd = (float *)safeAlloc(width*sizeof(float));
  hd = (float *)safeAlloc(height*sizeof(float));

  int i;

  for(i=0; i<width; i++)
  {
    vectorCrossProduct(&wplanes[i],&src->rays[0][i],&src->rays[height-1][i]);
    vectorNormalize(&wplanes[i]);
  }
  
  for(i=0; i<height; i++)
  {
    vectorCrossProduct(&hplanes[i],&src->rays[i][width-1],&src->rays[i][0]);
    vectorNormalize(&hplanes[i]);
  }
}

void Frustum::prepare(Camera *c)
{
  int i;

  for(i=0; i<width; i++)
  {
    twplanes[i] = wplanes[i];
    c->cameramatrix.multipleVector(twplanes[i]);
//    vectorMultipleMatrix(twplanes[i],c->cameramatrix,wplanes[i]);    
    wd[i] = -vectorDotProduct(&twplanes[i],&c->position);
  }
  for(i=0; i<height; i++)
  {
    thplanes[i] = hplanes[i];
    c->cameramatrix.multipleVector(thplanes[i]);
//    vectorMultipleMatrix(thplanes[i],c->cameramatrix,hplanes[i]);
    hd[i] = -vectorDotProduct(&thplanes[i],&c->position);
  }
}