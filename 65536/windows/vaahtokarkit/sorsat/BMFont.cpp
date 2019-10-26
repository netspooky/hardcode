#include "BMFont.h"
#include "LineFont.h"
#include "Bitmap.h"

#include <stdio.h>
#include <string.h>
#include <stdarg.h>

void BMFont::getFromLineFont(LineFont *lf,float scale)
{
  int i;

  for(i=0; i<256; i++)
  {
    bitmaps[i] = 0;

    if(lf->letters[i].totalvertices)
    {
      Bitmap *tee = new Bitmap((int)((lf->letters[i].right-lf->letters[i].left)*scale),(int)((lf->letters[i].down-lf->letters[i].up)*scale));
      bitmaps[i] = new Bitmap((int)((lf->letters[i].right-lf->letters[i].left)*scale/2),(int)((lf->letters[i].down-lf->letters[i].up)*scale/2));
      lf->letters[i].draw(*tee,(int)(-lf->letters[i].left*scale),(int)(-lf->letters[i].up*scale),scale);
      tee->smooth();
      bitmaps[i]->antialias(*tee);
      delete tee;
    }
  }

  space = (int)(16.0f*scale);
}
/*
void BMFont::printFormat(Bitmap &dest,int x,int y,char *f,...)
{
  va_list args;
  va_start(args,f);
  char buf[2048];
  vsprintf(buf,f,args);
  print(dest,0,x,y,buf);
  va_end(args);
}
*/
void BMFont::print(Bitmap &dest,int t,int x,int y,char *f)
{
  unsigned char *ustr = (unsigned char *) f;
  int l = strlen(f);

  for(int i = 0; i<l; i++)
  {
    int c = ustr[i];
    if(c==32) x+=space;

// Konvertoidaan vanhaan msdos muotoon...
    if((char)c=='ä') c=132;
    if((char)c=='Ä') c=142;
    if((char)c=='ö') c=148;
    if((char)c=='Ö') c=153;

    if(!bitmaps[c])
    {
// Pienet isoiksi tai päinvastoin tarvittaes...
      if(c>='A' && c<='Z') c += 'a'-'A';
      else if(c>='a' && c<='z') c -= 'a'-'A';

      if(c==132) c=142;
      else if(c==142) c=132;
      if(c==148) c=153;
      else if(c==153) c=148;
    }

    if(!bitmaps[c]) continue;

    bitmaps[c]->transparencyBlit(dest,t,x,y);
    x+=bitmaps[c]->width;
  }
}
