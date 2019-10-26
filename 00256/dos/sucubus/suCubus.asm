;  _   _   _   _
;  s u ( u b u s  this source code is written to be compiled by NASM
;  2 5 6 b y t e  http://www.web-sites.co.uk/nasm
;  i n t r o 2 K  my thanks goes to loveC for his invaluable hints and support
;  b a z e 3 S C  feel free to e-mail: baze@decef.elf.stuba.sk

[org 100h]
[segment .text]

	finit
	fldz
	mov	al,13h
	int	10h

	mov	cl,0
PAL	mov	al,cl
	mov	edx,0F65203C8h
	out	dx,al
	inc	dx
	shr	al,2
	out	dx,al
	shl	al,1
	out	dx,al
	mov	al,0
	out	dx,al
	loop	PAL

	mov	ax,cs
	add	ah,16
	mov	fs,ax
	add	ah,16
	mov	gs,ax

	mov	di,dx
CUBEG	sbb	ax,ax
	and	ax,112
	sub	ax,56
	stosw
	shr	edx,1
	jnz	CUBEG

MAIN	fadd	dword [ANGLE]

	mov	si,3C9h+2
	mov	cl,8*3
ROTATE	fld	st0
	fsincos
	fild	word [si]
	lodsw
	fld	st0
	fmul	st0,st2
	fild	word [si]
	lodsw
	lodsd
	mov	[si+64-8],ax
	fmul	st3,st0
	fmul	st0,st4
	fsubp	st1,st0
	fistp	word [si+64-6]
	fmulp	st2,st0
	faddp	st1,st0
	fistp	word [si+64-4]
	loop	ROTATE

	lea	di,[si+5]
	mov	al,0
	mov	cl,8
ZCOL	add	[di-1],byte 128
	add	al,85
	or	al,128
	mov	[di],al
	add	di,byte 8
	loop	ZCOL

	mov	bx,[si]
	mov	dx,[si+2]
	mov	ax,[si+4]

	mov	ch,10h		; change this to affect speed and quality
	bswap	ecx

CUBE	add	bp,cx
	ror	bp,cl
	push	bp
	and	bp,byte 111000b

	add	bx,[bp+si]
	sar	bx,1
	add	dx,[bp+si+2]
	sar	dx,1
	add	al,[bp+si+4]
	rcr	al,1
	add	ah,[bp+si+5]
	rcr	ah,1

	pop	bp
	imul	di,dx,320
	push	di
	add	di,160*320+100
	call	ZBUFF
	pop	di
	neg	di
	call	ZBUFF
	dec	ecx
	jnz	CUBE

	push	word 0A000h
	pop	es

	xor	di,di
BACK	add	si,cx
	rol	si,cl
	mov	bx,si
	sar	bx,12
	inc	bx
	add	ah,bl
	add	ah,[gs:di-320]
	shr	ah,1
	mov	al,[gs:di]
	mov	[fs:di],ah
	mov	[gs:di],ah
	stosb
	loop	BACK

	in	al,60h
	dec	al
	jnz	near MAIN
	mov	ax,3
	int	10h

ZBUFF	cmp	al,[fs:bx+di]
	jc	ZEND
	mov	[fs:bx+di],al
	mov	[gs:bx+di],ah
ZEND	ret

	db	23h,3Dh
ANGLE	equ	$-4
