
;**********************************************************
;
; WOBBLE256
; 2 Displaced sin based movment
; Another 256 Byte demo by
; Relsoft (Richard Eric M. Lope BSN RN)
; http://rel.betterwebber.com
; Assemble with FASM (FlatAssembler.net)
;
;**********************************************************
org 100h


;*****************************************************************
;*****************************************************************
;*****************************************************************

    mov ax, 0013h
    int 10h
    push 0a000h
    pop es
    push 08000h
    pop fs
    xor di, di
    fldpi
singen:
    mov [frame],di
    fild [frame]
    mov [frame], 256
    fidiv [frame]
    fmul st0, st1
    fsin
    mov [frame], 128
    fimul [frame]
    fistp [frame]
    mov al, byte[frame]
    mov [fs:di],al
    inc di
    cmp di, 512
    jbe singen
    fstp st0

   mov	 dx, 03c8h			;palette write register
   xor	 al, al 			;start at color 0
   out	 dx, al 			;send value
   inc	 dx				;0x3c9(write RGB values)
   mov cx, 255				;whole 256 colors
   palloop:
	mov bx, 255
	sub bx, cx
	shl bx,1
	mov al, [fs:bx]
	out  dx, al			;red
	shl bx,2			;green
	mov al, [fs:bx]
	out  dx, al
	shl bx, 2
	mov al, [fs:bx]
	out  dx, al			;than green
   loop palloop 			;go back if not 0

    and [frame], 0

main_loop:


	inc [frame]
;       wobble
;
;
       and di, 0
       and [ycounter], 0

       mov ax, [frame]
       and ax,1
       ;cmp ax, 0
       jne rotneg
       mov [rot], 64
       jmp y_loop
rotneg:
       mov [rot], -64
y_loop:
       ;xsin = sins[(y + i) and 511]
       mov bx, [ycounter]
       add bx, [frame]
       and bx, 511
       mov al, [fs:bx]
       mov [xsin], al
       mov cx, 0
x_loop:
       ;col = (x + xsin) XOR (y + sins[(x + i + rot) and 511])
       neg [rot]
       mov bx, cx
       add bx, [frame]
       sub bx, ycounter
       add bx, [rot]
       and bx, 511
       xor ax, ax
       mov al, [fs:bx]
       add ax, [ycounter]
       xor dx, dx
       mov dl, [xsin]
       add dx, cx
       xor ax, dx
       mov [es:di], al
       inc di
       inc cx
       cmp cx, 319
jb x_loop
       inc di
       mov [es:di], al
       inc [ycounter]
       cmp [ycounter], 200
jb y_loop


	mov dx,3dah
  vsync:
	in al,dx
	and al,8
	jz vsync

	in al,60h
	dec al
	jnz main_loop

	ret

ycounter  dw  ?
xsin	  db  ?
frame	  dw  ?
rot	  dw  ?
