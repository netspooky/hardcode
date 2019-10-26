#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include "workbnch.h"
#include "cfont.h"
#include "sprite.h"
#include "render.h"
#include "intro.h"

#define MIN(a,b) ((a)<(b)?(a):(b))
#define MAX(a,b) ((a)>(b)?(a):(b))

typedef struct {
  int  x, y, w, h, dx, dy, dw, dh;
} window;

// images

extern sprite  barol, baror, barro, barru, barul, barur;
extern sprite  cursor;
extern char    back[];
extern font    topaz8;
extern font    diamo12;
extern char    pal[];
extern char    text1[];
extern char    credz[];

char     background[307200];
char    *bData;
long     bPitch;

static char    *buf;
static char    *curtext;
static sprite  *txt;
static window   wins[3];
static char     zorder[3];
static char     initdone=0;
static int      frame;
static int      moving, resizing, sbm;
static int      mpx, mpy;
static int      cposx, cposy;
static int      win1v;

static int      scroll, scrollmax;

void memfill(void*,char,int);
void memcpyd(void*,void*,int);
void xorsb(void*,char,int);
#pragma aux memfill="rep stosb" parm [edi][al][ecx];
#pragma aux memcpyd="rep movsd" parm [edi][esi][ecx];
#pragma aux xorsb="lp:xor [edi],bl" "inc edi" "loop lp" parm [edi][bl][ecx];

static void unrle(char *in, char *out, int outc)
{
  int   c, lastc, i;
  char *om;

  om=&out[outc];
  lastc=-1;

  do
  {
    *out++=c=*in++;
    
    if (c==lastc)
    {
      i=*in++;
      while (i--)
        *out++=c;
    }

    lastc=c;
  } while (out<om);
}

static void initWin(window *win, int x, int y, int w, int h)
{
  win->x=x; win->y=y; win->w=w; win->h=h;
  win->dx=win->dy=-1;
}

#pragma aux initWorkbench "*"

int initWorkbench(void)
{
  int    i;
  POINT  p;

  curtext=text1;
  scroll=scrollmax=sbm=0;
  moving=resizing=-1;

  GetCursorPos(&p);
  cposx=p.x; cposy=p.y;

  renderSetFont(0, &topaz8);
  renderSetFont(1, &diamo12);
  renderSetFont(2, &topaz8);
  renderSetFont(3, &diamo12);

  unrle(back, background, 307200);

//initWin(wins+0, 4, 24, 492, 114);
  initWin(wins+0, 0, 0, 0, 0);
  initWin(wins+1, 246, 144, 390, 332);
  initWin(wins+2, 4, 150, 324, 262);

  for (i=0; i<3; i++)
    zorder[i]=i;

  Init();

  txt=renderTextBuffer(text1, 368, 6000);
  initdone++;

  return 0;
}

#pragma aux quitWorkbench "*"

void quitWorkbench(void)
{
  Quit();

  if (txt)
    LocalFree(txt);
}

// box

void box(int x1, int y1, int x2, int y2, char c)
{
  int   x, y, w, h;
  char *d;

  if (x2<x1) return;
  if (y2<y1) return;

  d=bData+y1*bPitch+x1;
  w=x2-x1+1;
  h=y2-y1+1;

  _asm {
    movzx eax, c
    mov   ebx, 0x1010101
    mul   ebx
    mov   edi, d
    mov   edx, h
    mov   ebx, bPitch
    sub   ebx, w

  ylp:
    mov   ecx, w
    shr   ecx, 1
    jnc   ok1
    stosb
  ok1:
    shr   ecx, 1
    jnc   ok2
    stosw
  ok2:
    rep   stosd

    add   edi, ebx

    dec   edx
    jnz   ylp
  }
}

void xrect(int x1, int y1, int x2, int y2)
{
  int   x, y, w, h;
  char *d;

  d=bData+y1*bPitch+x1;
  w=x2-x1+1;
  h=y2-y1+1;

  for (x=0; x<w; x++)
  {
    d[x]^=7;
    d[x+bPitch]^=7;
  }

  d+=bPitch<<1;

  for (y=0; y<h-4; y++)
  {
    d[0]^=7; d[1]^=7;
    d[w-1]^=7; d[w-2]^=7;

    d+=bPitch;
  }

  for (x=0; x<w; x++)
  {
    d[x]^=7;
    d[x+bPitch]^=7;
  }
}

// fenster zeichnen

