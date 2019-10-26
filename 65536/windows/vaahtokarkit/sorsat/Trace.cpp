#include "RayTracer.h"
#include "Primitive.h"
#include "World.h"
#include "Camera.h"
#include "Light.h"

#define invertNormal(d) \
float dot = (d.x*normal.x + d.y*normal.y + d.z*normal.z); \
if(dot>0) \
{ \
  normal.x = -normal.x; \
  normal.y = -normal.y; \
  normal.z = -normal.z; \
  dot = -dot; \
}

#ifdef WIN32
#define convertColorToInt(r,g,b,desti) \
  int *dest=&(desti); \
  __asm { \
    mov ebx,[dest] \
    fld r \
    fistp dword ptr [ebx] \
    fld g \
    fistp dword ptr [ebx+4] \
    fld b \
    fistp dword ptr [ebx+8] \
    int 3 \
  } \
  if(res->mulr > 255) res->mulr = 255; \
  if(res->mulg > 255) res->mulg = 255; \
  if(res->mulb > 255) res->mulb = 255;
#endif
/*
  res->mulr = (int)r; \
  res->mulg = (int)g; \
  res->mulb = (int)b; \
*/

Ray globalray;

RTResult *RayTracer::tracePoint(int x,int y)
{
  RTResult *r = &results[y][x];

  if(r->fid != currentfid)
  {
    r->fid = currentfid;

    vectorMultipleMatrix(globalray.dir,camera->cameramatrix,rays[y][x]);
    r->divide = 0;

    traceFirstHit(r,&objectareas[y>>4][x>>4]);
  }
  return r;
}

void RayTracer::traceFirstHit(RTResult *res,Ptrlist *objects)
{
  int i;
  Primitive *nta=0;
  float nt = 50000;

  globalray.rid = 0;

  for(i=0; i<objects->total; i++)
  {
    Primitive *ta = (Primitive *)objects->pointers[i];
    if(ta->mint > nt) continue;
    float t = ta->getPrecalcedIntersection(&globalray);
    if(t>0)
    {
      if(t<nt)
      {
        nta = ta;
        nt = t;
      }
    }
  }

  if(!nta)
  {
    res->mulr = bgcolorr;
    res->mulg = bgcolorg;
    res->mulb = bgcolorb;
    res->hid = NOHIT;
    res->quaddrawer = QUADDRAWER_FLAT;
    return;
  }

  Primitive *originalhit = nta;
  nta = nta->hitobject;

  res->hid = nta->currentoid;

  res->quaddrawer = QUADDRAWER_GOURAUD;
  if(nta->material.texture)
  {
    res->quaddrawer |= QUADDRAWER_TEXTURE;
    res->texture = nta->material.texture;
  }
  //if(nta->material.bumpmap) res->divide = 1;

  Vector hitpos,normal,reflect;
  hitpos.x = nt * globalray.dir.x + globalray.pos.x;
  hitpos.y = nt * globalray.dir.y + globalray.pos.y;
  hitpos.z = nt * globalray.dir.z + globalray.pos.z;

  nta->vGetIntersectionInfo(&hitpos,&normal,&res->u,&res->v);

  invertNormal(globalray.dir);

  if(nta->material.reflect || nta->material.shiness)
  {
    dot*=2;
    reflect.x = globalray.dir.x - dot*normal.x;
    reflect.y = globalray.dir.y - dot*normal.y;
    reflect.z = globalray.dir.z - dot*normal.z;
  }

  float r = nta->material.ambr, g = nta->material.ambg, b = nta->material.ambb;
  float ar = 0, ag = 0, ab = 0;

  for(i=0; i<lights.total; i++)
  {
    Light *l = (Light *)lights.pointers[i];

    Vector v;
    v.x = l->position.x - hitpos.x;
    v.y = l->position.y - hitpos.y;
    v.z = l->position.z - hitpos.z;

    float c = v.x * normal.x + v.y * normal.y + v.z * normal.z;
    if(c <= 0) {
      res->hid |= 1<<(8+i);
      continue;
    }

    float len = sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    float m = 1.0f/len;

    v.x *= m;
    v.y *= m;
    v.z *= m;

// Varjojen testaus
    Ray sray;
    sray.pos = l->position;
    sray.dir.x = -v.x;
    sray.dir.y = -v.y;
    sray.dir.z = -v.z;
    sray.rid = i+1;
    
    if(traceShadow(&sray,len*0.9999f,&originalhit->shadowobjects[i]))
    {
      res->hid |= 1<<(8+i);
      continue;
    }

    c = c * m;
    r += c*nta->material.difr*l->arg1;
    g += c*nta->material.difg*l->arg2;
    b += c*nta->material.difb*l->arg3;

    if(nta->material.shiness)
    {      
      float d = reflect.x*v.x + reflect.y*v.y + reflect.z*v.z;
      if(d>nta->material.mindot)
      {
        d = powf(d,nta->material.shiness)*nta->material.specular;
        ar += d*l->arg1;
        ag += d*l->arg2;
        ab += d*l->arg3;
        res->quaddrawer |= QUADDRAWER_PHONG;
        res->divide = 1;
      }
    }
  }

  if((res->hid & lightmask)==lightmask) res->quaddrawer &= 0xffffffff - QUADDRAWER_GOURAUD;

  if(nta->material.reflect)
  {
    Ray reflectray;
    reflectray.pos.x = hitpos.x + normal.x*0.1f; // Miks bugittaa, jos toleranssi pienempi?
    reflectray.pos.y = hitpos.y + normal.y*0.1f;
    reflectray.pos.z = hitpos.z + normal.z*0.1f;
    reflectray.dir = reflect;
    
    RTResult refres;
    trace(&reflectray,&refres);

    r = (1-nta->material.reflect)*r + refres.mulr*nta->material.reflect;
    g = (1-nta->material.reflect)*g + refres.mulg*nta->material.reflect;
    b = (1-nta->material.reflect)*b + refres.mulb*nta->material.reflect;

    res->quaddrawer |= refres.quaddrawer;

    if(refres.texture)
    {
      res->texture = refres.texture;
      res->u = refres.u;
      res->v = refres.v;
    }
    res->hid = res->hid | (refres.hid<<16);
  }

  if(res->quaddrawer&QUADDRAWER_PHONG)
  {
    if((res->quaddrawer&QUADDRAWER_TEXTURE)==0)
    {
      res->quaddrawer &= (0xFFFFFFFF - QUADDRAWER_PHONG);
      r += ar;
      g += ag;
      b += ab;
    } else {
      if(ar>255) res->addr=255; else res->addr = (int)ar;
      if(ag>255) res->addg=255; else res->addg = (int)ag;
      if(ab>255) res->addb=255; else res->addb = (int)ab;
    }
  }

  if(r>255) res->mulr=255; else res->mulr = (int)r;
  if(g>255) res->mulg=255; else res->mulg = (int)g;
  if(b>255) res->mulb=255; else res->mulb = (int)b;
}

