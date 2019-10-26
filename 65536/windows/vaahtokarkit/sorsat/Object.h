#ifndef _Object_h_
#define _Object_h_

#include "Vector.h"
#include "Ptrlist.h"
#include "Matrix.h"
#include "KeyFramer.h"

#define TYPE_CAMERA       0
#define TYPE_CAMERAT      1
#define TYPE_LIGHT        2

#define TYPE_PLANE        13
#define TYPE_SPHERE       14
#define TYPE_CYLINDER     15
#define TYPE_CONE         16
#define TYPE_PARABOLOID   17
#define TYPE_TORUS        18
#define TYPE_BOX          19

class Object
{
public:
  Object();
  void createHierarchy(Ptrlist &objects);
  void prepare(float time);
  void setHierarchyFather(Object *object);
  Object *clone(class World *world);

  int getKey(float t);
  int forceGetKey(float t);

  void setPosition(float x,float y,float z,float t);
  void getPosition(Vector *v,float t);
  void setArgs(float t,float a1,float a2,float a3);
  void getArgs(float t,float &a1,float &a2,float &a3);
  void setMatrix(float t,Matrix *m);
  void getMatrix(float t,Matrix *m);

  void saveObject(class Block *block);
  void loadObject(class Block *block);

  virtual void vPrepare() {};
  virtual void vPrecalculate(int rid,Vector *position) {};

  int visible;

  KeyFramer positionx,positiony,positionz;
  Vector position;

  int argsused;
  KeyFramer arg1kf,arg2kf,arg3kf;
  float arg1,arg2,arg3;

  int rotated,usematrixkf;
  Matrix matrix,tmatrix,invtmatrix;
  KeyFramer matrixkf[9];

  int hierarchyid,hierarchyfather;

  Object *parent;
  Ptrlist childs;
};

class AObject : public Object // rootti
{
};

#endif