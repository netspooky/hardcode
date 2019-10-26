;------------------------------------------------------------
;	RotXor
;	Mikolaj Felix 19/10/01
;	mfelix@polbox.com
;------------------------------------------------------------

.model tiny
.386
.code
org 100h

start:
	call	alloc_seg
	or	ax,ax
	jz	quit_me
	mov	buffer_seg,ax

	; generate texture
	mov	di,offset texture
	xor	dx,dx
gt_ver:
	xor	cx,cx
gt_hor:
	mov	ax,cx
	xor	ax,dx
	stosb
	inc	cx
	cmp	cx,128
	jne	gt_hor
	inc	dx
	cmp	dx,128
	jne	gt_ver

	; make sine & cosine tables
	finit
	fldz
	xor	di,di
	mov	cx,256
mk_look:
	fld	st
	fld	st
	fsin
	fmul	mul_const
	fistp	word ptr sintab[di]
	fcos
	fmul	mul_const
	fistp	word ptr costab[di]
	fadd	d_angle
	add	di,2
	dec	cx
	jnz	mk_look
	ffree	st

	; calculate palette
	mov	di,offset palette
	xor	ax,ax
	mov	cx,256
cp_loop:
	stosb
	stosb
	stosb
	inc	ah
	mov	al,ah
	shr	al,2
	dec	cx
	jnz	cp_loop


	mov	ax,13h
	int	10h
	mov	si,offset palette
	call	set_palette

main_loop:

;------------------------------------------------------------
;	precalculate lookups
;------------------------------------------------------------
	mov	bx,angle
	and	bx,255
	shl	bx,1
	mov	ax,word ptr sintab[bx]
	mov	_sin,ax
	mov	ax,word ptr costab[bx]
	mov	_cos,ax

	; vertical lookup tables
	xor	di,di
	mov	cx,-100
pre_v:
	mov	ax,_sin
	imul	cx
	shl	edx,16
	mov	dx,ax
	mov	dword ptr v_sin_lookup[di],edx
	
	mov	ax,_cos
	imul	cx
	shl	edx,16
	mov	dx,ax
	mov	dword ptr v_cos_lookup[di],edx

	add	di,4
	inc	cx
	cmp	cx,100
	jne	pre_v

	; horizontal lookup tables
	xor	di,di
	mov	cx,-160
pre_h:
	mov	ax,_sin
	imul	cx
	shl	edx,16
	mov	dx,ax
	mov	dword ptr h_sin_lookup[di],edx
	
	mov	ax,_cos
	imul	cx
	shl	edx,16
	mov	dx,ax
	mov	dword ptr h_cos_lookup[di],edx

	add	di,4
	inc	cx
	cmp	cx,160
	jne	pre_h

;------------------------------------------------------------
;	rotate & draw texture
;------------------------------------------------------------
	push	es
	mov	es,buffer_seg
	xor	di,di

	mov	cx,200
	xor	si,si
draw_ver:
	push	cx
	mov	cx,320
	xor	bp,bp
draw_hor:
	
	; tex_x = cos(angle)*x - sin(angle)*y
	; tex_x *= scale_const

	mov	eax,dword ptr h_cos_lookup[bp]
	sub	eax,dword ptr v_sin_lookup[si]
	sar	eax,7
	mul	scale_const
	shrd	ax,dx,7
	and	ax,127
	mov	bx,ax

	; tex_y = sin(angle)*x + cos(angle)*y
	; tex_y *= scale_const

	mov	eax,dword ptr h_sin_lookup[bp]
	add	eax,dword ptr v_cos_lookup[si]
	sar	eax,7
	mul	scale_const
	shrd	ax,dx,7
	and	ax,127

	shl	ax,7
	add	bx,ax
	mov	al,byte ptr texture[bx]
	stosb

	add	bp,4
	dec	cx
	jnz	draw_hor

	add	si,4
	pop	cx
	dec	cx
	jnz	draw_ver
	pop	es

;------------------------------------------------------------
;	update angle & scale
;------------------------------------------------------------
	mov	bx,a_sinpos
	and	bx,255
	shl	bx,1
	mov	ax,word ptr sintab[bx]
	add	angle,ax
	sar	angle,1
	inc	a_sinpos

	add	ax,scale_const
	sar	ax,1
	add	ax,31
	mov	scale_const,ax
;------------------------------------------------------------

	call	retrace
	call	copy_buffer

	in	al,60h
	dec	al
	jnz	main_loop

	mov	ax,03h
	int	10h

	mov	ax,buffer_seg
	call	free_seg
quit_me:
	mov	ah,4ch
	int	21h

include libs\mem.asm
include libs\graph.asm

.data
	d_angle dd 0.024543693			; pi/128
	mul_const dd 128.0

	angle dw 0
	a_sinpos dw 0

	scale_const dw 128
.data?
	texture db 128*128 dup(?)
	palette db 768 dup(?)

	sintab dw 256 dup(?)
	costab dw 256 dup(?)

	v_sin_lookup dd 200 dup(?)
	v_cos_lookup dd 200 dup(?)

	h_sin_lookup dd 320 dup(?)
	h_cos_lookup dd 320 dup(?)

	_sin dw ?
	_cos dw ?

	_pre1 dd ?
	_pre2 dd ?

end start