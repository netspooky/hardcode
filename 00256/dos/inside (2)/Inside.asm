model	tiny
.386
.387
locals

Variables	STRUC
per	dw	128
ampl	dw	48
cnt_x	db	0
cnt_y	db	64
fputmp	label	word
	db	'GLOBAL'
Variables	ENDS

.code
	org	0100h
start:	mov	al,13h
	int	10h
	push	ds
	pop	es

;--------------- set palette
	mov	dx,03c8h
	xor	al,al
	out	dx,al
	inc	dx
@@pal0:	out	dx,al
	out	dx,al
	out	dx,al
	inc	al
	cmp	al,64
	jnz	@@pal0

;--------------- calculate ball table
	finit
	mov	di,offset balltbl
	mov	bp,56*56
	mov	bh,-50
@@ylp:	mov	bl,-80
@@xlp:	mov	al,bl
	imul	al
	mov	cx,ax
	mov	al,bh
	imul	al
	add	ax,cx		;x^2 + y^2
	cmp	ax,bp
	jl	@@in
	neg	ax

@@in:	mov	cx,bp
	sub	cx,ax		;r^2 - (x^2+y^2)
	mov	[var.fputmp],cx
	fild	[var.fputmp]
	fsqrt
	fistp	[var.fputmp]

;(y*m)/z
	xor	ch,ch
	mov	al,bh
	call	persp

;(x*m)/z
	mov	al,bl
	call	persp

	inc	bl
	cmp	bl,80
	jnz	@@xlp
	inc	bh
	cmp	bh,50
	jnz	@@ylp

	push	0a000h
	pop	es

MLoop:	mov	dx,03dah
@@vs0:	in	al,dx
	test	al,8
	jz	@@vs0
@@vs1:	in	al,dx
	test	al,8
	jnz	@@vs1

	mov	di,offset var

	mov	al,[var.cnt_x]
	add	al,-1
	mov	[var.cnt_x],al
	call	sine
	mov	bl,al

	mov	al,[var.cnt_y]
	add	al,-1
	mov	[var.cnt_y],al
	call	sine
	mov	bh,al

	xor	di,di
	mov	si,offset balltbl
	mov	cx,100
@@1:	push	cx
	mov	cx,160
@@0:	lodsw
	add	ax,bx
	xor	al,ah
	and	al,3fh
	add	al,dl
	shr	al,1
	add	ah,dh
	xor	ah,dl
	mov	es:[di+320],al
	stosw
	mov	dx,ax
	loop	@@0
	add	di,320
	pop	cx
	loop	@@1

	in	al,60h
	dec	al
	jnz	MLoop

	mov	ax,3
	int	10h
	ret

persp:	mov	cl,32
	imul	cl
	mov	cl,byte ptr [var.fputmp]
	cwd
	idiv	cx
	add	al,56
	stosb
	ret

sine:	xor	ah,ah
	mov	[di+fputmp],ax
	fild	[di+fputmp]
	fild	[di+per]
	fdiv
	fldpi
	fmul
	fsin
	fild	[di+ampl]
	fmul
	fistp	[di+fputmp]
	mov	ax,[di+fputmp]
	ret

var	Variables <>

balltbl	db	?

end	start
