#ifndef _DRAWING_H_
#define _DRAWING_H_

#include "3dmath.h"
#include "perlin.h"
#include "Object3D.h"
#include "DrawObj.h"
#include "nrline.h"

 //forward declaration to make the compiler happy...
class DrawFaceObj;
class DrawLineObj;

#include "DrawObj.h"
#include "LineFont.h"
#define MAXYRES 1024

class PastelColor;

//forward declaration, just to make the compiler happy...
class texCoord;


class CDrawing
{
public:
	float t;
	Perlin *perlin;
	unsigned int* vscreen;
	CDrawing(void);
	~CDrawing(void);
	void DrawLine(Vector a, Vector b);
	void DrawTextLine(Vector a, Vector b);
	void DrawText(LineFont* lf, char* string, int x, int y, float size, int spacing, int lw);
  void drawFace(DrawFaceObj *f);
	void DDBresenhamLine(float x0, float y0, float x1, float y1, unsigned int value);
	
private:
  int o_eck, u_eck, r_eck, l_eck;
  int rdy, ldy;
  int rx, lx, lu, lv;
  int tdu, tdv;
  int rdx, ldx, ldu, ldv;

  struct
  {
    int x[3], y[3], u[3], v[3];
  } poly;

  void rightSide();
  void leftSide();
};

#endif //_DRAWING_H_