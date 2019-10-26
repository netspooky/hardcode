;********************
; Makemandelpalette *
;********************
makemandelpalette:
	pusha


	mov	dx,3C8h
	mov	ax,0;
	out	dx,al
	inc	dx
	mov	cx,64
paletteloop1:
	out	dx,al
	out	dx,al
	out	dx,al
	inc	al
	loop	paletteloop1

	mov	cx,64
	mov	bl,63
paletteloop2:
	mov	al,63
	out	dx,al
	mov	al,bl
	out	dx,al
	dec	bl
	out	dx,al
	loop	paletteloop2

	mov	cx,64
	mov	bl,63
	mov	bh,0
paletteloop3:
	mov	al,bl
	out	dx,al
	mov	al,bh
	out	dx,al
	mov	al,0
	out	dx,al
	dec	bl
	inc	bh
	loop	paletteloop3

	mov	cx,64
	mov	bl,63
	mov	bh,0
paletteloop4:
	mov	al,0
	out	dx,al
	mov	al,bl
	out	dx,al
	mov	al,bh
	out	dx,al
	dec	bl
	inc	bh
	loop	paletteloop4


	popa
ret



;*******************
; Makeclothpalette *
;*******************
makeclothpalette:
	pusha


	mov	dx, 3C8h
	mov	ax, 0
	out	dx, al
	inc	dx
	mov	cx, 64
cpaletteloop1:
	out	dx, al
	out	dx, al
	out	dx, al
	inc	al
	loop	cpaletteloop1


	mov	cx, 64
	mov	bl, 0
	mov	ax, 0
cpaletteloop2:
	mov	al, bl
	out	dx, al
	mov	al, 0
	out	dx, al
	out	dx, al
	inc	bl
	loop	cpaletteloop2


	mov	cx, 64
	mov	bl, 0
	mov	ax, 0
cpaletteloop3:
	mov	al, 0
	out	dx, al
	mov	al, bl
	out	dx, al
	mov	al, 0
	out	dx, al
	inc	bl
	loop	cpaletteloop3


	mov	cx, 64
	mov	bl, 0
	mov	ax, 0
cpaletteloop4:
	mov	al, 0
	out	dx, al
	out	dx, al
	mov	al, bl
	out	dx, al
	inc	bl
	loop	cpaletteloop4


	popa
ret



;**************
;* Copybuffer *
;**************
copybuffer:
	push	es
	push	ds
	pusha

	
	push	0A000h
	pop	es
	push	buffer
	pop	ds

	xor	di,di
	xor	si,si
	mov	cx,16000
	rep	movsd


	popa
	pop	ds
	pop	es
ret



;**************
;* clearbuffer *
;**************
clearbuffer:
	push	es
	pusha

	
	push	buffer
	pop	es

	xor	di,di
	xor	eax, eax
	mov	cx,16000
	rep	stosd


	popa
	pop	es
ret



;*************
; Initialize *
;*************
initialize:
	pusha


	mov	ax, 13h
	int	10h
	finit

	mov	ax, cs
	add	ax, 1000h
	mov	buffer, ax
	add	ax, 1000h
	mov	font, ax
	add	ax, 1024
	mov	mandelbuffer1, ax
	add	ax, 1000h
	mov	mandelbuffer2, ax
	add	ax, 1000h
	mov	mandelbackbuffer, ax
	add	ax, 1000h
	mov	clothvertices, ax
	add	ax, 1000h
	mov	clothtriangles, ax
	add	ax, 1000h
	mov	springs, ax
	add	ax, 1000h

	push	buffer
	pop	es
	xor	di, di
	xor	ax, ax
	mov	cx, 32768
	rep	stosw

	call	readfont

	
	mov	ax, mandelbuffer1
	mov	es, ax
	call	rendermandel
	
	fld	mandelzoom
	fmul	CONST0_5
	fstp	mandelzoom
	mov	ax, mandelbuffer2
	mov	es, ax
	call	rendermandel
	
	fld	mandelzoom
	fmul	CONST0_5
	fstp	mandelzoom

	
	;xor	di, di
	;mov	cx, 320
	;xor	ax, ax
	;rep	stosb
	
	mov	mandelcounter, 0

	fld1
	fidiv	MANDELSPEED
	fld	CONST2
	call	fpow
	fstp	MANDELZOOMBASE


