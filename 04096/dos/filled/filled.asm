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
petla:
	mov	si, offset object
	mov	di, offset object_rotated
	mov	cx, MAX_POINTS*3
copy_object:
	fild	word ptr [si]
	fstp	dword ptr [di]
	add	si, 2
	add	di, 4
	dec	cx
	jnz	copy_object

	mov	si, offset angle_x
	mov	di, offset object_rotated
	mov	cx, MAX_POINTS
	call	rotate_points

	mov	si, offset object_rotated
	mov	di, offset coord2d
	mov	cx, MAX_POINTS
	call	translate_points

	call	draw_faces
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

draw_faces proc
	push	bp
	mov	bp, sp
	sub	sp, 2			; bp-2 copro status

	mov	di, offset faces_queue
	mov	cx, MAX_FACES
	xor	al, al
df_reset_queue:
	stosb
	inc	al
	dec	cx
	jnz	df_reset_queue

	mov	si, offset faces_table
	mov	di, offset faces_z
	mov	cx, MAX_FACES
df_compute_z:
	push	cx
	mov	cx, 4
	fldz
df_point:
	xor	bh, bh
	mov	bl, byte ptr [si]
	mov	ax, bx
	shl	bx, 2
	shl	ax, 3
	add	bx, ax
	fadd	dword ptr object_rotated[bx+8]
	inc	si
	dec	cx
	jnz	df_point
	
	fstp	dword ptr [di]
	add	di, 4
	pop	cx
	dec	cx
	jnz	df_compute_z

df_sort_start:
	mov	si, offset faces_z+(MAX_FACES*4)-4
	mov	di, offset faces_queue+MAX_FACES-1
	mov	cx, MAX_FACES-1
df_sort:
	fld	dword ptr [si]
	fcomp	dword ptr [si-4]
	fstsw	word ptr [bp-2]
	mov	ah, byte ptr [bp-1]
	sahf
	jbe	df_sort_ok

	mov	eax, dword ptr [si]
	xchg	dword ptr [si-4], eax
	mov	dword ptr [si], eax

	mov	al, byte ptr [di]
	xchg	byte ptr [di-1], al
	mov	byte ptr [di], al

	jmp	df_sort_start
df_sort_ok:
	sub	si, 4
	dec	di
	dec	cx
	jnz	df_sort

	mov	si, offset faces_queue
	mov	cx, MAX_FACES
df_draw_face:
	push	cx
	mov	cx, 4
	
	movzx	di, byte ptr [si]

	xor	ah, ah
	mov	al, byte ptr colors[di]
	push	ax				; color
	
	shl	di, 2
	add	di, offset faces_table
df_point2d:
	xor	bh, bh
	mov	bl, byte ptr [di]
	shl	bx, 2

	push	word ptr coord2d[bx+2]	; y
	push	word ptr coord2d[bx]	; x

	inc	di
	dec	cx
	jnz	df_point2d

	call	draw_filled_polygon
	inc	si
	pop	cx
	dec	cx
	jnz	df_draw_face

	add	sp, 2
	pop	bp
	ret
endp

include graphlib.asm
include fillpol.asm
include math3d.asm

MAX_POINTS equ 24
MAX_FACES equ 20

inc_angle dd 0.01745329252
angle_x dd 0.0
angle_y dd 0.0
angle_z dd 0.0

scale_const dd 0.95

faces_table	db	0, 1, 2, 11,  2, 3, 9, 10,  3, 4, 8, 9,  4, 5, 6, 7
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

colors db 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50

faces_z dd MAX_FACES dup(?)
faces_queue db MAX_FACES dup(?)

object_rotated dd MAX_POINTS dup(?, ?, ?)
coord2d dw MAX_POINTS dup(?, ?)

end start