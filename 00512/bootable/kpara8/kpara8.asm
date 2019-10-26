bits 16

cpu 486

%define base                            0x7C00
%define num_mat_elem                    20
%define run_secs                        60
%define introdelay                      0
%define scr_width                       640
%define scr_height                      480
%define scr_size                        (scr_width * scr_height)
%define vga_font_seg                    0xF7A0
%define vga_font_off                    0x806E
%define vga_font_len                    96
%define vga_font_size                   (vga_font_len * 64)
%define custom_base                     vga_font_len
%define custom_font_buf                 (vga_font + vga_font_size)
%define custom_font_len                 ((customfontlen * 8) / 36)
%define custom_font_size                (custom_font_len * 64)
%define temp_font_loc                   (customfontlen * -8)
%define seg(x)                          ((x - $$ + base) >> 4)
%define addr(x)                         ((x - $$) - ((dstart - $$) & ~15))

%define glyphseg                        0x2000
%define backbuffer_seg                  0x4000

section .text
org base

init:
	push	seg(dstart)
	pop	ss					; ss = seg(dstart)
	xor	sp, sp					; sp = 0000

	mov	ax, 0x4F02				; ax = 4F02
	mov	bx, 0x0100				; bx = 0100
	int	0x10					; Enter 640x400x256

	mov	ax, 0x4F01				; ax = 4F01
	mov	cx, bx					; cx = 0100
	push	ss
	pop	es					; es = seg(dstart)
	mov	di, addr(vesamodeblk)			; es:di = vesamodeblk
	int	0x10					; Get mode info

	cli						; IF = 0
	cld						; DF = 0

	mov	cx, 11					; cx = 000B
.zero_regs:
	push	0					; *--sp = 0
	loop	.zero_regs				; cx = 0000

	popa

	; Current state:
	; ax = 0000
	; bx = 8000
	; cx = 0000
	; dx = 0000
	; si = 0000
	; di = 0000
	; bp = 0000
	; sp = FFFA
	; cs = ????
	; ds = ????
	; es = 7000
	; ss = data_seg
	; CF = 0
	; OF = 1
	; ZF = 0
	; SF = 1

	; Zero out backbuffer
	mov	bh, backbuffer_seg >> 8			; bx = backbuffer_seg
.backbuffer_zero:
	mov	es, bx					; es = backbuffer
	mov	ch, 0x80				; cx = 8000
	rep	stosw					; cx = 0000
	add	bh, 0x10				; es += 0x1000
	jns	.backbuffer_zero			; bx = 8000

	bsf	dx, [bp+addr(vesamodeblk)+4]		; dx = log2(blk_kb)
	neg	dx					; dx = -log2(blk_kb)
	add	[cs:bx+.page_adj+2-0x8000], dx		; Adjust shift count

	; Current state:
	; ax = 0000
	; bx = 8000
	; cx = 0000
	; dx = ????
	; si = 0000
	; di = 0000
	; bp = 0000
	; sp = FFFA
	; cs = ????
	; ds = ????
	; es = 7000
	; ss = seg(dstart)
	; CF = 0
	; OF = 1
	; ZF = 0
	; SF = 1

	; First 16 entries = solid white block
	mov	al, 0xFF				; ax = ??7F
	mov	ch, 4					; cx = 0400
	push	glyphseg
	pop	es					; es = glyphseg
	rep stosb					; cx = 0000
	         					; di = 0400

	; Current state:
	; ax = 007F
	; bx = 8000
	; cx = 0000
	; dx = ????
	; si = 0000
	; di = 0400
	; bp = 0000
	; sp = FFFA
	; cs = ????
	; ds = ????
	; es = 7000
	; ss = seg(dstart)
	; CF = 0
	; OF = 1
	; ZF = 0
	; SF = 1

	; Unpack custom font
	mov	ch, custom_font_size/256		; cx = custom_font_size
