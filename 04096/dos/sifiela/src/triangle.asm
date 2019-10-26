;************
;* trihline *
;************
trihline:
	push	bx

	fld	trix1
	call	floor
	fistp	x1
	fld	trix2
	call	floor
	fistp	x2
	
	cmp	x1, 0
	jns	noclip1
	mov	x1, 0
noclip1:
	cmp	x2, 0
	jns	noclip2
	mov	x2, 0
noclip2:
	
	mov	ax, x1
	cmp	ax, x2
	jb	noswap
	mov	bx, x2
	mov	x1, bx
	mov	x2, ax
noswap:

	cmp	x2, 320
	jb	noclip3
	mov	x2, 319
noclip3:
	
	cmp	triy, 0
	js	trihlineend
	cmp	triy, 200
	jnb	trihlineend
	cmp	x2, 00
	jb	trihlineend
	cmp	x1, 320
	jnb	trihlineend

	push	cx
	
	mov	cx, x2
	sub	cx, x1
	inc	cx
	
	mov	ax, triy
	mov	di, ax
	shl	ax, 8
	shl	di, 6
	add	di, ax
	add	di, x1
	mov	ax, color
	
	rep	stosb

	pop	cx	
trihlineend:
	pop	bx
ret



;*****************
;* drawtriangle *
;*****************
drawtriangle:
	mov	si, vertex1
	fld	fs:[si + vertex_py]
	mov	si, vertex2
	fld	fs:[si + vertex_py]
	fcompp
	fstsw	ax
	wait
	sahf
	ja	notriswap1
	mov	ax, vertex1
	mov	vertex2, ax
	mov	vertex1, si
notriswap1:
	
	mov	si, vertex1
	fld	fs:[si + vertex_py]
	mov	si, vertex3
	fld	fs:[si + vertex_py]
	fcompp
	fstsw	ax
	wait
	sahf
	ja	notriswap2
	mov	ax, vertex1
	mov	vertex3, ax
	mov	vertex1, si
notriswap2:
	
	mov	si, vertex2
	fld	fs:[si + vertex_py]
	mov	si, vertex3
	fld	fs:[si + vertex_py]
	fcompp
	fstsw	ax
	wait
	sahf
	ja	notriswap3
	mov	ax, vertex2
	mov	vertex3, ax
	mov	vertex2, si
notriswap3:

	mov	si, vertex1
	fld	fs:[si + vertex_py]
	fistp	tempint
	mov	ax, tempint
	mov	si, vertex3
	fld	fs:[si + vertex_py]
	fistp	tempint
	cmp	ax, tempint
	jnz	notriret
	ret
notriret:
	
