; #coder's 256 byte fire compo entry
; 'Sol' by Toby Hutton (c) May 1996

;-------------------------------------------------------------------------------------------------
	.model	tiny				; .com file

	.386					; requires 386+ processor
	.387					; and a math co-pro or FPU

	.code

	org	0100h

; ----------------------------------------------------------------------------------
RADIUS		equ	030h
FWIDTH		equ	01c0h

start:
		mov	ax,013h			; set vga mode 13h
		int	010h

	; ----- initialise fire palette -----

		mov	dx,03c8h
		sub	al,al
		out	dx,al			; set vga palette is coming

		inc	dx

		mov	cl,07fh			; set 80h colours
pal1:
		mov	al,bl
		shr	al,1
		out	dx,al			; red

		shr	al,5
		add	bh,al
		mov	al,bh
		out	dx,al			; green

		xor	al,al
		out	dx,al
		inc	bl			; blue

		loop	pal1

		mov	cl,080h
		mov	al,63
pal2:
		out	dx,al
		out	dx,al
		out	dx,al
		loop	pal2

	; ----- generate circular map lookup table -----

		mov	di,offset circle_buf

		fninit				; initialise FPU

;		fldpi
;		fild	width_on_2
;		fdivp	st(1),st
;		fstp	increment		; determine increment

		fldz				; 0=3Dtheta ( =3D 0)
table1:
		mov	cx,FWIDTH
table2:
		fld	st			; 0=3Dtheta,1=3Dtheta
		fsin				; 0=3Dsin(theta)
		fimul	r			; 0=3Dsin(theta)*radius
		fistp	result

		mov	ax,320
		mul	result

		fld	st			; 0=3Dtheta
		fcos				; 0=3Dcos(theta)
		fimul	r			; 0=3Dcos(theta)*radius
		fistp	result

		fadd	increment		; 0=3Dtheta+increment

		add	ax,result
		add	ax,32160
		stosw

		loop	table2

		dec	r
		jnz	table1

	; ----- flip the fire buffer to the screen -----

flip1:
		push	0a000h
		pop	es

;		mov	cx,256
;		sub	di,di
;temp1:
;		mov	ax,di
;		stosb
;		loop	temp1			; draws the palette on the top

		mov	si,offset fire_buf+FWIDTH
		mov	bx,offset circle_buf+FWIDTH*2

		mov	cx,FWIDTH*(RADIUS-1)	; total pixels
flip2:
		lodsb				; get colour from fire buffer
		mov	di,cs:[bx]		; get circular offset
		stosb				; put the colour on screen
		inc	bx
		inc	bx			; (smaller than add bx,2)
		loop	flip2
		mov	byte ptr es:[32160],07fh

	; ----- generate the fire -----

fire:
		push	ds
		pop	es

		mov	di,offset fire_buf
		mov	si,offset fire_buf+FWIDTH
		mov	cx,RADIUS			; <--- was cx
smooth2:
		push	cx
		mov	cx,FWIDTH
smooth1:
		sub	ax,ax
		sub	bx,bx

		lodsb
		add	bx,ax
		lodsb
		add	bx,ax
		lodsb
		add	bx,ax
		mov	al,[si+FWIDTH-2]
		add	bx,ax
		shr	bx,2
		mov	al,bl
		cmp	al,4
		jl	next1
		sub	al,4
next1:
		stosb
		dec	si
		dec	si
		loop	smooth1

		pop	cx
		loop	smooth2

	; ---- put random values at bottom of fire ----

		mov	cx,FWIDTH
random:
		in	al,040h
		mov	bl,rand
		inc	bl
		imul	bl
		shr	ax,4
		mov	rand,al
		and	al,1
		shl	al,7
		add	al,040h
		mov	bx,cx
		mov	byte ptr fire_buf[bx+FWIDTH*(RADIUS)],al
		loop	random


	; ----- write the string to screen ----

;		mov	ax,01300h
;		mov	bx,040h
;		mov	cl,3
;		mov	dx,01413h
;		mov	bp,offset sol
;		int	010h

	; ----- check for any keypress -----

kb_hit:
		mov	ah,1
		int	016h
		jz	flip1

		mov	ax,3
		int	010h

		ret

;------------------------------------------------------------------------------------------------------------------------ 
increment	dd	03c65c8fah		; 2=83/WIDTH in floating point
;width_on_2	dw	FWIDTH/2		; needed to calc. increment

;sol		db	"sol"

r		dw	RADIUS
theta		dw	0
result		dw	0

rand		db	32

fire_buf	db	FWIDTH*RADIUS dup (?)
circle_buf	db	FWIDTH*RADIUS*2 dup (?)

; -------------------------------------------------------------------------------------------------------------------------
	end	start

;===================================================================