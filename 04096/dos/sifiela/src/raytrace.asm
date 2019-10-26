;************
;* raytrace *
;************
raytrace:
	fldz
	fld	[raycurrent + 1*4]
	fcompp
	fstsw	ax
	wait
	sahf
	mov	ax, 0
	jnb	nofloor
	
	fld	[origin + 1*4]
	fdiv	[raycurrent + 1*4]
	fchs
	fstp	tempreal

	fld	tempreal
	fmul	[raycurrent + 0*4]
	fadd	[origin + 0*4]
	mov	tempint, 20;50
	fimul	tempint
	mov	tempint, 639
	call	fsmod
	fst	btx
	fistp	tx
	cmp	tx, 320
	jb	nomirrorx
	mov	tempint, 639
	fild	tempint
	fsub	btx
	fst	btx
	fistp	tx
	;mov	ax, 639
	;sub	ax, tx
	;mov	tx, ax
nomirrorx:
	
	fld	tempreal
	fmul	[raycurrent + 2*4]
	fadd	[origin + 2*4]
	mov	tempint, 20;50
	fimul	tempint
	mov	tempint, 399
	call	fsmod
	fst	bty
	fistp	ty
	cmp	ty, 200
	jb	nomirrory
	mov	tempint, 399
	fild	tempint
	fsub	bty
	fst	bty
	fistp	ty
	;mov	ax, 399
	;sub	ax, ty
	;mov	ty, ax
nomirrory:
	
	call	getbilinearpixel
	
;	mov	bx, ax
;	and	bx, 192
;	and	ax, 63
	mov	tempint, ax
	fild	tempint
	;fld1
	;mov	tempint, 63
	;fild	tempint
	fld	tempreal
	;fchs
	mov	tempint, 5
	fidiv	tempint
	fld1
	fadd
	fdiv
	fistp	tempint
	mov	ax, tempint
	;add	ax, bx
	;add	ax, 192
nofloor:
ret



;*************
;* drawfloor *
;*************
drawfloor:
	mov	fs, mandelbuffer1

	lea	si, raycorners
	fld	rayleft
	fst	dword ptr [si+0*4]
	fstp	dword ptr [si+6*4]
	fld	raytop
	fst	dword ptr [si+1*4]
	fstp	dword ptr [si+4*4]
	fld	rayright
	fstp	dword ptr [si+3*4]
	fld	raybottom
	fstp	dword ptr [si+7*4]
	fld1
	fst	dword ptr [si+2*4]
	fst	dword ptr [si+5*4]
	fstp	dword ptr [si+8*4]

	lea	si, cameramatrix
	lea	di, raycorners
	add	di, 0*4
	call	rotatepoint
	lea	di, raycorners
	add	di, 3*4
	call	rotatepoint
	lea	di, raycorners
	add	di, 6*4
	call	rotatepoint


	lea	si, raycorners
	;x
	fld	dword ptr [si+3*4]
	fld	dword ptr [si+0*4]
	fsubp
	fild	SCREENWIDTH
	fdivp
	fstp	raydeltax+0*4
	;y
	fld	dword ptr [si+4*4]
	fld	dword ptr [si+1*4]
	fsubp
	fild	SCREENWIDTH
	fdivp
	fstp	raydeltax+1*4
	;z
	fld	dword ptr [si+5*4]
	fld	dword ptr [si+2*4]
	fsubp
	fild	SCREENWIDTH
	fdivp
	fstp	raydeltax+2*4


	;x
	fld	dword ptr [si+6*4]
	fld	dword ptr [si+0*4]
	fsubp
	fild	SCREENHEIGHT
	fdivp
	fstp	raydeltay+0*4
	;y
	fld	dword ptr [si+7*4]
	fld	dword ptr [si+1*4]
	fsubp
	fild	SCREENHEIGHT
	fdivp
	fstp	raydeltay+1*4
	;z
	fld	dword ptr [si+8*4]
	fld	dword ptr [si+2*4]
	fsubp
	fild	SCREENHEIGHT
	fdivp
	fstp	raydeltay+2*4

	mov	eax,dword ptr [raycorners+0*4]
	mov	[rayleftside+0*4],eax
	mov	eax,dword ptr [raycorners+1*4]
	mov	[rayleftside+1*4],eax
	mov	eax,dword ptr [raycorners+2*4]
	mov	[rayleftside+2*4],eax

	xor	di,di
	mov	dx,SCREENHEIGHT


drawyloop:
	mov	eax,[rayleftside+0*4]
	mov	[rayshoot+0*4],eax
	mov	eax,[rayleftside+1*4]
	mov	[rayshoot+1*4],eax
	mov	eax,[rayleftside+2*4]
	mov	[rayshoot+2*4],eax
	mov	cx,SCREENWIDTH
drawxloop:

	mov	eax,[rayshoot+0*4]
	mov	[raycurrent+0*4],eax
	mov	eax,[rayshoot+1*4]
	mov	[raycurrent+1*4],eax
	mov	eax,[rayshoot+2*4]
	mov	[raycurrent+2*4],eax

	lea	si,raycurrent

	call	normalizep

	fld	dword ptr [camerapos + vector_x]
	fstp	[origin+0*4]
	fld	dword ptr [camerapos + vector_y]
	fstp	[origin+1*4]
	fld	dword ptr [camerapos + vector_z]
	fstp	[origin+2*4]

	call	raytrace

;	fld [color+2*4]
;	fmul REAL31
;	fistp bytecolor
;	mov ax,bytecolor
;
;	fld [color+1*4]
;	fmul REAL63
;	fistp bytecolor
;	shl bytecolor,5
;	add ax,bytecolor
;
;	fld [color+0*4]
;	fmul REAL31
;	fistp bytecolor
;	shl bytecolor,11
;	add ax,bytecolor
;

	;fld	raycurrent
	;fld1
	;fadd
	;fmul	CONST63
	;fistp	tempint
	;mov	ax, tempint
	stosb

	fld rayshoot+0*4
	fadd raydeltax+0*4
	fstp rayshoot+0*4
	fld rayshoot+1*4
	fadd raydeltax+1*4
	fstp rayshoot+1*4
	fld rayshoot+2*4
	fadd raydeltax+2*4
	fstp rayshoot+2*4



	dec	cx
	jnz	drawxloop


	fld	rayleftside+0*4
	fadd	raydeltay+0*4
	fstp	rayleftside+0*4
	fld	rayleftside+1*4
	fadd	raydeltay+1*4
	fstp	rayleftside+1*4
	fld	rayleftside+2*4
	fadd	raydeltay+2*4
	fstp	rayleftside+2*4


	dec dx
	jnz drawyloop
ret
