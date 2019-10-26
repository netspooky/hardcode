;
;  a n d r o m e d a 
;                        
;  a 256b demo
;  by insomniac/neon
;
code	SEGMENT
	ASSUME	CS:code, DS:code
	p386
	LOCALS

ORG	100h

max	=	4096
maxZ	=	5000

b	EQU	byte ptr

Start:	lea	di,vars
	mov	ch,60
	rep	stosw

	mov	al,13h
	int	10h

pal:	mov	al,cl
	mov	dx,3c8h
	out	dx,al
	inc	dx
	cmp	al,64
	jb	b64_1
	mov	al,63
b64_1:	out	dx,al
	mov	al,cl
	shr	al,1
	out	dx,al
	out	dx,al
	loop	pal


.main:	push	8000h
	pop	ES

	mov	si,max

.loop:	mov	ax,Z[si]
	cmp	ax,maxZ-(maxZ/4)
	jg	NewStar
	cmp	ax,2
	jg	Zok
NewStar:
	mov	ax,bp
	mov	X[si],ax

	imul	ax,8405h
	inc	ax
	mov	bp,ax

	shr	ax,6
	sub	ax,400
	mov	Y[si],ax

	mov	Z[si],maxZ-(maxZ/2)

Zok:	mov	ax,X[si]
	movsx	dx,ah
	shl	ax,8

	mov	cx,Z[si]

	idiv	cx
	add	ax,320/2
	cmp	ax,320-1
	jge	NewStar
	cmp	ax,1
	jle	NewStar

	mov	di,ax

	mov	ax,Y[si]
	movsx	dx,ah
	shl	ax,8
	idiv	cx
	add	ax,200/2

	imul	ax,320
	add	di,ax

	mov	al,127
	stosb

	mov	ax,X[si]
	cmp	ax,00
	jge	.add
	neg	ax
	shr	ax,6
	add	Y[si],ax
	jmp	.notadd
.add:	shr	ax,6
	sub	Y[si],ax
.notadd:
	add	Z[si],ax
	mov	ax,Y[si]
	sar	ax,3
	add	X[si],ax

.NextStar:
	dec	si
	dec	si
	jnz	.loop

	push	DS
	push	ES
	pop	DS

	xor	di,di
	xor	cx,cx
.blur:	movzx	ax,DS:[di]
	movzx	dx,DS:[di+1]
	add	ax,dx
	mov	dl,DS:[di-320]
	add	ax,dx
	mov	dl,DS:[di+321]
	add	ax,dx
	shr	ax,2

	cmp	al,0
	je	.skip
	dec	ax

.skip:	stosb
	loop	.blur

	push	0a000h
	pop	ES

	mov	si,di
	mov	ch,81h
	rep	movsw

	pop	DS

	mov	dx,3dah
.vrt:	in	al,dx
	test	al,8
	jz	.vrt

	in	al,60h
	dec	ax
	jnz	.main

endprog:
	mov	al,3
	int	10h

	ret

LABEL	vars
X	dw 	max DUP (?)
Y	dw	max DUP (?)
Z	dw	max DUP (?)

code	ENDS
	END	Start