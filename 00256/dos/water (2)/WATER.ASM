.model tiny
.386
.code

org 	100h

main:

	jmp	@@go
rain	proc
@@do_again:
	mov	dx,40h
	in	al,dx
	mov	di,ax
	shl	ax,10
	add	di,ax
	
	in	al,dx
	add	di,ax
	add	[ds:di],al
	ret
rain	endp
	
@@go:	
	mov	ax,13h
	int	10h
	
	mov	cl,0
@@snabel:
	mov	dx,3c8h
	mov	al,cl
	out	dx,al
	mov	al,cl
	shr	al,2
	inc	dx
	out	dx,al
	out	dx,al
	out	dx,al
	inc	cx
	cmp	cl,0
	jne	@@snabel
	mov	ax,cs
	add	ah,10h
	mov	fs,ax
	add	ah,10h
	mov	gs,ax
	
	push	gs
	pop	es
	mov	al,0
	mov	ch,0
	dec	cx
	xor	di,di
	rep	stosb
	push	fs
	pop	es
	dec	cx
	sub	di,di
	rep	stosb

@@Main_Loop:
	cmp	bp,1
	jne	@@page_2
	push	gs
	pop	es
	push 	fs
	pop	ds
	mov	bp,0
	jmp	@@start
@@page_2:
	push	gs
	pop	ds
	push	fs
	pop	es
	mov	bp,1
@@start:
	call	rain
	call	rain
	mov	di,1
	mov	cx,64000
@@Start_doin_water:
	mov	ah,0
	mov	si,di
	sub	si,321
	lodsb
	mov	bx,ax
	lodsb
	add	bx,ax
	lodsb
	add	bx,ax
	add	si,317
	lodsb
	add	bx,ax
	inc	si
	lodsb
	add	bx,ax
	add	si,317
	lodsb
	add	bx,ax
	lodsb
	add	bx,ax
	lodsb	
	add	bx,ax
	xor	ax,ax
	mov	al,[es:di]
	sal	ax,2
	sub	bx,ax
	sar	bl,2
	mov	ax,bx
	sar	al,6
	sub	bx,ax
	mov	[es:di],bl
	inc	di
	dec	cx
	jnz	@@Start_doin_water
	
	push	es
	pop	ds
	push	0a000h
	pop	es
	xor	di,di
	mov	ch,0fah
	mov	ah,0

@@bump_loop1:
	
	mov	si,di
	sub	si,320
	lodsb
	add	si,639
	sub	al,[ds:si]
	mov	dx,ax
	mov	si,di
	dec	si
	lodsb
	inc	si
	sub	al,[ds:si]
	add	al,dl
	sar	al,1
	add	al,128
	stosb
	loop	@@bump_loop1
	in	al,60h
	cmp	al,1
	jne	@@main_loop
	mov	ax,3
	int	10h
	
	mov	ah,4ch
	int	21h
	
end main

	