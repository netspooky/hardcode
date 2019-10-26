
;  || _ _   ||__ __   by baze of ||| (www.3sc.sk) 2003 a.d.
;  ||/.| \ /.|. ) _)  thanks to damian trebilco at cgshaders.com
;  |(__||_(__|_/||    who i got inspired from

; final version
; better palette and texture, sets back text mode, works faster on athlons

[org 256]

	mov	al,13h
	int	10h

	mov	ax,cs
	add	ah,10h
	mov	es,ax
	add	ah,10h
	mov	fs,ax

	xor	cx,cx
PALETTE	mov	dx,3C8h
	mov	al,cl
	out	dx,al
	inc	dx
	mul	al
	shr	ax,5
	cmp	al,64
	jc	CLAMP1
	mov	al,63
CLAMP1	out	dx,al
	cmp	cl,64
	cmc
	salc
	or	al,cl
CLAMP2	out	dx,al
	shr	al,1
	out	dx,al
	stosb
	loop	PALETTE
	mov	si,dx

TEXTURE	mov	bx,cx
	rcr	dl,cl
	mov	ah,dl
	sar	ah,3
	adc	al,ah
	adc	al,[es:bx+126]
	shr	al,1
	mov	[es:bx],al
	not	bh
	mov	[es:bx],al
	loop	TEXTURE

MAP1	mov	al,bl
	and	al,bh
	and	al,8
	mov	[si],bl
MAP2	fild	word [si]
	fmul	dword [PERIOD]
	fsin
	mov	[si],bh
	cmc
	jc	MAP2
	fmulp	st1,st0
	mov	[si],word 18
AMP	equ	$-2
	fimul	word [si]
	fiadd	word [si]
	fistp	word [si]
	sub	al,3
	add	al,[si]
	mov	[fs:bx],al
	dec	bx
	loop	MAP1

MOVE	equ	$-8
TEXUV	equ	$-6

	mov	bx,TEXUV
MAIN	mov	di,400h
	push	di
	sub	word [byte bx-TEXUV+MOVE],ax

	mov	dx,-100
SCRY	mov	bp,-160
SCRX	fninit

	mov	si,EYE
	mov	[bx],dx
	fild	word [bx]
	fidiv	word [si]
	mov	[bx],bp
	fild	word [bx]
	fidiv	word [si]

	fild	word [byte bx-TEXUV+MOVE]
	fld	st0
	fidiv	word [si]
	fcos
	fild	word [byte bx-TEXUV+AMP]
	fmul	st0,st1
	fiadd	word [si]
	fistp	word [bx]
	fimul	word [si]

	mov	ax,[bx]
	mov	cx,50
EYE	equ	$-2
RAYCAST	fadd	st0,st2
	fist	word [bx]
	fld	st3
	faddp	st2,st0
	fld	st1
	fistp	word [bx+1]
	mov	si,[bx]
	cmp	al,[fs:si]
	jc	RAYHIT
	dec	ax
	loop	RAYCAST

RAYHIT	sub	si,ax
	add	cx,cx
	es	lodsb
	mul	cl
	shr	byte [di],1
	add	[di],ah
	inc	di

	inc	bp
	cmp	bp,160
	jnz	SCRX
	inc	dx
	cmp	dx,byte 100
	jnz	SCRY

	pop	si
	push	es
	push	word 0A000h
	pop	es
	xor	di,di
	mov	ch,32000/256
	rep	movsw
	pop	es

	xchg	ax,cx
	in	al,60h
	dec	ax
	mov	al,3
	jnz	MAIN

	int	10h
	ret

	dw	3D49h
PERIOD	equ	$-4
