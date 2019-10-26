;title:         LENSING
;version:       v1.02 (24.10.2004)
;category:      256b intro
;author:        Akos Fekete (alias: CHUT)
;country:       Hungary
;e-mail:        fekete.akos@freemail.hu
;compiler:      Flat Assembler 1.55
;assumed:       AX=0000 BX=0000 CX=00FF DX>0080
;               SI=0100 DI=FFFE BP=09xx SP=FFFE DF=0

		Org	0100h

stackAX 	EQU	bp+14
stackCX 	EQU	bp+12
stackDX 	EQU	bp+10
stackBX 	EQU	bp+8
stackBP 	EQU	bp+4
stackSI 	EQU	bp+2
SizeOfLens	EQU	48

LENSING:	mov	al,13h		;set video mode 320x256x8
		int	10h		;

GEN_PAL:	mov	dx,03C8h	;set palette
		mov	al,cl		;
		out	dx,al		;
		inc	dx		;
		out	dx,al		;
		shr	al,1		;
		out	dx,al		;
		shr	al,1		;
		out	dx,al		;
		loop	GEN_PAL 	;

		mov	ah,88h		;generate random number array
		mov	es,ax		;
		mov	fs,ax		;
BACKGROUND:	add	ax,cx		;
		aad	129		;
		stosb			;
		loop	BACKGROUND	;

		mov	cl,8		;make blur on the array
BLURonBGROUND:	mov	al,[es:di]	;
		add	al,[es:di+1]	;
		add	al,[es:di-128]	;
		aam	3		;
		xchg	al,ah		;
		stosb			;
		dec	bx		;
		jnz	BLURonBGROUND	;
		loop	BLURonBGROUND	;

		push	0A000h		;set video segment
		pop	es		;

MAIN_CYCLE:	xor	di,di		;top-left pixel in video memory

		mov	cl,200		;Y coordinate - counter
NEW_LINE:	mov	bx,320		;X coordinate - counter
NEW_PIXEL:	mov	bp,160		;
		add	bp,[LensX]	;get centre of lens
		mov	si,100		;
		add	si,[LensY]	;
		pusha			;
		mov	bp,sp		;
		fninit			;clear FPU stack
		fild	word [stackBX]	;
		fisub	word [stackBP]	;calculate distance of pixel
		fld	st0		;from lens centre
		fmul	st0,st0 	;
		fild	word [stackCX]	;
		fisub	word [stackSI]	;
		fld	st0		;
		fmul	st0,st0 	;
		fadd	st0,st2 	;  _______
		fsqrt			;\/a*a+b*b
		fist	word [stackAX]	;AX=distance from lens centre
		popa			;
		mov	dx,[LensD]	;
		add	dx,SizeOfLens+1 ;DX=diameter of lens
		cmp	ax,dx		;
		pushf			;
		jc	ZOOMED		;is the pixel under lens on not?
		push	ax		;
		sub	ax,dx		;
		pop	dx		;zoom factor = 1 (out of lens)
ZOOMED: 	pusha			;calculate absolut value of pixel(X,Y)
		mov	bp,sp		;
		fidiv	word [stackDX]	;calculte coordinates of sourcepoint
		fld	st0		;source = background
		fmul	st0,st4 	;
		fiadd	word [stackBP]	;
		fiadd	word [MapX]	;
		fistp	word [stackBP]	;
		fmulp			;
		fiadd	word [stackSI]	;
		fiadd	word [MapY]	;
		fistp	word [stackSI]	;
		popa			;
		xchg	ax,dx		;DX=Distace from lens centre - Diameter of lens
		shl	si,7		;calculate texture pixel position
		mov	al,[fs:si+bp]	;AL=texture pixel
		popf			;
		jc	DRAW_PIXEL	;
		shr	dx,1		;fade
		sub	al,dl		;
		jnc	DRAW_PIXEL	;
		mov	al,0		;
DRAW_PIXEL:	stosb			;pixel ready to draw
		dec	bx		;
		jnz	NEW_PIXEL	;
		loop	NEW_LINE	;

		mov	si,FI		;next angle position for moving
		inc	word [si]	;

		mov	cl,5		;refresh diameter and relative X,Y values
CALC_CENTRE:	lodsw			;
		fild	word [FI]	;
		fidiv	word [si-(MapX-MapXSpeed)]
		fsin			;
		fimul	word [si-(MapX-MapXMoving)]
		fistp	word [si]	;
		loop	CALC_CENTRE	;

		mov	dx,03DAh	;retracing - not important!
RETRACE:	in	al,dx		;
		test	al,08h		;
		je	RETRACE 	;

		in	al,60h		;check ESC key
		cbw			;
		dec	ax		;
		jnz	MAIN_CYCLE	;

		mov	al,03h		;set text mode
		int	10h		;
		ret			;

MapXSpeed	dw	100		;try to set these values to higher
MapYSpeed	dw	150		;if you use faster computer!
LensXSpeed	dw	100		;these values good for 1.5GHz
LensYSpeed	dw	150		;
LensDSpeed	dw	125		;
MapXMoving	dw	240		;these values specify the scrolled
MapYMoving	dw	240		;screen size. do not set it higher
LensXMoving	dw	80		;to 255, because it will cause some
LensYMoving	dw	80		;ugly pixel on the screen
Radius		dw	SizeOfLens	;
FI		dw	0		;

MapX		dw	?		;if you have any question on
MapY		dw	?		;this intro, send a mail to me!
LensX		dw	?		;
LensY		dw	?		;
LensD		dw	?		;