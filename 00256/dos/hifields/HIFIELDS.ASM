JUMPS
.386p

ASSUME CS:CODE,DS:CODE


CODE	SEGMENT USE16
	org	100h
Start:
	mov	al,13h
	int	10h

	mov	dx,3c8h
	xor	ax,ax
	out	dx,al
	inc	dx
Pal:
	out	dx,al
	out	dx,al
	out	dx,al
	inc	ax
	jnz	Pal
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
	push	09000h
	pop	ds

	push	0A000h
	pop	es

	xor	di,di
RandomMess:
	add	ax,0E3F8h
	ror	ax,3
	mov	[di],al
	inc	di
	jnz	RandomMess

	mov	cx,12
Blur:
	mov	al,[di-1]
	mov	dl,[di+256]
	add	ax,dx
	mov	dl,[di+1]
	add	ax,dx
	mov	dl,[di-256]
	add	ax,dx
	shr	ax,2
	mov	[di],al
	inc	di
	jnz	Blur
	loop	Blur	

	push	ds
	pop	fs
	push	cs
	pop	ds	
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
MainLoop:


	mov	dx,320
XLoop:
	mov	bp,199
	mov	gs,bp

	mov	cx,256*65

	xor	ax,ax

	push	bx

	mov	di,64000+offset buffer
	sub	di,dx

DepthLoop:
	inc	ax
	mov	bh,ch
	mov	word ptr ds:[tt],ax
	push	ax
	push	dx
	push	cx
	xor	ch,ch
	call	SubRout

	push	ax
;	sub	ax,41100+50*256
	sub	ax,37500+50*256
	sar	ax,3
	cwd
	idiv	word ptr ds:[tt]
	add	ax,100

	push	ax
	inc	bx
	call	SubRout

	pop	cx
	pop	dx
	sub	ax,dx
	add	ax,ax
	add	ax,(128+16) shl 6
;---------------------------- newh & newc calculated -------------------------;
	push	ax

	sub	bp,cx
	jle	NoLine
;²²²²²²²²²²²²² Draw vert sub-line... ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
	push	bx
	mov	bx,gs
	sub	bx,cx
	sub	ax,si
	cwd
	idiv	bx
	sub	bx,bp
	imul	bx,ax
	add	bx,si
Line:
	mov	[di],bh
	sub	di,320
	add	bx,ax
	dec	bp
	jnz	Line
	pop	bx
;²²²²²²²²²²²²² AFTER Draw vert sub-line... ²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;

NoLine:
	add	bp,cx
	mov	gs,cx

	pop	si
	pop	cx
	pop	dx
	pop	ax

	sub	cx,dx
	add	cx,160
;	cmp	al,127
	cmp	al,110
	jnz	DepthLoop

Sky:
	mov	ax,bp
	shr	ax,1
	mov	[di],al
	sub	di,320
	dec	bp
	jge	Sky
	
	pop	bx
	dec	dx
	jnz	XLoop

	inc	bx

;þþþþþþþþþþþþþþþþþþþþþþþ Copy buffer to screen þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
	mov	dx,3dah
VertRetrace:
	in	al,dx
	and	al,8
	jz	VertRetrace

;	push	0a000h
;	pop	es

	mov	si,offset buffer
	xor	di,di
	mov	ch,64000/512
	rep	movsw

	in	al,60h
	cmp	al,1
	jnz	MainLoop

;	ret
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
SubRout	PROC
	xor	ax,ax
	cwd	
	mov	dl,fs:[bx]
	inc	bh
	mov	al,fs:[bx]

	sub	ax,dx
	imul	ax,cx
	add	ah,dl
	add	ax,ax

	ret
SubRout	ENDP

tt	dw ?
buffer	db 64000 dup (?)
CODE	ENDS

END	Start
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²;

