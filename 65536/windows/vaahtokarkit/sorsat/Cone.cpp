#include "Cone.h"
#include "Plane.h"
#include "RayTracer.h"
#include "ISList.h"

Cone::Cone()
{
  argsused = 2;
  totaloids = 2;
  backside = 1;

  plane1 = new Plane();
  plane1->parent = this;
  plane1->material = material;

  plane2 = new Plane();
  plane2->parent = this;
  plane2->material = material;
}

void Cone::vPrepare()
{
  radius = arg1;
  height = arg2;
  heightdiv = 1.0f / height * 256.0f;

  yscale = radius / height;
  yscale *= yscale;

// Bounding Spheressä optimoimista (jos radius < height niin positioo ylemmäs)
  bsposition.x = position.x;
  bsposition.y = position.y;
  bsposition.z = position.z;
  if(height > radius) bsradius = height; else bsradius = radius;
  hasbs=1;

  position2.x = position.x + tmatrix.m[1][0]*height;
  position2.y = position.y + tmatrix.m[1][1]*height;
  position2.z = position.z + tmatrix.m[1][2]*height;

  plane1->arg1 = tmatrix.m[1][0];
  plane1->arg2 = tmatrix.m[1][1];
  plane1->arg3 = tmatrix.m[1][2];
  plane1->position = position;
  plane1->currentoid = firstoid + 1;
  plane1->vPrepare();

  plane2->arg1 = tmatrix.m[1][0];
  plane2->arg2 = tmatrix.m[1][1];
  plane2->arg3 = tmatrix.m[1][2];

  plane2->position = position2;
  plane2->vPrepare();
}

void Cone::vPrecalculate(int rid,Vector *pos)
{
  precalcedpos[rid].x = pos->x-position2.x;
  precalcedpos[rid].y = pos->y-position2.y;
  precalcedpos[rid].z = pos->z-position2.z;
  invtmatrix.multipleVector(precalcedpos[rid]);

  precalcedc[rid] = precalcedpos[rid].x*precalcedpos[rid].x + precalcedpos[rid].z*precalcedpos[rid].z - precalcedpos[rid].y*precalcedpos[rid].y*yscale;
  precalcedpos[rid].y *= yscale;

  plane1->vPrecalculate(rid,pos);
  plane2->vPrecalculate(rid,pos);
}

int Cone::vGetPrecalcedIntersections(Ray *r,ISList *islist)
{
  Vector d;
  if(rotated) { vectorMultipleMatrix(d,invtmatrix,r->dir) }
  else d = r->dir;

  float b = precalcedpos[r->rid].x*d.x + precalcedpos[r->rid].z*d.z - precalcedpos[r->rid].y*d.y;
  float a = d.x*d.x + d.z*d.z - d.y*d.y*yscale;
  float D = b*b - a*precalcedc[r->rid];

  if(*(long *)&D<0) return 0;

  D=sqrtf(D);
  float m = 1.0f / a;
  float t2=(-b+D) * m;
  float t1=(-b-D) * m;

  if(t2<t1) { float t=t2; t2=t1; t1=t; }

  int pastt1=0, pastt2=0; // 0 = osu, 1 = yli, 2 = ali

  float muu1,muu2;

  if(!rotated)
  {
    muu1 = (r->dir.y*t1+r->pos.y);
    muu2 = (r->dir.y*t2+r->pos.y);
  } else {
    muu1 = (r->dir.x*t1+r->pos.x)*tmatrix.m[1][0] +
           (r->dir.y*t1+r->pos.y)*tmatrix.m[1][1] +
           (r->dir.z*t1+r->pos.z)*tmatrix.m[1][2];
    muu2 = (r->dir.x*t2+r->pos.x)*tmatrix.m[1][0] +
           (r->dir.y*t2+r->pos.y)*tmatrix.m[1][1] +
           (r->dir.z*t2+r->pos.z)*tmatrix.m[1][2];
  }

  if(muu1-plane1->d < 0) pastt1=2;
  if(muu2-plane1->d < 0) pastt2=2;
  if(muu1-plane2->d > 0) pastt1=1;
  if(muu2-plane2->d > 0) pastt2=1;
  if(pastt1 && pastt2) return 0;

  if(pastt1==0)
  {
    if(pastt2==0) islist->addISPair(t1,this,t2,this);
    if(pastt2==1) islist->addISPair(plane1->vGetPrecalcedIntersection(r),plane1,t1,this);
    if(pastt2==2) islist->addISPair(t1,this,plane1->vGetPrecalcedIntersection(r),plane1);
  } else if(pastt1==1)
  {
    islist->addISPair(t2,this,plane1->vGetPrecalcedIntersection(r),plane1);
  } else if(pastt1==2)
  {
    islist->addISPair(plane1->vGetPrecalcedIntersection(r),plane1,t2,this);
  }

  return 1;
}

