
blurer:
	mov	edi, d [FrameBuffer]
	xor	eax, eax
	mov	ecx, 320 / 4
	cld
	rep	stosd

	mov	ecx, 64000 - 320*2
	xor	ebx, ebx
b_loop:
	mov	al, b [edi - 1]
	mov	bl, b [edi + 1]
	add	eax, ebx
	mov	bl, b [edi - 320]
	add	eax, ebx
	mov	bl, b [edi + 320]
	add	eax, ebx
	shr	eax, 2
	stosb
	dec	ecx
	jnz	b_loop

	xor	eax, eax
	mov	ecx, 320 / 4
	rep	stosd
	ret
