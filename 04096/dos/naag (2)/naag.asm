;------------------------------------------------------------
;	NAAG Intro I v.1.1.
;
;	Code: Mikolaj Felix alias Majuma
;	majuma@wp.pl / www.naag.prv.pl
;
;	Updated: 13/11/01, 01/11/02
;------------------------------------------------------------

.386p
locals

code32 segment para public use32
	assume cs:code32,  ds:code32

_main proc
	finit

	; alloc memory
	mov	eax, REQ_MEM
	call	alloc_mem
	or	eax, eax
	jz	@@quit_progy
	mov	mem_handle, eax

	; set pointers
	mov	frame_buffer, ebx
	add	ebx, 64000
	mov	ptr_envmap, ebx
	add	ebx, 65536
	mov	ptr_bumpmap, ebx
	add	ebx, 65536

	mov	ptr_texture, ebx
	add	ebx, 65536
	mov	ptr_tunnel, ebx

	; clear scroll buffer
	mov	edi, offset scroll_buffer
	xor	eax, eax
	mov	ecx, 320*8/4
	cld
	rep	stosd

	; get font address
	mov	edi, offset _regs
	mov	dword ptr [edi._eax], 01130h
	mov	dword ptr [edi._ebx], 00000300h
	mov	ax, 0300h
	mov	bx, 10h
	int	31h
	movzx	eax, word ptr [edi._es]
	shl	eax, 4
	movzx	ebx, word ptr [edi._ebp]
	add	eax, ebx
	sub	eax, code32_base
	mov	ptr_font, eax
	
	; precalculate tables
	call	init_envmap
	call	init_bumpmap
	call	init_way

	call	init_texture
	call	init_tunnel

	; get VRAM address
	mov	eax, 0a0000h
	sub	eax, code32_base
	mov	_a0000h, eax

	; set mode 13h
	mov	ax, 0300h
	mov	bx, 10h
	mov	edi, offset _regs
	mov	[edi._eax], 13h
	int	31h

	mov	esi, offset palette1
	call	set_palette

;------------------------------------------------------------
;	main loop
;------------------------------------------------------------

	mov	curr_part, 1
@@part_start:

	cmp	curr_part, 1
	je	@@change_to_2
	mov	curr_part, 1
	jmp	@@part_changed
@@change_to_2:
	mov	curr_part, 0
@@part_changed:

	call	clear_buffer
	mov	main_counter, 0
	mov	flash_c, 0
@@main_loop:

	cmp	curr_part, 0
	jne	@@do_2nd_part
	call	bump_mapping
	jmp	@@part_done
@@do_2nd_part:
	call	do_tunnel

@@part_done:
	call	do_scroll

	call	retrace
	call	copy_buffer
	call	flash

	inc	main_counter
	cmp	main_counter, PART_TIMEOUT
	je	@@part_start

	in	al, 60h
	dec	al
	jnz	@@main_loop

;------------------------------------------------------------

	; back to text mode
	mov	ax, 0300h
	mov	bx, 10h
	mov	edi, offset _regs
	mov	[edi._eax], 03h
	int	31h

	; free memory
	mov	eax, mem_handle
	call	free_mem

@@quit_progy:
	ret
endp

do_scroll proc
	cmp	curr_line, 8
	jne	@@next
	mov	curr_line, 0
	inc	curr_letter
@@next:

	mov	esi, curr_letter
	add	esi, offset scroll_text
	lodsb
	or	al, al
	jnz	@@string_ok

	mov	curr_letter, 0
@@string_ok:

	shl	eax, 3
	add	eax, ptr_font
	mov	esi, eax

	mov	edi, offset scroll_buffer
	add	edi, 319
	mov	dl, TEXT_COLOR

	mov	ch, 8
@@put_dot:
	lodsb
	mov	cl, byte ptr curr_line
	rcl	al, cl
	jnc	@@next_dot

	mov	byte ptr [edi], dl
@@next_dot:
	add	edi, 320
	inc	dl
	dec	ch
	jnz	@@put_dot

	inc	curr_line

	; move text
	mov	esi, offset scroll_buffer
	mov	edx, 8
@@ver:
	mov	ecx, 320 - 2
	push	esi
	xor	al, al
	mov	edi, esi
	stosb
	add	esi, 2
	rep	movsb
	stosb
	pop	esi
	add	esi, 320
	dec	edx
	jnz	@@ver

	; draw scroller
	mov	edi, frame_buffer
	add	edi, 64000-8*320-320
	mov	esi, offset scroll_buffer
	mov	ecx, 8*320
