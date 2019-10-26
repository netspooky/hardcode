#include "Plane.h"
#include "RayTracer.h"

Plane::Plane()
{
  argsused = 3;
}

void Plane::vPrepare()
{
  dir.x = arg1;
  dir.y = arg2;
  dir.z = arg3;

  vectorNormalize(&dir);
  d = vectorDotProduct(&dir,&position);

  Vector v1;
  v1.x=1; v1.y=0; v1.z=0;
  vectorCrossProduct(&xdir,&v1,&dir);
  if(xdir.x==0 && xdir.y==0 && xdir.z==0)
  {
    xdir.x=0; xdir.y=1; xdir.z=0;
  }
  vectorCrossProduct(&ydir,&xdir,&dir);
  vectorNormalize(&ydir);
  xdir.x *= 4;
  xdir.y *= 4;
  xdir.z *= 4;
  ydir.x *= 4;
  ydir.y *= 4;
  ydir.z *= 4;
}

void Plane::vPrecalculate(int rid,Vector *pos)
{
  precalc[rid] = -vectorDotProduct(&dir,pos)+d;
}

int Plane::vGetPrecalcedIntersections(Ray *ray,ISList *islist)
{
  register float dot = dir.x*ray->dir.x + dir.y*ray->dir.y + dir.z*ray->dir.z;
  if(dot==0) return 0;
  dot = precalc[ray->rid] / dot;
  islist->addISPair(dot,this,dot,this);
  return 1;
}

int Plane::vGetIntersections(Ray *ray,ISList *islist)
{
  register float dot = dir.x*ray->dir.x + dir.y*ray->dir.y + dir.z*ray->dir.z;
  if(dot==0) return 0;
  dot = (-(dir.x*ray->pos.x + dir.y*ray->pos.y + dir.z*ray->pos.z)+d) / dot;
  islist->addISPair(dot,this,dot,this);
  return 1;
}

void Plane::vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v)
{
  *normal = dir;

  if(material.texture)
  {
    *u=(int)(hitpos->x*xdir.x + hitpos->y*xdir.y + hitpos->z*xdir.z);
    *v=(int)(hitpos->x*ydir.x + hitpos->y*ydir.y + hitpos->z*ydir.z);
  }
}

float Plane::vGetPrecalcedIntersection(Ray *ray)
{
  register float dot = dir.x*ray->dir.x + dir.y*ray->dir.y + dir.z*ray->dir.z;
  if(dot==0) return -1;
  else return precalc[ray->rid] / dot;
}

float Plane::vGetIntersection(Ray *ray)
{
  register float dot = dir.x*ray->dir.x + dir.y*ray->dir.y + dir.z*ray->dir.z;
  if(dot==0) return -1;
  else return (-(dir.x*ray->pos.x + dir.y*ray->pos.y + dir.z*ray->pos.z)+d) / dot;
}
