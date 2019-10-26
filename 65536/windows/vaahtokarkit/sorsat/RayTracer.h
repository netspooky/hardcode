#ifndef _RayTracer_h_
#define _RayTracer_h_

#include "Ptrlist.h"
#include "Vector.h"
#include "Frustum.h"

#define ANTIALIAS

#define NOHIT 0xFFFFFFFF
#define QUADDRAWER_FLAT           0
#define QUADDRAWER_GOURAUD        1
#define QUADDRAWER_TEXTURE        2
#define QUADDRAWER_PHONG          4

class Ray
{
public:
  Vector dir,pos;
  int rid;
};

typedef struct
{
  int hid,fid,quaddrawer;
  unsigned char mulr,mulg,mulb,addr,addg,addb;
  int u,v;
  class Bitmap *texture;
  unsigned char divide;
} RTResult;

class RayTracer
{
public:
// RayTracer.cpp
  RayTracer();
  ~RayTracer();
  void init(int w,int h);
  void deinit();
  void prepareRendering();
  void render(class Bitmap *dest,int nonrt);
  void renderQuad4(int x,int y);
  void renderQuad2(int x,int y);
  void renderQuad1(int x,int y);

// Trace.cpp
  class Primitive *getHitObject(int x,int y);
  RTResult *tracePoint(int x,int y);
  void traceFirstHit(RTResult *res,Ptrlist *objects); // Ray on globalray
  void trace(Ray *r,RTResult *res);
  int traceShadow(Ray *r,float maxt,Ptrlist *objectlist);

  int currentfid;

  int width,height;
  Vector **rays,**rays2; // rays2 antialiasoinnille
  RTResult **results;

  int oaw,oah;
  Ptrlist **objectareas;

  class Bitmap *dest;

  Frustum frustum;

  class World *world;
  class Camera *camera;
  int bgcolorr,bgcolorg,bgcolorb;

  Ptrlist visibleobjects;
  Ptrlist frustumedobjects;
  Ptrlist lights;
  //Ptrlist hitobjects1,hitobjects2;

  int lightmask;
};

#endif