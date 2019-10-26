;-----------------------------------------------------------------------------;
;                              ! BaD TV !                                     ;
;                            256byte  IntrO                                   ;
;                  by Doctor Max / Global Corporation                         ;
;                         2:5037/12.27@fidonet                                ;
;                       Chaos Constructions '999                              ;
;-----------------------------------------------------------------------------;


.model	small
.386
locals

.code
	org	0100h
begin:
	mov	al,13h
	int	10h

	mov	di,offset CircBuf
	mov	si,offset param0
	call	CircCalc

	push	0a000h
	pop	es

	mov	al,16+8
	mov	cx,-1
	rep	stosb

	mov	bp,319
	mov	al,16+15
	xor	di,di
	mov	cx,bp
	rep	stosb
	mov	cl,200
	call	Vline

	mov	di,(320*7)+15
	push	di
	mov	cl,185
	call	Vline
	mov	cl,202
	rep	stosb

	mov	di,(320*8)+232
	mov	bx,36
@@3:	push	di
	mov	cl,128
	call	Vline
	pop	di
	inc	di
	inc	di
	dec	bx
	jnz	@@3

	mov	al,16+6
	xor	di,di
	mov	cl,199
	call	Vline
	mov	cx,bp
	rep	stosb

	pop	di
	mov	cl,201
	rep	stosb
	mov	cl,185
	call	Vline

	mov	di,(320*132)+236
	mov	si,offset param1
	call	CircCalc

	mov	al,16+15
	mov	di,(320*137)+266
	mov	ah,5
@@12:	push	di
	mov	cl,55
	call	Vline
	pop	di
	inc	di
	dec	ah
	jnz	@@12

@@mlp:	mov	dx,03dah
@@v0:	in	al,dx
	test	al,8
	jnz	@@v0
@@v1:	in	al,dx
	test	al,8
	jz	@@v1
	
	mov	di,320*8+16
	mov	si,offset CircBuf
	mov	dl,200-16
@@l1:	mov	cx,200
@@l0:	lodsb
	add	al,bl
	xor	al,cl
	xor	al,dl
	add	al,ah
	mov	ah,al
	rcr	al,1
	add	ax,bp
	stosb
	loop	@@l0
	add	di,320-200
	dec	dl
	jnz	@@l1

	sub	bl,3
	inc	bp

	in	al,60h
	dec	al
	jnz	@@mlp
	mov	ax,3
	int	10h
	ret

Vline:
@@0:	stosb
	add	di,bp
	loop	@@0
	ret


;si - parameters string
CircCalc:
	mov	bh,[si]
@@l1:	mov	bl,[si]
@@l0:	mov	al,bl
	imul	al
	mov	dx,ax
	mov	al,bh
	imul	al
	add	ax,dx
	cmp	ax,[si+2]
	jg	@@sk
	shr	ax,5
	add	al,16
@@n:	mov	es:[di],al
@@sk:	inc	di
	inc	bl
	cmp	bl,[si+1]
	jnz	@@l0
	add	di,[si+4]
	inc	bh
	cmp	bh,bl
	jnz	@@l1
	ret

param0	db	-100,100
	dw	16384,0
param1	db	-32,32
	dw	576,320-64

CircBuf	db	' MaX'

end begin
