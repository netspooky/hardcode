;------------------------------------------------------------
;	SinXor
;	Mikolaj Felix 16/10/01
;	mfelix@polbox.com
;------------------------------------------------------------

.model tiny
.386c
.code
org 100h

start:
	call	alloc_seg
	or	ax,ax
	jz	quit_progy
	mov	buffer_seg,ax

	; set texture
	mov	di,offset texture
	xor	dx,dx
st_ver:
	xor	cx,cx
st_hor:
	mov	ax,cx
	xor	ax,dx
	stosb
	inc	cx
	cmp	cx,128
	jne	st_hor
	inc	dx
	cmp	dx,128
	jne	st_ver

	; calculate palette
	mov	di,offset palette
	xor	ax,ax
	mov	cx,256
sp_loop:
	stosb
	stosb
	stosb
	inc	ah
	mov	al,ah
	shr	al,2
	dec	cx
	jnz	sp_loop

	; init sine wave
	finit
	mov	di,offset sinwave
	mov	cx,256
isv_loop:
	fld	angle
	fld	st
	fsin
	fmul	mul_wave
	fistp	word ptr [di]
	fadd	d_angle
	fstp	angle
	add	di,2
	dec	cx
	jnz	isv_loop

	mov	ax,13h
	int	10h
	mov	si,offset palette
	call	set_palette

main_loop:

	; fill screen
	push	es
	mov	es,buffer_seg
	xor	di,di

	mov	dx,200
	mov	bp,sin_pos
dp_ver:
	mov	cx,320
	mov	si,sin_pos
dp_hor:
	mov	ax,word ptr sinwave[bp]
	add	ax,cx
	and	ax,127

	mov	bx,word ptr sinwave[si]
	add	bx,dx
	and	bx,127

	shl	bx,7
	add	bx,ax
	mov	al,byte ptr texture[bx]
	stosb

	add	si,2
	and	si,511
	
	dec	cx
	jnz	dp_hor

	add	bp,2
	and	bp,511

	dec	dx
	jnz	dp_ver
	pop	es

	; update sine position
	add	sin_pos,2
	and	sin_pos,511

	call	retrace
	call	copy_buffer

	in	al,60h
	dec	al
	jnz	main_loop

	mov	ax,03h
	int	10h

	mov	ax,buffer_seg
	call	free_seg
quit_progy:
	mov	ah,4ch
	int	21h
	
include libs\mem.asm
include libs\graph.asm

.data
	d_angle dd 0.024543693			; pi/128
	angle dd 0.0
	mul_wave dd 12.0

	sin_pos dw 0
.data?
	texture db 128*128 dup(?)
	palette db 768 dup(?)

	sinwave dw 256 dup(?)

end start