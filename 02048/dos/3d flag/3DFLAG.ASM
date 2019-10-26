;------------------------------------------------------------
;	3dflag
;	Mikolaj Felix
;	mfelix@polbox.com
;
;	Last update: 27/10/2001
;------------------------------------------------------------

.model tiny
.386c
locals
jumps

.code
org 100h

start:
	call	alloc_seg
	or	ax, ax
	jz	quit_me
	mov	buffer_seg, ax

	; init palette
	mov	di, offset palette
	mov	cx, 128
	xor	ax, ax
ip_loop1:
	stosb
	stosb
	stosb
	inc	ah
	mov	al, ah
	shr	al, 1
	loop	ip_loop1
	
	mov	cx, 128
	xor	ax, ax
ip_loop2:
	stosb
	xor	al, al
	stosb
	stosb
	inc	ah
	mov	al, ah
	shr	al, 1
	loop	ip_loop2

	call	init_font

	; clear scroll buffer
	mov	di, offset scroll_buffer
	xor	eax, eax
	mov	cx, 320*8/4
	cld
	rep	stosd

	finit
	call	init_sincos

	call	make_flag
	call	make_faces

	; make camera matrix
	mov	si, offset angle_x
	mov	di, offset cam_matrix
	call	mx_rotation_matrix
	
	mov	angle_x, 0
	mov	angle_z, 0

	mov	ax, 13h
	int	10h
	mov	si, offset palette
	call	set_palette

main_loop:
	call	move_flag

	mov	si, offset angle_x
	mov	di, offset rot_matrix
	call	mx_rotation_matrix

	mov	si, offset points
	mov	di, offset rotated_points
	mov	bx, offset rot_matrix
	mov	cx, MAX_P
	call	mx_rotate_points

	call	make_scene

	mov	si, offset rotated_points
	mov	di, offset translated_points
	mov	cx, MAX_P
	call	translate_points

	;call	draw_points
	call	draw_faces

	call	do_scroll

	call	retrace
	call	copy_buffer
	call	clear_buffer

	add	angle_y, 1

	inc	temp_cosofs
	mov	al, temp_cosofs
	test	al, 1
	jz	skip_wave_change
	inc	cosofs
skip_wave_change:

	in	al, 60h
	dec	al
	jnz	main_loop

	mov	ax, 03h
	int	10h

	mov	ax, buffer_seg
	call	free_seg
quit_me:
	mov	ah, 4ch
	int	21h

do_scroll proc
	cmp	curr_line, 8
	jne	@@next
	mov	curr_line, 0
	inc	curr_letter
@@next:

	mov	al, curr_letter
	xor	ah, ah
	mov	si, ax
	add	si, offset scroll_text
	lodsb
	or	al, al
	jnz	@@string_ok

	mov	curr_letter, 0
@@string_ok:

	mov	si, offset font_data
	and	ah, ah
	shl	ax, 3
	add	si, ax

	mov	di, offset scroll_buffer
	add	di, 318
	mov	dl, TEXT_COLOR

	mov	ch, 8
@@put_dot:
	lodsb
	mov	cl, curr_line
	rcl	al, cl
	jae	@@next_dot

	mov	[di], dl
@@next_dot:
	add	di, 320
	inc	dl
	dec	ch
	jnz	@@put_dot

	inc	curr_line

	; move text
	mov	si, offset scroll_buffer
	mov	cx, 8
@@ver:
	mov	bx, 4
@@hor:
	mov	eax, dword ptr [si][bx]
	mov	dword ptr [si][bx-1], eax
	add	bx, 4
	cmp	bx, 320
	jne	@@hor
	add	si, 320
	dec	cx
	jnz	@@ver

	; draw scroller
	push	es
	mov	es, buffer_seg
	mov	di, 320*191
	mov	si, offset scroll_buffer
	mov	cx, 320*8
@@put_p:
	lodsb
	or	al, al
	jz	@@next_p
	mov	byte ptr es:[di], al
@@next_p:
	inc	di
	dec	cx
	jnz	@@put_p
	pop	es

	ret
