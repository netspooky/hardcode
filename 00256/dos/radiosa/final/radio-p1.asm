
;        [\ /]
;  r a d I o S a  by baze of ||| [slower and longer pentium version]
;        [ | ]    http://www.3sc.sk/

[org 256]

	mov	al,13h
	int	10h
	push	word 0A000h
	pop	es

	xor	cx,cx
PALETTE	mov	dx,3C8h
MOVE	equ	$-2
	mov	ax,cx
	out	dx,al
	inc	dx
	mul	al
	shr	ax,5
	out	dx,al
	mov	al,cl
	out	dx,al
	out	dx,al
	loop	PALETTE

MAIN	fninit
	mov	di,EYE
	mov	si,400h
	push	si

	fild	word [byte di-EYE+MOVE]
	fidiv	word [di]
	fsin
	fldl2t
	fmulp	st1,st0

	mov	dx,100
EYE	equ	$-2
DRAWY	mov	bp,-160
DRAWX	fldlg2
	fmul	st0,st0

	mov	[si],dx
	fild	word [si]
	fidiv	word [di]
	fmul	st0,st1

	mov	[si],bp
	fild	word [si]
	fidiv	word [di]
	fmul	st0,st2

	call	ROTATE
	fstp	dword [si]
	fstp	dword [si+4]
	fstp	dword [si+8]

	fldpi
	fchs
	fldz
	fldz
	call	ROTATE

	xor	bx,bx
	mov	cl,50
RAYSTEP	mov	al,3
SQUARE	fld	st2
	fmul	st0,st0
	dec	al
	jnz	SQUARE

	fldpi
	fmul	st0,st0
	fcom	st0,st1
	fnstsw	ax
	sahf
	jc	CUBE
	fcom	st0,st2
	fnstsw	ax
	sahf
	jc	CUBE
	fcom	st0,st3
	fnstsw	ax
	sahf
	jc	CUBE

	fstp	st0
	faddp	st1,st0
	faddp	st1,st0
	fld	st1
	fmul	st0,st3
	fmul	st0,st4
	fmul	st0,st5
	faddp	st1,st0

	fld1
	fcompp
	fnstsw	ax
	sahf
	jc	NOHIT
	inc	bx

NOHIT	fld	dword [si+8]
	faddp	st3,st0
	fld	dword [si+4]
	faddp	st2,st0
	fadd	dword [si]

	loop	RAYSTEP
	jmp	short TEXEL

CUBE	fcompp
	fcompp
TEXEL	fmulp	st1,st0
	fmulp	st1,st0
	fistp	word [si]

	lodsb
	and	al,2
	add	al,bl
	add	al,cl
	mov	[si-1],al

	inc	bp
	cmp	bp,160
	jnz	near DRAWX

	dec	dx
	cmp	dx,byte -100
	jnz	near DRAWY

	pop	si
	xor	di,di
	mov	ch,32000/256
	rep	movsw

	sub	word [byte bp-160+MOVE],byte 5

	in	al,60h
	dec	al
	jnz	near MAIN

	mov	ax,3
	int	10h

ROTATE	call	ROTXY
ROTXY	fld	st1
	fld	st1
	fild	word [byte di-EYE+MOVE]
	fidiv	word [di]
	fsincos
	fmul	st4,st0
	fmulp	st5,st0
	fmul	st1,st0
	fmulp	st2,st0
	faddp	st3,st0
	fsubp	st1,st0
	fxch	st0,st2
	ret
