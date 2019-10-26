#ifndef _Primitive_h_
#define _Primitive_h_

#include "Object.h"
#include "Ptrlist.h"
#include "ISList.h"
#include "Material.h"

#define CSG_NOT          0
#define CSG_DIFFERENCE   1
#define CSG_INTERSECTION 2
#define CSG_UNION        3

class Primitive : public Object
{
public:
  Primitive();
  int prepareCSG();
  float getPrecalcedIntersection(class Ray *ray);
  float getIntersection(class Ray *ray);
  void getIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v);
  void testPlane(Vector *plane,float d,int *side);
  void save(class Block *block);
  void load(class Block *block);

  virtual void vPrecalculate(int rid,Vector *position) {};
  virtual int vGetPrecalcedIntersections(class Ray *ray,ISList *islist) { return 0; };
  virtual int vGetIntersections(class Ray *ray,ISList *islist) { return 0; };
  virtual void vGetIntersectionInfo(Vector *hitpos,Vector *normal,int *u,int *v) {};

  int materialid;
  Material material;

  int currentoid,firstoid,totaloids; // oid = Object ID
  int castshadows,csgtype;

  Ptrlist csgs,activecsgs;

  Primitive *hitobject;
  ISList islist1,islist2;

  int hasbs;
  Vector bsposition;
  float bsradius;
  
  float mint;
  int left,right,up,down;

  //Ptrlist noshadowobjects;
  Ptrlist shadowobjects[8];

  //Object *realhit; // todellinen osuma (sylinterin planeissa sylinteri)

// Sekalaista, jota tarvitaan eri apuohjelmis
  Vector helperv;
  float helper,helper2;
  Ptrlist templist;
};

#endif