.unpack_custom_font:
	mov	al, 0x3F				; ax = 63
	and	ax, di					; ax = di & 63
	bt	[bp+addr(borderdata)], ax		; CF = load next char?
	jnc	.skip_load
	bt	[bp+addr(customfont)], si		; CF = next bit
	inc	si					; si++
.skip_load:
	salc
	stosb
	loop	.unpack_custom_font			; cx = 0000

	; Current state:
	; ax = 0000
	; bx = 8000
	; cx = 0000
	; dx = ????
	; si = custom_font_len*36
	; di = 0800
	; bp = 0000
	; sp = FFFA
	; cs = ????
	; ds = ????
	; es = 7000
	; ss = seg(dstart)
	; CF = 0
	; OF = ?
	; ZF = ?
	; SF = ?

	; Copy lower 128 VGA font chars -> 8x8 table
	mov	ch, ((vga_font_size + 255) / 256)	; cx = vga_font_size + slop
	push	vga_font_seg
	pop	ds					; ds = vga_font_seg

.vga_font_loop:
	mov	ax, di					; ax = di
	xor	al, 7					; ax = di ^ 7
	bt	[bx+vga_font_off-0x8000], ax		; CF = next bit
	salc						; al = next pixel (0 or 255)
	stosb						; *di++ = al
	loop	.vga_font_loop				; cx = 0000

	; Current state:
	; ax = 1F??
	; bx = 8000
	; cx = 0000
	; dx = ????
	; si = custom_font_len*36
	; di = 2000
	; bp = 0000
	; sp = FFFA
	; cs = ????
	; ds = vga_font_seg
	; es = 7000
	; ss = seg(dstart)
	; CF = ?
	; OF = ?
	; ZF = ?
	; SF = ?

	; Set up palette
	mov	dx, 0x03C8				; dx = 03C8
	pop	ax					; ax = 0000
	out	dx, al					; index = 0
	inc	dx					; dx = 03C9

.palette_loop:
	; ax = red/blue
	; cx = green
	out	dx, al
	xchg	ax, cx					; ax = green
	    	      					; cx = red/blue
	out	dx, al
	xchg	ax, cx					; ax = red/blue
	    	      					; cx = green
	out	dx, al
	out	dx, al
	xchg	ax, cx					; ax = green
	    	      					; cx = red/blue
	out	dx, al
	xchg	ax, cx					; ax = red/blue
	    	      					; cx = green
	out	dx, al
.ctr:
	inc	cx					; ax = 003F
	add	bl, 2
	jz	.done_palette
	jno	.palette_loop
	dec	byte [cs:bp+.ctr]
	dec	cx					; cx = 003F
	jmp	.palette_loop

.done_palette:
	; Current state:
	; ax = 003F
	; bx = 8000
	; cx = 003F
	; dx = 03C9
	; si = custom_font_len*36
	; di = 2000
	; bp = 0000
	; sp = FFFC
	; cs = ????
	; ds = vga_font_seg
	; es = 7000
	; ss = seg(dstart)
	; CF = 1
	; OF = 0
	; ZF = 1
	; SF = 0

	mov	fs, dx					; rand_seed = 03C9
	mov	bx, render_intro			; bx = render_intro
	pop	cx					; cx = 0000

	; Current state:
	; ax = 003F
	; bx = render_intro
	; cx = 0000
	; dx = 03C9
	; si = custom_font_len*36
	; di = 2000
	; bp = 0000
	; sp = FFFE
	; cs = ????
	; ds = vga_font_seg
	; es = 7000
	; ss = seg(dstart)
	; CF = 1
	; OF = 0
	; ZF = 1
	; SF = 0

.renderloop:
	; Current state:
	; ax = 003F
	; bx = render_intro
	; cx = 003F
	; dx = 03C9
	; si = custom_font_len*36
	; di = 2000
	; bp = 0000
	; sp = FFFE
	; cs = ????
	; ds = vga_font_seg
	; es = 7000
	; ss = seg(dstart)
	; CF = ?
	; OF = ?
	; ZF = ?
	; SF = ?

	; Wait for vsync
	mov	dx, 0x03DA				; dx = 03DA
