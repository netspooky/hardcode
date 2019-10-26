#include "World.h"
#include "Primitive.h"
#include "SafeAlloc.h"

#include "Camera.h"
#include "Light.h"
#include "Plane.h"
#include "Sphere.h"
#include "Cylinder.h"
#include "Cone.h"
#include "Paraboloid.h"

#include <string.h>

short getWord(unsigned char *buf,int &p)
{
  short s;
  memcpy(&s,&buf[p],2);
  p += 2;
  return s;
}

char getSByte(unsigned char *buf,int &p)
{
  char s;
  memcpy(&s,&buf[p],1);
  p += 1;
  return s;
}

int World::loadBuffer(unsigned char *buf,int size)
{
  int pos=0,i,j;

  if(buf[pos++] != 'D') return 1;

  bgcolorr = (float) buf[pos++];
  bgcolorg = (float) buf[pos++];
  bgcolorb = (float) buf[pos++];

  int m = buf[pos++];

  for(i=0; i<m; i++)
  {
    Material *m = (Material *) safeAlloc(sizeof(Material));
    m->ambr = (float) buf[pos++];
    m->ambg = (float) buf[pos++];
    m->ambb = (float) buf[pos++];
    m->difr = (float) buf[pos++];
    m->difg = (float) buf[pos++];
    m->difb = (float) buf[pos++];
    m->specular = (float) buf[pos++];
    m->shiness = (float) buf[pos++];
    m->reflect = (float) buf[pos++] / 255.0f;
    pos+=2;
    m->textureid = buf[pos++];
    m->bumpid = buf[pos++];
    pos++;
    materials.add(m);
  }

  int firsthid = (nexthierarchyid+=2);

  Object *o;
  Primitive *p;

  while(pos<size)
  {
    o=0;
    p=0;

    int type = buf[pos++], muu = 0;

    switch(type)
    {
      case TYPE_CAMERA: o = camera; break;
      case TYPE_CAMERAT: o = camera->target; muu=1; break;
      case TYPE_SPHERE: o = p = new Sphere(); break;
      case TYPE_PLANE: o = p = new Plane(); break;
      case TYPE_CYLINDER: o = p = new Cylinder(); break;
      case TYPE_CONE: o = p = new Cone(); break;
      case TYPE_LIGHT: o = new Light(); break;
      default: return 2;
    }

    int argsused = o->argsused;
    if(muu) argsused = 0;

    o->hierarchyid = getWord(buf,pos) + firsthid;
    o->hierarchyfather = getWord(buf,pos);
    if(o->hierarchyfather != 0) o->hierarchyfather += firsthid;

// Flagit
    int flags = buf[pos++];
    o->usematrixkf = flags & 1;
    o->visible = (flags&2)==2;
    if(p)
    {
      p->castshadows = (flags & 4)==4;
      p->csgtype = (flags >> 4) & 3;
      p->materialid = buf[pos++];
    }

// Keyframeri
    int keys = buf[pos++];
    float spline = buf[pos++]/255.0f;

    for(int i=0; i<9; i++) o->matrixkf[i].spline = spline;
    o->arg3kf.spline = o->arg2kf.spline = o->arg1kf.spline = o->positionz.spline = o->positiony.spline = o->positionx.spline = spline;

    for(i=0; i<keys; i++)
    {
      float t = getWord(buf,pos);

      float x = getWord(buf,pos)/16.0f;
      float y = getWord(buf,pos)/16.0f;
      float z = getWord(buf,pos)/16.0f;

      o->setPosition(x,y,z,t);

      float a1=0,a2=0,a3=0;
      if(argsused >= 1) a1 = getWord(buf,pos)/16.0f;
      if(argsused >= 2) a2 = getWord(buf,pos)/16.0f;
      if(argsused >= 3) a3 = getWord(buf,pos)/16.0f;
      o->setArgs(t,a1,a2,a3);

      if(o->usematrixkf)
      {
        int k = o->forceGetKey(t);
        for(j=0; j<9; j++)
        {
          ((Key *)(o->matrixkf[j].keys.pointers[k]))->v = getSByte(buf,pos)/127.0f;
        }
      }
    }

// CSG
    if(p)
    {
      p->templist.total = 0;
      int c = buf[pos++];
      for(i=0; i<c; i++)
      {
        p->templist.add((void *) getWord(buf,pos));
      }
    }

    if(type==TYPE_LIGHT) lights.add(o);
    if(p) primitives.add(p);
  }

  for(i=0; i<primitives.total; i++)
  {
    Primitive *p = (Primitive *) primitives.pointers[i];
    for(j=0; j<p->templist.total; j++)
    {
      p->csgs.add(primitives.pointers[(int)p->templist.pointers[j]]);
    }
  }

  ready();

  return 0;
}
