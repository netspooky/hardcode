#ifndef _TextManager_h_
#define _TextManager_h_

#include "Ptrlist.h"
#include "Bitmap.h"
#include "BMFont.h"

typedef struct
{
  int x,y,st,et,f;
  BMFont *font;
  char *text;
} Text;

class TextManager
{
public:
  Text *add(int x,int y,int st,int et,int f,BMFont *font,char *text);
  void draw(Bitmap &dest,int t);

  Ptrlist texts;
};

#endif