;**********************
;* clipputpixel       *
;*	param:	x,y   *
;*		color *
;**********************
clipputpixel:
	cmp	x, 0
	js	putpixelend
	cmp	x, 320
	jnb	putpixelend
	cmp	y, 0
	js	putpixelend
	cmp	y, 200
	jnb	putpixelend
;**********************
;* putpixel           *
;*	param:	x,y   *
;*		color *
;**********************
putpixel:
	mov	ax, y
	mov	di, ax
	shl	di, 8
	shl	ax, 6
	add	di, ax
	add	di, x
	mov	ax, color

	mov	es:[di], al
putpixelend:
ret



;*********************
;* transformvertices *
;*********************
transformvertices:
	push	es
	
	mov	ax, vertices
	mov	es, ax
	
;	mov	ax, vertices2
;	mov	fs, ax

	xor	di, di
	xor	si, si
	mov	cx, vertexcount
transverticesloop:
	call	cameratransform

	fld	dword ptr es:[di + vertex_rz]
	fld1
	fdivr
	fld	st(0)
	
	fld	dword ptr es:[di + vertex_rx]
	fmul	PERSPECTIVEMUL
	fmul
	mov	tempint, 160
	fiadd	tempint
	fstp	dword ptr es:[di + vertex_px]
	
	fld	dword ptr es:[di + vertex_ry]
	fmul	PERSPECTIVEMUL
	fmul
	mov	tempint, 100
	fisubr	tempint
	fstp	dword ptr es:[di + vertex_py]
	
	mov	byte ptr es:[di + vertex_color], 63
	

;	mov	fs:[si], di
	add	di, VERTEXSIZE
;	add	si, 2
	loop	transverticesloop
	
	pop	es
ret


	
;**************
;* drawvertex *
;**************
drawvertex:
	fld	dword ptr fs:[si + vertex_px]
	fistp	x
	fld	dword ptr fs:[si + vertex_py]
	fistp	y
	
	mov	al, byte ptr fs:[si + vertex_color]
	mov	color, ax
	call	clipputpixel
ret


	
;************
;* drawline *
;************
drawline:
	;mov	ax, x1
	;mov	x, ax
	;mov	ax, y1
	;mov	y, ax
	mov	ax, x2
	sub	ax, x1
	jnz	drawlinecont
	mov	ax, y2
	sub	ax, y1
	jnz	drawlinecont
	ret
drawlinecont:
	
	push	cx
	
	
	
	fild	x1
	fstp	fx
	fild	y1
	fstp	fy
	
	fild	x2
	fisub	x1
	fld	st(0)
	fmul
	fild	y2
	fisub	y1
	fld	st(0)
	fmul
	fadd
	fsqrt
	fist	tempint
	fld1
	fdivr
	mov	cx, tempint
	fld	st(0)
	
	fild	x2
	fisub	x1
	fmul
	fstp	fkx
	
	fild	y2
	fisub	y1
	fmul
	fstp	fky

drawlineloop:
	fld	fx
	fistp	x
	fld	fy
	fistp	y
	call	clipputpixel

	fld	fx
	fadd	fkx
	fstp	fx
	fld	fy
	fadd	fky
	fstp	fy
	loop	drawlineloop
	
	pop	cx
