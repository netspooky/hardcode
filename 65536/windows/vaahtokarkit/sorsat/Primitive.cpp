#include "Primitive.h"
#include "Error.h"

#include <string.h>
#include <stdlib.h>

Primitive::Primitive()
{
  //materialid = 0;

  //castshadows = 1;
  hasbs = 0;
  totaloids = 1;

  hitobject = this;
  //csgtype = CSG_NOT;
  csgs.init();
  activecsgs.init();
  islist1.init();
  islist2.init();

  templist.init();

  for(int i=0; i<8; i++) shadowobjects[i].init();
  //noshadowobjects.init();
}

int Primitive::prepareCSG()
{
  activecsgs.total = 0;

  for(int i=0; i<csgs.total; i++)
  {
    if(hasbs)
    {
      Vector v = bsposition;
      vectorSub(&v,&((Primitive *)csgs.pointers[i])->bsposition);
      if(vectorLength(&v) > ((Primitive *)csgs.pointers[i])->bsradius + bsradius)
      {
        if(((Primitive *)csgs.pointers[i])->csgtype == CSG_DIFFERENCE) continue;
        else return 1;
      }
    }
    activecsgs.add(csgs.pointers[i]);
  }

  return 0;
}

// CSG objektit on hitaat, oikea tapa on ihan tyhmä :)
float Primitive::getPrecalcedIntersection(Ray *ray)
{
  islist1.total = 0;
  if(!vGetPrecalcedIntersections(ray,&islist1)) return -1;

  if(activecsgs.total)
  {
    for(int i=0; i<activecsgs.total; i++)
    {
      Primitive *t=((Primitive *)(activecsgs.pointers[i]));
      islist2.total = 0;
      if(!t->vGetPrecalcedIntersections(ray,&islist2))
      {
        if(t->csgtype == CSG_INTERSECTION) return -1;
        else continue;
      }
      islist1.csgTest(&islist2,t->csgtype);
    }
  }

  IS *is = islist1.getNearest();
  if(!is) return -1;
  hitobject = is->obj;
  return is->t;
}

float Primitive::getIntersection(Ray *ray)
{
  islist1.total = 0;
  if(!vGetIntersections(ray,&islist1)) return -1;

  if(activecsgs.total)
  {
    int i;

    for(i=0;i<activecsgs.total;i++)
    {
      Primitive *t=((Primitive *)(activecsgs.pointers[i]));
      islist2.total = 0;
      if(!t->vGetIntersections(ray,&islist2))
      {
        if(t->csgtype == CSG_INTERSECTION) return -1;
        else continue;
      }
      islist1.csgTest(&islist2,t->csgtype);
    }
  }

  IS *is = islist1.getNearest();
  if(!is) return -1;
  hitobject = is->obj;
  return is->t;
}

void Primitive::testPlane(Vector *plane,float d,int *side)
{
  float dd = plane->x * bsposition.x + plane->y * bsposition.y + plane->z * bsposition.z + d;

  if(fabs(dd)<bsradius)
  {
    *side = 0;
  } else {
    if(dd<0)
    {
      *side = -1;
    } else {
      *side = 1;
    }
  }
}
