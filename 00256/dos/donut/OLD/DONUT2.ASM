; Shaded donut in 256 bytes
; 17 Oct 1999, Mikael Kalms <mikael@kalms.org>
;
; Unreadable, booby-trapped version which is exactly at the 256byte limit.
; The donut rotates around 2 axes (same rotation speed around both axes).
; Assembles with TASM.

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
DONUTSTEPSA	EQU	(1 SHL DONUTRESA)
DONUTSTEPSB	EQU	(1 SHL DONUTRESB)

b		EQU	byte ptr
w		EQU	word ptr
d		EQU	dword ptr


		LOCALS	@@
		.MODEL	TINY
		.CODE
		.386

		ORG	100h
start:
		mov	ax,13h
		int	10h	
		
@@main:
		mov	ax,cs
		add	ax,1000h
		mov	es,ax

		mov	bx,offset bss

	; Update rotation

		fld	d [bx+rot-bss]	; oldrot
		fadd	d [bx+rot+4-bss] ; rot
		fst	d [bx+rot-bss]	; rot
		fsincos			; rotcos  rotsin
		fstp	d [bx+rotcos-bss] ; rotsin
		fstp	d [bx+rotsin-bss] ;

	; Set palette

		xor	ax,ax
		mov	dx,3c8h
		out	dx,al
		inc	dx
@@col:		out	dx,al
		out	dx,al
		out	dx,al
		inc	al
		jnz	@@col

	; Clear vscreen

		mov	cx,65535
		rep	stosb

	; Draw mr. Donut

		fldz			; b
		mov	dx,DONUTSTEPSB
@@b:
		fld	st(0)		; b  b
		fsincos			; cosb  sinb  b
		fstp	d [bx+cosb-bss]	; sinb  b
		fstp	d [bx+sinb-bss]	; b

		fldz			; a  b

		mov	cl,DONUTSTEPSA
@@a:
		call	@@calcpoint

		lodsw
		xchg	di,ax
		imul	di,320
		lodsw
		add	di,ax
		add	di,100*320+160
		mov	al,b [donutnormal+5]

		call	@@dot2x2

		fadd	d [bx+donutinca-bss] ; a  b
		loop	@@a

		fstp	st(0)		; b
		fadd	d [bx+donutincb-bss] ; b
		dec	dx
		jnz	@@b	


		fstp	st(0)		;

	; Copy vscreen to gfxmem
	
		push	ds

		push	es
		pop	ds
		push	0a000h
		pop	es
		mov	cx,16384
		mov	di,si
		rep	movsd

		pop	ds

	; Check for keypress

		mov	ah,1
		int	16h
		jz	@@main
	
		mov	ax,3
		int	10h
				
		ret


	; Draw 2x2 pixels, with colour = max(oldcolor, newcolour)
	; in	al	colour
	;	es:di	pixel

@@dot2x2:	call	@@y
		add	di,319
@@y:		call	@@x
		inc	di
@@x:		cmp	al,es:[di]
		jle	@@npixel1
		mov	es:[di],al
@@npixel1:	ret


	; Calculate one vertex + corresponding normal
	; in	bx	bss
	; out	si	donutvertex

@@calcpoint:
		mov	si,offset donutscalevertex
		call	@@calcvtx
@@calcvtx:
		fld	st(0)		; a  a  b
		fsincos			; cosa  sina  a  b
		fmul	d [si]		; x0  sina  a  b

		fadd	d [si+4]	; x1  sina  a  b

		fld	st(0)		; x1  x1  sina  a  b
		fmul	d [bx+sinb-bss]	; z2  x1  sina  a  b
		fxch	st(1)		; x1  z2  sina  a  b
		fmul	d [bx+cosb-bss]	; x2  z2  sina  a  b

		fxch	st(2)		; sina  z2  x2  a  b
		fmul	d [si]		; y0  z2  x2  a  b
		call	rot2d		; z3  y3  x2  a  b
		fxch	st(2)		; x2  y3  z3  a  b
		call	rot2d		; y4  x4  z3  a  b

		fistp	w [si+16+2]	; x4  z3  a  b
		fistp	w [si+16]	; z3  a  b
		fistp	w [si+16+4]	; a  b
		add	si,8
		ret

	; Standard 2d rotation
	; in	bx	bss
	;	st0	x0	
	;	st1	y0
	; out	st0	y
	;	st1	x
rot2d:					; x0  y0
		fld	st(1)		; y0  x0  y0
		fmul	d [bx+rotcos-bss] ; cos*y0  x0  y0
		fld	st(1)		; x0  cos*y0  x0  y0
		fmul	d [bx+rotcos-bss] ; cos*x0  cos*y0  x0  y0
		fld	d [bx+rotsin-bss] ; sin  cos*x0  cos*y0  x0  y0
		fmul	st(3),st(0)	; sin  cos*x0  cos*y0  sin*x0  y0
		fmulp	st(4),st(0)	; cos*x0  cos*y0  sin*x0  sin*y0
		fsubrp	st(3),st(0)	; cos*y0  sin*x0  cos*x0-sin*y0
		faddp	st(1),st(0)	; sin*x0+cos*y0  cos*x0-sin*y0
		ret
	
		ALIGN	4	; Alignment needed for the movsd-copy
				; in mainloop

donutinca	dd	F_TWOPI - (F_EXPFACTOR * DONUTRESA)
donutincb	dd	F_TWOPI - (F_EXPFACTOR * DONUTRESB)
	
rot		dd	0
rotinc		dd	F_TWOPI - (F_EXPFACTOR * 6)	; Rotation speed

donutscalevertex dd	F_1 + (F_EXPFACTOR * 4)		; Donut ring radius
		dd	F_1 + (F_EXPFACTOR * 5)		; Donut radius
donutscalenormal dd	F_1 + F_EXPFACTOR * 14 - 20000h	; Normal-length
		dd	0
donutvertex	dw	?,?,?,?
donutnormal	dw	?,?,?,?

bss:
rotcos		dd	?
rotsin		dd	?
cosb		dd	?
sinb		dd	?


		END	start