ret


	
;*****************
;* drawwireframe *
;*****************
;drawwireframe:
;	mov	ax, vertices
;	mov	fs, ax
;	
;	mov	ax, lines
;	mov	gs, ax
;	xor	bx, bx
;
;	mov	cx, linecount
;lineloop:
;	fild	word ptr gs:[bx]
;	mov	tempint, VERTEXSIZE
;	fimul	tempint
;	fistp	tempint
;	mov	si, tempint
;	fld	fs:[si + vertex_px]
;	fistp	x1
;	fld	fs:[si + vertex_py]
;	fistp	y1
;	mov	al, fs:[si + vertex_color]
;	fld	fs:[si + vertex_z]
;	fld1
;	fadd
;	fmul	CONST63
;	fistp	color
;	;mov	color, ax
;
;	fild	word ptr gs:[bx + 2]
;	mov	tempint, VERTEXSIZE
;	fimul	tempint
;	fistp	tempint
;	mov	si, tempint
;	fld	fs:[si + vertex_px]
;	fistp	x2
;	fld	fs:[si + vertex_py]
;	fistp	y2
;	
;	call	drawline
;	
;	add	bx, 4
;	loop	lineloop
;ret


	
;*************
;* getnormal *
;*************
getnormal:
	push	si
	push	di
	push	bx
	
	mov	si, vertex1

	mov	bx, vertex2
	lea	di, vector1
	fld	fs:[bx + vertex_x]
	fsub	fs:[si + vertex_x]
	fstp	[di + vector_x]
	fld	fs:[bx + vertex_y]
	fsub	fs:[si + vertex_y]
	fstp	[di + vector_y]
	fld	fs:[bx + vertex_z]
	fsub	fs:[si + vertex_z]
	fstp	[di + vector_z]

	mov	bx, vertex3
	lea	di, vector2
	fld	fs:[bx + vertex_x]
	fsub	fs:[si + vertex_x]
	fstp	[di + vector_x]
	fld	fs:[bx + vertex_y]
	fsub	fs:[si + vertex_y]
	fstp	[di + vector_y]
	fld	fs:[bx + vertex_z]
	fsub	fs:[si + vertex_z]
	fstp	[di + vector_z]
	
	lea	si, vector1
	lea	bx, normal
	call	crossproduct
	mov	si, bx
	call	normalizep
	
	pop	bx
	pop	di
	pop	si
ret


	
;*****************
;* swaptriangles *
;*****************
swaptriangles:
	fild	qword ptr gs:[di + triangle_v1]
	fild	qword ptr gs:[si + triangle_v1]
	fistp	qword ptr gs:[di + triangle_v1]
	fistp	qword ptr gs:[si + triangle_v1]
	
;	fild	gs:[di + triangle_v2]
;	fild	gs:[si + triangle_v2]
;	fistp	gs:[di + triangle_v2]
;	fistp	gs:[si + triangle_v2]
	
;	fild	gs:[di + triangle_v3]
;	fild	gs:[si + triangle_v3]
;	fistp	gs:[di + triangle_v3]
;	fistp	gs:[si + triangle_v3]
	
;	fild	word ptr gs:[di + triangle_color]
;	fild	word ptr gs:[si + triangle_color]
;	fistp	word ptr gs:[di + triangle_color]
;	fistp	word ptr gs:[si + triangle_color]
	
	fld	gs:[di + triangle_z]
	fld	gs:[si + triangle_z]
	fstp	gs:[di + triangle_z]
	fstp	gs:[si + triangle_z]
ret


	
;*****************
;* sorttriangles *
;*****************
sorttriangles:
	mov	ax, vertices
	mov	fs, ax
	
	mov	ax, triangles
	mov	gs, ax
	xor	bx, bx

	mov	cx, trianglecount
	
trianglezloop:
	fild	gs:[bx + triangle_v1]
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	vertex1
	mov	si, vertex1
	fld	fs:[si + vertex_rz]

	fild	gs:[bx + triangle_v2]
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	vertex2
	mov	si, vertex2
	fadd	fs:[si + vertex_rz]

	fild	gs:[bx + triangle_v3]
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	vertex3
	mov	si, vertex3
	fadd	fs:[si + vertex_rz]
	
	mov	tempint, 3
	fidiv	tempint
	fstp	gs:[bx + triangle_z]

	add	bx, TRIANGLESIZE
	
	loop	trianglezloop
	
	
	xor	bx, bx
	mov	cx, trianglecount
	dec	cx
trianglesortloop1:
	mov	di, bx
	mov	si, bx
	add	si, TRIANGLESIZE
trianglesortloop2:
	fld	gs:[di + triangle_z]
	fld	gs:[si + triangle_z]
	
	fcompp
	fstsw	ax
	wait
	sahf
	
	jna	sortnoswap
	
	call	swaptriangles
	
	mov	si, di
	sub	di, TRIANGLESIZE
	jns	trianglesortloop2
	
	
sortnoswap:
	add	bx, TRIANGLESIZE
	loop	trianglesortloop1
ret


	
;*********
;* zclip *
;*********
zclip:
	mov	clip, 0
	
	mov	di, vertex1
	fild	fs:[di + vertex_rz]
	fldz
	fcompp
	fstsw	ax
	wait
	sahf
	js	notriangledraw1

	mov	di, vertex2
	fild	fs:[di + vertex_rz]
	fldz
	fcompp
	fstsw	ax
	wait
	sahf
	js	notriangledraw1

	mov	di, vertex3
	fild	fs:[di + vertex_rz]
	fldz
	fcompp
	fstsw	ax
	wait
	sahf
	js	notriangledraw1

	ret	
