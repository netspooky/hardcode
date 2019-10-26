#include "World.h"
#include "Primitive.h"
#include "Camera.h"
#include "RayTracer.h"
#include "Light.h"
#include "SafeAlloc.h"
#include "Sphere.h"

World::World()
{
  objects.init();
  primitives.init();
  lights.init();
  materials.init();
  textures.init();

  nexthierarchyid = 1;

  camera = new Camera();
  camera->hierarchyid = nexthierarchyid++;
  camera->target->hierarchyid = nexthierarchyid++;

  time = 0;

  ready();
}

void World::ready()
{
  int i;

  objects.total = 0;

  lightmask = 0;
  for(i=0; i<lights.total; i++)
  {
    lightmask |= 1<<(8+i);
    objects.add(lights.pointers[i]);
  }

  objects.add(camera);
  objects.add(camera->target);
  
  for(i=0; i<primitives.total; i++)
  {
    Primitive *p = (Primitive *) primitives.pointers[i];
    if(p->materialid>=0)
    {
      p->material = *((Material *)materials.pointers[p->materialid]);
      if(p->material.textureid >= 1)
      {
        if(p->material.textureid-1 >= textures.total)
        {
          p->material.texture = 0;
        }
        p->material.texture = (Bitmap *) textures.pointers[p->material.textureid-1];
      } else p->material.texture = 0;
    }
    objects.add(p);
  }

  rootobject.hierarchyfather=-2;
  rootobject.hierarchyid=0;
  rootobject.createHierarchy(objects);
}

