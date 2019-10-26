;------------------------------------------------------------------------------
; INVU by MyCroft/Ignorance
;
; Release date 2004-06-11, version 1.0
;------------------------------------------------------------------------------
; Assemble with NASM - Netwide Assembler
; nasm -f bin invu.asm -o invu.com
;
; Many thanks to XKp for optimisation tips!
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
;
; To whom it concerns:
; f(p0) = 256sin((d(p0, p1) + d(p0, p2)))/k)cos((d(p0, p1) - d(p0, p2)))/k),
; where d is the distance operator, p1 and p2 are 2D points of 'attraction' and
; p0 is the point of intrest (k equals 16).
;
; Or, if you like: its a multiplicative interference function with moving
; 'standing waves'. You could also call it "sine distance madness".
;
; Data LUT is the way to do it! :)
;
;------------------------------------------------------------------------------

;------------------------------------------------------------------------------
; assumes on program entry:
; ax = 00xxh
; cx = 00FFh

[org 100h]
[segment .text]

;	push	si		; unf*ck win95/98 part I (see below)
	mov	al, 13h
	int	10h
	push	word 0A000h
	pop	es

;	mov	cl, 255
palette:			; butt-ugly, but functional...
	mov	dx, 3C8h
	mov	al, cl
	out	dx, al
	inc	dx
	cmp	al, 128
	jb	p1
	neg	al
	dec	ax		; why, oh why!?
p1:
	mov	bl, al
	sub	al, 64
	jnc	p2
	mov	al, 0
p2:
	out	dx, al
	mov	al, bl
	shr	al, 1
	out	dx, al
	mov	al, bl
	cmp	al, 64
	jb	p3
	mov	al, 63
p3:
	out	dx, al
	loop	palette

;	fninit			; finit
	mov	si, word data - 2
	mov	word [si], 64
	fild	word [si]
	mov	di, word data + 64000 - 1
	mov	cl, 200
data_y:
	mov	bp, 320
data_x:
	mov	word [si], bp
	fild	word [si]
	fmul	st0
	mov	word [si], cx
	fild	word [si]
	fmul	st0
	faddp	st1
	fsqrt
	fidiv	word [k]
	fsin
	fmul	st1
	fistp	word [si]
	mov	al, byte [si]
	mov	byte [di], al
	dec	di
	dec	bp
	jnz	data_x
	loop	data_y

	mov	byte [si], 50 + 64
	fldpi
	fild	word [si]
main:
	inc	word [si]
	fild	word [si]
	fdiv	st3
	fsincos
	fmul	st3
	fsincos
	fmul	st5
	fadd	st5
	fadd	st3
	fistp	word [si - 4]
	fmul	st4
	fadd	st2
	fist	word [si - 2]
	fistp	word [si - 8]
	fmul	st2
	fsin
	fmul	st3
	fadd	st1
	fistp	word [si - 6]

	xor	di, di
	mov	cl, 200
loop_y:
	mov	bp, 320
	mov	bx, 4
next_y:
	xor	ah, ah
	mov	al, cl
	sub	al, byte [si + bx - 10]
	jnc	skipneg1
	neg	al
skipneg1:
	mul	bp
	mov	word [si + bx - 14], ax
	sub	bx, 2
	jnz	next_y
loop_x:
	mov	bx, bp
	sub	bx, word [si - 4]
	jnc	skipneg2
	neg	bx
skipneg2:
	add	bx, word [si - 12]
	mov	al, byte [si + bx + 2]

	mov	bx, bp
	sub	bx, word [si - 2]
	jnc	skipneg3
	neg	bx
skipneg3:
	add	bx, word [si - 10]
	mov	ah, byte [si + bx + 2]

	mov	dl, al
	sub	dl, ah
	add	al, ah
	imul	dl
	sar	ax, 4 		; 3, 4 or 5 ... try it out!
	add	al, byte [si]	; the oldest effect in the world!

	stosb

	dec	bp
	jnz	loop_x
	loop	loop_y

	mov	dx, 3DAh
vsync:
	in	al, dx
	and	al, 8
	jz	vsync		; flimmerfri!

	in	al, 60h
	dec	al
	jne	main

	mov	al, 03h
	int	10h
;	pop	si		; unfu*k win95/98 (part II)
	ret
	db	'XKp'

k	dw	16		; edit "thickness"

data	equ	$ + 10h

;------------------------------------------------------------------------------
; EOF
