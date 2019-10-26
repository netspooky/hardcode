
; in: esi = ptr to 128*32 bitmap, eax = scale << 8
zoomer:
	cld
	mov	ebp, eax

	mov	edi, d [ZoomerLookups]
	mov	ecx, -160
z_mlx:
	mov	eax, ebp
	mul	ecx
	shrd	eax, edx, 8
	sub	eax, 128 / 2
	and	eax, 127
	stosd				; bmp_x = (x * scale) >> 8
	inc	ecx
	cmp	ecx, 160
	jne	z_mlx

	mov	ecx, -100
z_mly:
	mov	eax, ebp
	mul	ecx
	shrd	eax, edx, 8
	sub	eax, 32 / 2
	and	eax, 31
	shl	eax, 7
	stosd				; bmp_y = ((y * scale) >> 8) * 128
	inc	ecx
	cmp	ecx, 100
	jne	z_mly


	mov	ebp, d [ZoomerLookups]
	mov	edi, d [FrameBuffer]
	xor	edx, edx
z_v:
	xor	ecx, ecx
z_h:
	mov	eax, d [edx + ebp + 320*4]
	add	eax, d [ecx + ebp]
	mov	al, b [esi + eax]	; pixel = bmp_x + bmp_y
	stosb

	;or	al, al
	;jz	z_next
	;mov	b [edi], al
z_next:
	;inc	edi

	add	ecx, 4
	cmp	ecx, 320 * 4
	jne	z_h

	add	edx, 4
	cmp	edx, 200 * 4
	jne	z_v
	ret


ZoomerLookups	dd ?
