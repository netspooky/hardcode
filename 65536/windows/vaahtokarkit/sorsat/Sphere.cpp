#include "Sphere.h"
#include "NormalMap.h"
#include "RayTracer.h"

Sphere::Sphere()
{
  argsused = 1;
}

void Sphere::vPrepare()
{
  radius2 = arg1*arg1;
  radiusdiv = 1.0f / arg1;

  bsposition = position;
  bsradius = arg1;
  hasbs=1;
}

void Sphere::vPrecalculate(int rid,Vector *pos)
{
  float xx = pos->x - position.x;
  float yy = pos->y - position.y;
  float zz = pos->z - position.z;
  precalcedc[rid] = -(xx*xx + yy*yy + zz*zz - radius2);
}

int Sphere::vGetPrecalcedIntersections(Ray *ray,ISList *islist)
{
  float xx = ray->pos.x - position.x;
  float yy = ray->pos.y - position.y;
  float zz = ray->pos.z - position.z;
  float b = - xx*ray->dir.x - yy*ray->dir.y - zz*ray->dir.z;

  float D = b*b + precalcedc[ray->rid];
  if(D<=0) return 0;

  D = sqrtf(D);

  islist->addISPair(b-D,this,b+D,this);
  return 1;
}

int Sphere::vGetIntersections(Ray *ray,ISList *islist)
{
  float xx = ray->pos.x - position.x;
  float yy = ray->pos.y - position.y;
  float zz = ray->pos.z - position.z;
  float b = - xx*ray->dir.x - yy*ray->dir.y - zz*ray->dir.z;

  float D = b*b - (xx*xx + yy*yy + zz*zz - radius2);
  if(D<=0) return 0;

  D = sqrtf(D);

  islist->addISPair(b-D,this,b+D,this);
  return 1;
}

void Sphere::vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v)
{
  normal->x = (hitpos->x - position.x) * radiusdiv;
  normal->y = (hitpos->y - position.y) * radiusdiv;
  normal->z = (hitpos->z - position.z) * radiusdiv;

  if(material.texture || material.bumpmap)
  {
    Vector rnormal;
    vectorMultipleMatrix(rnormal,invtmatrix,*normal);

    *u=(int)(fabs(atan2f(rnormal.x,rnormal.z)) / (2.0f*3.141592f)*256.0f*1.0f);
    *v=(int)(rnormal.y*255.0f);

    if(material.bumpmap)
    {
      float x = material.bumpmap->xd[((*v<<8)&0xFF00)+(*u&255)];
      float y = material.bumpmap->yd[((*v<<8)&0xFF00)+(*u&255)];
      normal->x += -normal->z*x + -normal->z*y;
      normal->y += normal->y*y;
      normal->z += normal->x*x;
      vectorNormalize(normal);
    }
  }
}