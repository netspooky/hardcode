#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "render.h"

#define  NEWPARA   4
#define  NEWLINE   8

char *words[8192];
char  modes[8192];
font *fonts[4];
int   wcount;

void mcopy(char*,char*,int);
void mfill(char*,char,int);
#pragma aux mcopy="rep movsb" parm [edi][esi][ecx];
#pragma aux mfill="rep stosb" parm [edi][al][ecx];

extern char fontColor;

void renderSetFont(int nr, font *fnt)
{
  fonts[nr]=fnt;
}

sprite *renderTextBuffer(char *txt, int width, int height)
{
  int     i, spw, curw, w, wfl, wl, wend, dsp[256], x, y, xsz, lmh;
  font   *curf;
  char   *t;
  sprite *sp;

  t=txt;
  wcount=0;

  while (*t)
  {
    words[wcount++]=t;
    while (*t++);
  }

  mcopy(modes, t+1, wcount);
  sp=(sprite *) LocalAlloc(LMEM_FIXED, 8+width*height);
  sp->w=width;
  sp->h=height;
  mfill(sp->data, 2, width*height);

  w=0;
  y=2;

  while (w<wcount)
  {
    if (modes[w] & NEWPARA)
      y+=fonts[modes[w] & 3]->height;

    for (wend=w+1; wend<wcount; wend++)
      if (modes[wend] & (NEWLINE | NEWPARA))
        break;

    while (w<wend)
    {
      wl=width;
      wfl=lmh=0;

      while (1)
      {
        curf=fonts[modes[w+wfl] & 3];
        if (curf->height>lmh)
          lmh=curf->height;

        spw=(curf->height+1)>>1;
        xsz=fontStringWidth(curf, words[w+wfl]);

        if (xsz+(wfl?spw:0)<wl)
        {
          wl-=xsz+(wfl?spw:0);
          wfl++;
        }
        else
          break;

        if (w+wfl>=wend)
          break;
      }

      for (i=0; i<wfl-1; i++)
        dsp[i]=spw;

      if (w+wfl<wend)
        for (i=0; wl; i++, wl--)
          dsp[i%(wfl-1)]++;

      dsp[wfl]=x=0;

      for (i=0; i<wfl; i++)
      {
        curf=fonts[modes[w+i] & 3];
        fontColor=(modes[w+i] & 2)?5:6;
        fontBlitString(sp, curf, words[w+i], x, y);
        x+=fontStringWidth(curf, words[w+i])+dsp[i];
      }

      w+=wfl;
      y+=lmh+2;
    }
  }

  sp->h=y; // haaaaaaaaaaaaaaaaaack

  return sp;
}