endp

make_scene proc
	; move scene to camera position
	mov	si, offset rotated_points
	mov	di, offset temp_points
	mov	cx, MAX_P
@@move:
	fld	dword ptr [si.x3d]
	fsub	cam_x
	fstp	dword ptr [di.x3d]
	fld	dword ptr [si.y3d]
	fsub	cam_y
	fstp	dword ptr [di.y3d]
	fld	dword ptr [si.z3d]
	fsub	cam_z
	fstp	dword ptr [di.z3d]
	add	si, type point3d
	add	di, type point3d
	dec	cx
	jnz	@@move

	; multiply vertices by camera matrix
	mov	si, offset temp_points
	mov	di, offset rotated_points
	mov	bx, offset cam_matrix
	mov	cx, MAX_P
	call	mx_rotate_points
	ret
endp

draw_faces proc
	mov	si, offset faces
	mov	cx, MAX_F
@@draw_face:
	push	si
	push	cx

	; push color
	mov	bx, word ptr [si.face_v1]
	movzx	ax, byte ptr point_colors[bx]
	push	ax

	; push coords
	mov	dx, 3
@@push_xy:
	mov	bx, word ptr [si]
	shl	bx, 2
	add	bx, offset translated_points
	push	word ptr [bx.y2d]
	push	word ptr [bx.x2d]
	add	si, 2
	dec	dx
	jnz	@@push_xy

comment #
	mov	bx, word ptr [si.face_v1]
	shl	bx, 2
	add	bx, offset translated_points
	push	word ptr [bx.y2d]
	push	word ptr [bx.x2d]

	mov	bx, word ptr [si.face_v2]
	shl	bx, 2
	add	bx, offset translated_points
	push	word ptr [bx.y2d]
	push	word ptr [bx.x2d]

	mov	bx, word ptr [si.face_v3]
	shl	bx, 2
	add	bx, offset translated_points
	push	word ptr [bx.y2d]
	push	word ptr [bx.x2d] #

	call	flat_triangle

	pop	cx
	pop	si
	add	si, type face
	dec	cx
	jnz	@@draw_face
	ret
endp

comment #
draw_points proc
	push	es
	mov	es, buffer_seg
	mov	si, offset translated_points
	mov	cx, MAX_P
@@draw:
	mov	ax, word ptr [si.x2d]
	or	ax, ax
	jl	@@next
	cmp	ax, 319
	jg	@@next

	mov	bx, word ptr [si.y2d]
	or	bx, bx
	jl	@@next
	cmp	bx, 199
	jg	@@next

	mov	di, bx
	shl	di, 6
	shl	bx, 8
	add	di, bx
	add	di, ax
	mov	al, 31
	stosb
@@next:
	add	si, type point2d
	dec	cx
	jnz	@@draw
	pop	es
	ret
endp #

move_flag proc
	push	bp
	mov	bp, sp
	sub	sp, 2

	mov	si, offset points
	mov	di, offset point_colors
	mov	dx, FLAG_HEIGHT
@@ver:
	mov	cx, FLAG_WIDTH
@@hor:
	mov	ax, cx
	add	ax, dx
	add	ax, cosofs

comment #
	mov	bx, COS_STEP
	push	dx
	imul	bx
	pop	dx #

	; COS_STEP = 20 = 2^4 + 2^2
	mov	bx, ax
	shl	ax, 4
	shl	bx, 2
	add	bx, ax
	and	bx, MAX_DEGS-1
	shl	bx, 2
	fld	dword ptr costab[bx]
	fld	st
	fmul	wave_amp
	fstp	dword ptr [si.y3d]

	;fld	dword ptr costab[bx]
	fchs
	fmul	max_colors
	fistp	word ptr [bp-2]
	mov	ax, word ptr [bp-2]
	
	shr	ax, 1
	add	ax, 64+1
	test	cx, 1
	jnz	@@no_add
	add	ax, 127
@@no_add:
	stosb					; color = (-cos(_BX)*62)+64+1+add_col

	add	si, type point3d
	dec	cx
	jnz	@@hor

	dec	dx
	jnz	@@ver

	mov	sp, bp
	pop	bp
	ret
