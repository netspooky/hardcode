; Mikolaj Felix 31/05/2001,  30/09/2001
; mfelix@polbox.com

.model tiny
.386
.code
org 100h

start:
	call	generate_palette 

	call	alloc_screen_buffer
	call	init_costable

	mov	ax, 13h
	int	10h

	mov	dx, 03c8h
	xor	ax, ax
	out	dx, al
	inc	dx
	mov	si, offset palette
	mov	cx, 768
	cld
	rep	outsb

progy_loop:
	call	plasma
	
	call	wait_for_frame
	call	copy_screen_buffer
	in	al, 60h
	cmp	al, 1
	jne	progy_loop

	mov	ax, 03h
	int	10h

	call	free_screen_buffer

quit_progy:
	mov	ah, 4ch
	int	21h

generate_palette proc
	push	bp
	mov	bp, sp
	sub	sp, 6

	mov	di, offset palette
	mov	cx, 256
	cld

	fldz
	fstp	dword ptr [bp-4]
gp_loop:
	fld	dword ptr [bp-4]
	fld	st
	fsin
	fmul	col_const
	fistp	word ptr [bp-6]
	mov	ax, word ptr [bp-6]
	sar	ax, 2
	and	ax, 255
	push	ax
	xor	al, al
	stosb
	pop	ax
	stosb
	stosb
	fadd	delta_c
	fstp	dword ptr [bp-4]
	dec	cx
	jnz	gp_loop

	mov	sp, bp
	pop	bp
	ret
endp

plasma proc
	push	es
	mov	es, buffer_seg
	xor	di, di

	mov	dx, word ptr rver_1
	mov	cx, 200/2
@@ver_loop:
	mov	si, dx
	and	si, 0ffh
	mov	al, byte ptr costable[si]
	mov	si, dx
	shr	si, 8
	add	al, byte ptr costable[si]

	mov	bx, word ptr rhor_1
	push	cx
	mov	cx, 320/2
@@hor_loop:
	push	ax

	mov	si, bx
	and	si, 0ffh
	add	al, byte ptr costable[si]
	mov	si, bx
	shr	si, 8
	add	al, byte ptr costable[si]
	
	mov	ah, al
	stosw
	mov	word ptr es:[di+320-2], ax

	pop	ax

	add	bl, 4
	add	bh, 1

	dec	cx
	jnz	@@hor_loop

	add	dl, 4
	add	dh, 5

	add	di, 320
	pop	cx
	dec	cx
	jnz	@@ver_loop

	add	rver_1, -4
	add	rver_2, -1
	add	rhor_1, 2
	add	rhor_2, 3

	pop	es
	ret
endp

comment #
plasma proc
	push	es
	mov	es, buffer_seg
	xor	di, di

	mov	dx, word ptr rver_1
	mov	cx, 200
@@ver_loop:
	mov	si, dx
	and	si, 0ffh
	mov	al, byte ptr costable[si]
	mov	si, dx
	shr	si, 8
	add	al, byte ptr costable[si]

	mov	bx, word ptr rhor_1
	push	cx
	mov	cx, 320
@@hor_loop:
	push	ax
	mov	si, bx
	and	si, 0ffh
	add	al, byte ptr costable[si]
	mov	si, bx
	shr	si, 8
	add	al, byte ptr costable[si]
	stosb
	pop	ax

	add	bl, 4
	add	bh, 1

	dec	cx
	jnz	@@hor_loop

	add	dl, 4
	add	dh, 5

	pop	cx
	dec	cx
	jnz	@@ver_loop

	add	rver_1, -4
	add	rver_2, -1
	add	rhor_1, 2
	add	rhor_2, 3

	pop	es
	ret
endp
#

init_palette proc
	mov	dx, 03c8h
	xor	ax, ax
	out	dx, al
	inc	dx
	mov	cx, 256
@@color:
	out	dx, al
	out	dx, al
	out	dx, al
	inc	al
	loop	@@color
	ret
endp

init_costable proc
	finit
	mov	di, offset costable
	xor	cx, cx
@@loop:
	mov	_f16, cx
	fild	_f16
	fmul	pi_128
	fcos
	fmul	scale_const
	fistp	_f16
	mov	ax, _f16
	stosb
	inc	cx
	cmp	cx, 256
	jne	@@loop
	ret
endp

include graphlib.asm

col_const dd 255.0
delta_c dd 0.01232	; (180/255)*PI/180

pi_128 dd 0.02454369260617
scale_const dd 32.0
_f16 dw ?

palette db 768 dup(?)

costable db 256 dup(?)
rver_1 db ?
rver_2 db ?
rhor_1 db ?
rhor_2 db ?

end start