@@put_pix:
	lodsb
	or	al, al
	jz	@@next_pix
	mov	byte ptr [edi], al
@@next_pix:
	inc	edi
	dec	ecx
	jnz	@@put_pix
	ret
endp

;------------------------------------------------------------
;	part 1 - bump mapping
;------------------------------------------------------------

bump_mapping proc
	; update light position
	add	pos_light_x, 2
	add	pos_light_y, 1

	; get coordinates of light
	mov	eax, pos_light_x
	and	eax, 255
	shl	eax, 2
	mov	eax, dword ptr way_table[eax]
	shl	eax, 1
	add	eax, 160
	mov	light_x, eax

	mov	eax, pos_light_y
	and	eax, 255
	shl	eax, 2
	mov	eax, dword ptr way_table[eax]
	sar	eax, 1
	add	eax, 100
	mov	light_y, eax

	; main code of bumper
	mov	edi, frame_buffer
	add	edi, 320
	mov	esi, ptr_bumpmap
	add	esi, 320

	mov	edx, 1
@@ver:
	xor	ecx, ecx
@@hor:
	movzx	eax, byte ptr [esi-1]
	movzx	ebp, byte ptr [esi+1]
	sub	eax, ebp			; eax = tex[y][x-1] - tex[y][x+1]
	
	sub	eax, ecx
	add	eax, light_x
	add	eax, 128			; eax -= (x - light_x)
						; eax += 128	
	or	eax, eax
	jge	@@ok1
	xor	eax, eax
	jmp	@@put_pixel
@@ok1:
	cmp	eax, 255
	jle	@@ok2
	xor	eax, eax
	jmp	@@put_pixel
@@ok2:
	movzx	ebx, byte ptr [esi-320]
	movzx	ebp, byte ptr [esi+320]
	sub	ebx, ebp			; ebx = tex[y-1][x] - tex[y+1][x]

	sub	ebx, edx
	add	ebx, light_y
	add	ebx, 128			; ebx -= (y - light_y)
						; ebx += 128	
	or	ebx, ebx
	jge	@@ok3
	xor	eax, eax
	jmp	@@put_pixel
@@ok3:
	cmp	ebx, 255
	jle	@@ok4
	xor	eax, eax
	jmp	@@put_pixel
@@ok4:

	shl	ebx, 8
	add	ebx, eax
	add	ebx, ptr_envmap
	mov	al, byte ptr [ebx]
@@put_pixel:
	stosb
	inc	esi

	inc	ecx
	cmp	ecx, 320
	jl	@@hor
	inc	edx
	cmp	edx, 199
	jl	@@ver
	ret
endp

;------------------------------------------------------------
;	part 2 - tunnel effect
;------------------------------------------------------------

do_tunnel proc
	mov	esi, ptr_tunnel
	mov	edi, frame_buffer
	mov	ecx, 64000
@@do:
	movzx	eax, byte ptr [esi]
	movzx	ebx, byte ptr [esi + 1]
	add	eax, t_add_x
	and	eax, 255
	add	ebx, t_add_y
	and	ebx, 255
	shl	ebx, 8
	add	ebx, eax
	add	ebx, ptr_texture
	mov	al, byte ptr [ebx]
	sub	al, byte ptr [esi + 2]
	stosb
	add	esi, 3
	dec	ecx
	jnz	@@do

	; move tunnel
	add	t_add_x, 1
	add	t_add_y, 1
	ret
endp

init_bumpmap proc
	mov	edi, ptr_bumpmap
	mov	eax, -1
	mov	ecx, 65536/4
	cld
	rep	stosd

	; unpack logo
	mov	esi, offset packed_logo
	mov	edi, ptr_bumpmap
	add	edi, 32000-(320*70/2)
	mov	ecx, 320*70/8
@@unpack:
	lodsb
	mov	edx, 8
@@bit_test:
	rcl	al, 1
	jnc	@@next
	mov	byte ptr [edi], 0
@@next:
	inc	edi
	dec	edx
	jnz	@@bit_test
	dec	ecx
	jnz	@@unpack

	; make random thrash
	mov	edi, ptr_bumpmap
	mov	ecx, 65536
@@rnd:
	push	ecx
	mov	ecx, 1
	mov	edx, 255
	call	random
	cmp	byte ptr [edi], 0
	je	@@next_pix
	mov	byte ptr [edi], al
