#ifndef _DRAWOBJ_H_
#define _DRAWOBJ_H_

#include "3dmath.h"

//forward declaration to make the compiler happy...
class Face; 
class Vertex;

class DrawFaceObj;
class DrawLineObj;
typedef DrawLineObj* DrawLineObjPtr;
typedef DrawFaceObj* DrawFaceObjPtr;

#include "Object3D.h"

class CDrawing;
#include "Drawing.h"

#define NEAR_Z 0.0001f
#define FAR_Z  100000.0f


#define MAXLINE 15000
#define MAXFACE 15000

class PastelColor;

extern CDrawing *drawing;

class DrawObj
{
public:
	DrawObj(){};
};

class DrawFaceObj : public DrawObj
{
public:
	float x1,x2,x3,y1,y2,y3,z1,z2,z3;
	float minx,maxx,miny,maxy;
	float minZ,maxZ;
    float u1,v1,u2,v2,u3,v3;
    DrawLineObjPtr l[3];
    int lcount;
	int visible;
	PastelColor* col;
	int texnum;
};


class DrawLineObj : public DrawObj
{
public:
	float x1,x2,y1,y2,z1,z2;
	float minZ,maxZ;
    int visible;
};

//forward declaration
class FaceList;

class LineList {
public:
	DrawLineObjPtr dl[MAXLINE];
	int count;
    int scratchCount;
	void clear();   
	DrawLineObjPtr add(Vector *v1,Vector *v2);
	void draw(CDrawing* pD);
	void doClip(FaceList *fl);
private:
	void sort(DrawLineObjPtr *l,DrawLineObjPtr *r,DrawLineObjPtr *b,DrawLineObjPtr *e);
	DrawLineObj scratchLines[MAXLINE];
};

class FaceList {
public:
	DrawFaceObjPtr dl[MAXFACE];
	int count;
    int scratchCount;
	void clear();
	void add(Vertex* pVert,Face *face);
    void draw(CDrawing* pD);
	void doClip(int mz);
private:
	void sortmax(DrawFaceObjPtr *l,DrawFaceObjPtr *r,DrawFaceObjPtr *b,DrawFaceObjPtr *e);
	void sortmin(DrawFaceObjPtr *l,DrawFaceObjPtr *r,DrawFaceObjPtr *b,DrawFaceObjPtr *e);
  DrawFaceObj scratchFaces[MAXFACE];
};

#endif //_DRAWOBJ_H_