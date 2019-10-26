[ORG 0x0100]

[SECTION .text]

   mov  di  , pal
   mov  si  , pal

   xor  bx  , bx
   xor  dx  , dx

   mov  cx  , 0x80

mkpl00:

   mov  [di], bh
   inc  di
   stosw         
   add  bx  , (0x2000>>7)
   loop mkpl00

   mov  cx  , 0x80

mkpl01:

   mov  [di], bh
   inc  di
   mov  [di], dh
   inc  di
   stosb
   add  bx  , (0x1f00>>7)
   add  dx  , (0x2000>>7)
   loop mkpl01

   push word 0xa000
   pop  es

   mov  ax  , 0x0013
   int  0x0010

   xor  ax  , ax
   mov  cx  , 0x300
   mov  dx  , 0x03c8
   out  dx  , al
   inc  dx

   rep  outsb

   fld  dword [five]
   fld  dword [tres]
   fldz

bobs00:

   mov  cx  , 64000
   xor  di  , di

blur00:

   mov  al  , [es:di]
   or   al  , al
   jz   blur01
   dec  al

blur01:

   stosb
   loop blur00

   xor  bx  , bx
   mov  cx  , 8

   fld   st0
   fmul  st2
   fcos
   fmul  dword [ampx]
   fistp word  [bobx]

   fld   st0
   fmul  st3
   fsin
   fmul  dword [ampy]
   fistp word  [boby]
   fadd  dword [inct]

   mov  di  , 32160
   mov  ax  , [bobx]
   mov  dx  , [boby]
   imul dx  , 320
   add  ax  , dx
   add  di  , ax

   push ax
   
   call mkbobs

   pop  ax
   mov  di  , 32160
   sub  di  , ax

   call mkbobs

   mov  ax  , 0x0100
   int  0x0016
   jz   bobs00

   fcompp
   fcomp st0

   mov  ax  , 0x0003
   int  0x0010

   ret

mkbobs

  xor   bx  , bx
  mov   cx  , 8

bobs01:

   mov  dl  , [bobs+bx]

bobs02:

   mov  al  , [es:di]
   shr  dl  , 1
   jnc  bobs03
   add  al  , 0x40
   jnc  bobs03
   or   al  , 0xff

bobs03:

   stosb
   loop bobs02

   mov  cx  , 8
   add  di  , 312

   inc  bx
   cmp  bx  , 8
   jne  bobs01

   ret

[SECTION .data]

ampx dd  96.0
ampy dd  48.0
five dd  5.0
inct dd  0.01 
tres dd  3.0

bobs db 00111100b
     db 01111110b
     db 11111111b
     db 11111111b
     db 11111111b
     db 11111111b
     db 01111110b
     db 00111100b

[SECTION .bss]

pal  resb 0x0300
bobx resw 1
boby resw 1

