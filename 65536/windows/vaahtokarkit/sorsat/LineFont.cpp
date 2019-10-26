#include "LineFont.h"
#include "SafeAlloc.h"

#include <stdio.h>
#include <string.h>

void LineFont::load(unsigned char *buf)
{
  int i;

  for(i=0; i<256; i++)
  {
    letters[i].init();
  }

  int l = *buf++;

  while(l--)
  {
    unsigned char c = *buf++;
    unsigned char v = *buf++;
    unsigned char l = *buf++;

    int i;

    for(i=0; i<v; i++)
    {
      letters[c].addVertex();
      short a;
      memcpy(&a,buf,2); buf+=2;
      letters[c].x[i] = a / 32.0f;
      memcpy(&a,buf,2); buf+=2;
      letters[c].y[i] = a / 32.0f;
      memcpy(&a,buf,2); buf+=2;
      letters[c].width[i] = a / 32.0f;
    }

    for(i=0; i<l; i++)
    {
      Line *l = (Line *) safeAlloc(sizeof(Line));
      letters[c].lines.add(l);
      memcpy(&l->v1,buf,1); buf+=1;
      memcpy(&l->v2,buf,1); buf+=1;
    }
    letters[c].getArea();
  }
}
