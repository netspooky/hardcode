;************************************************************
; Matrix Effect v.1.0
;
; Idea and coding by Majuma. All rights reserved to Majuma.
; Feel free to copy and distribute this code as you will
; but do not change it without my permission !
; Have any suggestions? Mail me -> majuma@wp.pl
;
; Build date: 29/03/02
;
; Compile and link under TASM 4.1:
;	tasm matrix.asm
;	tlink matrix.obj /t
;************************************************************

.model tiny
.386

.code
org 100h

start_code:

;************************************************************
;	entry point
;************************************************************

	; set segment registers
	; CS = DS = ES
	push	cs
	push	cs
	pop	ds
	pop	es

	; allocate buffer segment
	mov	ah, 4ah
	mov	bx, 1000h
	int	21h
	mov	ah, 48h
	mov	bx, 1000h
	int	21h
	jc	quit_me_now
	mov	[buffer_seg], ax

	; get pointer to system font
	push	es
	mov	ax, 01130h
	mov	bh, 03h
	int	10h
	mov	word ptr [font_address + 0], bp
	mov	word ptr [font_address + 2], es
	pop	es

	; set 13h VGA mode
	mov	ax, 13h
	int	10h

	; set green palette
	mov	dx, 03c8h
	xor	ax, ax
	out	dx, al
	inc	dx
	mov	cx, 64
set_green:
	xor	al, al
	out	dx, al
	mov	al, ah
	out	dx, al
	xor	al, al
	out	dx, al
	inc	ah
	loop	set_green

	; init speeds of letters in each column
	mov	di, offset let_speed
	mov	cx, 320 / 8
init_speed:
	push	cx
	call	random_num
	pop	cx
	and	ax, 3
	stosb
	dec	cx
	jnz	init_speed

;************************************************************
;	main loop starts here !
;************************************************************

do_frame:

	; clear buffer
	push	es
	mov	es, [buffer_seg]
	xor	di, di
	xor	ax, ax
	mov	cx, 16000
	cld
	rep	stosd
	pop	es

	; decide if it's needed to generate new
	; letter table
	mov	ax, [frame_cnt]
	inc	ax
	and	ax, 7
	mov	[frame_cnt], ax
	jnz	next_rnd

	; make new table
	mov	di, offset let_table
	mov	si, offset let_speed
	mov	cx, 320 / 8
make_new_x:
	mov	dx, 200 / 8
	xor	bx, bx
	lodsb
	movzx	bp, al
make_new_y:
	mov	al, [di + bx]
	or	al, al
	jnz	make_new_next

	push	cx
	push	dx
	push	bx
	call	random_num
	pop	bx
	pop	dx
	pop	cx
	mov	[di + bx], al

	dec	bp
	jle	make_new_next_col
make_new_next:
	inc	bx
	dec	dx
	jnz	make_new_y

	xor	bx, bx
	xor	al, al
	mov	bp, 200 / 8
make_new_clear_col:
	mov	[di + bx], al
	inc	bx
	dec	bp
	jnz	make_new_clear_col

	; set new speed for current column
	push	cx
	call	random_num
	pop	cx
	and	ax, 3
	mov	[si - 1], al

make_new_next_col:
	add	di, 200 / 8
	dec	cx
	jnz	make_new_x
next_rnd:


	; draw matrix code
	mov	si, offset let_table
	cld
	xor	cx, cx
draw_matrix_x:
	xor	dx, dx
draw_matrix_y:
	lodsb
	or	al, al
	jz	draw_matrix_skip
	push	si
	push	cx
	push	dx
	call	put_letter
	pop	dx
	pop	cx
	pop	si
draw_matrix_skip:
	add	dx, 8
	cmp	dx, 200
	jne	draw_matrix_y
	add	cx, 8
	cmp	cx, 320
	jne	draw_matrix_x

	; draw text
	push	es
	mov	es, [buffer_seg]
	mov	si, [current_way]
	mov	cx, [txt_position]
	or	cx, cx
	jz	text_done
	cld
draw_text:
	lodsw
	mov	di, ax
	mov	al, [current_col]
	mov	ah, al
	mov	word ptr es:[di], ax
	mov	word ptr es:[di + 320], ax
	dec	cx
	jnz	draw_text
text_done:
	pop	es

	; change text position
	mov	ax, [txt_position]
	add	ax, DRAWING_SPEED
	cmp	ax, [current_max]
	jb	text_pos_ok

	; decrease text color
	mov	ax, [txt_wait]
	test	ax, 1
	jz	skip_new_color
	mov	al, [current_col]
	or	al, al
	jz	set_new_color
	dec	al
