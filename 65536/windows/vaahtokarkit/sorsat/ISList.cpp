#include "ISList.h"
#include "SafeAlloc.h"
#include "Primitive.h"

void ISList::init()
{
  total = max = 0;
  is = 0;
}

void ISList::addISPair(float t1,class Primitive *o1,float t2,class Primitive *o2)
{
  if(total>=max)
  {
    ISPair *old = is;
    is = (ISPair *) safeAlloc(sizeof(ISPair)*(max+2));
    safeFree(old);
    max+=2;
  }
  is[total].used = 1;
  is[total].is1.obj = o1;
  is[total].is1.t = t1;
  is[total].is2.obj = o2;
  is[total++].is2.t = t2;
}

void ISList::csgTest(ISList *csg,int csgtype)
{
  int i,j;

  for(i=0; i<csg->total; i++)
  {
    ISPair *ispb = &csg->is[i];
    if(!ispb->used) continue;

    int oldtotal = total;

    for(j=0; j<oldtotal; j++)
    {
      ISPair *ispa = &is[j];
      if(!ispa->used) continue;
      switch(csgtype)
      {
        case CSG_INTERSECTION:
          if(ispa->is2.t <= ispb->is1.t) { ispa->used=0; continue; }
          if(ispa->is1.t >= ispb->is2.t) { ispa->used=0; continue; }

          if(ispb->is1.t <= ispa->is1.t && ispb->is2.t >= ispa->is2.t) continue;

          if(ispa->is1.t <= ispb->is1.t && ispa->is2.t >= ispb->is2.t)
          {
            ispa->is1.t=ispb->is1.t;
            ispa->is1.obj=ispb->is1.obj;
            ispa->is2.t=ispb->is2.t;
            ispa->is2.obj=ispb->is2.obj;
            continue;
          }

          if(ispa->is1.t <= ispb->is1.t && ispa->is2.t <= ispb->is2.t)
          {
            ispa->is1.t=ispb->is1.t;
            ispa->is1.obj=ispb->is1.obj;
            continue;
          }

          if(ispb->is1.t <= ispa->is1.t && ispb->is2.t <= ispa->is2.t)
          {
            ispa->is2.t=ispb->is2.t;
            ispa->is2.obj=ispb->is2.obj;
            continue;
          }
          break;

        case CSG_DIFFERENCE:
          if(ispa->is1.t >= ispb->is1.t && ispa->is2.t <= ispb->is2.t)
          {
            ispa->used = 0;
            continue;
          }

          if(ispb->is1.t >= ispa->is2.t || ispb->is2.t <= ispa->is1.t) continue;

// Ilkee jako, tän takia piti tehä eri tavalla...
          if(ispa->is1.t < ispb->is1.t && ispa->is2.t > ispb->is2.t)
          {
            addISPair(ispb->is2.t,ispb->is2.obj,ispa->is2.t,ispa->is2.obj);
            ispa->is2.t = ispb->is1.t;
            ispa->is2.obj = ispb->is1.obj;
          }

          if(ispb->is1.t > ispa->is1.t && ispb->is2.t > ispa->is2.t)
          {
            ispa->is2.t = ispb->is1.t;
            ispa->is2.obj = ispb->is1.obj;
            continue;
          }
          if(ispa->is1.t > ispb->is1.t && ispb->is2.t < ispa->is2.t)
          {
            ispa->is1.t = ispb->is2.t;
            ispa->is1.obj = ispb->is2.obj;
            continue;
          }
          break;
/*
        case CSG_UNION:
          if(ispb->is1.t >= ispa->is2.t || ispb->is2.t <= ispa->is1.t)
          {
            addISPair(ispb->is1.t,ispb->is1.obj,ispb->is2.t,ispb->is2.obj);
            continue;
          }
          if(ispb->is1.t > ispa->is1.t && ispb->is2.t > ispa->is2.t)
          {
            ispa->is2.t = ispb->is2.t;
            ispa->is2.obj = ispb->is2.obj;
            continue;
          }
          if(ispa->is1.t > ispb->is1.t && ispb->is2.t < ispa->is2.t)
          {
            ispa->is1.t = ispb->is1.t;
            ispa->is1.obj = ispb->is1.obj;
            continue;
          }
          break;
*/
        case CSG_NOT:
          break;
      }
    }
  }
}

IS *ISList::getNearest()
{
  IS *nearest = 0;

  for(int i=0; i<total; i++)
  {
    if(!is[i].used) continue;
    if(is[i].is1.t>=0)
    {
      if(!nearest) nearest=&is[i].is1;
      else if(is[i].is1.t<nearest->t) nearest = &is[i].is1;
    }
    if(is[i].is2.t>=0)
    {
      if(!nearest) nearest=&is[i].is2;
      else if(is[i].is2.t<nearest->t) nearest = &is[i].is2;
    }
  }

  return nearest;
}
