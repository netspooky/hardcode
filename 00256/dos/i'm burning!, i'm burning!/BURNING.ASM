.386
cra segment use16
assume es:cra,cs:cra,ss:cra,ds:cra
org 100h
all:

 mov  al,13h
 int  10h
 mov  dx,03C8h
 mov  cl,3Fh
@p:
 mov  al,cl
 out  dx,al
 inc  dx
 out  dx,al
 out  dx,al
 shr  al,1
 out  dx,al
 dec  dx
 loop @p 
; mov  dx,03C8h
; xor  al,al
; out  dx,al
; inc  dx
; mov  cx,300h
;@p1:
; out  dx,al
; inc  ax
; loop @p1
 mov  ah,9
 mov  dx,offset napis
 int  21h
;skopiruje 2560 bytu z A000h:0000h do cs:0400h
 PUSH DS
 push cs
 pop  es
 mov  di,0400h
 push 0A000h
 pop  ds
 xor  si,si
 mov  ch,0Ah
@m1:
 lodsb
 shl  al,3
 stosb
 loop @m1
 POP  DS
 push 0A000h
 pop  es
 xor  di,di
 mov  ch,0Ah
 rep  stosb
 xor  bx,bx	;bx-offset textu
@main:
;prdne text z cs:0400h na A000:bx
 PUSH DS
 push 0A000h
 pop  es
 push cs
 pop  ds
 mov  si,0400h
 add  bx,0140h
 cmp  bx,64000-8*320
 jb   @1
 xor  bx,bx
@1:
 mov  di,bx
 mov  ch,0Ah
@k1:
 lodsb
 or   al,al
 jz   @k2
 mov  es:[di],al
@k2:
 inc  di
 loop @k1
 POP  DS
 call @inportsub
 in   al,60h
 dec  al
 jnz  @main
 xor  ax,ax
 int  16h
 mov  ax,3
 int  10h
 retn
 
napis	db	9,'I''m burning!  I''m burning!$'

@inportsub:
 push 0A000h
 pop  es
 xor  di,di
 mov  dh,200	;radky
@2:
 in   al,40h
 mov  ah,al
 mov  cx,320
@3:
 inc  ah
 and  ah,argument
 mov  al,es:[di]
 sub  al,ah
 jns  @4
 xor  al,al
@4:
 stosb
 loop @3
 dec  dh
 jnz  @2
 retn

argument equ 15

cra ends
end all
