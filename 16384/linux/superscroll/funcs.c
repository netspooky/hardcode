#include <stdio.h>
#include <stdlib.h>
#include "xliblib.h"

/* init the font */
void FontInit(char *fonttype)
{
  XFontStruct* font_info;
  char* font_name = fonttype;
  font_info = XLoadQueryFont(dis, font_name);
  XSetFont(dis, green_gc, font_info->fid);
}

