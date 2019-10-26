;------------------------------------------------------------
;	SinScr by Majuma
;	mfelix@polbox.com
;	www.ps.nq.pl / www.naag.prv.pl
;
;	updated: 19/01/02, 21/01/02, 22/01/02
;------------------------------------------------------------

.386p
locals

code32 segment para public use32
	assume cs:code32, ds:code32

_main:
	mov	eax, MEM_TO_ALLOC
	call	alloc_mem
	or	eax, eax
	jz	quit_me
	mov	d [MemHandle], eax

	; set pointers
	mov	d [FrameBuffer], ebx
	add	ebx, 64000
	mov	d [Palette], ebx
	add	ebx, 768
	mov	d [FontTable], ebx
	add	ebx, FTAB_SIZE
	mov	d [scr_buffer], ebx
	add	ebx, 32*320
	mov	d [SineWave], ebx
	add	ebx, 256*4
	mov	d [LogoNAAG], ebx
	add	ebx, 128*32
	mov	d [ZoomerLookups], ebx
	;add	ebx, (320 + 200)*4

	mov	eax, 0a0000h
	sub	eax, d [code32_base]
	mov	d [VideoMem], eax

	; init linear palette
	mov	edi, d [Palette]
	xor	eax, eax
	mov	ecx, 64
	cld
slp_1:
	xor	al, al
	stosb
	stosb
	mov	al, ah
	stosb
	inc	ah
	loop	slp_1

	xor	eax, eax
	mov	ecx, 64
slp_2:
	xor	al, al
	stosb
	mov	al, ah
	stosb
	mov	al, 63
	stosb
	inc	ah
	loop	slp_2

	xor	eax, eax
	mov	ecx, 64
slp_3:
	mov	al, ah
	stosb
	mov	al, 63
	stosb
	stosb
	inc	ah
	loop	slp_3

	mov	eax, 63
	mov	ecx, 64 * 3
	rep	stosb


	; init SineWave
	finit
	mov	edi, d [SineWave]
	xor	ecx, ecx
isw_loop:
	mov	d [_temp32], ecx
	fild	d [_temp32]
	fmul	d [pi_128]
	fsin
	mov	d [_temp32], SINEWAVE_AMP
	fimul	d [_temp32]
	fistp	d [edi]
	add	edi, 4
	inc	ecx
	cmp	ecx, 256
	jne	isw_loop
	

	; init font
	call	init_font

	; make NAAG logo
	call	clear_buffer
	mov	esi, o txt_logo
	mov	ecx, 4
	mov	edx, 2
	call	put_string

	mov	ecx, 2
mnl_blur:
	push	ecx
	call	blurer
	pop	ecx
	loop	mnl_blur

	mov	esi, d [FrameBuffer]
	mov	edi, d [LogoNAAG]
	mov	edx, 32
mnl_loop:
	mov	ecx, 128 / 4
mnl_c:
	lodsd
	and	eax, 0fcfcfcfch ;0fefefefeh
	shr	eax, 2
	stosd
	dec	ecx
	jnz	mnl_c
	add	esi, 320 - 128
	dec	edx
	jnz	mnl_loop


	; clear scroll
	mov	edi, d [scr_buffer]
	xor	eax, eax
	mov	ecx, 32*320/4
	rep	stosd

	; set 13h mode
	mov	edi, o _regs
	mov	d [edi._eax], 00000013h
	mov	eax, 300h
	mov	ebx, 10h
	int	31h

	mov	esi, d [Palette]
	call	set_palette

;------------------------------------------------------------

main_loop:
	mov	ebp, o scr_letter
	call	scroll_text

	; put scroll buffer
	;mov	esi, d [scr_buffer]
	;mov	edi, d [FrameBuffer]
	;mov	ecx, 32*320/4
	;cld
	;rep	movsd

	inc	d [scale_delay]
	cmp	d [scale_delay], 400
	jne	sc_ok
	mov	d [scale_delay], 0
	neg	d [scale_dir]
sc_ok:
	test	d [scale_delay], 1
	jz	sc_call

	mov	eax, d [scale_dir]
	add	d [scale], eax
sc_call:
	mov	eax, d [scale]
	mov	esi, d [LogoNAAG]
	call	zoomer


	; put using sine wave
	mov	esi, d [scr_buffer]
	sub	d [WaveStart], 2
	mov	ebp, d [WaveStart]
	xor	ecx, ecx
	cld
pusw_h:
	mov	eax, ebp
	and	eax, 255
	shl	eax, 2
	add	eax, d [SineWave]
	mov	eax, d [eax]
	add	eax, 100 - SINEWAVE_AMP - (LETTER_SIZE / 2)
	mov	ebx, eax
	shl	eax, 6
	shl	ebx, 8
	add	eax, ebx
	add	eax, ecx
	mov	edi, eax
	add	edi, d [FrameBuffer]
	push	esi
	mov	edx, LETTER_SIZE
pusw_v:
	;movsb
	;add	esi, 319
	;add	edi, 319
	
	lodsb
	or	al, al
	jz	pusw_next
	mov	b [edi], al
