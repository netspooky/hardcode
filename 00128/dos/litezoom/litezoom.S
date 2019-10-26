; vim: tabstop=8
; litezoom
; 128 byte intro by Kodest


; assuming si=0x100
	org	0x100

	push	0xa000
	pop	es

	mov	al, 0x13
	int	0x10

	inc	si
	inc	si

	fldl2t
	fidiv	word [si]
	fldz

frame:	xor	di, di

	fadd	st1
	fld	st0
	fsincos
	fimul	word [si]
	fistp	word [si+2]
	fimul	word [si]
	fiadd	word [si]
	fistp	word [si+4]

	xor	bx, bx
	xor	bp, bp

line:
	mov	cx, 320
	push	bx
	push	bp
pix:
	mov	ax, bp
	xor	ax, bx
	shr	ax, 15
	shl	al, 5
	dec	al
	jns	put
	es mov	al, [di]
	cmp	al, 16
	jle	put
	dec	al
put:	stosb
	or	di, di
	jz	framend
	add	bx, [si+2]
	add	bp, [si+4]
	loop	pix

	pop	bp
	pop	bx
	sub	bx, [si+4]
	add	bp, [si+2]

	jmp	line

framend:
	pop	ax
	pop	ax

	in	al, 0x60
	dec	al
	jnz	frame
	ret