notriangledraw1:
	mov	clip, 1
ret


	
;*****************
;* drawtriangles *
;*****************
drawtriangles:
	mov	ax, vertices
	mov	fs, ax
	
	mov	ax, triangles
	mov	gs, ax
	xor	bx, bx

	mov	cx, trianglecount
	mov	color, 63
	
triangleloop:
;	push	fs
;	mov	ax, vertices2
;	mov	fs, ax
;	mov	si, gs:[bx + triangle_v1]
;	shl	si, 1
;	mov	ax, fs:[si]
;	mov	vertex1, ax
;	mov	si, gs:[bx + triangle_v2]
;	shl	si, 1
;	mov	ax, fs:[si]
;	mov	vertex2, ax
;	mov	si, gs:[bx + triangle_v3]
;	shl	si, 1
;	mov	ax, fs:[si]
;	mov	vertex3, ax
;	pop	fs
	fild	gs:[bx + triangle_v1]
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	vertex1

	fild	gs:[bx + triangle_v2]
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	vertex2

	fild	gs:[bx + triangle_v3]
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	vertex3

	call	zclip
	
	cmp	clip, 1
	jz	notriangledraw


	call	getnormal
	
	lea	si, light
	call	normalizep
	lea	di, normal
	call	dotproduct

	fabs
	mov	tempint, 55
	fimul	tempint
	fistp	color
	add	color, 8
	mov	al, gs:[bx + triangle_color]
	xor	ah, ah
	add	color, ax
	
	call	drawtriangle
	
notriangledraw:
	
	add	bx, TRIANGLESIZE
	
	loop	triangleloop
ret



;****************
;* createspring *
;****************
createspring:
	fild	v1
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	v1
	
	fild	v2
	mov	tempint, VERTEXSIZE
	fimul	tempint
	fistp	v2

	fild	springcount
	mov	tempint, SPRINGSIZE
	fimul	tempint
	fistp	tempint
	mov	di, tempint
	mov	ax, v1
	mov	fs:[di + spring_v1], ax
	mov	ax, v2
	mov	fs:[di + spring_v2], ax
	
	
	push	si
	
	mov	bx, v1
	mov	si, v2
	fld	es:[bx + vertex_x]
	fsub	es:[si + vertex_x]
	fld	st(0)
	fmul
	fld	es:[bx + vertex_y]
	fsub	es:[si + vertex_y]
	fld	st(0)
	fmul
	fld	es:[bx + vertex_z]
	fsub	es:[si + vertex_z]
	fld	st(0)
	fmul
	fadd
	fadd
	fsqrt
	fstp	fs:[di + spring_length]
	
;	fild	es:[bx + vertex_scount]
;	inc	es:[bx + vertex_scount]
;	mov	tempint, SPRINGSIZE
;	fimul	tempint
;	fistp	tempint
;	add	bx, tempint
;	mov	es:[bx + vertex_s0], di
	
;	fild	es:[si + vertex_scount]
;	inc	es:[si + vertex_scount]
;	mov	tempint, SPRINGSIZE
;	fimul	tempint
;	fistp	tempint
;	add	si, tempint
;	mov	es:[si + vertex_s0], di

	pop	si
	
	
	
	inc	springcount
ret



;***************
;* Clothcamera *
;***************
clothcamera:
	fld	dword ptr [cameratarget + 1*4]
	fstp	tempreal

	fild	framecounter
	mov	tempint, -400
	fiadd	tempint
	mov	tempint, 500
	fidiv	tempint
	fsin
	fld	st(0)
	fadd
	fst	dword ptr [camerapos + 0*4]
	fmul	CONST0_5
	fstp	dword ptr [cameratarget + 0*4]

	fld1
	fld1
	fld1
	fmul	CONST0_5
	fadd
	fadd
	fild	framecounter
	mov	tempint, 100
	fidiv	tempint
	fld1
	fadd
	fdiv
	fst	dword ptr [cameratarget + 1*4]
	
	fmul	CONST0_5
	fld1
	fld1
	fadd
	fsubr
	fstp	dword ptr [camerapos + 1*4]
	
	cmp	framecounter, 1100
	jb	nocameraup
	
	mov	ax, framecounter
	sub	ax, 1100
	mov	tempint, ax
	fild	tempint
	;fimul	tempint
	mov	tempint, 2000
	fidiv	tempint
	;mov	tempint, 10
	;fidiv	tempint
	fld	tempreal;dword ptr [cameratarget + 1*4]
	fadd
	fstp	dword ptr [cameratarget + 1*4]

