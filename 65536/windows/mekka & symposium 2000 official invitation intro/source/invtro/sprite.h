// sprite struct

#ifndef __SPRITE_H_
#define __SPRITE_H_

#pragma pack (push, 1)

typedef struct {
  int  w, h;
  char data[];
} sprite;

#pragma pack (pop)

extern void putSprite(sprite *spr, int x, int y);
extern void putText(sprite *spr, int x, int y, int sx, int h);
extern void putBackground();

//#pragma aux putSprite "*" parm [esi][eax][ebx];
//#pragma aux putText "*" parm [esi][eax][ebx][ecx][edx];
//#pragma aux putBackground "*";

#endif