.wait1:
	in	al, dx
	test	al, 8
	jz	.wait1
.wait2:
	in	al, dx
	test	al, 8
	jnz	.wait2

	mov	ax, backbuffer_seg			; ax = backbuffer_seg
	push	0xA000
	pop	es					; es = A000
	xor	dx, dx					; dx = 0000
	xor	si, si					; si = 0000
	xor	di, di					; di = 0000

	; Current state:
	; ax = backbuffer_seg
	; bx = render_func
	; cx = 0000
	; dx = 0000
	; si = 0000
	; di = 0000
	; bp = 0000
	; sp = FFFE
	; cs = ????
	; ds = ????
	; es = A000
	; ss = seg(dstart)
	; CF = 0
	; OF = 0
	; ZF = 1
	; SF = 0

.backbuffer_copy:
	pusha
	mov	ax, 0x4F05				; ax = 4F05
	xor	bx, bx
.page_adj:
	shl	dx, 6
	int	0x10
	popa

	mov	ds, ax					; ds = backbuffer_seg + window
	mov	ch, 0x80				; cx = 8000
	rep	movsw					; cx = 0000

	inc	dx
	add	ah, 0x10
	jns	.backbuffer_copy			; ax = 8000

	; Current state:
	; ax = 8000
	; bx = render_func
	; cx = 0000
	; dx = 0004
	; si = 0000
	; di = 0000
	; bp = 0000
	; sp = FFFE
	; cs = ????
	; ds = 7000
	; es = A000
	; ss = seg(dstart)
	; CF = ?
	; OF = ?
	; ZF = ?
	; SF = ?

	pop	ax
	add	dx, ax
	jz	.exit
	push	dx

	call	bx

	in	al, 0x64
	shr	al, 1					; CF = data ready
	jnc	.renderloop

.exit:
	jmp	0xFFFF:0x0000

	; Input:
	; ss:si = pointer to end of elem
	; bp = 0000
	;
	; Output:
	; ax = ????
	; fl = ????
gen_matdata_elem:
	call	rand
	and	ax, 0x3FFF
	mov	[bp+si-4], ax
	call	rand
	and	ax, 0x0101
	mov	[bp+si-2], ax
	ret

	; Input:
	; None
	;
	; Output:
	; ax = random number
	; fs = rand_seed
	; fl = ????
rand:
	mov	ax, fs
	imul	ax, 13
	xchg	ah, al
	inc	ax
	mov	fs, ax
	ret

	; Input:
	; ax = tick
	; cx = 0000
	; si = 0000
	; di = 0000
	; bp = 0000
	; ss = seg(dstart)
	;
	; Output:
	; ax = ????
	; dx = 8000
	; si = ????
	; di = ????
	; fl = ????
render_main:
	; Fade current screen
	mov	dx, backbuffer_seg

.fade:
	mov	es, dx

.inner_fade:
	es lodsb
	sub	al, 4
	sbb	ah, ah
	not	ah
	and	al, ah
	stosb
	loop	.inner_fade

	add	dh, 0x10
	jns	.fade

	; Mat data elem:
	; [00] = (Y*320)+X
	; [02] = ticks left on cur char
	; [03] = initial
	mov	cl, num_mat_elem

.matloop:
	; Load the destination pointer
	ss lodsw
	xchg	ax, di

	; Check to see if it's our time to fall
	dec	byte [bp+si]
	ss lodsw
	jns	.do_nothing

	mov	[bp+si-2], ah
	add	byte [bp+si-3], scr_width*8/256/4
	jnc	.ok

	call	gen_matdata_elem

.ok:
	call	rand
	mov	ah, 3
	and	al, 0x0F
	or	al, 0x10
	call	blit

