#include "cfont.h"

static char bmk[8]={128, 64, 32, 16, 8, 4, 2, 1};
char fontColor;

void fontBlitChar(sprite *out, font *fnt, int ch, int x, int y)
{
  char *o, *in, ic;
  int   yc, xc;

  if ((ch>=fnt->first) && (ch<(fnt->first+fnt->count)))
    ch-=fnt->first;
  else
    ch=' '-fnt->first;

  o=out->data+y*out->w+x+fnt->charinfo[ch].prekern;

  ic=fnt->charinfo[ch].loc&7;
  in=fnt->map+(fnt->charinfo[ch].loc>>3);

  for (yc=0; yc<fnt->height; yc++)
  {
    for (xc=0; xc<fnt->charinfo[ch].cellwidth; xc++)
      if (in[(xc+ic)>>3] & bmk[(ic+xc)&7])
        o[xc]=fontColor;

    o+=out->w;
    in+=(fnt->width+7)>>3;
  }
}

void fontBlitString(sprite *out, font *fnt, char *str, int x, int y)
{
  for (; *str; str++)
  {
    fontBlitChar(out, fnt, *str, x, y);
    x+=fontCharWidth(fnt, *str);
  }
}

int fontCharWidth(font *fnt, int ch)
{
  if ((ch>=fnt->first) && (ch<(fnt->first+fnt->count)))
    ch-=fnt->first;
  else
    ch=' '-fnt->first;

  return fnt->charinfo[ch].prekern+fnt->charinfo[ch].totalwidth;
}

int fontStringWidth(font *fnt, char *str)
{
  int  w=0;

  while (*str)
    w+=fontCharWidth(fnt, *str++);

  return w;
}