int Cone::vGetIntersections(Ray *r,ISList *islist)
{
  Vector d;
  if(rotated) { vectorMultipleMatrix(d,invtmatrix,r->dir) }
  else d = r->dir;

  Vector v;
  v.x = r->pos.x-position2.x;
  v.y = r->pos.y-position2.y;
  v.z = r->pos.z-position2.z;
  invtmatrix.multipleVector(v);

  float b = v.x*d.x + v.z*d.z - v.y*d.y;
  float a = d.x*d.x + d.z*d.z - d.y*d.y;
  float D = b*b - a*(v.x*v.x + v.z*v.z - v.y*v.y);

  if(*(long *)&D<0) return 0;

  D=sqrtf(D);
  float m = 1.0f / a;
  float t2=(-b+D) * m;
  float t1=(-b-D) * m;

  if(t2<t1) { float t=t2; t2=t1; t1=t; }

  int pastt1=0, pastt2=0; // 0 = osu, 1 = yli, 2 = ali

  float muu1,muu2;

  if(!rotated)
  {
    muu1 = (r->dir.y*t1+r->pos.y);
    muu2 = (r->dir.y*t2+r->pos.y);
  } else {
    muu1 = (r->dir.x*t1+r->pos.x)*tmatrix.m[1][0] +
           (r->dir.y*t1+r->pos.y)*tmatrix.m[1][1] +
           (r->dir.z*t1+r->pos.z)*tmatrix.m[1][2];
    muu2 = (r->dir.x*t2+r->pos.x)*tmatrix.m[1][0] +
           (r->dir.y*t2+r->pos.y)*tmatrix.m[1][1] +
           (r->dir.z*t2+r->pos.z)*tmatrix.m[1][2];
  }

  if(muu1-plane1->d < 0) pastt1=2;
  if(muu2-plane1->d < 0) pastt2=2;
  if(muu1-plane2->d > 0) pastt1=1;
  if(muu2-plane2->d > 0) pastt2=1;
  if(pastt1 && pastt2) return 0;

  if(pastt1==0)
  {
    if(pastt2==0) islist->addISPair(t1,this,t2,this);
    if(pastt2==1) islist->addISPair(plane1->vGetIntersection(r),plane1,t1,this);
    if(pastt2==2) islist->addISPair(t1,this,plane1->vGetIntersection(r),plane1);
  } else if(pastt1==1)
  {
    islist->addISPair(t2,this,plane1->vGetIntersection(r),plane1);
  } else if(pastt1==2)
  {
    islist->addISPair(plane1->vGetIntersection(r),plane1,t2,this);
  }

  return 1;
}

void Cone::vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v)
{
  if(!rotated)
  {
    if(material.texture)
    {
      Vector rv;

      rv.x = hitpos->x - position.x;
      rv.y = hitpos->y - position.y;
      rv.z = hitpos->z - position.z;

      *u=(int)(fabs(atan2f(-rv.z,-rv.x)) / (2.0f*3.141592f) * 256.0f*1.0f);
      *v=(int)(rv.y*heightdiv);

      normal->x=rv.x;
      normal->y=0;
      normal->z=rv.z;
      vectorNormalize(normal);
      normal->y = yscale;
    } else {
      normal->x=hitpos->x - position.x;
      normal->y=0;
      normal->z=hitpos->z - position.z;
      vectorNormalize(normal);
      normal->y = yscale;
    }
  } else {
    Vector vv,rv;

    vv.x = hitpos->x - position.x;
    vv.y = hitpos->y - position.y;
    vv.z = hitpos->z - position.z;
    vectorMultipleMatrix(rv,invtmatrix,vv);

    if(material.texture)
    {
      *u=(int)(fabs(atan2f(-rv.z,-rv.x)) / (2.0f*3.141592f) * 256.0f*1.0f);
      *v=(int)(rv.y*heightdiv);
    }

    rv.y=0;
    vectorNormalize(&rv);
    rv.y = yscale;

    vectorMultipleMatrix(*normal,tmatrix,rv);
  }
}