pusw_next:
	add	esi, 319
	add	edi, 320
	dec	edx
	jnz	pusw_v

	pop	esi
	inc	esi

	inc	ebp
	inc	ecx
	cmp	ecx, 320
	jne	pusw_h


	mov	edx, 03dah
vr_1:
	in	al, dx
	test	al, 8
	jz	vr_1
vr_2:
	in	al, dx
	test	al, 8
	jnz	vr_2

	call	copy_buffer
	;call	clear_buffer

	in	al, 60h
	dec	al
	jnz	main_loop

;------------------------------------------------------------


	mov	edi, o _regs
	mov	d [edi._eax], 00000003h
	mov	eax, 300h
	mov	ebx, 10h
	int	31h

	mov	eax, d [MemHandle]
	call	free_mem

quit_me:
	ret

;------------------------------------------------------------

init_font:
	mov	edi, o _regs
	mov	d [edi._eax], 00001130h
	mov	d [edi._ebx], 00000300h
	mov	eax, 0300h
	mov	ebx, 10h
	int	31h
	movzx	eax, w [edi._es]
	shl	eax, 4
	movzx	ebx, w [edi._ebp]
	add	eax, ebx
	sub	eax, d [code32_base]
	mov	esi, eax
	; save font address !
	push	esi
	
	mov	edi, d [FontTable]
	mov	ecx, FTAB_SIZE / 4
	xor	eax, eax
	cld
	rep	stosd

comment #
	; make "background" (letter 0, usually unused)
	mov	edi, d [FontTable]
	mov	esi, 256
	mov	ecx, LETTER_SIZE
ifont_back:
	mov	eax, esi
	mov	ah, al
	mov	dx, ax
	shl	eax, 16
	mov	ax, dx
	push	ecx
	mov	ecx, LETTER_SIZE / 4
	rep	stosd
	pop	ecx
	sub	esi, 256 / LETTER_SIZE
	loop	ifont_back #

	
	mov	edi, d [FontTable]
	xor	edx, edx
ifont_back_v:
	xor	ecx, ecx
ifont_back_h:
	mov	eax, ecx
	add	eax, edx
	shr	eax, 1
	add	eax, 32
	stosb

	add	ecx, (256 / 2) / LETTER_SIZE
	cmp	ecx, 256 / 2
	jne	ifont_back_h

	add	edx, (256 / 2) / LETTER_SIZE
	cmp	edx, 256 / 2
	jne	ifont_back_v


	; restore font address and skip first letter
	pop	esi
	add	esi, 8
	mov	ecx, 256 - 1
ifont_letter:
	push	ecx
	mov	ecx, 8
	xor	ebx, ebx
ifont_v:
	mov	edx, 8
	lodsb
ifont_h:
	rcl	al, 1
	jnc	ifont_next
	;mov	d [edi + ebx], LETTER_COLOR
	;mov	d [edi + ebx + LETTER_SIZE], LETTER_COLOR
	;mov	d [edi + ebx + LETTER_SIZE*2], LETTER_COLOR
	;mov	d [edi + ebx + LETTER_SIZE*3], LETTER_COLOR

	push	eax
	mov	ebp, d [FontTable]
	mov	eax, d [ebp + ebx]
	mov	d [edi + ebx], eax
	mov	eax, d [ebp + ebx + LETTER_SIZE]
	mov	d [edi + ebx + LETTER_SIZE], eax
	mov	eax, d [ebp + ebx + LETTER_SIZE*2]
	mov	d [edi + ebx + LETTER_SIZE*2], eax
	mov	eax, d [ebp + ebx + LETTER_SIZE*3]
	mov	d [edi + ebx + LETTER_SIZE*3], eax
	pop	eax
ifont_next:
	add	ebx, 4
	dec	edx
	jnz	ifont_h
	add	ebx, LETTER_SIZE*3
	loop	ifont_v

	add	edi, (LETTER_SIZE * LETTER_SIZE)
	pop	ecx
	loop	ifont_letter

comment #
	mov	ecx, 2
ifont_make_blur:
	push	ecx
	
	mov	edi, d [FontTable]
	mov	ecx, 256
ifont_blur:
	mov	edx, (LETTER_SIZE * LETTER_SIZE)
	xor	eax, eax
	xor	ebx, ebx
	xor	esi, esi
ifont_bb:
	mov	ebp, esi
	dec	ebp
	and	ebp, (LETTER_SIZE * LETTER_SIZE) - 1
	mov	al, b [ebp + edi]

	mov	ebp, esi
	inc	ebp
	and	ebp, (LETTER_SIZE * LETTER_SIZE) - 1
	mov	bl, b [ebp + edi]
	add	eax, ebx

	mov	ebp, esi
	sub	ebp, LETTER_SIZE
	and	ebp, (LETTER_SIZE * LETTER_SIZE) - 1
	mov	bl, b [ebp + edi]
	add	eax, ebx

	mov	ebp, esi
	add	ebp, LETTER_SIZE
	and	ebp, (LETTER_SIZE * LETTER_SIZE) - 1
	mov	bl, b [ebp + edi]
	add	eax, ebx
	shr	eax, 2

	mov	b [esi + edi], al
	inc	esi
	dec	edx
	jnz	ifont_bb

	add	edi, (LETTER_SIZE * LETTER_SIZE)
	loop	ifont_blur

	pop	ecx
	loop	ifont_make_blur #
	ret

