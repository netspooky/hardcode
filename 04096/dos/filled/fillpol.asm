; Mikolaj Felix 5/5/2001
; mfelix@polbox.com

					; x1  +4	y1	+6
					; x2  +8	y2	+10
					; x3 +12	y3	+14
					; x4 +16	y4	+18
					; k +20
draw_filled_polygon proc
	push	bp
	mov	bp, sp

	mov	di, offset polygon_left
	mov	ax, 32000
	shl	eax, 16
	mov	ax, 32000
	mov	cx, 100
	cld
	rep	stosd
	mov	ax, -32000
	shl	eax, 16
	mov	ax, -32000
	mov	cx, 100
	rep	stosd

	push	word ptr [bp+10]		; y2
	push	word ptr [bp+8]		; x2
	push	word ptr [bp+6]		; y1
	push	word ptr [bp+4]		; x1
	call	filled_scan_side

	push	word ptr [bp+14]		; y3
	push	word ptr [bp+12]		; x3
	push	word ptr [bp+10]		; y2
	push	word ptr [bp+8]		; x2
	call	filled_scan_side

	push	word ptr [bp+18]		; y4
	push	word ptr [bp+16]		; x4
	push	word ptr [bp+14]		; y3
	push	word ptr [bp+12]		; x3
	call	filled_scan_side
	
	push	word ptr [bp+6]		; y1
	push	word ptr [bp+4]		; x1
	push	word ptr [bp+18]		; y4
	push	word ptr [bp+16]		; x4
	call	filled_scan_side

	push	es
	mov	es, buffer_seg

	xor	di, di
	xor	cx, cx
dfp_loop:
	mov	ax, word ptr polygon_left[di]
	cmp	ax, 32000
	je	dfp_next

	push	cx
	push	di

	push	word ptr [bp+20]		; color
	push	cx
	push	word ptr polygon_right[di]
	push	word ptr polygon_left[di]
	call	draw_polygon_line

	pop	di
	pop	cx
	
dfp_next:
	add	di, 2
	inc	cx
	cmp	cx, 200
	jne	dfp_loop

	pop	es
	pop	bp
	ret	18
endp

					; x1 +4
					; y1 +6
					; x2 +8
					; y2 +10
filled_scan_side proc
	push	bp
	mov	bp, sp

	mov	ax, word ptr [bp+6]
	cmp	ax, word ptr [bp+10]
	je	fss_quit			; y1 = y2
	jl	fss_ok			; y1 < y2

	xchg	ax, word ptr [bp+10]	; xchg y1, y2 
	mov	word ptr [bp+6], ax

	mov	ax, word ptr [bp+4]
	xchg	ax, word ptr [bp+8]		; xchg x1, x2
	mov	word ptr [bp+4], ax
fss_ok:
	mov	cx, word ptr [bp+10]
	sub	cx, word ptr [bp+6]		; cx = y2-y1

	mov	ax, word ptr [bp+8]
	sub	ax, word ptr [bp+4]		; ax = x2-x1
	shl	ax, 7
	cwd
	idiv	cx
	mov	bx, ax			; delta_x

	mov	ax, word ptr [bp+4]
	shl	ax, 7			; ax = x1<<7
	
	mov	di, word ptr [bp+6]
	shl	di, 1
fss_loop:
	mov	dx, ax
	shr	dx, 7
	cmp	dx, word ptr polygon_left[di]
	jg	fss_next1				; x > polygon_left[di]

	mov	word ptr polygon_left[di], dx	; polygon_left[di] = x
fss_next1:
	cmp	dx, word ptr polygon_right[di]
	jl	fss_next2				; x < polygon_right[di]

	mov	word ptr polygon_right[di], dx	; polygon_right[di] = x
fss_next2:
	add	ax, bx				; x+=delta_x
	add	di, 2
	dec	cx
	jnz	fss_loop
fss_quit:
	pop	bp
	ret	8
endp

					; x1 +4
					; x2 +6
					; y  +8
					; k  +10
draw_polygon_line proc
	push	bp
	mov	bp, sp

	mov	ax, word ptr [bp+4]
	cmp	ax, word ptr [bp+6]
	jl	dpl_ok
	je	dpl_quit

	xchg	ax, word ptr [bp+6]
	mov	word ptr [bp+4], ax
dpl_ok:
	mov	di, word ptr [bp+8]
	mov	ax, di
	shl	di, 6
	shl	ax, 8
	add	di, ax
	add	di, word ptr [bp+4]

	mov	ax, word ptr [bp+10]
	mov	ah, al

	mov	cx, word ptr [bp+6]
	sub	cx, word ptr [bp+4]
	inc	cx
	shr	cx, 1
	jnc	dpl_jump
	stosb
dpl_jump:
	rep	stosw
dpl_quit:
	pop	bp
	ret	8
endp

polygon_left dw 200 dup(?)
polygon_right dw 200 dup(?)