void RayTracer::trace(Ray *ray,RTResult *res)
{
  int i;
  Primitive *nta = 0;
  float nt = 50000;

  for(i=0; i<visibleobjects.total; i++)
  {
    Primitive *ta = (Primitive *)visibleobjects.pointers[i];
    float t = ta->getIntersection(ray);
    if(t>0) {
      if(t<nt) {
        nta = ta;
        nt = t;
      }
    }
  }

  if(!nta)
  {
    res->mulr = bgcolorr;
    res->mulg = bgcolorg;
    res->mulb = bgcolorb;
    res->hid = NOHIT;
    res->quaddrawer = QUADDRAWER_FLAT;
    return;
  }

  nta = nta->hitobject;

  res->hid = nta->currentoid;
  res->quaddrawer = QUADDRAWER_GOURAUD;
  if(nta->material.texture)
  {
    res->quaddrawer |= QUADDRAWER_TEXTURE;
    res->texture = nta->material.texture;
  }

  Vector hitpos,normal;
  hitpos.x = nt * ray->dir.x + ray->pos.x;
  hitpos.y = nt * ray->dir.y + ray->pos.y;
  hitpos.z = nt * ray->dir.z + ray->pos.z;

  nta->vGetIntersectionInfo(&hitpos,&normal,&res->u,&res->v);

  invertNormal(ray->dir);

  float r = nta->material.ambr, g = nta->material.ambg, b = nta->material.ambb;

  for(i=0; i<lights.total; i++)
  {
    Light *l = (Light *)lights.pointers[i];

    Vector v;
    v.x = l->position.x - hitpos.x;
    v.y = l->position.y - hitpos.y;
    v.z = l->position.z - hitpos.z;

    float c = v.x * normal.x + v.y * normal.y + v.z * normal.z;
    if(c <= 0) {
      res->hid |= 1<<(8+i);
      continue;
    }

    // Ei varjoja peilauksis... Häh? Mitäköhän mäkin oon aatellu, no ei jaksa pistää =)

    c = c / sqrtf(v.x*v.x + v.y*v.y + v.z*v.z);
    r += c*nta->material.difr*l->arg1;
    g += c*nta->material.difg*l->arg2;
    b += c*nta->material.difb*l->arg3;
  }

  if((res->hid & lightmask)==lightmask) res->quaddrawer &= 0xffffffff - QUADDRAWER_GOURAUD;

  if(nta->material.reflect) // Ei nyt jaksa oikeasti peilailla tässä =)
  {
    r = (1-nta->material.reflect)*r;
    g = (1-nta->material.reflect)*g;
    b = (1-nta->material.reflect)*b;
  }

  if(r>255) res->mulr=255; else res->mulr = (int)r;
  if(g>255) res->mulg=255; else res->mulg = (int)g;
  if(b>255) res->mulb=255; else res->mulb = (int)b;
}

int RayTracer::traceShadow(Ray *r,float maxt,Ptrlist *objectlist)
{
  for(int i=0; i<objectlist->total; i++)
  {
    float t = ((Primitive *)objectlist->pointers[i])->getPrecalcedIntersection(r);
    if(t>0) if(t<maxt) {
      void *t = objectlist->pointers[i];
      objectlist->pointers[i] = objectlist->pointers[0];
      objectlist->pointers[0] = t;
      return 1;
    }
  }
  return 0;
}
