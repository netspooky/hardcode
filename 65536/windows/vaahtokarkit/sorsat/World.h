#ifndef _World_h_
#define _World_h_

#include "Object.h"

class World
{
public:
  World();
  ~World();
  void ready();
  void prepare(class RayTracer *rt);
  int removeObject(class Object *o);
  int save(char *file);
  int load(char *file);
  int loadBuffer(unsigned char *buf,int s);

  float time;

  AObject rootobject;
  class Camera *camera;

  Ptrlist objects;
  Ptrlist primitives;
  Ptrlist lights;

  Ptrlist materials;
  Ptrlist textures;

  float bgcolorr,bgcolorg,bgcolorb;

  int lightmask;
  int nexthierarchyid;
};

#endif