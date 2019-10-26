#ifndef _LineFont_h_
#define _LineFont_h_

#include "Ptrlist.h"

typedef struct
{
  int v1,v2;
} Line;

class LineLetter
{
public:
  void init();
  void getArea();
  void addVertex();
  void subVertex(int v);
  Line *addLine();
  void subLine(int l);
  void draw(class Bitmap &dest,int x,int y,float scale);

  int left,right,up,down;

  int totalvertices;
  float *x,*y,*width;
  Ptrlist lines;
};

class LineFont
{
public:
  void load(unsigned char *buf);

  LineLetter letters[256];
};

#endif