void drawWindow(window *win, int scr, int scrv, int scrm)
{
  int x, y, x2, y2, sh, svs, sp, i;

  if (!win->w)
    return;

  x=win->x;
  y=win->y;
  x2=x+win->w;
  y2=y+win->h;

  box(x, y, x2-1, y2-1, 2);

  // oben
  putSprite(&barol, x, y);
  putSprite(&baror, x2-58, y);

  for (i=0; i<5; i++)
    box(x+195, y+i*4, x2-59, y+i*4+3, 6-((i&1)<<2));

  // links
  box(x, y+20, x+1, y2-18, 6);

  // unten
  putSprite(&barul, x, y2-18);
  putSprite(&barur, x2-31, y2-18);

  box(x+17, y2-18, x2-32, y2-17, 6);
  box(x+17, y2-14, x2-32, y2-5, 6);
  box(x+17, y2-2, x2-32, y2-1, 6);

  // rechts
  putSprite(&barro, x2-16, y+20);
  putSprite(&barru, x2-16, y2-34);

  box(x2-16, y+36, x2-15, y2-35, 6);
  box(x2-2, y+36, x2-1, y2-35, 6);

  sh=y2-y-70;
  svs=(sh*scrv+scrm-1)/scrm;
  sp=sh*scr/scrm;

  box(x2-12, y+36+sp, x2-5, y+35+sp+svs, 6);
}

// zorder-stuff

static void toFront(int v)
{
  int i, j;

  for (i=0; i<3; i++)
    if (zorder[i]==v)
      j=i;

  for (i=j; i>0; i--)
    zorder[i]=zorder[i-1];

  zorder[0]=v;
}

static void toBack(int v)
{
  int i, j;

  for (i=0; i<3; i++)
    if (zorder[i]==v)
      j=i;

  for (i=j; i<3; i++)
    zorder[i]=zorder[i+1];

  zorder[2]=v;
}

#pragma aux workbenchMouseHandler "*" parm [eax][ebx][ecx];

void workbenchMouseHandler(int typ, int cx, int cy)
{
  int      i, j, scrm;
  sprite  *fake;

  cx&=~1;
  cy&=~1;

  if (!initdone)
    return;

  if (typ==0)
  {
    moving=-1;

    if ((cx>=wins[1].x+wins[1].w-16) && (cx<wins[1].x+wins[1].w))
    {
      if ((cy>=wins[1].y+20) && (cy<wins[1].y+36))
        scroll=MAX(scroll-6, 0);

      if ((cy>=wins[1].y+wins[1].h-34) && (cy<wins[1].y+wins[1].h-16))
        scroll=MIN(scroll+6, scrollmax);
    }

    for (i=0; i<3; i++)
    {
      j=zorder[i];

      if ((cx>=wins[j].x) && (cx<wins[j].x+wins[j].w-50))
        if ((cy>=wins[j].y) && (cy<wins[j].y+20))
        {
          moving=j;
          mpx=cx-wins[moving].x;
          mpy=cy-wins[moving].y;
          wins[moving].dx=wins[moving].x;
          wins[moving].dy=wins[moving].y;
          wins[moving].dw=wins[moving].w;
          wins[moving].dh=wins[moving].h;
          break;
        }

      if ((cy>=wins[j].y) && (cy<wins[j].y+20))
      {
        if ((cx>=wins[j].x+wins[j].w-50) && (cx<wins[j].x+wins[j].w-28))
          toBack(j);

        if ((cx>=wins[j].x+wins[j].w-26) && (cx<wins[j].x+wins[j].w-4))
          toFront(j);
      }

      if ((cx>=wins[j].x+wins[j].w-18) && (cx<wins[j].x+wins[j].w))
        if ((cy>=wins[j].y+wins[j].h-18) && (cy<wins[j].y+wins[j].h))
        {
          if (j==2)
            break;

          resizing=j;
          mpx=cx-wins[resizing].x-wins[resizing].w+18;
          mpy=cy-wins[resizing].y-wins[resizing].h+18;
          wins[resizing].dx=wins[resizing].x;
          wins[resizing].dy=wins[resizing].y;
          wins[resizing].dw=wins[resizing].w;
          wins[resizing].dh=wins[resizing].h;
          break;
        }

       if (scrollmax)
         if ((cx>=wins[j].x+wins[j].w-16) && (cx<wins[j].x+wins[j].w))
           if ((cy>=wins[j].y+36) && (cy<wins[j].y+wins[j].h-34))
           {
             sbm=j;
             mpx=scroll; // hack
             mpy=cy;
           }

      if ((cx>=wins[j].x+2) && (cx<wins[j].x+wins[j].w-16))
        if ((cy>=wins[j].y+20) && (cy<wins[j].y+wins[j].h-18))
          return;
    }
  }

  if (sbm!=1)
    sbm=0;

  if (typ==1)
  {
    if ((moving!=-1) || (resizing!=-1))
    {
      if (moving==-1)
        moving=resizing;

      wins[moving].x=wins[moving].dx;
      wins[moving].y=wins[moving].dy;
      wins[moving].w=wins[moving].dw;
      wins[moving].h=wins[moving].dh;
      wins[moving].dx=wins[moving].dy=-1;
      wins[moving].dw=wins[moving].dh=-1;

      if (resizing==1)
      {
        if (txt) LocalFree(txt);
        txt=renderTextBuffer(curtext, wins[resizing].w-22, 6000);
      }

      moving=-1;
      resizing=-1;
    }

    sbm=0;
  }

  if (typ==2)
  {
    cposx=cx;
    cposy=cy;

    if (moving!=-1)
    {
      wins[moving].dx=cx-mpx;
      wins[moving].dy=cy-mpy;

      if (wins[moving].dx<0) { mpx+=wins[moving].dx; wins[moving].dx=0; };
      if (wins[moving].dy<0) { mpy+=wins[moving].dy; wins[moving].dy=0; };
      if (wins[moving].dx+wins[moving].w>639)
      {
        wins[moving].dx=640-wins[moving].w;
        mpx=cx-wins[moving].dx;
      }

      if (wins[moving].dy+wins[moving].h>479)
      {
        wins[moving].dy=480-wins[moving].h;
        mpy=cy-wins[moving].dy;
      }
    }

    if (resizing!=-1)
    {
      wins[resizing].dw=(cx-mpx+18)-wins[resizing].dx+1;
      wins[resizing].dh=(cy-mpy+18)-wins[resizing].dy+1;

      if (wins[resizing].dw<380) wins[resizing].dw=380;
      if (wins[resizing].dh<60)  wins[resizing].dh=60;
      if (wins[resizing].dx+wins[resizing].dw>639) wins[resizing].dw=640-wins[resizing].x;
      if (wins[resizing].dy+wins[resizing].dh>479) wins[resizing].dh=480-wins[resizing].y;
    }

    if (sbm)
    {
      scrm=txt->h;

      i=cy-mpy;
      scroll=(i*scrm)/win1v+mpx;
      scrm-=win1v;
      scroll=(scroll<0)?0:(scroll>scrm)?scrm:scroll;
    }
  }

  if (typ==3)
  {
    curtext=credz;

    if (txt)
      LocalFree(txt);

    txt=renderTextBuffer(curtext, wins[1].w-22, 6000);
  }

  if (typ==4)
  {
    curtext=text1;

    if (txt)
      LocalFree(txt);

    txt=renderTextBuffer(curtext, wins[1].w-22, 6000);
  }
}