.do_nothing:
	loop	.matloop				; cx = 0000

	ret

	; Input:
	; cx = 0000
	; si = 0000
	; bp = 0000
	; ss = seg(dstart)
	;
	; Output:
	; ax = 0000
	; bx = render_main
	; si = num_mat_elem*4
	; fl = ????
switch_render:
	mov	cl, num_mat_elem

.random_loop:
	add	si, 4
	call	gen_matdata_elem
	loop	.random_loop				; cx = 0000

	; Switch to blend mode
	mov	word [bp+addr(blit.accumulate)], 0x050A

	; Launch next stage
	mov	bx, render_main				; bx = render_main

	ret

	; Input:
	; ax = tick
	; cx = 0000
	; si = 0000
	; di = 0000
	; bp = 0000
	; ss = seg(dstart)
	;
	; Output:
	; ax = 0000
	; si = ????
	; di = ????
	; fl = ????
render_intro:
	shr	ax, 4
	cmp	al, introtextlen + introdelay
	jae	switch_render

	cmp	al, introtextlen
	jae	.skip_frame

	imul	di, ax, 2
	add	di, ((scr_width-(introtextlen*8))/2)/4
	xchg	ax, si
	mov	al, [bp+si+addr(introtext)]
	call	blit

	add	di, 2					; di += 0002
	salc						; al = 00
	call	blit

.skip_frame:
	ret

dstart EQU $

customfont:
	db 0xAA
	db 0x0A
	db 0x82
	db 0xB0
	db 0x37
	db 0x0C
	db 0xFF
	db 0x3F
	db 0x0C
	db 0x10
	db 0x46
	db 0x79
	db 0x90
	db 0x47
	db 0xF8
	db 0x06
	db 0xC3
	db 0x68
	db 0x88
	db 0x8F
	db 0x70
	db 0x08
	db 0x41
	db 0xFD
	db 0x92
	db 0xC0
	db 0x60
	db 0x1C
	db 0x45
	db 0x91
	db 0x22
	db 0xF0
	db 0xE0
	db 0x88
	db 0x87
	db 0xFC
	db 0x30
	db 0x62
	db 0x32
	db 0x30
	db 0xC0
	db 0x21
	db 0xBE
	db 0x08
	db 0x73
	db 0x06
	db 0x60
	db 0x80
	db 0xA0
	db 0x07
	db 0xFC
	db 0x80
	db 0x07
	db 0xFC
	db 0x3E
	db 0x08
	db 0x82
	db 0xA0
	db 0x2F
	db 0xFC
	db 0x92
	db 0x23
	db 0x7C
	db 0x3E
	db 0xE2
	db 0x91
	db 0x04
	db 0xE6
	db 0x01
	db 0x1E
	db 0x04
	db 0x39

introtext:
	db "What is #asm?"

introtextlen equ $-introtext

customfontlen equ $-customfont

borderdata:
	db 0x00
	db 0x7E
	db 0x7E
	db 0x7E
	db 0x7E
	db 0x7E
	db 0x7E
	db 0x00

	; Input:
	; al = src_char
	; di = ((x * 640) + y) / 4
	;
	; Output:
	; ds = ????
	; es = ????
	; fl = ????
blit:
	pusha

	push	glyphseg
	pop	ds					; ds = glyphseg

	cbw						; ax = al
	imul	si, ax, 64				; si = src_ptr

	push	di
	shr	di, 2
	add	di, backbuffer_seg
	mov	es, di
	pop	di
	and	di, 3
	shl	di, 2

	mov	cl, 8					; cl = width

.scanline:
	mov	ch, 8					; ch = height

.addloop:
	lodsb
	es
.accumulate:
	nop
	nop
	stosb						; dest[y][x] |= src[y][x]
	dec	ch					; ch = ch - 1
	jnz	.addloop				; ch = 0

	add	di, scr_width - 8			; di = dest + dest_stride
	loop	.scanline

	popa
	ret

vesamodeblk:

times 510-($-$$) db 0
dw 0xAA55
