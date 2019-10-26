calcplan:
	mov	cx, 352
	mov	di, OFFSET Plan
	xor	bx, bx
@Lp1:	mov	ax, bx
	mov	cs:[di], ax			      ; + 0

	add	ax,6
	mov	cs:[di+2], ax			      ; + 1
	mov	cs:[di+6], ax			      ; + 1

	add	ax, 186
	mov	cs:[di+4], ax			      ; + 32
	mov	cs:[di+10], ax			      ; + 32

	add	ax, 6
	mov	cs:[di+8], ax			      ; + 33

	add	di, 12
	add	bx, 6
	loop	@Lp1
	ret


calcbol:
	push	cs
	pop	es

	mov	a, 11
@philoop:
	mov	bx, a
	imul	bx, 93
	shr	bx, 1
	call	sine		; cosinus...
	mov	ctc, eax
	sub	bx, 256
	call	sine		; sinus
	mov	sts, eax

	mov	b, 32
@theta:
	mov	bx, b
	call	radius1
@Self20:

	shl	bx, 5
	call	sine		; cosinus...
	mov	cpc, eax
	sub	bx, 256
	call	sine		; sinus
	mov	sps, eax

	imul	eax, sts
	sar	eax, 15
	imul	eax, r
	sar	eax, 15 	; point.x
	stosw

	mov	eax, cpc
	imul	eax, sts
	sar	eax, 15
	imul	eax, r
	sar	eax, 15 	; point.y
	stosw

	mov	eax, ctc
	imul	eax, r
	sar	eax, 15 	; point.z
	stosw

	dec	b
	jnz	@theta
	dec	a
	jns	@philoop

	mov	word ptr cs:[@self20-2], 00B0h
@self21:
	ret


radius1:
	push	bx
	shl	bx, 6
	sub	bx, 256
	call	sine
	imul	eax, 8000
	sar	eax, 15
	mov	ecx, eax
	mov	bx, a
	imul	bx, 12*8
	sub	bx, 256
	call	sine
	imul	eax, ecx
	sar	eax, 15
	add	eax, 14000
	mov	r, eax
	pop	bx
	ret

radius2:
	push	bx
	shl	bx, 5
	sub	bx, 256
	call	sine
	imul	eax, 4000
	sar	eax, 15
	mov	ecx, eax
	mov	bx, a
	imul	bx, 171
	sub	bx, 256
	call	sine
	imul	eax, 4000
	sar	eax, 15
	add	eax, ecx
	add	eax, 14000
	mov	r, eax
	pop	bx
	mov	word ptr cs:[@self21-2], 00FBh
	ret


radius3:
	push	bx
	shl	bx, 6
	sub	bx, 256
	call	sine
	imul	eax, 8000
	sar	eax, 15
	mov	ecx, eax
	mov	bx, a
	imul	bx, 12*16
	sub	bx, 256
	call	sine
	imul	eax, ecx
	sar	eax, 15
	add	eax, 14000
	mov	r, eax
	pop	bx
	mov	word ptr cs:[@self21-2], 0140h
	ret

radius4:
	mov	r, 21000
	ret



interpolate:
	xor	di, di

	mov	cx, 1152*2		 ; interpolate points + normals.
nextpoint:
	mov	bp, interofs1
	movsx	eax, word ptr [bp+di]
	mov	bp, interofs2
	movsx	ebx, word ptr [bp+di]
	imul	eax, esi
	xor	si, 0ffh
	imul	ebx, esi
	xor	si, 0ffh
	add	eax, ebx
	sar	eax, 8
	mov	[points.di], ax
	add	di, 2
	dec	cx
	jns	nextpoint
	ret


