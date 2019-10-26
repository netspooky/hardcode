#include "NormalMap.h"
#include "SafeAlloc.h"

void NormalMap::init()
{
  if(xd) return;

  xd = (float *) safeAlloc(256*256*sizeof(float));
  yd = (float *) safeAlloc(256*256*sizeof(float));
}

void NormalMap::getFromBitmap(Bitmap *bm)
{
  init();

  int i = 0;

  for(int y=0; y<256; y++)
  {
    for(int x=0; x<256; x++)
    {
      xd[i] = (float)(bm->data[y][(x+1)&255] - bm->data[y][(x-1)&255])*4/256.0f;
      yd[i] = (float)(bm->data[(y+1)&255][x] - bm->data[(y-1)&255][x])*4/256.0f;
      i++;
    }
  }
}

void NormalMap::affectNormal(Vector *normal,Vector *xdir,Vector *ydir,int u,int v)
{
  float x = xd[((v<<8)&0xFF00)+(u&255)];
  float y = yd[((v<<8)&0xFF00)+(u&255)];
  normal->x += xdir->x*x + ydir->x*y;
  normal->y += xdir->y*x + ydir->y*y;
  normal->z += xdir->z*x + ydir->z*y;
  vectorNormalize(normal);
}
