     ; ษออออออออออออออออออออออออออออออออออออออออออออออออป
     ; บ     ÜÜÜÜÜÜ ÜÜÜÜÜ  ÜÜÜÜÜÜ ÜÜÜÜÜÜ ÜÜÜ ÜÜ ÜÜÜ	บ
     ; บ     ÜÜÜ ฿Û ÜÜÜ ÛÛ ÜÜÜ ฿Û ÜÜÜ ฿Û ÜÜÜ ÛÛ ÛÛÛ	บ
     ; บ     ÛÛÛ฿   ÛÛÛ฿ÛÜ ÛÛÛ฿ Ü Ü ฿ÛÜÜ ÛÛÛ฿ÛÛ ÛÛÛ	บ
     ; บ     ÛÛÛ    ÛÛÛ ÛÛ ÛÛÛÜÛÛ ÛÛÜÜÛÛ ÛÛÛ ÛÛ ÜÜÜ	บ
     ; บ			     [productions]	บ
     ; วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
     ; บ     "meteorz" conference3K 256byte intro compo บ
     ; วฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤถ
     ; บ     copyright (c)Y2K-1. by Joco/fresh!		บ
     ; ศออออออออออออออออออออออออออออออออออออออออออออออออผ

     ALIGN 1
     ORG 100h

     SECTION .text

Start:
  mov  al,13h
  int  10h
  mov  dx,03C8h
  inc  cx
LoopP:
  mov  al,cl
  out  dx,al
  inc  dx
  push ax
  test al,0C0h
  jz   RedOk
  mov  al,63
RedOk:
  out  dx,al
  pop  ax
  shr  al,2
  out  dx,al
  shr  al,3
  out  dx,al
  dec  dx
  loop LoopP
  mov  di,word Buffer
  mov  cx,25600
  rep  stosw
  mov  ah,9
  mov  dx, About
  int  21h
NoKeyPress:
  push word 0A000h
  pop  es
  mov  si,word Buffer
  mov  di,6721
  mov  dl,158
LoopY:
  mov  cx,318
LoopX:
  xor  bx,bx
  xor  ah,ah
  push si
  mov  bp,3
Loop1K:
  mov  dh,3
Loop1B:
  lodsb
  add  bx,ax
  dec  dh
  jnz  Loop1B
  add  si,317
  dec  bp
  jnz  Loop1K
  mov  ax,bx
  mov  bl,9
  div  bl
  pop  si
  inc  si
  stosb
  loop LoopX
  inc  si
  inc  di
  inc  si
  inc  di
  dec  dl
  jnz  LoopY
  push ds
  push word 0A000h
  pop  ds
  push cs
  pop  es
  mov  si,6400
  mov  di,word Buffer
  mov  cx,25600
  rep  movsw
  pop  ds
  fld  dword [Start]
  fsin
  fimul word [MulX]
  fistp word [A]
  fldl2e
  fmul dword [Start]
  fcos
  fimul word [MulY]
  fistp word [B]
  ffree st0
  mov  cl,2
Loop1:
  push cx
  mov  cl,2
Loop2:
  mov  di,word Buffer
  add  di,word [A]
  mov  ax,320
  mul  word [B]
  add  di,ax
  add  di,20624
  mov  bl,32
LoopA:
  mov  bh,32
LoopC:
  add  byte [es:di],3
  inc  di
  dec  bh
  jnz  LoopC
  add  di,288
  dec  bl
  jnz  LoopA
  neg  word [A]
  loop Loop2
  pop  cx
  neg  word [B]
  loop Loop1
  fld  dword [Start]
  fsub dword [Rad]
  fstp dword [Start]
  in   al,060h
  cbw
  dec  ax
  jnz  near NoKeyPress
  mov  al,03h
  int  10h
  ret

SECTION .data

Rad: dd 0.01745
MulX: dw 128
MulY: dw 64
About: db "JOCO$"

SECTION .bss

A: resw 1
B: resw 1
Buffer: resb 51200

