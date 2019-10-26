;********************************
;* getmandel 			*
;*	param	mandelx,mandely *
;*	return	ax		*
;********************************
getmandel:
	push	cx
	
	fldz
	fst	mx
	fstp	mx2
	fldz
	fst	my
	fstp	my2
	
	mov	cx, 255
mandelloop:
	fld	mx
	fmul	my
	fmul	CONST2
	fadd	mandely
	fstp	my
	
	fld	mx2
	fsub	my2
	fadd	mandelx
	fstp	mx
	
	fld	mx
	fmul	mx
	fst	mx2
	fld	my
	fmul	my
	fst	my2
	fadd
	
	;fld	CONST4
	;fcompp
	;fstsw	ax
	;wait
	;sahf
	;jns	mandelexit
	;fsub	CONST0_5
	fistp	tempint
	sub	tempint, 4
	jns	mandelexit
	
	loop	mandelloop
mandelexit:
	
	mov	ax, cx
	
	pop	cx
ret



;**************
;* mandelpart *
;**************
mandelpart:
	mov	bx, mandelcounter
	
	fild	framecounter
	mov	ax, MANDELSPEED
	mov	tempint, ax
	call	modulo
	fistp	mandelcounter
	
	cmp	mandelcounter, bx
	jnb	mandelnoswap
	
	mov	mandelyphase, 0
	mov	bx, mandelbackbuffer
	mov	ax, mandelbuffer1
	mov	mandelbackbuffer, ax
	mov	ax, mandelbuffer2
	mov	mandelbuffer1, ax
	mov	mandelbuffer2, bx

	fld	mandelzoom
	fmul	CONST0_5
	fstp	mandelzoom
	
mandelnoswap:
	
	cmp	mandelyphase, 200
	jnb	mandelsleep
	mov	ax, mandelyphase
	mov	mandelystart, ax
	add	ax, 5
	mov	mandelyend, ax
	mov	mandelyphase, ax
	
	push	es
	mov	ax, mandelbackbuffer
	mov	es, ax

	call	rendermandel
	pop	es	
	
mandelsleep:
	
	call	rendermandelbuffers
	
		
ret



;*****************************************
;* rendermandel                          *
;*	param:	es = target              *
;*		mandelystart, mandelyend *
;*		mandelzoom               *
;*****************************************
rendermandel:
	fld	mandelzoom
	fst	mandeldx
	fmul	CONSTASPECT
	fstp	mandeldy
	
	fld	mandeltargetx
	fld	mandeldx
	fmul	CONST0_5
	fsub
	fst	mandelx1
	fadd	mandeldx
	fstp	mandelx2
	
	fld	mandeltargety
	fld	mandeldy
	fmul	CONST0_5
	fsub
	fst	mandely1
	fadd	mandeldy
	fstp	mandely2
	
	;xslope
	fld	mandelx2
	fsub	mandelx1
	fst	mandeldx
	fmul	CONSTOO320
	fstp	mandelxslope
	
	;yslope
	fld	mandely2
	fsub	mandely1
	fst	mandeldy
	fmul	CONSTOO200
	fstp	mandelyslope
	
	fld	mandely1
	fld	mandelyslope
	fimul	mandelystart
	fadd
	fstp	mandely
	
	mov	ax, mandelystart
	mov	di, ax
	shl	ax, 8
	shl	di, 6
	add	di, ax

	
	mov	dx, mandelyend
	sub	dx, mandelystart
	
mandelyloop:
	fld	mandelx1
	fstp	mandelx
	mov	cx, 320
mandelxloop:

	call	getmandel
	;add	ax, framecounter
	stosb
	
	fld	mandelx
	fadd	mandelxslope
	fstp	mandelx
	
	loop 	mandelxloop

	
	fld	mandely
	fadd	mandelyslope
	fstp	mandely

	dec	dx
	jnz	mandelyloop
	
ret



;****************************
;* rendermandelbuffers      *
;****************************
rendermandelbuffers:
	fild	mandelcounter
	fiadd	MANDELSPEED
	fld	MANDELZOOMBASE
	call	fpow
	fstp	mandelsize


	fld	mandelsize
	mov	tempint, 80
	fimul	tempint
	fistp	tempint
	mov	ax, tempint
	mov	x1, 160
	mov	x2, 160
	sub	x1, ax
	add	x2, ax

	fld	mandelsize
	mov	tempint, 50
	fimul	tempint
	fistp	tempint
	mov	ax, tempint
	mov	y1, 100
	mov	y2, 100
	sub	y1, ax
	add	y2, ax
	
	;mov	x1, 0
	;mov	y1, 0
	;mov	x2, 320
	;mov	y2, 200
	mov	tx1, 0
	mov	ty1, 0
	mov	tx2, 320
	mov	ty2, 200
	mov	ax, mandelbuffer1
	mov	fs, ax
	call	texturedrectangle


	fld	mandelsize
	mov	tempint, 40
	fimul	tempint
	fistp	tempint
	mov	ax, tempint
	mov	x1, 160
	mov	x2, 160
	sub	x1, ax
	add	x2, ax

	fld	mandelsize
	mov	tempint, 25
	fimul	tempint
	fistp	tempint
	mov	ax, tempint
	mov	y1, 100
	mov	y2, 100
	sub	y1, ax
	add	y2, ax

	mov	tx1, 0
	mov	ty1, 0
	mov	tx2, 320
	mov	ty2, 200
	mov	ax, mandelbuffer2
	mov	fs, ax
	call	texturedrectangle
ret