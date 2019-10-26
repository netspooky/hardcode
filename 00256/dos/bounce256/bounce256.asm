;**********************************************************
;
; BOUNCE256
; A bouncing lensmap of the overused XOR texture. :*)
; Another 256 Byte demo by
; Relsoft (Richard Eric M. Lope BSN RN)
; http://rel.betterwebber.com
; Assemble with FASM (FlatAssembler.net)
;
;**********************************************************

RADIUS	= 64				; Try to change this
S_HEIGHT = (RADIUS / 2)
CLEANER = (S_HEIGHT * 25)
RADIUS_SQUARED = (RADIUS * RADIUS)
WID_HEI = (RADIUS * 2)
Y_RAD = 80


org 100h
	  mov	ax, 0013h	; mode 13h
	  int	10h		; we are now in 320x200x256
	  push word 0a000h
	  pop es
	  and [frame], 0
blit_loop:
	inc [frame]
lens_loop:
	fild [frame]
	mov [short87], 30
	fidiv [short87]
	fsin
	fabs
	mov [short87], -Y_RAD
	fimul [short87]
	fistp [miny]
	add [miny], 75
	;
	; lens
	;
	mov [yt], WID_HEI
	yloop:
	mov [xt], WID_HEI
	xloop:
	       mov ax, [xt]
	       sub ax, RADIUS
	       mov [x1], ax
	       imul ax, ax	  ;x1 * x1

	       mov bx, [yt]
	       sub bx, RADIUS
	       mov [y1], bx
	       imul bx, bx	  ;y1 * y1
	       add ax, bx	  ;x1 * x1 + y1 * y1

	       mov cx, RADIUS_SQUARED
	       sub cx, CLEANER
	       cmp ax, cx

	       ja no_plot

	       mov [h], RADIUS_SQUARED
	       sub [h], ax
	       fild [h]
	       fsqrt		    ;sqrt (radsquared - hypotsqr)
	       fistp [h]
	       ;sx
	       mov ax, [x1]	   ;x1
	       sal ax, 7
	       cwd
	       idiv [h]
	       mov bx, S_HEIGHT
	       sub bx, [h]
	       imul ax, bx	  ;ax = ax * (S_HEIGHT - H)
	       mov cx, ax	  ;cx = sx
	       ;sy
	       mov ax, [y1]	   ;y1
	       sal ax, 7
	       cwd
	       idiv [h]
	       imul ax, bx	  ;eax = eax * (S_HEIGHT - H)
	       ;eax = sy
	       ;ecx = sx
	       sar ax, 7
	       add ax, [yt]
	       add ax, [miny]
	       sar cx, 7
	       add cx, [xt]
	       add cx, [frame]
	       xor ax, cx
	       and ax, 31
	       add ax, 16
	       jmp plot
	       ;
	       ;
	       ;
no_plot:
	       xor al, al
plot:
	       mov di, [yt]
	       add di, [miny]
	       imul di, 320
	       add di, [xt]
	       add di, [frame]
	       stosb
	       ;
	       ;
	       ;end lens
	       ;

	       dec [xt]
	       jnz xloop
	       dec [yt]
	       jnz yloop
	mov dx,3dah
  vsync:
	in al,dx
	and al,8
	jz vsync

	in al,60h
	dec al
	jnz blit_loop

	mov ax, 003h
	int 10h

	ret

datastuff:
	xt	   dw ?
	yt	   dw ?
	x1	   dw ?
	y1	   dw ?
	miny	   dw ?
	h	   dw ?
	frame	   dw ?
	short87    dw ?