model tiny
.code
.386
org 100h
.startup
  mov  al,13h
  int  10h
  push 0a000h
  pop  es
  xor  di,di ;stosw make it slower, but why?
  mov  bp,-200
loopy:
  mov  si,-320
loopx:
  push di
  xor  cx,cx
  xor  bx,bx
  xor  di,di
  xor  ax,ax
loopa:
  imul zi
  shrd ax,dx,6
  add  ax,bp
  add  ax,100
  mov  zi,ax

  lea  ax,[bx+si+160-90]
  sub  ax,di
  push ax
  imul ax
  shrd ax,dx,7
  xchg ax,bx

  mov  ax,zi
  imul ax
  shrd ax,dx,7
  mov  di,ax  ;i2

  add  ax,bx
  cmp  ax,200h
  pop  ax
  jg   draw
  inc  cl
  jnz  loopa
  dec  cx
draw:
  pop  di
  inc  cx
  xchg ax,cx
  stosb
  inc  si
  jnz  loopx
  inc  bp
  jnz  loopy
  int  16h
  mov  ax,3h
  int  10h
  ret
zi     dw ?
END