; harmony
; 256 bytes intro
; by Galen/MAXTER /e-mail: gal_mxtr@dir.bg/
; for Fiasko 2001 demoparty

       .model tiny
       .code
       .386
       org 100h
 begin:
       jmp start

 Ainc  dd 3d54fdf4h               ; angle increment
 Rays  dw 1                       ; number of rays
 Dir   dw 0                       ; contract / expand
 R     dw 50                      ; curve radius
 Angle dd 0                       ; rotation angle
 C40   dw 40                      ; morph radius
 f     dd 0                       ; curve points angle

Radius proc near
       fld   Angle
       fimul Rays
       fsin
       fimul C40
       fiadd R
       fmul
       ret
Radius endp


 start:
       xor  bp,bp

       mov  di,Offset Buf
       mov  al,16
       mov  cx,64000
       rep  stosb

       mov  ax,13h
       int  10h

 Full:
       mov  cx,121
 Curve:
       fld   f
       fadd  Angle
       fsincos

       call Radius
       fistp tempi

       call Radius
       fistp tempj

       mov  ax,tempj
       add  ax,105
       mov  bx,320
       mul  bx
       add  ax,tempi
       add  ax,30
       mov  di,ax
       mov  al,31
       stosb
 Outside:
       fld   Angle
       fadd  AInc
       fstp  Angle

       loop  Curve

       cmp  Dir,0
       jne  Drr
       dec  C40
       jne  Drr
       mov  Dir,1
       inc  Rays
       inc  bp
       cmp  bp,5
       jne  Drr
       sub  Rays,2
       dec  bp
 Drr:
       cmp  Dir,1
       jne  NoDr
       inc  C40
       cmp  C40,40
       jna  NoDr
       mov  Dir,0
 NoDr:

       fld   f
       fadd  AInc
       fstp  f

       mov  dx,3dah
 retrace:
       in   al,dx
       test al,8
       jz   retrace

       push es
       mov  ax,0a000h
       mov  es,ax
       xor  di,di
       mov  si,offset Buf
       mov  cx,64000
 Scan:
       lodsb
       stosb
       cmp  al,16
       je   Black
       dec  al
 Black:
       mov  ds:[si-1],al
       loop Scan
       pop  es

       cmp  Rays,1
       jne  Full
       cmp  bp,4
       je   MorphEnd
       jmp  Full

Morphend:

       mov  ax,3
       int  10h
       ret


 tempi dw ?
 tempj dw ?

 Buf:                            ; Frame Buffer

      end begin