#include "Object.h"
#include "Error.h"
#include "Sphere.h"
#include "Cone.h"
#include "Cylinder.h"
#include "Plane.h"
#include "Light.h"
#include "World.h"
#include "SafeAlloc.h"

#include <string.h>
#include <stdio.h>

Object::Object()
{
/*
  hierarchyid = 32766;
  hierarchyfather = 0;
  visible = 1;
  parent = 0;

  usematrixkf = 0;
  rotated = 0;
*/
  matrix.identity();
  tmatrix.identity();

  positionx.init();
  positiony.init();
  positionz.init();
  arg1kf.init();
  arg2kf.init();
  arg3kf.init();
  for(int i=0; i<9; i++) matrixkf[i].init();

  setPosition(0,0,0,0);
  setArgs(0,0,0,0);
  setMatrix(0,&matrix);
  argsused = 0;

  childs.init();
}

void Object::createHierarchy(Ptrlist &objects)
{
  childs.total = 0;

  for(int i=0; i<objects.total; i++)
  {
    Object *o = (Object *) objects.pointers[i];
    if(o->hierarchyfather == hierarchyid)
    {
/*
      if(o==this)
      {
        continue;
      }
*/

      o->createHierarchy(objects);
      childs.add(o);
      o->parent = this;
    }
  }
}

void Object::prepare(float t)
{
  Vector v;

  v.x = positionx.getValue(t);
  v.y = positiony.getValue(t);
  v.z = positionz.getValue(t);

  arg1 = arg1kf.getValue(t);
  arg2 = arg2kf.getValue(t);
  arg3 = arg3kf.getValue(t);

  if(usematrixkf)
  {
    matrix.m[0][0] = matrixkf[0].getValue(t);
    matrix.m[1][0] = matrixkf[1].getValue(t);
    matrix.m[2][0] = matrixkf[2].getValue(t);
    matrix.m[0][1] = matrixkf[3].getValue(t);
    matrix.m[1][1] = matrixkf[4].getValue(t);
    matrix.m[2][1] = matrixkf[5].getValue(t);
    matrix.m[0][2] = matrixkf[6].getValue(t);
    matrix.m[1][2] = matrixkf[7].getValue(t);
    matrix.m[2][2] = matrixkf[8].getValue(t);
    matrix.fix();
  }

  if(parent)
  {
    vectorMultipleMatrix(position,parent->tmatrix,v);
    position.x += parent->position.x;
    position.y += parent->position.y;
    position.z += parent->position.z;

    tmatrix.identity();
    tmatrix.multipleMatrix(matrix);
    tmatrix.multipleMatrix(parent->tmatrix);
    invtmatrix = tmatrix;
    invtmatrix.inverse();

    rotated = 0;
    rotated |= parent->rotated;
    if(usematrixkf) rotated = 1;
  } else position = v;

  vPrepare();

  for(int i=0; i<childs.total; i++)
  {
    ((Object *)childs.pointers[i])->prepare(t);
  }
}

/*
void Object::setHierarchyFather(Object *object)
{
  int i;

  if(object==0)
  {
    hierarchyfather = 0;

    for(i=0; i<positionx.keys.total; i++)
    {
      ((Key *)positionx.keys.pointers[i])->v += parent->position.x;
      ((Key *)positiony.keys.pointers[i])->v += parent->position.y;
      ((Key *)positionz.keys.pointers[i])->v += parent->position.z;
    }
  } else {
    if(hierarchyid != object->hierarchyfather)
    {
      hierarchyfather = object->hierarchyid;
      for(i=0; i<positionx.keys.total; i++)
      {
        ((Key *)positionx.keys.pointers[i])->v += parent->position.x;
        ((Key *)positiony.keys.pointers[i])->v += parent->position.y;
        ((Key *)positionz.keys.pointers[i])->v += parent->position.z;
      }
      for(i=0; i<positionx.keys.total; i++)
      {
        ((Key *)positionx.keys.pointers[i])->v -= object->position.x;
        ((Key *)positiony.keys.pointers[i])->v -= object->position.y;
        ((Key *)positionz.keys.pointers[i])->v -= object->position.z;
      }
    }
  }
}
*/

int Object::getKey(float t)
{
  int i;
  for(i=0; i<positionx.keys.total; i++)
  {
    if(((Key *)positionx.keys.pointers[i])->t == t)
    {
      return i;
    }
  }
  return -1;
}

