;
;  l u m i n o u s
;  the world of lights
;                        
;  a 256 byte bump-mapper
;  by Insomniac/Matrix    
;
code	SEGMENT
	ASSUME cs:code, ds:code, es:code
	p386

ORG	100h

LPATH	=	100
BUMPH	=	6

BOXW	=	5
BOXH	=	10

Start:	mov	al,13h
	int	10h

	mov	ax,ds
	add	ax,1000h
	mov	es,ax

;  s e t   t h e   p a l e t t e
Pal:	mov	al,cl
	mov	dx,3c8h
	out	dx,al
	inc	dx
	shr	al,2
	out	dx,al
	out	dx,al
	out	dx,al
	loop	Pal

;  d o   t h e   t e x t u r e
	mov	ah,9
	lea	dx,Text
	int	21h

	push	0a000h
	pop	DS

	mov	di,320*((200-8*BOXH)/2) + (320-8*BOXW*8)/2
	db	0D6h

WriteText:
	cmp	byte ptr DS:[bx],7
	jne	@NoPix
	pusha
	mov	cx,BOXH
@BVert:	push	cx
	mov	cl,BOXW
@BHor:	stosb
	loop	@BHor
	add	di,320-BOXW
	pop	cx
	loop	@BVert
	popa
@NoPix:	inc	bx
	add	di,BOXW
	loop	WriteText

;  b l u r   i t
	mov	cx,BUMPH
Blur:	push	cx
	xor	cx,cx
	xor	dx,dx
@Blur:	xor	ax,ax
	mov	dl,ES:[di]
	add	ax,dx
	mov	dl,ES:[di+2]
	add	ax,dx
	mov	dl,ES:[di-320]
	add	ax,dx
	mov	dl,ES:[di+321]
	add	ax,dx
	shr	ax,2
	stosb
	loop	@Blur
	pop	cx
	loop	Blur

;  c a l c u l a t e   t h e   l i g h t
	push	ES DS CS
	pop	DS ES GS

	mov	XY,-LPATH
Main:	push	XY
	mov	[x],XY
	mov	[y],XY

Bump:	xor	di,di
	mov	si,-LPATH
@Bump:	mov	bp,-158
@@Bump:	movzx	ax,GS:[di+1]
	movzx	bx,GS:[di-2]
	sub	ax,bx
	mov	bx,bp
	sar	bx,1
	sub	bx,[x]
	sub	ax,bx
	movzx	cx,GS:[di+320]
	movzx	dx,GS:[di-320*2]
	sub	cx,dx
	mov	dx,si
	sar	dx,1
	sub	dx,[y]
	sub	cx,dx
	imul	cx,dx
	imul	ax,bx
	add	ax,cx
	cwd
	xor	ax,dx
	sub	ax,dx
	shr	ax,3
	inc	ax
	or	ah,ah
	jz	PutPix
	xor	ax,ax

PutPix:	neg	al
	stosb
	inc	bp
	cmp	bp,320/2
	jl	@@Bump
	inc	di
	inc	di
	inc	si
	cmp	si,LPATH
	jle	@Bump

	pop	XY

	inc	XY
	cmp	XY,LPATH
	jne	NotB

	neg	XY
NotB:	in	al,60h
	dec	ax
	jnz	main

Exit:	mov	al,3
	int	10h

	ret

Text	db	'LUMINOUS','$'

;  v a r i a b l e s
XY	EQU	bx

x	dw	?
y	dw	?

code	ENDS
	END	Start