;	mov	cx, vertexcount
;	mov	ax, verticest
;	mov	es, ax
;	xor	di, di
;	lea	si, vertices
;vertexfillloop:
;	mov	eax, [si + vector_x]
;	mov	es:[di + vertex_x], eax
;	mov	eax, [si + vector_y]
;	mov	es:[di + vertex_y], eax
;	mov	eax, [si + vector_z]
;	mov	es:[di + vertex_z], eax
;	add	si, VECTORSIZE
;	add	di, VERTEXSIZE
;	loop	vertexfillloop




	;Create cloth-grid
	fild	clothwidth
	fimul	clothheight
	fistp	clothvertexcount
	
	mov	ax, clothvertices
	mov	es, ax

	fild	clothvertexcount
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	tempint
	mov	di, tempint
	
	mov	dx, clothheight
gridzloop:
	mov	ax, clothheight
	shr	ax, 1
	mov	tempint, dx
	sub	tempint, ax
	fild	tempint
	fmul	CLOTHSCALE

	mov	cx, clothwidth
gridxloop:
	sub	di, VERTEXSIZE

	fst	es:[di + vertex_z]

	fld1
	fmul	CONST0_5
	fst	es:[di + vertex_y]
	fstp	es:[di + vertex_y + 32768]

	mov	ax, clothwidth
	shr	ax, 1
	mov	tempint, cx
	sub	tempint, ax
	fild	tempint
	fmul	CLOTHSCALE
	fstp	es:[di + vertex_x]
	
	fldz
	fstp	es:[di + vertex_vx]
	fldz
	fstp	es:[di + vertex_vy]
	fldz
	fstp	es:[di + vertex_vz]
	
	loop	gridxloop
	fstp	tempreal
	
	dec	dx
	jnz	gridzloop
	
	;Movement for one corner
	;sub	di, VERTEXSIZE
	;xor	di, di
	;mov	di, 70*(size vertex_s)
	;fld1
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fstp	es:[di + vertex_vy]
	
	
	
;	;Lines for cloth
;	mov	ax, lines
;	mov	es, ax
;	xor	di, di
;	xor	ax, ax
;	
;	mov	dx, gridsize
;gridlinezloop1:
;	mov	cx, gridsize
;	dec	cx
;gridlinexloop1:
;	mov	es:[di], ax
;	inc	ax
;	mov	es:[di + 2], ax
;	add	di, LINESIZE
;
;	loop	gridlinexloop1
;
;	inc	ax
;	dec	dx
;	jnz	gridlinezloop1
;	
;	
;	xor	ax, ax
;	
;	mov	dx, gridsize
;gridlinezloop2:
;	mov	cx, gridsize
;	dec	cx
;	push	ax
;gridlinexloop2:
;	mov	es:[di], ax
;	add	ax, gridsize
;	mov	es:[di + 2], ax
;	add	di, LINESIZE
;
;	loop	gridlinexloop2
;	
;	pop	ax
;	inc	ax
;
;	dec	dx
;	jnz	gridlinezloop2
	
	
	
	
	
	;Triangles for cloth
	mov	ax, clothtriangles
	mov	es, ax

	xor	di, di
	xor	ax, ax
	
	mov	color, 0
	
	mov	dx, clothheight
	dec	dx
gridtrianglezloop:
	mov	cx, clothwidth
	dec	cx
