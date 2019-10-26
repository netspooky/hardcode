; Mikolaj Felix 5/5/2001
; mfelix@polbox.com

.model tiny
.386c
.code
org 100h

start:
	finit
	call	alloc_screen_buffer

	mov	si, offset object
	mov	cx, MAX_POINTS*3
scale_loop:
	fild	word ptr [si]
	fmul	scale_const
	fistp	word ptr [si]
	add	si, 2
	dec	cx
	jnz	scale_loop

	mov	ax, 13h
	int	10h
	call	init_palette
petla:
	mov	si, offset object
	mov	di, offset object_new
	mov	cx, MAX_POINTS*3
copy_object:
	fild	word ptr [si]
	fstp	dword ptr [di]
	add	si, 2
	add	di, 4
	dec	cx
	jnz	copy_object

	mov	si, offset angle_x
	mov	di, offset object_new
	mov	cx, MAX_POINTS
	call	rotate_points

	mov	si, offset object_new
	mov	di, offset coord2d
	mov	cx, MAX_POINTS
	call	translate_points

	call	draw_glenz_faces
	call	wait_for_frame
	call	copy_screen_buffer
	call	clear_screen_buffer

	fld	angle_x
	fadd	inc_angle
	fstp	angle_x
	fld	angle_y
	fadd	inc_angle
	fadd	inc_angle
	fadd	inc_angle
	fstp	angle_y
	fld	angle_z
	fadd	inc_angle
	fstp	angle_z

	in	al, 60h
	cmp	al, 1
	jne	petla

	mov	ax, 03h
	int	10h
	call	free_screen_buffer
	mov	ah, 4ch
	int	21h
	ret

init_palette proc
	mov	dx, 03c8h
	xor	ax, ax
	out	dx, al
	inc	dx
	mov	cx, 256
ip_loop:
	out	dx, al
	out	dx, al
	out	dx, al
	mov	al, ah
	shr	al, 2
	inc	ah
	loop	ip_loop
	ret
endp

draw_glenz_faces proc
	mov	si, offset face_table
	mov	cx, MAX_FACES
	mov	ax, 8
dgf_loop:
	push	cx
	push	ax

	mov	cx, 4
	push	ax				; color
dgf_point:
	xor	bh, bh
	mov	bl, byte ptr [si]
	shl	bx, 2
	push	word ptr coord2d[bx+2]	; y
	push	word ptr coord2d[bx]	; x
	inc	si
	dec	cx
	jnz	dgf_point

	call	draw_glenz_polygon

	pop	ax
	add	ax, 2
	pop	cx
	dec	cx
	jnz	dgf_loop
	ret
endp

include graphlib.asm
include glenzpol.asm
include math3d.asm

MAX_POINTS equ 24
MAX_FACES equ 20

inc_angle dd 0.01745329252
angle_x dd 0.0
angle_y dd 0.0
angle_z dd 0.0

scale_const dd 0.95

face_table	db	0, 1, 2, 11,  2, 3, 9, 10,  3, 4, 8, 9,  4, 5, 6, 7
		db	12, 13, 14, 23,  14, 15, 21, 22,  15, 16, 20, 21
		db	16, 17, 18, 19,  0, 1, 13, 12,  1, 2, 14, 13
		db	2, 14, 15, 3,  4, 16, 15, 3,  4, 5, 17, 16
		db	5, 6, 18, 17,  6, 18, 19, 7,  8, 20, 19, 7
		db	8, 20, 21, 9,  10, 22, 21, 9,  10, 22, 23, 11,  0, 12, 23, 11

object	dw	-65, 65, 25,  -65, -65, 25,  -32, -65, 25,  0, -32, 25
	dw	32, -65, 25,  65, -65, 25,  65, 65, 25,  32, 65, 25
	dw	32, 0, 25,  0, 32, 25,  -32, 0, 25,  -32, 65, 25
	dw	-65, 65, -25,  -65, -65, -25,  -32, -65, -25
	dw	0, -32, -25,  32, -65, -25,  65, -65, -25,  65, 65, -25
	dw	32, 65, -25,  32, 0, -25,  0, 32, -25,  -32, 0, -25
	dw	-32, 65, -25

object_new dd MAX_POINTS dup(?, ?, ?)
coord2d dw MAX_POINTS dup(?, ?)

end start