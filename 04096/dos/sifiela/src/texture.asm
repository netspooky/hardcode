;*************************
;* Getpixel              *
;*	param:	tx,ty      *
;*	return:	ax=color *
;*************************
getpixel:
	mov	ax,ty
	shl	ax,8
	shl	ty,6
	add	ax,ty
	add	ax,tx

	mov	si,ax
	xor	ax,ax
	mov	al,fs:[si]
ret



;*************************
;* getbilinearpixel      *
;*	param:	btx,bty  *
;*	return:	ax=color *
;*************************
getbilinearpixel:
	fld	btx
	fld	st(0)
	fsub	CONST0_5
	frndint
	fist	btextx1
	fchs
	fadd
	fst	btextfx
	fchs
	fld1
	fadd
	fstp	btext1fx

	fld	bty
	fld	st(0)
	fsub	CONST0_5
	frndint
	fist	btexty1
	fchs
	fadd
	fst	btextfy
	fchs
	fld1
	fadd
	fstp	btext1fy

	fild	btextx1
	fld1
	fadd
	fistp	btextx2
	fild	btexty1
	fld1
	fadd
	fistp	btexty2
;	fild	btextx1
;	mov	tempint,320
;	call	modulo
;	fist	btextx1
;	fld1
;	fadd
;	call	modulo
;	fistp	btextx2
;
;	fild	btexty1
;	mov	tempint,200
;	call	modulo
;	fist	btexty1
;	fld1
;	fadd
;	call	modulo
;	fistp	btexty2

	mov	ax,btexty1
	mov	ty,ax
	mov	ax,btextx1
	mov	tx,ax
	call	getpixel
	and	ax, 63
	mov	color1,ax

	mov	ax,btexty1
	mov	ty,ax
	mov	ax,btextx2
	mov	tx,ax
	call	getpixel
	and	ax, 63
	mov	color2,ax

	mov	ax,btexty2
	mov	ty,ax
	mov	ax,btextx1
	mov	tx,ax
	call	getpixel
	and	ax, 63
	mov	color3,ax

	mov	ax,btexty2
	mov	ty,ax
	mov	ax,btextx2
	mov	tx,ax
	call	getpixel
	and	ax, 63
	mov	color4,ax

	fild	color1
	fmul	btext1fx
	fmul	btext1fy
	fild	color2
	fmul	btextfx
	fmul	btext1fy
	fadd
	fild	color3
	fmul	btext1fx
	fmul	btextfy
	fadd
	fild	color4
	fmul	btextfx
	fmul	btextfy
	fadd
	fistp	color

	mov	ax,color
ret



;**********************************************
;* getbilinearvalue                           *
;*	param:	color1,color2,color3,color4   *
;*		textfx,text1fx,textfy,text1fy *
;*	return:	ax=color                      *
;**********************************************
getbilinearvalue:
	fild	color1
	fmul	btext1fx
	fmul	btext1fy
	fild	color2
	fmul	btextfx
	fmul	btext1fy
	fadd
	fild	color3
	fmul	btext1fx
	fmul	btextfy
	fadd
	fild	color4
	fmul	btextfx
	fmul	btextfy
	fadd
	fistp	color
	mov	ax,color
ret



;***********************************
;* texturedrectangle               *
;*	param:	x1, y1, x2, y2     *
;*		tx1, ty1, tx2, ty2 *
;*		es = target        *
;*		fs = texture       *
;***********************************
texturedrectangle:
	mov	ax, x2
	sub	ax, x1
	mov	xd, ax
	mov	ax, tx2
	sub	ax, tx1
	mov	txd, ax
	fild	txd
	fidiv	xd
	fstp	txk

	mov	ax, y2
	sub	ax, y1
	mov	yd, ax
	mov	ax, ty2
	sub	ax, ty1
	mov	tyd, ax
	fild	tyd
	fidiv	yd
	fstp	tyk
	
	
	cmp	x1, 0
	jns	nox1clip
	xor	ax, ax
	sub	ax, x1
	mov	tempint, ax
	fild	tempint
	fmul	txk
	fiadd	tx1
	fistp	tx1
	mov	x1, 0
nox1clip:
	cmp	x2, 320
	jna	nox2clip
	mov	x2, 320
nox2clip:

	mov	ax, x2
	sub	ax, x1
	mov	xd, ax
	mov	ax, tx2
	sub	ax, tx1
	mov	txd, ax
	

	cmp	y1, 0
	jns	noy1clip
	xor	ax, ax
	sub	ax, y1
	mov	tempint, ax
	fild	tempint
	fmul	tyk
	fiadd	ty1
	fistp	ty1
	mov	y1, 0
noy1clip:
	cmp	y2, 200
	jna	noy2clip
	mov	y2, 200
noy2clip:	
	
	
	mov	tempint, 320
	fild	tempint
	fimul	y1
	fiadd	x1
	fistp	tempint
	mov	di, tempint


	mov	dx, y2
	sub	dx, y1
	mov	y, 0
textureyloop:
	mov	cx, x2
	sub	cx, x1
	mov	x, 0
texturexloop:
	
	fild	x
	fmul	txk
	fiadd	tx1
	fadd	CONSTEPSILON
	fistp	tx
	;fstp	btx
	fild	y
	fmul	tyk
	fiadd	ty1
	fadd	CONSTEPSILON
	;fstp	bty
	;call	getbilinearpixel
	fistp	ty
	call	getpixel
	
	stosb
	inc	x
	loop	texturexloop
	
	
	add	di, 320
	sub	di, xd
	inc	y
	
	dec	dx
	jnz	textureyloop
	
ret