int Object::forceGetKey(float t)
{
  int i = getKey(t);
  if(i>=0) return i;

  Key *k;
  k=positionx.addKey(t,positionx.getValue(t));
  positiony.addKey(t,positiony.getValue(t));
  positionz.addKey(t,positionz.getValue(t));
  arg1kf.addKey(t,arg1kf.getValue(t));
  arg2kf.addKey(t,arg2kf.getValue(t));
  arg3kf.addKey(t,arg3kf.getValue(t));
  for(i=0; i<9; i++) matrixkf[i].addKey(t,matrixkf[i].getValue(t));
/*
  positionx.sortKeys();
  positiony.sortKeys();
  positionz.sortKeys();
  arg1kf.sortKeys();
  arg2kf.sortKeys();
  arg3kf.sortKeys();
  for(i=0; i<9; i++) matrixkf[i].sortKeys();
*/
  for(i=0; i<positionx.keys.total; i++)
  {
    if(positionx.keys.pointers[i] == (void *)k) return i;
  }

  return -1;
}

void Object::setPosition(float x,float y,float z,float t)
{
  int k = forceGetKey(t);
  ((Key *)positionx.keys.pointers[k])->v = x;
  ((Key *)positiony.keys.pointers[k])->v = y;
  ((Key *)positionz.keys.pointers[k])->v = z;
}

/*
void Object::getPosition(Vector *v,float t)
{
  int k = forceGetKey(t);
  v->x = ((Key *)positionx.keys.pointers[k])->v;
  v->y = ((Key *)positiony.keys.pointers[k])->v;
  v->z = ((Key *)positionz.keys.pointers[k])->v;
}
*/

void Object::setArgs(float t,float a1,float a2,float a3)
{
  int k = forceGetKey(t);
  ((Key *)arg1kf.keys.pointers[k])->v = a1;
  ((Key *)arg2kf.keys.pointers[k])->v = a2;
  ((Key *)arg3kf.keys.pointers[k])->v = a3;
}

/*
void Object::getArgs(float t,float &a1,float &a2,float &a3)
{
  int k = forceGetKey(t);
  a1 = ((Key *)arg1kf.keys.pointers[k])->v;
  a2 = ((Key *)arg2kf.keys.pointers[k])->v;
  a3 = ((Key *)arg3kf.keys.pointers[k])->v;
}
*/

void Object::setMatrix(float t,Matrix *m)
{
  int k = forceGetKey(t);
  ((Key *)(matrixkf[0].keys.pointers[k]))->v = m->m[0][0];
  ((Key *)(matrixkf[1].keys.pointers[k]))->v = m->m[1][0];
  ((Key *)(matrixkf[2].keys.pointers[k]))->v = m->m[2][0];
  ((Key *)(matrixkf[3].keys.pointers[k]))->v = m->m[0][1];
  ((Key *)(matrixkf[4].keys.pointers[k]))->v = m->m[1][1];
  ((Key *)(matrixkf[5].keys.pointers[k]))->v = m->m[2][1];
  ((Key *)(matrixkf[6].keys.pointers[k]))->v = m->m[0][2];
  ((Key *)(matrixkf[7].keys.pointers[k]))->v = m->m[1][2];
  ((Key *)(matrixkf[8].keys.pointers[k]))->v = m->m[2][2];
}

/*
void Object::getMatrix(float t,Matrix *m)
{
  int k = forceGetKey(t);
  m->m[0][0] = ((Key *)matrixkf[0].keys.pointers[k])->v;
  m->m[1][0] = ((Key *)matrixkf[1].keys.pointers[k])->v;
  m->m[2][0] = ((Key *)matrixkf[2].keys.pointers[k])->v;
  m->m[0][1] = ((Key *)matrixkf[3].keys.pointers[k])->v;
  m->m[1][1] = ((Key *)matrixkf[4].keys.pointers[k])->v;
  m->m[2][1] = ((Key *)matrixkf[5].keys.pointers[k])->v;
  m->m[0][2] = ((Key *)matrixkf[6].keys.pointers[k])->v;
  m->m[1][2] = ((Key *)matrixkf[7].keys.pointers[k])->v;
  m->m[2][2] = ((Key *)matrixkf[8].keys.pointers[k])->v;
  m->fix();
}*/