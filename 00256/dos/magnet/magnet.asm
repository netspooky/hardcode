; a little magnetic field effect with 3D
; rotation and some sierpinski triangle stuff
;
; by INT-E <int-e@gmx.de>
;
; thanks:
;   to the dosemu folks
;
; usage: nasm magnet.asm -o magnet.com

	bits	16
	org	100h

; ax = 0000
; bx = 0000
; cx = 00FF
; dx = cs = ds = es
; si = 0100
; di = FFFE = sp
; bp = 09xx

s:	mov	al, 13h
	int	10h

	push	0A000h
	pop	es

	mov	cl, 17
	mov	bl, 100

	lodsw
il:	xor	bl, 100^3
	lodsw
	mul	bx
	inc	dx
	push	dx
	loop	il

pl:	mov	dx, 3C8h
	out	dx, al
	inc	dx
ppl:	push	ax
	sub	al, cl
	jc	psk1
	cmp	al, 40h
	jc	psk2
psk1:	cmc
	salc
psk2:	out	dx, al
	pop	ax
	sub	cl, 40h
	jnc	ppl
	inc	ax
	jg	pl

	push	cx				; 192

ml:	mov	si, sp
	xor	di, di
	mov	cl, 100
	push	cx
yl:	push	cx
	fninit
	fild	dword [si+8*4+2]		; c
	fidiv	word [si]			; c/192
	fsincos	     				; cos sin
	fdiv	st1, st0			; cos tan

	fild	word [si-4]			; y cos tan

	fdivr	st1, st0			; y y/cos tan
	fmul	st2				; y*tan y/cos tan
	fisubr	word [si]			; 192S y/cos tan

	fst	dword [si+8*4+6]

	fidivr	word [si]			; 1/S y/cos tan
	fmul	st1, st0
	fstp	st2

	fld	st0
	fabs
	fisubr	word [si-2]
	fistp	word [si+8*4+6]

	mov	cx, 160
	push	cx
xl:	pusha

; stack: (highest addresses first)
;       c
;	X4
;	DX4
;	Y4
;	DY4
; ...
;	X1
;	DX1
;	Y1
;	DY1
; si:	192
;	100
;	Y
;	160
;	[AX]
;	X
;	[DX]
;	[BX]
;	[SP]
;	[BP]
;	[SI]
; sp:	[DI]

	fldz				; 0 y f
	fldz				; 0 0 y f

z:	fild	word [si-10]		; x s1 s2 y f
	fmul	st0, st4
	fld	st0
	fabs
	fisubr	word [si-6]
	fistp	word [si-18]		; will be BP
	fisub	word [si+bx+1]		; dx s1 s2 y f
	fld	st0  			; dx dx s1 s2 y f
	fmul	st1, st0		; dx dx^2 s1 s2 y f
	fld	st4			; y dx dx^2 s1 s2 y f
	fisub	word [si+bx+5]		; dy dx dx^2 s1 s2 y f
	fld	st0  			; dy dy dx dx^2 s1 s2 y f
	fmul	st0, st0		; dy^2 dy dx dx^2 s1 s2 y f
	faddp	st3, st0		; dy dx dx^2+dy^2 s1 s2 y f
	fpatan	     			; phi dx^2+dy^2 s1 s2 y f
	fsubrp	st2, st0		; dx^2+dy^2 s1' s2 y f
	fsqrt	     			; d s1' s2 y f
	fsubrp	st2, st0		; s1' s2' y f
	add	bx, byte 8
	jpo	z

	fldpi				; pi s1 s2 y f
	fdivp	st1, st0		; s1/pi s2 y f
	fimul	word [si]		; 192s1/pi s2 y f
	fistp	word [si-12]		; will be DX
	fistp	word [si-8]		; will be AX
	popa

	cmp  	byte [si+8*4+9], bh
	js	ccl
	or	bp, [si+8*4+6]
	jns	sk
	inc	bp
	inc	bp
	js	ccl
sk:
	cbw
	xor	ah, al

	mov	al, dl
	sub	al, 19
	xor	al, dl

	add	al, ah
	jnc	sk2
ccl:	salc
sk2:

	stosb

	dec	cx
	pop	ax
	push	ax
	add	ax, cx
	jnz	xl
	pop	bp

	pop	cx

	dec	cx
	pop	ax
	push	ax
	add	ax, cx
	jnz	yl
	pop	di

	inc	dword [si+8*4+2]

	lodsw
rl:	lodsw
	add	[si], ax
	lodsw
	cwd
	xor	ax, dx
	cmp	ax, bp
	jb	nr
	neg	word [si-4]
nr:	xchg	di, bp
	shr	ch, 1
	jnz	rl

	mov	ah, 1
	int	16h
	jz	ml

	xchg	ax, bx
	int	10h
	int	20h
	db	"INT-E"