endp

make_flag proc
	push	bp
	mov	bp, sp
	sub	sp, 2

	mov	di, offset points
	xor	dx, dx				; z
@@ver:
	xor	cx, cx				; x
@@hor:
	; x = ((FLAG_WIDTH*CELL_SIZE/2)-(x*CELL_SIZE))-CELL_SIZE/2

	mov	ax, TEMP1
	mov	bx, cx
	shl	bx, 5				; y*CELL_SIZE
	sub	ax, bx
	sub	ax, CELL_SIZE/2
	mov	word ptr [bp-2], ax
	fild	word ptr [bp-2]
	fstp	dword ptr [di.x3d]

	; y = 0

	mov	dword ptr [di.y3d], 0

	; z = ((FLAG_HEIGHT*CELL_SIZE/2)-(z*CELL_SIZE))-CELL_SIZE/2

	mov	ax, TEMP2
	mov	bx, dx
	shl	bx, 5				; z*CELL_SIZE
	sub	ax, bx
	mov	word ptr [bp-2], ax
	fild	word ptr [bp-2]
	fstp	dword ptr [di.z3d]

	add	di, type point3d
	inc	cx
	cmp	cx, FLAG_WIDTH
	jne	@@hor

	inc	dx
	cmp	dx, FLAG_HEIGHT
	jne	@@ver

	mov	sp, bp
	pop	bp
	ret
endp

make_faces proc
	mov	si, offset faces
	xor	dx, dx
@@ver:
	xor	cx, cx
@@hor:
	; face_v1 = (y*FLAG_WIDTH)+x

	mov	ax, dx
	shl	ax, 4
	add	ax, cx
	mov	word ptr [si.face_v1], ax

	; face_v2 = (y*FLAG_WIDTH)+(x+1)

	inc	ax
	mov	word ptr [si.face_v2], ax

	; face_v3 = ((y+1)*FLAG_WIDTH)+(x+1)

	mov	ax, dx
	inc	ax
	shl	ax, 4
	add	ax, cx
	inc	ax
	mov	word ptr [si.face_v3], ax
	
	add	si, type face

	; face_v1 = (y*FLAG_WIDTH)+x
	
	mov	ax, dx
	shl	ax, 4
	add	ax, cx
	mov	word ptr [si.face_v1], ax
	
	; face_v2 = ((y+1)*FLAG_WIDTH)+(x+1)

	mov	ax, dx
	inc	ax
	shl	ax, 4
	add	ax, cx
	inc	ax
	mov	word ptr [si.face_v2], ax

	; face_v3 = ((y+1)*FLAG_WIDTH)+x

	dec	ax
	mov	word ptr [si.face_v3], ax

	add	si, type face

	inc	cx
	cmp	cx, FLAG_WIDTH-1
	jne	@@hor

	inc	dx
	cmp	dx, FLAG_HEIGHT-1
	jne	@@ver
	ret
endp

include 3dflag.inc
include 3dmath.asm
include mem.asm
include graph.asm
include flat3.asm
include font.asm

.data
	wave_amp dd 12.0
	max_colors dd 62.0

	cam_x dd 0.0
	cam_y dd -170.0
	cam_z dd -350.0

	angle_x dw 50
	angle_y dw 0
	angle_z dw 0

	scroll_text	db "This effect was written by Mikolaj Felix specially for "
			db "Programmers' Sun (www.ps.nq.pl) * ", 0
	
	curr_letter db 0
	curr_line db 0
.data?
	points point3d MAX_P dup(?)
	rotated_points point3d MAX_P dup(?)
	temp_points point3d MAX_P dup(?)
	translated_points point2d MAX_P dup(?)

	faces face MAX_F dup(?)
	point_colors db MAX_P dup(?)

	rot_matrix matrix ?
	cam_matrix matrix ?

	temp_cosofs db ?
	cosofs dw ?

	scroll_buffer db 320*8 dup(?)
	palette db 768 dup(?)

end start
