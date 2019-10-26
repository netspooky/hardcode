; Shaded donut in 256 bytes
; 22 Nov 1999, Mikael Kalms <mikael@kalms.org>
;
; A fellow named Fysx has apparently made a 256byte donut back in 1997.
; Cheers to him!
; Idea to clear & copy buffers simultaneously using a normal loop,
; rather than doing one operation at a time using REP <op> was
; 'borrowed' from his implementation (saved 4 bytes).
;
; The donut is generated at runtime using FPU sines/cosines. Rotation is
; also performed using FPU ops, and each pixel is plotted as a 2x2 block.
; 8bit Zbuffer is used for the depth sorting.
;
; The donut rotates around 2 axes (same rotation speed around both axes);
; having individual 3-axis rotation would take lots of space.
;
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
	; Set graphics mode (320x200x256)

		mov	al,13h
		int	10h	
		
	; Set palette (greyscale, 64 entries)

		xchg	ax,bx
		mov	dx,3c8h
		out	dx,al
		inc	dx
@@col:		out	dx,al
		out	dx,al
		out	dx,al
		inc	al
		jnz	@@col

@@main:
		mov	dx,cs		; Setup extrasegs
		add	dh,10h
		mov	es,dx		; 1) Screenbuffer
		add	dh,10h
		mov	fs,dx		; 2) Zbuffer

		mov	bx,offset bss

	;	ax	?
	;	bx	bss
	;	cx	0
	;	dx	?
	;	si	?
	;	di	?
	;	bp	0

	; Update rotation

		fld	d [bx+rot-bss]	; oldrot
		fadd	d [bx+rot+4-bss] ; rot
		fst	d [bx+rot-bss]	; rot
		fsincos			; rotcos  rotsin
		fstp	d [bx+rotcos-bss] ; rotsin
		fst	d [bx+rotsin-bss] ; rotsin

	
	; Draw mr. Donut

	; rotsin is used as initial value for b, as b's starting value
	; doesn't matter as long as it goes from x to x+2*PI

					; b

		mov	dx,DONUTSTEPSB
@@b:
		fld	st(0)		; b  b
		fsincos			; cosb  sinb  b
		fstp	d [bx+cosb-bss]	; sinb  b
		fst	d [bx+sinb-bss]	; sinb  b

	; sinb is used as initial value for a, as a's starting value
	; doesn't matter as long as it goes from x to x+2*PI

					; a  b
	
		mov	cl,DONUTSTEPSA
@@a:
		call	calcpoint	; Calculate one vertex/normal pair

		lodsw			; Fetch y
		xchg	di,ax
		imul	di,320
		lodsw			; Fetch x
		add	di,ax
		add	di,100*320+160	; Center of screen please
		dec	si
		lodsw			; Fetch z * 256 + junk
		mov	al,b [donutnormal+5] ; Fetch colour
		add	ax,0800ah	; Apply bias to z & colour

		call	dot2x2		; Buffer/draw 2x2 pixel block

		fadd	d [bx+donutinca-bss] ; a  b
		loop	@@a

		fstp	st(0)		; b
		fadd	d [bx+donutincb-bss] ; b
		dec	dx
		jnz	@@b	

		fstp	st(0)		;

	;	ax	?
	;	bx	bss
	;	cx	0
	;	dx	0
	;	si	?
	;	di	?
	;	bp	0
	
	; Copy screenbuffer to gfxmem, and clear screenbuffer & zbuffer
	
		push	ds

		push	es
		pop	ds
		push	0a000h
		pop	es
		mov	di,si		; Go through whole segment, no
@@copyclr:				; matter where we begin
		movsb
		mov	[si-1],dl
		mov	fs:[si],dl
		loop	@@copyclr
		
		pop	ds

	; Check for keypress

		mov	ah,1
		int	16h
		jz	@@main

	; Restore textmode
	
		mov	ax,3
		int	10h

	; Exit program

		ret


	; Draw 2x2 zbuffered pixels
	; in	al	colour
	;	ah	zbuffer value
	;	es:di	pixel

dot2x2:		call	@@y		; Two lines
		add	di,319
@@y:		call	@@x		; Two pixels per line
		inc	di
@@x:		cmp	ah,fs:[di]	; Zcompare
		jb	@@npixel1	; Hidden? if not, draw to buffers
		mov	fs:[di],ah
		stosb
		dec	di
@@npixel1:	ret


	; Calculate one vertex + corresponding normal
	; in	bx	bss
	; out	si	donutvertex

calcpoint:
		mov	si,offset donutscalevertex
		call	@@calcvtx	; First gen vertex, then gen normal
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
	
donutinca	dd	F_TWOPI - (F_EXPFACTOR * DONUTRESA)

rot		dd	0				; Rotation angle
rotinc		dd	F_TWOPI - (F_EXPFACTOR * 6)	; Rotation speed

donutscalevertex dd	F_1 + (F_EXPFACTOR * 4)		; Donut ring radius
		dd	F_1 + (F_EXPFACTOR * 5)		; Donut radius
donutscalenormal dd	F_1 + F_EXPFACTOR * 14 - 300000h ; Normal-length
donutincb	dd	F_TWOPI - (F_EXPFACTOR * DONUTRESB) ; Almost 0.0
donutvertex	dw	?,?,?,?		; Vertex/normal pair generated
donutnormal	dw	?,?,?,?		;  by calcpoint

bss:
rotcos		dd	?		; Temporaries used in
rotsin		dd	?		;  donut generation
cosb		dd	?
sinb		dd	?


		END	start
