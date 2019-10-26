/* Bitmap Font */

#ifndef _BMFont_h_
#define _BMFont_h_

class BMFont
{
public:
  void getFromLineFont(class LineFont *lf,float scale);
  //void printFormat(class Bitmap &dest,int x,int y,char *f,...);
  void print(class Bitmap &dest,int t,int x,int y,char *f);

  class Bitmap *bitmaps[256];
  int space;
};

#endif