nocameraup:
	
	lea	bx, cameratarget
	call	dircamera
ret



;****************
;* springupdate *
;****************
springupdate:
	fld	es:[bx + vertex_x]
	fsub	es:[di + vertex_x]
	fst	dword ptr [tempvector + vector_x]
	fld	st(0)
	fmul
	fld	es:[bx + vertex_y]
	fsub	es:[di + vertex_y]
	fst	dword ptr [tempvector + vector_y]
	fld	st(0)
	fmul
	fld	es:[bx + vertex_z]
	fsub	es:[di + vertex_z]
	fst	dword ptr [tempvector + vector_z]
	fld	st(0)
	fmul
	fadd
	fadd
	fsqrt
	fst	springlength
	fsub	fs:[si + spring_length]
	fdiv	fs:[si + spring_length]
	fstp	springforce

	push	si
	lea	si, tempvector
	fld	springforce
	fmul	SMALLAMOUNT
	fdiv	springlength
	call	scalevector
	fstp	tempreal
	pop	si
	
	fld	es:[di + vertex_vx]
	fadd	dword ptr [tempvector + vector_x]
	fstp	es:[di + vertex_vx]
	fld	es:[di + vertex_vy]
	fadd	dword ptr [tempvector + vector_y]
	fstp	es:[di + vertex_vy]
	fld	es:[di + vertex_vz]
	fadd	dword ptr [tempvector + vector_z]
	fstp	es:[di + vertex_vz]
	
	fld	es:[bx + vertex_vx]
	fsub	dword ptr [tempvector + vector_x]
	fstp	es:[bx + vertex_vx]
	fld	es:[bx + vertex_vy]
	fsub	dword ptr [tempvector + vector_y]
	fstp	es:[bx + vertex_vy]
	fld	es:[bx + vertex_vz]
	fsub	dword ptr [tempvector + vector_z]
	fstp	es:[bx + vertex_vz]
ret



;******************
;* updatevertex *
;******************
updatevertex:
	fld	dword ptr es:[di + vertex_x]
	fadd	dword ptr es:[di + vertex_vx]
	fstp	dword ptr es:[di + vertex_x]
	fld	dword ptr es:[di + vertex_y]
	fadd	dword ptr es:[di + vertex_vy]
	fstp	dword ptr es:[di + vertex_y]
	fld	dword ptr es:[di + vertex_z]
	fadd	dword ptr es:[di + vertex_vz]
	fstp	dword ptr es:[di + vertex_z]
	
	fld	dword ptr es:[di + vertex_vx]
	fmul	FRICTION
	fstp	dword ptr es:[di + vertex_vx]
	fld	dword ptr es:[di + vertex_vy]
	fmul	FRICTION
	fadd	GRAVITY
	fstp	dword ptr es:[di + vertex_vy]
	fld	dword ptr es:[di + vertex_vz]
	fmul	FRICTION
	fstp	dword ptr es:[di + vertex_vz]


	fldz
	fld	dword ptr es:[di + vertex_y]
	fcompp
	fstsw	ax
	wait
	sahf
	jnb	nofloorclamp
	fld	dword ptr es:[di + vertex_vx]
	fmul	CONST0_5
	fstp	dword ptr es:[di + vertex_vx]
	fld	dword ptr es:[di + vertex_vy]
	fmul	CONST0_5
	fstp	dword ptr es:[di + vertex_vy]
	fld	dword ptr es:[di + vertex_vz]
	fmul	CONST0_5
	fstp	dword ptr es:[di + vertex_vz]
	fldz
	fstp	dword ptr es:[di + vertex_y]
nofloorclamp:
ret



;******************
;* Calculatecloth *
;******************
calculatecloth:
	push	es

	mov	ax, vertices
	mov	es, ax


;Springs
	mov	ax, springs
	mov	fs, ax
	xor	si, si
	
	mov	cx, springcount