gridtrianglexloop:
	push	ax
	
	mov	bx, color
	add	bl, 64
	;First triangle
	mov	es:[di + triangle_color], bl
	mov	es:[di + triangle_v1], ax
	inc	ax
	mov	es:[di + triangle_v2], ax
	push	ax
	dec	ax
	add	ax, clothwidth
	mov	es:[di + triangle_v3], ax
	;Second triangle
	add	di, TRIANGLESIZE
	mov	es:[di + triangle_color], bl
	mov	es:[di + triangle_v1], ax
	pop	ax
	mov	es:[di + triangle_v2], ax
	add	ax, clothwidth
	mov	es:[di + triangle_v3], ax
	add	di, TRIANGLESIZE
	pop	ax
	
	xor	color, 64
	
	inc	ax
	loop	gridtrianglexloop

	inc	ax
	dec	dx
	jnz	gridtrianglezloop
	
	
	
	
	
	;Springs for cloth
	mov	ax, clothvertices
	mov	es, ax
	
	mov	ax, springs
	mov	fs, ax


	xor	si, si

	mov	dx, clothheight
gridspringzloop1:
	mov	cx, clothwidth
	dec	cx
gridspringxloop1:
	mov	v1, si
	mov	v2, si
	inc	v2
	call	createspring
	
	inc	si
	loop	gridspringxloop1
	
	inc	si
	dec	dx
	jnz	gridspringzloop1


	xor	si, si

	mov	dx, clothheight
	dec	dx
gridspringzloop2:
	mov	cx, clothwidth
gridspringxloop2:
	mov	v1, si
	mov	v2, si
	mov	ax, clothwidth
	add	v2, ax
	call	createspring
	
	inc	si
	loop	gridspringxloop2
	
	dec	dx
	jnz	gridspringzloop2


	xor	si, si

	mov	dx, clothheight
	dec	dx
gridspringzloop3:
	mov	cx, clothwidth
	dec	cx
gridspringxloop3:
	mov	v1, si
	mov	v2, si
	mov	ax, clothwidth
	inc	ax
	add	v2, ax
	call	createspring
	
	inc	si
	loop	gridspringxloop3
	
	dec	dx
	jnz	gridspringzloop3


	xor	si, si
	;mov	si, 1

	mov	dx, clothheight
	dec	dx
gridspringzloop4:
	mov	cx, clothwidth
	dec	cx
gridspringxloop4:
	inc	si

	mov	v1, si
	mov	v2, si
	mov	ax, clothwidth
	dec	ax
	add	v2, ax
	call	createspring
	
	loop	gridspringxloop4
	
	dec	dx
	jnz	gridspringzloop4
	
	popa
ret



;********
;* Main *
;********
main:
	call	initialize
	call	makeclothpalette
	call	settimer
	
	mov	ax, clothvertices
	mov	vertices, ax
	mov	ax, clothvertexcount
	mov	vertexcount, ax
	mov	ax, clothtriangles
	mov	triangles, ax
	mov	ax, clothtrianglecount
	mov	trianglecount, ax

mainloop:
	cmp	framecounter, 0
	js	mainloop

	
	mov	ax, buffer
	mov	es, ax

	
	cmp	part, 0
	jnz	cloth
	call	mandelpart
	cmp	framecounter, 3700
	jna	partend

	mov	part, 1
	push	es
	mov	ax, mandelbuffer1
	mov	es, ax
	mov	mandelystart, 0
	mov	mandelyend, 200
	fld	MANDELZOOM2
	fstp	mandelzoom
	call	rendermandel
	pop	es
	mov	framecounter, 0

	jmp	partend
cloth:
	cmp	framecounter, 1210
	ja	nomainloop

	call	clothpart
partend:
	

	call	copybuffer
	call	retrace


	;Keyboard handling
	mov	ax,256
	int	16h
	jz	yesmainloop          ;No keys pressed

	mov	ah,0
	int	16h
	dec	ah
	jz	nomainloop           ;ESC pressed

	cmp 	al,32
	jnz 	yesmainloop         ;Space not pressed
	
	;add i,3
	inc	mandelcounter
	

yesmainloop:
	jmp	mainloop
nomainloop:
	call	unsettimer
	mov	ax,3h
	int	10h
	mov	ah,9
	lea	dx,endstring
	int	21h
ret