
;------------------------------------------------------------
;	in:	eax = size of block in bytes
;	out:	eax = handle (0 if error occured) 
;		ebx = base address
;------------------------------------------------------------

alloc_mem:
	mov	cx, ax
	shr	eax, 16
	mov	bx, ax
	mov	ax, 0501h
	int	31h
	jnc	am_ok

	xor	eax, eax
	ret
am_ok:
	shl	ebx, 16
	mov	bx, cx
	sub	ebx, d [code32_base]
	mov	ax, si
	shl	eax, 16
	mov	ax, di
	ret

;------------------------------------------------------------
;	in:	eax = handle
;	out:	none
;------------------------------------------------------------

free_mem:
	mov	di, ax
	shr	eax, 16
	mov	si, ax
	mov	ax, 0502h
	int	31h
	ret
