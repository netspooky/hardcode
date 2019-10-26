#ifndef _OBJECT3D_H_
#define _OBJECT3D_H_

#include "3dmath.h"
#include "drawing.h"
//forward declaration
class LineList;
class FaceList;

#include "DrawObj.h"
#include "LineFont.h"
#include "PastelColor.h"

//forward declaration, just to make the compiler happy...
class CDrawing;

class texCoord
{
public:
	int u,v;
	texCoord(int a, int b){u=a;v=b;}
	texCoord(){}
};


class Face
{
public:
	int pIndex[3];
    int lIndex[6];
	texCoord tc[3];
	int count;
    int visible;
    DrawFaceObjPtr theDrawFace;
	Vector n;
	Vector wn;
	PastelColor* col;
	int texnum;
	Face(void)
	{
		count=0;
	}
	~Face(void)
	{
	}

	Face(int a, int b, int c, Vector e, texCoord t1, texCoord t2, texCoord t3, int tex)
	{
		texnum = tex;
		count=3;
		pIndex[0] = a;
		pIndex[1] = b;
		pIndex[2] = c;	

		tc[0] = t1;
		tc[1] = t2;
		tc[2] = t3;

		col = new PastelColor(e);
	}
};

typedef Face* FacePtr;

class Line
{
public:
  int pIndex[2];
  Vector col;
  int fcount;
  FacePtr f[2];

  Line(void)
	{
		fcount=0;
	}
	~Line(void)
	{
	}

  Line(int a,int b,FacePtr f1,FacePtr f2)
  {    
    fcount=0;
    pIndex[0]=a;
    pIndex[1]=b;
    if (f1!=NULL) f[fcount++]=f1;
    if (f2!=NULL) f[fcount++]=f2;
  }
};

class Vertex
{
public:
	Vector os;
	Vector ws;
	Vector ss;
	Vertex()
	{
		os = ws = ss = Vector(0.0f,0.0f,0.0f);
	}
	Vertex(Vector a)
	{
		os = a;
	}
};

class Object3D
{
	void DeAlloc();
	void Alloc();
public:
	Vertex* pVert;
	int verts;
	int faces;
	int lines;
	Face* pFaces;
    Line* pLines;

    Quaternion rot;
    Vector     trans;
    Matrix     m;


	Object3D(void);
	~Object3D(void);
	void BuildCube(float size);
	unsigned char* Object3D::BuildObj(unsigned char *mem,int texturnummer);
    void BuildText(LineFont* lf, char* string, float x, float y, float z,float size, float spacing, int lw);
	void Transform(Matrix m);
    void Draw(LineList* ll,FaceList *fl);
	void MakeNormals();
	
};


class Camera
{
  public:
  Matrix m;
  unsigned short angx,angy,angz;
  float perspX,perspY;
  float roll;
  Vector eyepoint,target;
  float *posKeys;
  float *targetKeys;
  float *rollKeys;

  Camera(void);
  void Camera2Matrix();
  unsigned char* BuildCam(unsigned char *mem);
  unsigned char* BuildCamKeys(unsigned char *mem);
};

typedef Object3D* Object3DPtr;


class Scene3D {
public:
  Camera cam;
  int count;
  Object3DPtr o[1000];

  Scene3D(void)
  {
	  count=0;
  }
  
  void buildScene(unsigned char *mem);
  void buildfirstScene(LineFont*);
  void buildsecondScene(LineFont*);
  void buildthirdScene(LineFont*);
  void buildgreetingScene(LineFont*,char* text, float x, float y, float z, float size);
  void drawScene(float frame,LineList* ll,FaceList *fl);
  static void spline(float *keyArray,float curFrame,float *out,int numOfFloats);
};

#endif //_OBJECT3D_H_