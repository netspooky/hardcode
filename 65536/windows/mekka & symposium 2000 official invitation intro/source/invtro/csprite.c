#include "sprite.h"
#include "workbnch.h"

// sprite stuff

void putSprite(sprite *spr, int x, int y)
{
  char  *d, *o;
  int   _dw, _dh, sw;

  if (x>639) return;
  if (y>479) return;
  if (x<=-spr->w) return;
  if (y<=-spr->h) return;

  d=spr->data;
  sw=_dw=spr->w; _dh=spr->h;

  if (x<0) { _dw+=x; d-=x; x=0; };
  if (y<0) { _dh+=y; d-=y*spr->w; y=0; };
  if (x+_dw>639) _dw=640-x;
  if (y+_dh>479) _dh=480-y;

  o=bData+(y*bPitch)+x;
  _dw--;

  _asm {
    mov  esi, d
    mov  edi, o
    mov  edx, _dh
  ylp:
    mov  ecx, _dw
  xlp:
    mov  al, [esi+ecx]
    cmp  al, 2
    je   dontput
    mov  [edi+ecx], al
  dontput:
    dec  ecx
    jns  xlp
    add  esi, sw
    add  edi, bPitch
    dec  edx
    jnz  ylp
  }
}

#define MIN(a,b) ((a)<(b)?(a):(b))

void putText(sprite *spr, int x, int y, int sy, int h)
{
  char  *d, *o;
  int   _dw, _dh, sw;

  if (x>639) return;
  if (y>479) return;
  if (x<=-spr->w) return;
  if (y<=-h) return;

  d=spr->data+(sy*spr->w);
  sw=_dw=spr->w; _dh=MIN(h, spr->h);

  if (x<0) { _dw+=x; d-=x; x=0; };
  if (y<0) { _dh+=y; d-=y*spr->w; y=0; };
  if (x+_dw>639) _dw=640-x;
  if (y+_dh>479) _dh=480-y;

  o=bData+(y*bPitch)+x;
  sw-=_dw;

  _asm {
    mov  esi, d
    mov  edi, o
    mov  edx, _dh
  ylp:
    mov  ecx, _dw
    shr  ecx, 2
    rep  movsd

    mov  ecx, _dw
    and  ecx, 3
    rep  movsb

    add  esi, sw
    add  edi, bPitch
    sub  edi, _dw
    dec  edx
    jnz  ylp
  }
}

void putBackground()
{
  _asm {
    .586
    mov  esi, offset background
    mov  edi, bData
    mov  edx, 480
  ylp:
    mov  ecx, 78
  xlp:
    movq mm0, [esi+ecx*8]
    movq mm1, [esi+ecx*8+8]
    movq [edi+ecx*8], mm0
    movq [edi+ecx*8+8], mm1
    sub  ecx, 2
    jns  xlp
    add  esi, 640
    add  edi, bPitch
    dec  edx
    jnz  ylp
    emms
  }
}