;	mov	si, vertex1
;	fld	fs:[si + vertex_px]
;	fistp	tempint
;	fild	tempint
;	fstp	fs:[si + vertex_px]
;	fld	fs:[si + vertex_py]
;	fistp	tempint
;	fild	tempint
;	fstp	fs:[si + vertex_py]
;
;	mov	si, vertex2
;	fld	fs:[si + vertex_px]
;	fistp	tempint
;	fild	tempint
;	fstp	fs:[si + vertex_px]
;	fld	fs:[si + vertex_py]
;	fistp	tempint
;	fild	tempint
;	fstp	fs:[si + vertex_py]
;
;	mov	si, vertex3
;	fld	fs:[si + vertex_px]
;	fistp	tempint
;	fild	tempint
;	fstp	fs:[si + vertex_px]
;	fld	fs:[si + vertex_py]
;	fistp	tempint
;	fild	tempint
;	fstp	fs:[si + vertex_py]



	;Deltas
	mov	di, vertex1
	mov	si, vertex2
	fld	fs:[si + vertex_px]
	fsub	fs:[di + vertex_px]
	fstp	trideltax1
	fld	fs:[si + vertex_py]
	fsub	fs:[di + vertex_py]
	fstp	trideltay1

	mov	si, vertex3
	fld	fs:[si + vertex_px]
	fsub	fs:[di + vertex_px]
	fstp	trideltax2
	fld	fs:[si + vertex_py]
	fsub	fs:[di + vertex_py]
	fstp	trideltay2

	mov	di, vertex2
	mov	si, vertex3
	fld	fs:[si + vertex_px]
	fsub	fs:[di + vertex_px]
	fstp	trideltax3
	fld	fs:[si + vertex_py]
	fsub	fs:[di + vertex_py]
	fstp	trideltay3


	;ey1=(int)(y1+1)-y1;
	;ey2=(int)(y2+1)-y2;
	mov	si, vertex1
	fld	fs:[si + vertex_py]
	fld1
	fadd
	call	floor
	fsub	fs:[si + vertex_py]
	fstp	triey1
	
	mov	si, vertex2
	fld	fs:[si + vertex_py]
	fld1
	fadd
	call	floor
	fsub	fs:[si + vertex_py]
	fstp	triey2
	

	mov	si, vertex1
	fld	fs:[si + vertex_px]
	fst	trix1
	fstp	trix2

	
	push	cx
	
	;Big slope: deltay2 is never zero
	fld	trideltax2
	fdiv	trideltay2
	fstp	trik2

	;ex2=ey1*k2;
	;px2+=ex2;
	fld	triey1
	fmul	trik2
	fst	triex2
	fadd	trix2
	fstp	trix2
	

	;cmp	trideltay1, 0
	mov	si, vertex1
	fld	fs:[si + vertex_py]
	mov	si, vertex2
	fld	fs:[si + vertex_py]
	fcompp
	fstsw	ax
	wait
	sahf
	jz	trisecondpart ;Jump to second part


	;First slope: 
	fld	trideltax1
	fdiv	trideltay1
	fstp	trik1


	;ex1=ey1*k1;
	;px1+=ex1;
	fld	triey1
	fmul	trik1
	fst	triex1
	fadd	trix1
	fstp	trix1

	
	mov	si, vertex1
	fld	fs:[si + vertex_py]
	fld1
	fadd
	call	floor
	fistp	triy
	
	mov	si, vertex2
	fld	fs:[si + vertex_py]
	call	floor
	fistp	tempint
	mov	cx, tempint
	sub	cx, triy
	inc	cx
	jz	trisecondpart
triyloop1:
	call	trihline
	
	fld	trix1
	fadd	trik1
	fstp	trix1
	
	fld	trix2
	fadd	trik2
	fstp	trix2
	
	inc	triy
	
	loop	triyloop1



trisecondpart:
	mov	si, vertex2
	fld	fs:[si + vertex_py]
	fld1
	fadd
	call	floor
	fistp	triy
	
	mov	si, vertex3
	fld	fs:[si + vertex_py]
	call	floor
	fistp	tempint
	mov	cx, tempint
	sub	cx, triy
	inc	cx
	jz	trinosecondpart


	mov	si, vertex2
	fld	fs:[si + vertex_px]
	fstp	trix1

	fld	trideltax3
	fdiv	trideltay3
	fstp	trik1

	;ex1=ey2*k1;
	;px1+=ex1;
	fld	triey2
	fmul	trik1
	fst	triex1
	fadd	trix1
	fstp	trix1
	

triyloop2:
	call	trihline
	
	fld	trix1
	fadd	trik1
	fstp	trix1
	
	fld	trix2
	fadd	trik2
	fstp	trix2
	
	inc	triy
	
	loop	triyloop2
	
trinosecondpart:
	
	
	
	
	pop	cx



;	mov	si, vertex1
;	fld	fs:[si + vertex_px]
;	fistp	x1
;	fld	fs:[si + vertex_py]
;	fistp	y1
;	;mov	al, fs:[si + vertex_color]
;	
;	push	x1
;	push	y1
;
;	mov	si, vertex2
;	fld	fs:[si + vertex_px]
;	fistp	x2
;	fld	fs:[si + vertex_py]
;	fistp	y2
;	
;;	call	drawline
;
;	mov	si, vertex3
;	fld	fs:[si + vertex_px]
;	fistp	x1
;	fld	fs:[si + vertex_py]
;	fistp	y1
;	mov	al, fs:[si + vertex_color]
;	
;;	call	drawline
;
;	pop	y2
;	pop	x2
;;	call	drawline
ret
