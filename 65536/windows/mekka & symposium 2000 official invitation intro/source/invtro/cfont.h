#include "sprite.h"

#ifndef __FONT_H_
#define __FONT_H_

// font struct

#pragma pack (push, 1)

typedef struct {
  int   loc;
  char  prekern, cellwidth, totalwidth;
} cinfo;

typedef struct {
  char   *map;
  char    first, count, unused, height;
  int     width;                       
  cinfo   charinfo[];
} font;

#pragma pack (pop)

extern void fontBlitChar(sprite *out, font *fnt, int ch, int x, int y);
extern void fontBlitString(sprite *out, font *fnt, char *str, int x, int y);
extern int fontCharWidth(font *fnt, int ch);
extern int fontStringWidth(font *fnt, char *str);

#endif