@@next_pix:
	inc	edi
	pop	ecx
	dec	ecx
	jnz	@@rnd

	; blur 4 times
	mov	ecx, 4
	mov	edx, ptr_bumpmap
	mov	ebp, 320
@@blur:
	call	blur_seg
	dec	ecx
	jnz	@@blur

	ret
endp

blur_seg proc
	push	ecx
	xor	eax, eax
	xor	ebx, ebx
	
	xor	edi, edi
	mov	ecx, 65536
@@blur:
	mov	esi, edi
	dec	esi
	and	esi, 0ffffh
	add	esi, edx			; edx - texture offset
	mov	al, byte ptr [esi]

	mov	esi, edi
	inc	esi
	and	esi, 0ffffh
	add	esi, edx
	mov	bl, byte ptr [esi]
	add	eax, ebx

	mov	esi, edi
	sub	esi, ebp
	and	esi, 0ffffh
	add	esi, edx
	mov	bl, byte ptr [esi]
	add	eax, ebx
	
	mov	esi, edi
	add	esi, ebp
	and	esi, 0ffffh
	add	esi, edx
	mov	bl, byte ptr [esi]
	add	eax, ebx
	
	shr	eax, 2
	mov	esi, edi
	add	esi, edx
	mov	byte ptr [esi], al

	inc	edi
	dec	ecx
	jnz	@@blur

	pop	ecx
	ret
endp

init_envmap proc
	mov	edi, ptr_envmap

	mov	edx, -128
@@ver:
	mov	ecx, -128
@@hor:
	mov	_temp32, ecx
	fild	_temp32
	fdiv	em_const1
	fmul	st, st

	mov	_temp32, edx
	fild	_temp32
	fdiv	em_const1
	fmul	st, st

	faddp	st(1), st
	fsqrt
	fmul	em_const2
	fistp	_temp32
	mov	eax, 63
	sub	eax, _temp32

	or	eax, eax
	jge	@@ok1
	xor	eax, eax
	jmp	@@ok2
@@ok1:
	cmp	eax, 63
	jle	@@ok2
	mov	eax, 63
@@ok2:
	stosb

	inc	ecx
	cmp	ecx, 128
	jl	@@hor
	inc	edx
	cmp	edx, 128
	jl	@@ver
	ret
endp

init_way proc
	mov	edi, offset way_table
	xor	ecx, ecx
@@init:
	fldpi
	mov	_temp32, ecx
	fimul	_temp32
	mov	_temp32, 256/2
	fidiv	_temp32
	fsin
	sar	_temp32, 1
	fimul	_temp32
	fistp	dword ptr [edi]

	add	edi, 4
	inc	ecx
	cmp	ecx, 256
	jne	@@init
	ret
endp

comment #
init_texture proc
	mov	edi, ptr_texture
	
	xor	edx, edx
@@ver:
	xor	ecx, ecx
@@hor:
	mov	eax, ecx
	xor	eax, edx
	and	eax, 63
	stosb
	inc	ecx
	cmp	ecx, 256
	jne	@@hor
	inc	edx
	cmp	edx, 256
	jne	@@ver

	mov	edx, ptr_texture
	mov	ecx, 2
@@b:
	call	blur_seg
	dec	ecx
	jnz	@@b
	ret
endp #

init_texture proc
	mov	edi, offset tex_cos_tab
	mov	ecx, 256
	fldz
@@gen_cos:
	fld	st
	fcos
	fmul	tex_mul
	fistp	_temp32
	mov	eax, _temp32
	stosb
	fadd	a_step
	dec	ecx
	jnz	@@gen_cos
	ffree

	mov	edi, ptr_texture
	mov	edx, 256
@@ver:
	mov	ecx, 256
@@hor:
	movzx	ebx, a1
	mov	al, byte ptr tex_cos_tab[ebx]
	movzx	ebx, a2
	add	al, byte ptr tex_cos_tab[ebx]
	movzx	ebx, a3
	add	al, byte ptr tex_cos_tab[ebx]
	movzx	ebx, a4
	add	al, byte ptr tex_cos_tab[ebx]
	and	al, 63
	;shr	al, 1
	;add	al, 16
	stosb

	add	a1, 4
	add	a2, 3
	dec	ecx
	jnz	@@hor

	add	a3, 1
	add	a4, 5
	dec	edx
	jnz	@@ver

	mov	edx, ptr_texture
	mov	ebp, 256
	call	blur_seg
	call	blur_seg
	ret
