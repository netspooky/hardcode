   ;------------------------------
     ;Balls By Quasimodo/TiTAN  2006
      ;------------------------------
     ;written for nasm
   ;greets to:
 ;brainstorm, darklite & paradise
;------------------------------
 ;mail me: qua-mod@web.de
   ;------------------------------

[org 100h]

radius	equ	38
speed	equ	4
Nr	equ	4

	mov	al,13h
	int	10h
	push	0a000h
	pop	es

	mov	dx,0x3c9
	inc	ch
pal:	mov	ax,cx
	not	ax
	out	dx,al
	out	dx,al
	out	dx,al
	loop	pal

	mov	si,size+4
	mov	cl,Nr
init:	mov	eax,[si-53]
	mov	[si+6],eax
	add	si,10
	loop	init

	fninit	
	fldz
SCREEN:	fadd	dword [angle]
	fld	st0	
	fsincos

	mov	si,size+4	
	mov	cl,Nr
move:	mov	dx,[si+6]
	mov	bx,[si+8]

	cmp	dl,256-radius-speed
	jc	next1
	mov	bl,-1*speed
next1:	cmp	dl,radius+speed
	jnc	next2
	mov	bl,speed
next2:	cmp	dh,256-radius
	jc	next3
	mov	bh,-1*speed
next3:	cmp	dh,56+radius
	jnc	next4
	mov	bh,speed
next4:	add	dx,bx
	mov	[si+6],dx
	mov	[si+8],bx
	add	bp,bx		
	add	si,10
	loop	move

	mov	ch,200
	xor	di,di
PIXEL:	push	cx
	mov	cx,Nr
	mov	si,size+4
nextb:	pop	ax
	push	ax
	add	ax,[si+6]
	movsx	bx,ah
	movsx	ax,al
	mov	[si],ax
	mov	[si+2],bx
	imul	ax,ax
	imul	bx,bx
	add	ax,bx
	mov	[si+4],ax
	cmp	ax,[size]
	jc	ball

	add	si,10
	loop	nextb
	pop	ax
	push	ax
	add	ax,bp
	and	al,ah

	jmp short	draw
	
ball:	fild	word [size]
	fisub	word [si+4]
	fsqrt
	fild	word [si+2]
	fild	word [si]
	call	ROTATE	
	fxch	st0,st2
	call	ROTATE
	fistp	word [si]
	mov	ax,[si]
	fistp	word [si]
	imul	ax,[si]
	fistp	word [si]
	imul	ax,[si]	
	shr	ax,8	
		
draw:	stosb
	pop	cx	
	test	cl,3
	jnz	next
	stosb
next:	loop	PIXEL
	fstp	dword [di]
	fstp	dword [di]

	in	al,60h
	dec	al
	jnz	SCREEN

ROTATE:	fld	st1
	fmul	st0,st5
	fld	st1
	fmul	st0,st5
	fsubp	st1,st0
	fxch	st0,st2
	
	fmul	st0,st4
	fld	st1
	fmul	st0,st6
	faddp	st1,st0
	fstp	st1

	ret

angle:	dd	0.1
size:	dw	radius*radius


