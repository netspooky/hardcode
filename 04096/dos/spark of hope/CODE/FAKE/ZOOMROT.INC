;edi - dest
;ebx - texture
;word ptr ZRLen+1  - length of zoomrot
;word ptr ZRLen2+2  - resolution - length of zoomrot

ZRScale	dw 256

ZoomRot	PROC
	fild	ds:[FrameCount]
	fidiv	ds:[ZRScale]
	fsincos
	fimul	ds:[ZRScale]
	fistp	word ptr ds:[ZRDu+2]
	fimul	ds:[ZRScale]
	fistp	word ptr ds:[ZRDv+2]
	shr	ebx,1
	shr	edi,1
	mov	si,200
ZRYLoop:
	mov	bl,ch
	push	cx
	mov	bh,dh
	push	dx
ZRLen:	mov	bp,320
ZRXLoop:
	mov	ax,[ebx+ebx]
ZRDu:	add	cx,1234h
	mov	bl,ch
ZRDv:	add	dx,1234h
	mov	bh,dh
	mov	[edi+edi],ax
	inc	di
	dec	bp
	jnz	ZRXLoop
	pop	dx
	pop	cx
	add	cx,word ptr ds:[ZRDv+2]
	sub	dx,word ptr ds:[ZRDu+2]
ZRLen2:	add	di,1234h
	dec	si
	jnz	ZRYLoop
	ret
ZoomRot	ENDP
