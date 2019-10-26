;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
ColorTunelInt1	PROC
	mov	edi,ds:[TabPtr]
	add	edi,ColBuffers
	xor	bx,bx
	mov	si,offset TraceTab+8
OutY:
	mov	cx,41
IntY:
	mov	ax,[si+41*12]
	sub	ax,[si]
	imul	bx
	mov	dh,dl
	mov	dl,ah
	mov	ax,[si]
	add	si,12
	add	ax,dx
	mov	dx,fs
	mov	fs,ax
	sub	ax,dx
	sar	ax,3
	cmp	cl,41
	jz	OutNone
IntX:
	mov	[edi],dh
	inc	di
	add	dx,ax
	add	bh,(256/8)
	jnz	IntX
OutNone:
	loop	IntY
	add	bl,(256/8)
	jz	okj
	sub	si,41*12
okj:
	cmp	di,320*(200-32)
	jnz	OutY
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
TunelInt1:
;	push	fs
;	push	gs

	mov	edi,ds:[TabPtr]
	add	edi,TunelBuffer
	shr	edi,1
	mov	si,offset TraceTab


	xor	bx,bx
OutYT:
	mov	cx,41
IntYT:
	mov	ax,[si+41*12]
	sub	ax,[si]
	imul	bx
	mov	dh,dl
	mov	dl,ah
	mov	ax,[si]
	add	si,4
	add	ax,dx
	mov	dx,fs
	mov	fs,ax
	sub	ax,dx
	sar	ax,3

	push	dx
	push	ax

	mov	ax,[si+41*12]
	sub	ax,[si]
	imul	bx
	mov	dh,dl
	mov	dl,ah
	mov	ax,[si]
	add	si,4
	add	ax,dx
	mov	dx,gs
	mov	gs,ax
	sub	ax,dx
	sar	ax,3

	add	si,4

	mov	bp,ax
	pop	ax
	rol	edx,16
	pop	dx
	
	push	cx
	push	si

	cmp	cl,41
	jz	OutNoneT


	mov	cx,dx
	rol	edx,16
	mov	si,ax
IntXT:
	mov	al,ch
	add	cx,si
	mov	ah,dh
	add	dx,bp
	mov	[edi+edi],ax
	inc	di
	add	bh,(256/8)
	jnz	IntXT
OutNoneT:
	pop	si
	pop	cx
	loop	IntYT
	add	bl,(256/8)
	jz	okjT
	sub	si,41*12
okjT:
	cmp	di,320*(200-32)
	jnz	OutYT


;	pop	gs
;	pop	fs
	ret
ColorTunelInt1	ENDP
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