void World::prepare(RayTracer *rt)
{
  int i;

// Objektien preppaus
  rootobject.prepare(time); // Prepare on hierarkinen

  rt->camera = camera;
  camera->createCameraMatrix();

// Prekalkuloinnit
  for(i=0; i<objects.total; i++)
  {
    ((Object *)objects.pointers[i])->vPrecalculate(0,&camera->position);
    for(int j=0; j<lights.total; j++)
    {
      ((Object *)objects.pointers[i])->vPrecalculate(j+1,&((Object *)lights.pointers[j])->position);
    }
  }

// RayTracerin preppaus tälle worldille
  rt->frustumedobjects.total = 0;
  rt->visibleobjects.total = 0;
  rt->frustum.prepare(camera);
  rt->lightmask = lightmask;
  rt->bgcolorr = (int) bgcolorr;
  rt->bgcolorg = (int) bgcolorg;
  rt->bgcolorb = (int) bgcolorb;

  rt->lights.total = 0;
  for(i=0; i<lights.total; i++) rt->lights.add(lights.pointers[i]);

// Katsotaan mitkä objektit pitää treissata (frustum) ja preparoidaan vähän

  //float d;
  int oidi = 0,s;

  for(i=0; i<primitives.total; i++)
  {
    Primitive *o = (Primitive *) primitives.pointers[i];

    o->currentoid = oidi;
    o->firstoid = oidi;
    oidi += o->totaloids;

    for(int j=0; j<lights.total; j++) o->shadowobjects[j].total = 0;
    if(o->material.shiness) o->material.mindot = powf(2.0f/256.0f,1.0f/o->material.shiness);

    if(!o->visible) continue;

    if(o->prepareCSG()) continue;

    rt->visibleobjects.add(o);

    if(o->hasbs)
    {
      o->testPlane(&rt->frustum.twplanes[0],rt->frustum.wd[0],&s);
      if(s==-1) continue;
      o->testPlane(&rt->frustum.twplanes[rt->width-1],rt->frustum.wd[rt->width-1],&s);
      if(s==1) continue;
      o->testPlane(&rt->frustum.thplanes[0],rt->frustum.hd[0],&s);
      if(s==-1) continue;
      o->testPlane(&rt->frustum.thplanes[rt->height-1],rt->frustum.hd[rt->height-1],&s);
      if(s==1) continue;
    }

    rt->frustumedobjects.add(o);
  }

// Huonolla tavalla katotaan missä päin ruutua objektit on (2D bounding box)

  int a=rt->width/16,a2=rt->height/16;

  for(i=0; i<rt->frustumedobjects.total; i++)
  {
    Primitive *o = (Primitive *)rt->frustumedobjects.pointers[i];
    o->left = 0;
    o->up = 0;
    o->right = rt->width;
    o->down = rt->height;
    if(!o->hasbs)
    {
      o->mint = 0;
      continue;
    }

    Vector v = o->bsposition;
    vectorSub(&v,&camera->position);
    o->mint = vectorLength(&v) - o->bsradius;
    if(o->mint < 0) o->mint = 0;

    int p=0,p2=0,j;

    for(j=0; j<15; j++)
    {
      p+=a;
      o->testPlane(&rt->frustum.twplanes[p],rt->frustum.wd[p],&s);
      if(s==1) o->left=p;
      if(s==-1)
      {
        o->right=p;
        break;
      }
    }
    for(j=0; j<15; j++)
    {
      p2+=a2;
      o->testPlane(&rt->frustum.thplanes[p2],rt->frustum.hd[p2],&s);
      if(s==1) o->up=p2;
      if(s==-1)
      {
        o->down=p2;
        break;
      }
    }
  }

// Sortataan obut, jotta minimi t:stä (mint) olis eniten hyötyä

  for(i=0; i<rt->frustumedobjects.total; i++)
  {
    for(int j=0; j<rt->frustumedobjects.total; j++)
    {
      if(i==j) continue;
      if(((Primitive *)rt->frustumedobjects.pointers[i])->mint < ((Primitive *)rt->frustumedobjects.pointers[j])->mint)
      {
        void *t = rt->frustumedobjects.pointers[i];
        rt->frustumedobjects.pointers[i] = rt->frustumedobjects.pointers[j];
        rt->frustumedobjects.pointers[j] = t;
      }
    }
  }

// Piirretään objektit objectareassiin

  for(int y=0; y<rt->oah; y++)
  {
    for(int x=0; x<rt->oaw; x++)
    {
      rt->objectareas[y][x].total = 0;
    }
  }

  for(i=0; i<rt->frustumedobjects.total; i++)
  {
    Primitive *o=(Primitive *)rt->frustumedobjects.pointers[i];
    int x1 = o->left/16;
    int y1 = o->up/16;
    int x2 = o->right/16;
    int y2 = o->down/16;

    for(; y1<=y2; y1++)
    {
      for(int x=x1; x<=x2; x++)
      {
        rt->objectareas[y1][x].add(o);
      }
    }
  }

// Katsotaan mitkä objektit voi varjostaa mitäkin objektia

  for(int k=0; k<lights.total; k++)
  {
    Light *l = (Light *)lights.pointers[k];

    for(i=0; i<primitives.total; i++)
    {
      Primitive *o=(Primitive *)primitives.pointers[i];
      if(!o->hasbs) continue;

      o->helperv = o->bsposition;
      vectorSub(&o->helperv,&l->position);
      o->helper2 = vectorNormalizeAndGetLength(&o->helperv);
      if(o->helper2 <= o->bsradius)
      {
        o->helper = 100;
        o->helperv.x = 0;
        o->helperv.y = 0;
        o->helperv.z = 0;
      } else o->helper = asinf(o->bsradius/o->helper2);
    }

    for(i=0; i<primitives.total; i++)
    {
      Primitive *o1=(Primitive *)primitives.pointers[i];
      if(!o1->visible) continue;
      if(!o1->castshadows) continue;
      if(!o1->hasbs)
      {
        for(int j=0; j<primitives.total; j++)
        {
          if(o1==primitives.pointers[j]) continue;
          ((Primitive *)primitives.pointers[j])->shadowobjects[k].add(o1);
        }
        continue;
      }

      for(int j=0; j<primitives.total; j++)
      {
        Primitive *o2=(Primitive *)primitives.pointers[j];
        if(o1==o2) { o2->shadowobjects[k].add(o1); continue; }

//        int l;
//        for(l=0; l<o2->noshadowobjects.total; l++) if(o2->noshadowobjects.pointers[l] == o1) break;
//        if(l!=o2->noshadowobjects.total) continue;

        if(!o2->hasbs)
        {
          o2->shadowobjects[k].add(o1);
          continue;
        }

        if(o1->helper2 - o1->bsradius >= o2->helper2 + o2->bsradius) continue;
        float a = acosf(vectorDotProduct(&o1->helperv,&o2->helperv));
        if(a < o1->helper + o2->helper) o2->shadowobjects[k].add(o1);
      }
    }
  }
}

