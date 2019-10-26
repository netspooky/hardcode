#include "RayTracer.h"
#include "SafeAlloc.h"
#include "World.h"
#include "Bitmap.h"
#include "Camera.h"

RayTracer::RayTracer()
{
  lights.init();
  visibleobjects.init();
  frustumedobjects.init();
//  hitobjects1.init();
//  hitobjects2.init();
}

void RayTracer::init(int w,int h)
{
  int i;

  w = w & (0xFFFFFFFF - 3);
  h = h & (0xFFFFFFFF - 3);

  width = w;
  height = h;

  rays = (Vector **)safeAlloc((h+1)*sizeof(Vector *));
  rays[0] = (Vector *)safeAlloc((w+1)*(h+1)*sizeof(Vector));
  rays2 = (Vector **)safeAlloc((h+1)*sizeof(Vector *));
  rays2[0] = (Vector *)safeAlloc((w+1)*(h+1)*sizeof(Vector));

  results = (RTResult **)safeAlloc((h+1)*sizeof(RTResult *));
  for(i=0; i<(h+1); i++) results[i]=(RTResult *)safeAlloc((w+1)*sizeof(RTResult));

  oaw = (w+16+1) / 16;
  oah = (h+16+1) / 16;
  objectareas = (Ptrlist **)safeAlloc(oah*sizeof(Ptrlist *));
  objectareas[0] = (Ptrlist *)safeAlloc(oaw*oah*sizeof(Ptrlist));

  for(i=1; i<(h+1); i++) rays[i]=rays[i-1]+w+1;
  for(i=1; i<(h+1); i++) rays2[i]=rays2[i-1]+w+1;
  for(i=1; i<oah; i++) objectareas[i] = objectareas[i-1]+oaw;

  int y;

  for(y=0; y<h+1; y++)
  {
    for(int x=0; x<w+1; x++)
    {
      rays[y][x].x = (float)(x-w/2) / (float)(w/1.7);
      rays[y][x].y = (float)(h/2-y) / (float)(w/1.7);
      rays[y][x].z = 1.0f;
      vectorNormalize(&rays[y][x]);

      rays2[y][x].x = ((float)(x-w/2)-0.5f) / (float)(w/1.7);
      rays2[y][x].y = ((float)(h/2-y)+0.5f) / (float)(w/1.7);
      rays2[y][x].z = 1.0f;
      vectorNormalize(&rays2[y][x]);
    }
  }

  for(y=0; y<oah; y++)
  {
    for(int x=0; x<oaw; x++)
    {
      objectareas[y][x].init();
    }
  }

  frustum.init(this,w,h);

  currentfid = 1;
}

/*
void RayTracer::deinit()
{
  safeFree(rays[0]);
  safeFree(rays);

  for(int i=0; i<(height+1); i++) safeFree(results[i]);
  safeFree(results);

  safeFree(objectareas[0]);
  safeFree(objectareas);
}
*/

extern Ray globalray;

void RayTracer::prepareRendering()
{
  currentfid++;

  world->prepare(this);
  globalray.pos = camera->position;
}

void RayTracer::render(Bitmap *d,int nonrt)
{
  dest = d;
  prepareRendering();

  int y,x;

  if(nonrt)
  {
    for(y=0; y<height; y+=1)
    {
      for(x=0; x<width; x+=1)
      {
        renderQuad1(x,y);
      }
    }
  } else {
    for(y=0; y<height; y+=4)
    {
      for(x=0; x<width; x+=4)
      {
        renderQuad4(x,y);
      }
    }
  }
}