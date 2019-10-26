.code

flat_triangle proc

@@x1 equ word ptr [bp+4]
@@y1 equ word ptr [bp+6]
@@x2 equ word ptr [bp+8]
@@y2 equ word ptr [bp+10]
@@x3 equ word ptr [bp+12]
@@y3 equ word ptr [bp+14]
@@col equ word ptr [bp+16]

@@dx12 equ dword ptr [bp-4]
@@dx13 equ dword ptr [bp-8]
@@dx23 equ dword ptr [bp-12]

	push	bp
	mov	bp, sp
	sub	sp, 12

	push	es
	mov	es, buffer_seg

	mov	ax, @@y1
	cmp	ax, @@y3
	jle	ft_check1

	xchg	ax, @@y3
	mov	@@y1, ax

	mov	ax, @@x1
	xchg	ax, @@x3
	mov	@@x1, ax
ft_check1:

	mov	ax, @@y2
	cmp	ax, @@y3
	jle	ft_check2

	xchg	ax, @@y3
	mov	@@y2, ax

	mov	ax, @@x2
	xchg	ax, @@x3
	mov	@@x2, ax
ft_check2:

	mov	ax, @@y1
	cmp	ax, @@y2
	jle	ft_check3

	xchg	ax, @@y2
	mov	@@y1, ax

	mov	ax, @@x1
	xchg	ax, @@x2
	mov	@@x1, ax
ft_check3:


	mov	bx, @@y2
	sub	bx, @@y1
	jnz	ft_dx12_make

	mov	@@dx12, 0
	jmp	ft_dx12_done
ft_dx12_make:
	mov	ax, @@x2
	sub	ax, @@x1
	movsx	eax, ax
	movsx	ebx, bx
	shl	eax, SHIFT_CONST
	cdq
	idiv	ebx
	mov	@@dx12, eax
ft_dx12_done:

	mov	bx, @@y3
	sub	bx, @@y1
	jnz	ft_dx13_make

	mov	@@dx13, 0
	jmp	ft_dx13_done
ft_dx13_make:
	mov	ax, @@x3
	sub	ax, @@x1
	movsx	eax, ax
	movsx	ebx, bx
	shl	eax, SHIFT_CONST
	cdq
	idiv	ebx
	mov	@@dx13, eax
ft_dx13_done:

	mov	bx, @@y3
	sub	bx, @@y2
	jnz	ft_dx23_make

	mov	@@dx23, 0
	jmp	ft_dx23_done
ft_dx23_make:
	mov	ax, @@x3
	sub	ax, @@x2
	movsx	eax, ax
	movsx	ebx, bx
	shl	eax, SHIFT_CONST
	cdq
	idiv	ebx
	mov	@@dx23, eax
ft_dx23_done:


	movsx	eax, @@x1
	shl	eax, SHIFT_CONST
	mov	ebx, eax
	mov	cx, @@y1
	cmp	cx, @@y2
	jge	ft_loop1_end
ft_loop1:
	push	eax
	push	cx

	push	@@col
	push	cx
	mov	edx, ebx
	sar	edx, SHIFT_CONST
	push	dx
	sar	eax, SHIFT_CONST
	push	ax
	call	flat_line

	pop	cx
	pop	eax

	add	eax, @@dx13
	add	ebx, @@dx12
	inc	cx
	cmp	cx, @@y2
	jl	ft_loop1
ft_loop1_end:

	
	movsx	ebx, @@x2
	shl	ebx, SHIFT_CONST
	mov	cx, @@y2
	cmp	cx, @@y3
	jge	ft_loop2_end
ft_loop2:
	push	eax
	push	cx

	push	@@col
	push	cx
	mov	edx, ebx
	sar	edx, SHIFT_CONST
	push	dx
	sar	eax, SHIFT_CONST
	push	ax
	call	flat_line

	pop	cx
	pop	eax

	add	eax, @@dx13
	add	ebx, @@dx23
	inc	cx
	cmp	cx, @@y3
	jl	ft_loop2
ft_loop2_end:

	pop	es

	mov	sp, bp
	pop	bp
	ret	14
endp

flat_line proc

@@x1 equ word ptr [bp+4]
@@x2 equ word ptr [bp+6]
@@y equ word ptr [bp+8]
@@col equ word ptr [bp+10]

	push	bp
	mov	bp, sp

	; vertical clipping
	mov	ax, @@y
	or	ax, ax
	jl	fl_quit
	cmp	ax, 199
	jg	fl_quit

	; horizontal clipping
	mov	ax, @@x1
	or	ax, ax
	jge	fl_x1_ok1
	mov	@@x1, 0
	jmp	fl_x1_ok2
fl_x1_ok1:
	cmp	ax, 319
	jle	fl_x1_ok2
	mov	@@x1, 319
fl_x1_ok2:

	mov	ax, @@x2
	or	ax, ax
	jge	fl_x2_ok1
	mov	@@x2, 0
	jmp	fl_x2_ok2
fl_x2_ok1:
	cmp	ax, 319
	jle	fl_x2_ok2
	mov	@@x2, 319
fl_x2_ok2:


	mov	ax, @@x1
	cmp	ax, @@x2
	je	fl_quit
	jl	fl_ok

	xchg	ax, @@x2
	mov	@@x1, ax
fl_ok:
	mov	di, @@y
	mov	ax, di
	shl	di, 6
	shl	ax, 8
	add	di, ax
	add	di, @@x1

	mov	ax, @@col
	mov	ah, al

	mov	cx, @@x2
	sub	cx, @@x1
	shr	cx, 1
	jnc	fl_draw
	stosb
fl_draw:
	rep	stosw
fl_quit:
	pop	bp
	ret	8
endp