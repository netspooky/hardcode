;#########################################################################
.386
.model tiny
locals @@
jumps
;#########################################################################
CODESEG
.Startup
	; switch to graphics mode
	mov	al, 013h
	int	10h

	; initialize the distance table
	push	cs
	pop	es
	mov	di, OFFSET dist
	mov	bx, 200
@@dsty:	mov	cx, 320
	@@dstx:	mov	[x], cx
		mov	[y], bx
		sub	[x], 160
		sub	[y], 100
		fild	[x]
		fild	[x]
		fmul
		fild	[y]
		fild	[y]
		fmul
		fadd
		fsqrt
		fistp	[x]
		mov	ax, [x]
		stosb
		loop	short @@dstx
	dec	bx
	jnz	short @@dsty

	; initialize the palette
	mov	cx, 256
	xor	ax, ax
@@spal:	mov	dx, 3C8h
	out	dx, al
	inc	dx
	out	dx, al
	out	dx, al
	out	dx, al
	inc	al
	loop	short @@spal

	; main loop
@@main:	; wait for vertical sync
	mov	dx, 3DAh
@@vs0:	in	al, dx
	test	al, 8
	jz	short @@vs0
@@vs1:	in	al, dx
	test	al, 8
	jnz	short @@vs1

	; draw
	push	0A000h
	pop	es
	mov	bx, 200
	mov	si, OFFSET dist
	xor	di, di
	xor	ax, ax
@@y:	mov	cx, 320
	@@x:	lodsb
		mov	[x], ax
		fild	[x]
		fdiv	[freq]
		fild	[counter]
		fsub
		fsin
		fmul	[amp]
		fadd	[amp]
		fistp	[x]
		mov	ax, [x]
		stosb
		loop	short @@x
	dec	bx
	jnz	short @@y

	inc	[counter]
	; delay
	push	cs
	push	040h
	pop	ds
	mov	ax, [ds:6Ch]
@@wait:	mov	cx, [ds:6Ch]
	sub	cx, ax
	cmp	cx, 2
	jl	@@wait
	pop	ds
	; check for key press
	mov	ah, 001h
	int	16h
	jz	short @@main

	; restore text mode
	mov	ax, 003h
	int	10h

	mov	dx, OFFSET info
	mov	ah, 9
	int	21h

	mov	ax, 4C00h
	int	21h
	ret
;#########################################################################
	counter	dw	0
	freq	real4	10.0
	amp	real4	31.0
	x	dw	0
	y	dw	0
	info	db	"1kb", 13, 10, "coded by comrade in 20 minutes", 13, 10, "DOS sucks", 13, 10, "comrade2k@hotmail.com", 13, 10, 13, 10, "I am off to pass fliers for my volunteer hours...$"
	junk	db	1024-343 dup (0)
	dist	db	320*200 dup (?)
;#########################################################################
;#########################################################################
end