endp

init_tunnel proc
	mov	edi, ptr_tunnel
	mov	edx, -100
@@ver:
	mov	ecx, -160
@@hor:
	mov	_temp32, ecx
	fild	_temp32
	fmul	st, st
	mov	_temp32, edx
	fild	_temp32
	fmul	st, st
	faddp	st(1), st
	fsqrt
	fist	_temp32_1
	fld1
	faddp	st(1), st
	fdivr	tunnel_persp
	fistp	_temp32
	mov	eax, _temp32
	and	eax, 255
	stosb				; tex_x = persp / (sqrt(x^2 + y^2) +1)
	mov	_temp32, edx
	fild	_temp32
	mov	_temp32, ecx
	fild	_temp32
	fpatan
	fmul	tunnel_const
	fistp	_temp32
	mov	eax, _temp32
	and	eax, 255
	stosb				; tex_y = atan(y, x)*tunnel_const
	mov	eax, 189 - 32
	sub	eax, _temp32_1
	shr	eax, 2
	or	al, al
	jae	@@it_ok1
	xor	al, al
@@it_ok1:
	stosb
	inc	ecx
	cmp	ecx, 160
	jl	@@hor
	inc	edx
	cmp	edx, 100
	jl	@@ver
	ret
endp

flash proc
	mov	eax, flash_c
	cmp	eax, 64
	je	@@quit
	or	eax, eax
	jnz	@@do_flash

	mov	edi, offset flash_dest_pal
	call	get_palette

	mov	edx, 03c8h
	xor	eax, eax
	out	dx, al
	inc	edx
	mov	ecx, 768
	mov	eax, 63
@@set_white:
	out	dx, al
	dec	cx
	jnz	@@set_white
@@do_flash:

	mov	edi, offset flash_curr_pal
	call	get_palette

	mov	esi, offset flash_curr_pal
	mov	edi, offset flash_dest_pal
	mov	ecx, 768
@@dec_colors:
	lodsb
	cmp	al, byte ptr [edi]
	je	@@next
	dec	al
	mov	byte ptr [esi-1], al
@@next:
	inc	edi
	dec	ecx
	jnz	@@dec_colors

	mov	esi, offset flash_curr_pal
	call	set_palette

	inc	flash_c
@@quit:
	ret
endp

include kernel\kernel.inc
include alloc.asm
include random.asm
include graph.asm

include palette1.inc
include logo.inc

REQ_MEM		equ 64000 + 65536 + 65536 + 65536 + 64000*3

PART_TIMEOUT	equ 800
TEXT_COLOR	equ 64

scroll_text	db 'New Age ASM Group proudly presents a short intro made '
		db 'by Majuma in pure 32-bit Assembler ;) *** '
		db 'If you want to join our group or just have any reason for '
		db 'contacting us, visit our web page: www.naag.prv.pl *** ' 
		db 'Greetings are scrolling to all members of NAAG: HaRv3sTeR, '
		db 'Klemik, tOudi, SEM, pkmiecik, Overlord, Oolv, Miodzio, '
		db 'asmCode, _TeStON_, Zedd and anybody I forgot... Keep coding !'
		db 30 dup(32), 0

; envmap variables
em_const1	dd 128.0
em_const2	dd 63.0

em_color_mul	dd 0.2

tunnel_persp	dd 4096.0
tunnel_const	dd 81.487330863		; 256/pi

; texture generator		
a_step		dd 0.025
tex_mul		dd 31.0
tex_cos_tab	db 256 dup(?)
a1		db ?
a2		db ?
a3		db ?
a4		db ?

t_add_x		dd ?
t_add_y		dd ?

main_counter	dd ?
curr_part	dd ?

_regs		dpmi_regs ?
_temp32		dd ?
_temp32_1	dd ?

; handle to allocated memory
mem_handle	dd ?

; pointers
ptr_envmap	dd ?
ptr_bumpmap	dd ?

ptr_texture	dd ?
ptr_tunnel	dd ?

; bump mapping variables
way_table	dd 256 dup(?)
pos_light_x	dd ?
pos_light_y	dd ?
light_x		dd ?
light_y		dd ?

; flash effect
flash_c		dd ?
flash_curr_pal	db 768 dup(?)
flash_dest_pal	db 768 dup(?)

scroll_buffer	db 320*8 dup(?)
curr_letter	dd ?
curr_line	dd ?

ptr_font	dd ?

code32 ends
end
