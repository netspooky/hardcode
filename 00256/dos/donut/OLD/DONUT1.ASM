; Shaded donut in 339 bytes (final version is 256 bytes)
; 17 Oct 1999, Mikael Kalms <mikael@kalms.org>
;
; Readable version. The donut and its normals is generated at runtime
; using FPU sines/cosines, and is drawn by plotting 2x2 pixel blocks.
; Larger donut therefore requires more iterations.
; Hidden-surface-removal is performed by buffering on colour values
; purely (and therefore it looks a bit weird).
; The donut is rotated around 2 axes (independent rotation speeds).
; Assembles with NASM.
; (Notice how the same code is used to calculate the vectors and the normals!)

	; Various useful floating-point constants
		
F_65536		EQU	4f800000h
F_256		EQU	48800000h
F_1		EQU	3f800000h
F_OO256		EQU	37800000h
F_OO65536	EQU	2f800000h
F_PI		EQU	40490fdbh
F_TWOPI		EQU	40c90fdbh
F_EXPFACTOR	EQU	00800000h
	
DONUTRESA	EQU	6	; log2 of "number of vertices per ring"
DONUTRESB	EQU	8	; log2 of "number of rings"
DONUTSTEPSA	EQU	(1 << DONUTRESA)
DONUTSTEPSB	EQU	(1 << DONUTRESB)

		struc	DonutScale
.scalea		resd	1
.scaleb		resd	1
		endstruc
		
%define b byte
%define w word
%define d dword


		bits	16

		section	.text
	
		org	100h

start:
		mov	ax,13h
		int	10h	

	; Set palette
	
		xor	ax,ax
		mov	dx,3c8h
		out	dx,al
		inc	dx
.col		out	dx,al
		out	dx,al
		out	dx,al
		adc	ax,4000h
		cmp	al,0ffh
		jnz	.col
		
		
		mov	ax,cs
		add	ax,1000h
		mov	es,ax

.main
	; Update rotation

		lea	si,[rotx]
		lea	di,[rotparms_x]
		call	.updaterot
		lea	si,[rotz]
		lea	di,[rotparms_z]
		call	.updaterot

	; Clear vscreen
	
		xor	ax,ax
		xor	di,di
		mov	cx,32000
		rep	stosw

	; Draw mr. Donut

		call	drawdonut

	; Copy vscreen to gfxmem
	
		push	ds
		push	es

		pop	ds
		push	ds
		push	w 0a000h
		pop	es
		mov	cx,16000
		xor	si,si
		xor	di,di
		rep	movsd

		pop	es
		pop	ds

	; Check for keypress
		
		mov	ah,1
		int	16h
		jz	.main
	
		xor	ax,ax
		int	16h
		
		mov	ax,3
		int	10h
				
		ret

	; Step rotation, and calculate sine/cosine for the new angle
	; in	si	rot, rotinc
	;	di	rotcos, rotsin

.updaterot:
		fld	d [si]		; oldrot
		fadd	d [si+4]	; rot
		fst	d [si]		; rot
		fsincos			; rotcos  rotsin
		fstp	d [di]		; rotsin
		fstp	d [di+4]	;
		ret
	
drawdonut:
		fldz			; b
		mov	dx,DONUTSTEPSB
.b:
		fld	st0		; b  b
		fsincos			; cosb  sinb  b
		fstp	d [cosb]	; sinb  b
		fstp	d [sinb]	; b
	
		fldz			; a  b

		mov	cx,DONUTSTEPSA
.a:
		lea	si,[donutscalevertex]
		lea	di,[donutvertex]
		call	.calcpoint
		lea	si,[donutscalenormal]
		lea	di,[donutnormal]
		call	.calcpoint

		mov	al,[donutnormal+5]
		or	al,al
		js	.npixel
		mov	bx,[donutvertex+2]
		imul	bx,320
		add	bx,[donutvertex]
		add	bx,100*320+160

		call	.twodots
		add	bx,319
		call	.twodots
.npixel:
		fadd	d [donutinca]	; a  b
		loop	.a

		fstp	st0		; b
		fadd	d [donutincb]	; b
		dec	dx
		jnz	.b

		fstp	st0		;
	
		ret


	; Draw two pixels, with colour = max(newpixel, oldpixel)
	; in	al	colour
	;	es:bx	pixel

.twodots:
		call	.blah
		inc	bx
.blah:		cmp	al,[es:bx]
		jbe	.npixel1
		mov	[es:bx],al
.npixel1:	ret

	; Calculate one vertex or one normal
	; in	si	scalefactors
	;	di	output vertex (words)

.calcpoint
		fld	st0		; a  a  b
		fsincos			; cosa  sina  a  b
		fld	d [si+DonutScale.scalea] ; scalea  cosa  sina  a  b
		fmul	st1,st0		; scalea  x0  sina  a  b 
		fmulp	st2,st0		; x0  y0  a  b

		fadd	d [si+DonutScale.scaleb] ; x1  y0  a  b

		fld	st0		; x1  x1  y0  a  b
		fmul	d [sinb]	; z2  x1  y0  a  b
		fxch	st0,st1		; x1  z2  y0  a  b
		fmul	d [cosb]	; x2  z2  y0  a  b

		fxch	st0,st2		; y0  z2  x2  a  b
		lea	bx,[rotparms_x]
		call	rot2d		; y3  z3  x2  a  b
		fxch	st0,st1		; z3  y3  x2  a  b
		fxch	st0,st2		; x2  y3  z3  a  b
		lea	bx,[rotparms_z]
		call	rot2d		; x4  y4  z3  a  b
	
		fistp	w [di]		; y4  z3  a  b
		fistp	w [di+2]	; z3  a  b
		fistp	w [di+4]	; a  b
		ret

	; Standard 2d rotation
	; in	bx	rotparms
	;	st0	x0	
	;	st1	y0
	; out	st0	x
	;	sti	y
	
rot2d:					; x0  y0
		fld	st0		; x0  x0  y0
		fmul	d [bx]		; cos*x0  x0  y0
		fld	st2		; y0  cos*x0  x0  y0
		fmul	d [bx+4]	; sin*y0  cos*x0  x0  y0
		fxch	st0,st2		; x0  cos*x0  sin*y0  y0
		fmul	d [bx+4]	; sin*x0  cos*x0  sin*y0  y0
		fxch	st0,st3		; y0  cos*x0  sin*y0  sin*x0
		fmul	d [bx]		; cos*y0  cos*x0  sin*y0  sin*x0
		faddp	st3,st0		; cos*x0  sin*y0  y
		fsubrp	st1,st0		; x  y
		ret
					
donutinca	dd	F_TWOPI - (F_EXPFACTOR * DONUTRESA)
donutincb	dd	F_TWOPI - (F_EXPFACTOR * DONUTRESB)

donutscalevertex:
		dd	F_1 + (F_EXPFACTOR * 4)		; Ring radius
		dd	F_1 + (F_EXPFACTOR * 5)		; Donut radius

donutscalenormal:
		dd	F_1 + F_EXPFACTOR * 14		; Normal-length
		dd	0
	
rotx		dd	0
rotxinc		dd	F_TWOPI - (F_EXPFACTOR * 6)	; xrot speed
rotz		dd	0
rotzinc		dd	F_TWOPI - (F_EXPFACTOR * 5) - 90000h ; zrot speed

		section	.bss
	
cosb		resd	1
sinb		resd	1

rotparms_x	resd	2
rotparms_z	resd	2

donutvertex	resw	3
donutnormal	resw	3
