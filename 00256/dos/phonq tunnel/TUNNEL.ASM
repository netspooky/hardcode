; funky tunnel by whizzter/woorlic
; compiles with nasm.. (nasm tunnel.asm -o tunnel.com)
; source included!

; originating somewhere else in a comfile would be kinda hazardous
org 100h
; sinetable used for the twirling
sinetab equ 64010

; misc temp operands
tt1 equ 64570
tt2 equ 64575
; misc tunnel position values
aa1 equ 64590
aa2 equ 64591
aa3 equ 64592
aa4 equ 64593

; this segment should be free
; (a com program uses all memory from PSP->0a000, so as long as you have
;  over 150k of mem free this should work)
mov ah,080h
mov ds,ax
; the 'ol videomem
mov ah,0a0h
mov es,ax
; setting mode13
mov ax,13h
int 10h

; clear the copro before creating sinetable and setting the palette
finit
mov cx,256
mov di,sinetab
fldz
mov dx,3c8h
xor ax,ax
out dx,al
inc dx
sinpal_loop:
 fld st0
 fsin
 fimul word [cs:fme]
 fiadd word [cs:fme]
 fistp dword [di]
 fadd dword [cs:fadda]
 mov al,ah
 shr al,2
 out dx,al
 out dx,al
 xor al,al
 out dx,al
 inc ah
 inc di
loop sinpal_loop

; create the LUT for the tunnel
; lut setup:
;  320x100 with
;  2 bytes.. first = angle(0>_x>_255), second = Z of tunnel
; this tunnel uses polar cords..
; so the precalc is simply
; beware of pseudo code..! :)
;  angle=atan(x/y)
;  distZ=3000/sqrt(x^2 + y^2)
; you might be wondering how the Z stuff works..
; if you remember the old projection formula
;  u=x/z where u is screen X and x and z is the 3D coords
; if we rewrite this we get that
;  z=x/u
; so 3000 is the radius of our tunnel, u is in our case the distance from the
; center of the screen and then Z is resolved
mov cx,32000
mov bx,320
xor di,di
tunnel_precalc:
 mov ax,cx
 add ax,319
 xor dx,dx

 div bx

 sub dx,160
 sub ax,50
 mov [tt1],ax
 mov [tt2],dx

 fild word [tt1]
 fild word [tt2]
 fpatan
 fmul dword [cs:fma]
 fistp word [di]

 inc di
 fild word [tt1]
 fimul word [tt1]
 fild word [tt2]
 fimul word [tt2]
 faddp st1
 fsqrt
 fidivr word [cs:fp]
 fistp word [di]
 inc di

loop tunnel_precalc

main:
 add byte[aa4],2
 dec byte[aa3]
 inc byte[aa1]
 inc byte[aa2]
 mov di,0
 call dotun
 call dotun

; check the last pressed key
in al,60h
dec al
; scancode for ESC = 1.. 1-1 = 0 .. if this is true then exit
jnz main

; set mode 3(text)
mov ax,3
int 10h
; and exit
ret

; painting code..
; distorts the angle depending on the sinetable and the distance..
dotun:
 mov cx,32000
 mov si,0
 inner:
  xor bh,bh
  mov bl,[si+1]
  add bl,[aa3]
  mov al,[bx+sinetab]

  mov bl,[si+1]
  add bl,[aa4]
  add al,[bx+sinetab]

  mov bl,[si]
  add bl,al

  add bl,[aa2]
  and bl,0f0h

  mov al,bl

  inc si
  mov bl,[si]
  add bl,[aa1]
  inc si
  and bl,0f0h
  xor al,bl
  stosb
 loop inner
ret

fp dw 3000
fme dw 30
fadda dd 0.024543692
fma dd 40.74366543

; eh.. last note.. the doc and com filesizes were luck, this wasn't
; tunnel.com - 255 bytes, tunnel.doc - 512 bytes , tunnel.asm 2999 bytes
