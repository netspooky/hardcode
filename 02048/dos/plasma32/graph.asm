
set_13h:
	mov	edx, 00000013h
	jmp	set_vga
set_03h:
	mov	edx, 00000003h
set_vga:
	mov	ebp, esp
	sub	esp, size dpmi_regs

	mov	edi, esp
	xor	eax, eax
	mov	ecx, (size dpmi_regs) / 4
	cld
	rep	stosd
	
	mov	edi, esp
	mov	d [edi._eax], edx
	mov	eax, 300h
	mov	ebx, 10h
	int	31h

	mov	eax, 0a0000h
	sub	eax, d [code32_base]
	mov	d [VideoMem], eax
	
	mov	esp, ebp
	ret

;------------------------------------------------------------

copy_buffer:
	mov	esi, d [FrameBuffer]
	mov	edi, d [VideoMem]
	mov	ecx, 16000
	cld
	rep	movsd
	ret

comment #
clear_buffer:
	mov	edi, d [FrameBuffer]
	xor	eax, eax
	mov	ecx, 16000
	cld
	rep	stosd
	ret #

wait_vr:
	mov	edx, 03dah
wvr_1:
	in	al, dx
	test	al, 8
	jz	wvr_1
wvr_2:
	in	al, dx
	test	al, 8
	jnz	wvr_2
	ret

comment #
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

; in: edi = palette ptr
get_palette:
	mov	edx, 03c7h
	xor	eax, eax
	out	dx, al
	add	edx, 2
	mov	ecx, 768
	cld
	rep	insb
	ret #

;------------------------------------------------------------

FrameBuffer	dd ?
VideoMem	dd ?
