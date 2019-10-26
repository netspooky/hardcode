#include "LineFont.h"
#include "SafeAlloc.h"
#include "Bitmap.h"

#include <string.h>

void LineLetter::init()
{
  totalvertices = 0;
  lines.init();
}

void LineLetter::draw(Bitmap &dest,int ox,int oy,float s)
{
  for(int i=0; i<lines.total; i++)
  {
    Line *l = (Line *) lines.pointers[i];
    dest.line((int)(x[l->v1]*s)+ox,(int)(y[l->v1]*s)+oy,(int)(x[l->v2]*s)+ox,(int)(y[l->v2]*s)+oy,
              (int)(width[l->v1]*s),(int)(width[l->v2]*s),0xFFFFFF);
    dest.circle((int)(x[l->v1]*s)+ox,(int)(y[l->v1]*s)+oy,(int)(width[l->v1]*s*0.5f),0,0xFFFFFF);
    dest.circle((int)(x[l->v2]*s)+ox,(int)(y[l->v2]*s)+oy,(int)(width[l->v2]*s*0.5f),0,0xFFFFFF);
  }
}

void LineLetter::getArea()
{
  left=right=up=down=0;

  if(totalvertices)
  {
    left = (int)(x[0] - width[0]);
    right = (int)(x[0] + width[0]);
    up = (int)(y[0] - width[0]);
    down = (int)(y[0] + width[0]);

    for(int i=1; i<totalvertices; i++)
    {
      if(x[i]-width[i] < (float)left) left = (int)(x[i]-width[i]);
      if(x[i]+width[i] > (float)right) right = (int)(x[i]+width[i]);
      if(y[i]-width[i] < (float)up) up = (int)(y[i]-width[i]);
      if(y[i]+width[i] > (float)down) down = (int)(y[i]+width[i]);
    }
  }
}

void LineLetter::addVertex()
{
  float *oldx = x, *oldy = y, *oldw = width;

  totalvertices++;

  x = (float *) safeAlloc(sizeof(float)*totalvertices);
  y = (float *) safeAlloc(sizeof(float)*totalvertices);
  width = (float *) safeAlloc(sizeof(float)*totalvertices);
  
  memcpy(x,oldx,sizeof(float)*(totalvertices-1));
  memcpy(y,oldy,sizeof(float)*(totalvertices-1));
  memcpy(width,oldw,sizeof(float)*(totalvertices-1));

  safeFree(oldx);
  safeFree(oldy);
  safeFree(oldw);
}

/*
void LineLetter::subVertex(int v)
{
  if(v >= totalvertices || v<0) return;

  int i;

  for(i=0; i<lines.total; i++)
  {
    Line *l = (Line *) lines.pointers[i];
    if(l->v1==v || l->v2==v)
    {
      lines.remove(i);
      i=-1;
    } else {
      if(l->v1 > v) l->v1--;
      if(l->v2 > v) l->v2--;
    }
  }

  totalvertices--;
  for(i=v; i<totalvertices; i++)
  {
    x[i] = x[i+1];
    y[i] = y[i+1];
    width[i] = width[i+1];
  }
}
*/
/*
Line *LineLetter::addLine()
{
  Line *l = (Line *) safeAlloc(sizeof(Line));
  lines.add(l);
  return l;
}
*/