#pragma aux workbenchKeyHandler "*" parm [eax];

void workbenchKeyHandler(int key)
{
  switch (key)
  {
    case VK_UP:
      scroll=MAX(scroll-6, 0);
      break;

    case VK_DOWN:
      scroll=MIN(scroll+6, scrollmax);
      break;

    case VK_HOME:
      scroll=0;
      break;

    case VK_END:
      scroll=MAX(txt->h-win1v, 0);
      break;

    case VK_PRIOR:
      scroll=MAX(scroll-win1v, 0);
      break;

    case VK_NEXT:
      scroll=MIN(scroll+win1v, scrollmax);
      break;
  }
}

#pragma aux workbenchFrame "*" parm [eax][ebx];

void workbenchFrame(char * data, int pitch)
{
  int i, j;

  bData  = data;
  bPitch = pitch;

  win1v=wins[1].h-38;
  scrollmax=MAX(txt->h-win1v, 0);
  if (scroll>scrollmax)
    scroll=scrollmax;

  putBackground();

  for (i=2; i>=0; i--)
  {
    j=zorder[i];

    if (j==2)
    {
      drawWindow(wins+j, 0, 1, 1);
      DoFrame(bData+bPitch*(wins[j].y+20)+wins[j].x+2, bPitch);
    }
    else if (j==1)
    {
      drawWindow(wins+j, scroll, win1v, MAX(txt->h, win1v));
      putText(txt, wins[1].x+4, wins[1].y+20, scroll, win1v);
    }

    if ((wins[j].dx!=-1) || (wins[j].dw!=-1))
      xrect(wins[j].dx, wins[j].dy, wins[j].dx+wins[j].dw-1, wins[j].dy+wins[j].dh-1);
  }

  putSprite(&cursor, cposx, cposy);
}

// watcom sucking calls
void __CHP               (void) {}
void _fltused_           (void) {}
void __8087              (void) {}
void __init_387_emulator (void) {}
#pragma aux __CHP               "__CHP";
#pragma aux _fltused_           "_fltused_";
#pragma aux __8087              "__8087";
#pragma aux __init_387_emulator "__init_387_emulator";