;------------------------------------------------------------

; in: esi = string ptr, ecx = x, edx = y
put_string:
	mov	edi, d [FrameBuffer]
	mov	eax, edx
	shl	eax, 6
	shl	edx, 8
	add	eax, edx
	add	edi, eax
	add	edi, ecx
	cld

ps_letter:
	lodsb
	or	al, al
	jz	ps_quit
	push	edi

	; get offset, LETTER_SIZE^2 = 1024 = 2^10
	movzx	ebp, al
	shl	ebp, 10
	add	ebp, d [FontTable]

	mov	edx, LETTER_SIZE
ps_v:
	mov	ecx, LETTER_SIZE
ps_h:
	mov	al, b [ebp]
	or	al, al
	jz	ps_next
	mov	b [edi], al
ps_next:
	inc	ebp
	inc	edi
	dec	ecx
	jnz	ps_h
	add	edi, 320 - LETTER_SIZE
	dec	edx
	jnz	ps_v

	pop	edi
	add	edi, LETTER_SIZE
	jmp	ps_letter
ps_quit:
	ret

;------------------------------------------------------------

; in: ebp = scroll params ptr
scroll_text:
	cld

	cmp	d [ebp + 4], LETTER_SIZE
	jb	scrt_ok

	mov	d [ebp + 4], 0
	inc	d [ebp + 0]
scrt_ok:
	mov	esi, d [ebp + 12]
	add	esi, d [ebp + 0]
	lodsb
	or	al, al
	jz	scrt_repeat

	movzx	esi, al
	shl	esi, 10			; esi * (LETTER_SIZE^2)
	add	esi, d [FontTable]

	mov	eax, d [ebp + 4]
	add	esi, eax
	mov	ecx, LETTER_SIZE

	mov	edi, d [ebp + 8]
	add	edi, 319
scrt_put:
	movsb
	add	esi, LETTER_SIZE - 1
	add	edi, 319
	dec	ecx
	jnz	scrt_put

	inc	d [ebp + 4]
	jmp	scrt_scroller

scrt_repeat:
	mov	d [ebp + 0], 0		; letter
	mov	d [ebp + 4], 0		; line

scrt_scroller:
	mov	esi, d [ebp + 8]
	mov	edx, LETTER_SIZE
scrt_v:
	mov	edi, esi
	inc	esi
	mov	ecx, 316 / 4
	rep	movsd
	movsw
	movsb
	dec	edx
	jnz	scrt_v
	
comment #
	mov	edi, d [ebp + 8]
	mov	edx, LETTER_SIZE
scrt_v:
	mov	ebx, 1
scrt_h:	
	mov	al, b [edi + ebx]
	mov	b [edi + ebx - 1], al
	inc	ebx
	cmp	ebx, 320
	jne	scrt_h
	add	edi, 320
	dec	edx
	jnz	scrt_v #
	ret

;------------------------------------------------------------

copy_buffer:
	mov	esi, d [FrameBuffer]
	mov	edi, d [VideoMem]
	mov	ecx, 16000
	cld
	rep	movsd
	ret

clear_buffer:
	mov	edi, d [FrameBuffer]
	xor	eax, eax
	mov	ecx, 16000
	cld
	rep	stosd
	ret

; in: esi = palette ptr
set_palette:
	mov	edx, 03c8h
	xor	eax, eax
	out	dx, al
	inc	edx
	mov	ecx, 768
	cld
	rep	outsb
	ret

;------------------------------------------------------------

include kernel\kernel.inc
include sinscr.inc

include alloc.asm
include zoomer.asm
include blurer.asm

MEM_TO_ALLOC	equ 64000 + 768 + FTAB_SIZE + 32*320 + 256*4 + 128*32 + \
		(320 + 200)*4

LETTER_COLOR	equ 0c8c8c8c8h
LETTER_SIZE	equ 32
FTAB_SIZE	equ 256 * (LETTER_SIZE * LETTER_SIZE)

SINEWAVE_AMP	equ 7

; pi / 128.0
pi_128		dd 0.02454

txt_scroller	db 'Sine Scroller & Zoomer coded by Majuma'
		db ' on 19th of January 2002 * ',0
txt_logo	db '@@@@',0

; scroll params
scr_letter	dd 0
scr_line	dd 0
scr_buffer	dd 0
scr_text	dd o txt_scroller

WaveStart	dd ?

MemHandle	dd ?

; pointers
FrameBuffer	dd ?
Palette		dd ?
FontTable	dd ?
SineWave	dd ?
LogoNAAG	dd ?

VideoMem	dd ?

_regs		dpmi_regs ?
_temp32		dd ?

scale		dd 1
scale_delay	dd 0
scale_dir	dd 1

code32 ends
end
