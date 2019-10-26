model tiny
.code
.386
org 100h
start:
  mov  al,13h
  int  10h
  push 0a000h
  pop  es
  stosw  ;xor  di,di
  mov  bp,-200
loopy:
  mov  si,-320
loopx:
  push di
  xor  cx,cx
  xor  bx,bx
  xor  di,di
loopa:
  push bx
  lea  ax,[bx+di]
  sub  bx,di
  imul bx
  shrd ax,dx,7
  xchg bx,ax
  lea  bx,[bx+si+160-90]
  pop  ax
  imul di
  shrd ax,dx,6
  xchg di,ax
  lea  di,[bp+di+100]
  cmp  bh,1
  jg   draw
  inc  cl
  jnz  loopa
draw:
  pop  di
;  xchg [di],cl
;  inc  di
  xchg ax,cx
  stosb
  inc  si
  jne  loopx
  inc  bp
  jne  loopy
;  xchg ax,cx
  int  16h
  mov  ax,3
  int  10h
  ret
end start