set_new_color:
	mov	[current_col], al
skip_new_color:

	mov	ax, [txt_wait]
	inc	ax
	cmp	ax, WAIT_TIME
	jb	text_wait

	xor	ax, ax
	mov	[txt_wait], ax
	mov	[txt_position], ax
	mov	al, TXT_COLOR
	mov	[current_col], al

	; change way !
	mov	ax, [current_way]
	cmp	ax, offset way_data
	je	set_way2

	mov	ax, offset way_data
	mov	bx, N_OFS
	jmp	set_now
set_way2:
	mov	ax, offset way_data2
	mov	bx, N_OFS2
set_now:
	mov	[current_max], bx
	mov	[current_way], ax
	jmp	text_leave
text_wait:
	mov	[txt_wait], ax
	mov	ax, [current_max]
	dec	ax
text_pos_ok:
	mov	[txt_position], ax
text_leave:

comment #
	; smooth screen (heavily optimized for speed
	; but works only if there's no color bigger than
	; 63 in a buffer !)
	push	es
	push	ds
	mov	ax, [buffer_seg]
	mov	ds, ax
	mov	es, ax

	xor	di, di
	xor	eax, eax
	mov	cx, 320 / 4
	cld
	rep	stosd

	mov	cx, (64000 - 320*2) / 4
	xor	bx, bx
sscr_loop:
	mov	eax, [di - 1]
	add	eax, [di + 1]
	add	eax, [di - 320]
	add	eax, [di + 320]
	and	eax, 0fcfcfcfch
	shr	eax, 2
	stosd
	dec	cx
	jnz	sscr_loop
	
	xor	eax, eax
	mov	cx, 320 / 4
	rep	stosd
	pop	ds
	pop	es #


	; wait for vertical retrace
	mov	dx, 03dah
vr1:
	in	al, dx
	test	al, 8
	jz	vr1
vr2:
	in	al, dx
	test	al, 8
	jnz	vr2

	; copy buffer to VGA memory
	push	ds
	push	es
	mov	ax, 0a000h
	mov	es, ax
	mov	ds, buffer_seg
	xor	si, si
	xor	di, di
	mov	cx, 16000
	cld
	rep	movsd
	pop	es
	pop	ds

	; check for ESC
	in	al, 60h
	cmp	al, 1
	jne	do_frame

;************************************************************
;	main loop ends !
;************************************************************

	; set 03h text mode
	mov	ax, 03h
	int	10h

	; free buffer segment
	mov	es, [buffer_seg]
	mov	ah, 49h
	int	21h

quit_me_now:

	; quit program via DOS service
	mov	ah, 4ch
	int	21h

;************************************************************
;	Prints a single letter
;	in: cx = x, dx = y, ax = letter
;************************************************************

put_letter:
	push	ds
	push	es
	mov	es, [buffer_seg]
	mov	di, dx
	shl	di, 6
	shl	dx, 8
	add	di, dx
	add	di, cx

	mov	si, word ptr [font_address + 0]
	mov	ds, word ptr [font_address + 2]
	and	ax, 255
	shl	ax, 3
	add	si, ax

	cld
	mov	ah, LETTER_COLOR
	; modification !!! do not draw a full letter
	; for better effect
	mov	dx, 5 ;8
pl_y:
	mov	cx, 5 ;8
	lodsb
pl_x:
	rcl	al, 1
	jnc	pl_next_pix
	mov	byte ptr es:[di], ah
pl_next_pix:
	inc	di
	dec	cx
	jnz	pl_x

	inc	ah
	add	di, 320 - 5 ;8
	dec	dx
	jnz	pl_y

	pop	es
	pop	ds
	ret

;************************************************************
;	Random number generator (thx to Binboy!)
;	out: ax = random number (0..255)
;************************************************************

random_num:
	mov	bx, [rnd_seed]
	add	bx, 9248h
	ror	bx, 3
	mov	[rnd_seed], bx
	mov	ax, 255
	mul	bx
	mov	ax, dx
	ret


;************************************************************
;	DATA section
;************************************************************

include	way.inc
include	way2.inc

LETTER_COLOR	equ 40 - 8
TXT_COLOR	equ 63
WAIT_TIME	equ 300
DRAWING_SPEED	equ 2

txt_position	dw 0
txt_wait	dw 0
current_way	dw offset way_data
current_max	dw N_OFS
current_col	db TXT_COLOR

rnd_seed	dw 666h
buffer_seg	dw ?
font_address	dd ?
frame_cnt	dw ?

let_table	db ((320 * 200) / 8) dup(?)
let_speed	db (320 / 8) dup(?)

end start_code
