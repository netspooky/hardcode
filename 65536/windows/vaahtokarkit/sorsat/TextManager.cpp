#include "TextManager.h"
#include "SafeAlloc.h"

Text *TextManager::add(int x,int y,int st,int et,int f,BMFont *font,char *text)
{
  Text *t = (Text *) safeAlloc(sizeof(Text));
  texts.add(t);
  t->x = x;
  t->y = y;
  t->st = st;
  t->et = et;
  t->f = f;
  t->text = text;
  t->font = font;
  return t;
}

void TextManager::draw(Bitmap &dest,int t)
{
  for(int i=0; i<texts.total; i++)
  {
    Text *text = (Text *) texts.pointers[i];
    if(t < text->st) continue;
    if(t > text->et) continue;
    if(text->f)
    {
      if(t-text->st < text->f)
      {
        int f = 255 - (t-text->st) * 256 / text->f;
        text->font->print(dest,f,text->x,text->y,text->text);
        continue;
      }
      if(text->et-t < text->f)
      {
        int f = 255 - (text->et-t) * 256 / text->f;
        text->font->print(dest,f,text->x,text->y,text->text);
        continue;
      }
    }
    text->font->print(dest,0,text->x,text->y,text->text);
  }
}