springupdateloop:
	
	mov	bx, fs:[si + spring_v1]
	mov	di, fs:[si + spring_v2]
	
	call	springupdate
	
	
	add	si, SPRINGSIZE
	loop	springupdateloop




	;Change smallamount
	cmp	framecounter, 400
	jb	nochangesmallamount
	fld	SMALLAMOUNT
	fmul	INTERPOL
	fld1
	fsub	INTERPOL
	fmul	SMALLAMOUNT2
	fadd
	fstp	SMALLAMOUNT
nochangesmallamount:

	
	;Lock vertices for introname
	mov	ax, clothvertices
	mov	es, ax

	cmp	framecounter, 500
	ja	skiptextlocks
	
	mov	ax, font
	mov	fs, ax
	lea	bx, introname


	xor	di, di
	
	mov	dx, clothheight
textgridzloop:

	mov	cx, clothwidth
textgridxloop:
	;Height of vertex
	mov	si, 56
	sub	si, cx
	;mov	si, cx
	shr	si, 3
	xor	ax, ax
	mov	al, [bx + si]
	mov	letter, ax ;ASCII-character of current letter

	shl	letter, 6 ;Memorypointer of current letter
	mov	si, 56
	sub	si, cx
	;mov	si, cx
	and	si, 7
	mov	charx, si

	;mov	si, 8
	;sub	si, dx
	mov	si, dx
	dec	si
	mov	chary, si
	shl	si, 3
	add	si, charx
	
	add	si, letter

	mov	al, fs:[si]
	;mov	ax, letter
	cmp	framecounter, 210
	jb	yeslock
	cmp	al, 0
	jz	nolock
yeslock:

	;fld1
	;fmul	CONST0_5
	;fmul	CONST0_5
	;fstp	es:[di + vertex_y]
	fldz
	fst	es:[di + vertex_vx]
	fst	es:[di + vertex_vy]
	fstp	es:[di + vertex_vz]

nolock:

	add	di, VERTEXSIZE
	
	loop	textgridxloop
	
	dec	dx
	jnz	textgridzloop
	
	jmp	locksdone
	
skiptextlocks:

	cmp	framecounter, 600
	ja	nolock2


	;jb	nochangegravity
	fld	GRAVITY
	fmul	INTERPOL2
	fld1
	fsub	INTERPOL2
	fmul	GRAVITY2
	fadd
	fstp	GRAVITY
	
	mov	di, CLOTHCENTER1
	fld1
	mov	tempint, 100
	fidiv	tempint
	fst	es:[di + vertex_vy]
	fchs
	fmul	CONST0_5
	fstp	es:[di + vertex_vx]

	mov	di, CLOTHCENTER2
	fld1
	mov	tempint, 100
	fidiv	tempint
	fstp	es:[di + vertex_vy]

	jmp	locksdone

nolock2:
	
	cmp	framecounter, 1300
	ja	locksdone

	mov	di, 0;CLOTHCENTER1
	fld1
	mov	tempint, 100
	fidiv	tempint
	fmul	CONST0_5
	;fmul	CONST0_5
	fst	es:[di + vertex_vy]
	fmul	CONST0_5
	mov	tempint, 6
	fimul	tempint
	;fmul	CONST4
	;fchs
	;fdiv	CONST0_5
	;fdiv	CONST0_5
	fst	es:[di + vertex_vx]
	fstp	es:[di + vertex_vz]

	
locksdone:


	;Vertices	
	xor	di, di
	mov	cx, vertexcount
updateverticesloop:

	call	updatevertex

	
	add	di, VERTEXSIZE
	loop	updateverticesloop
	


	pop	es	


	call	clothcamera
ret



;*************
;* Clothpart *
;*************
clothpart:
	mov	ax, oldclothcounter
        cmp	ax, framecounter
        jz	clothpart
        mov	cx, framecounter
	sub	cx, oldclothcounter
frameskip:
	push	cx

	call	calculatecloth

	pop	cx
	dec	cx
	jnz	frameskip

        mov	ax, framecounter
	mov	oldclothcounter, ax

	
	call	clearbuffer

	call	transformvertices

	call	drawfloor

	call	sorttriangles

	call	drawtriangles
	
	;mov	triy, 4000
	;mov	tempint, 30
	;fild	tempint
	;fstp	trix1
	;mov	tempint, 410
	;fild	tempint
	;fstp	trix2
	
	;call	trihline
ret
