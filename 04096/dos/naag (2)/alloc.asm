.386p
locals

code32 segment para public use32
	assume cs:code32,  ds:code32

;------------------------------------------------------------
;	in:	eax - size of block in bytes
;	out:	eax - handle (0 if error occured) 
;		ebx - base address
;------------------------------------------------------------

alloc_mem proc
	mov	cx, ax
	shr	eax, 16
	mov	bx, ax
	mov	ax, 0501h
	int	31h
	jnc	@@ok

	xor	eax, eax
	ret
@@ok:
	shl	ebx, 16
	mov	bx, cx
	sub	ebx, code32_base
	mov	ax, si
	shl	eax, 16
	mov	ax, di
	ret
endp

;------------------------------------------------------------
;	in:	eax - handle
;	out:	none
;------------------------------------------------------------

free_mem proc
	mov	di, ax
	shr	eax, 16
	mov	si, ax
	mov	ax, 0502h
	int	31h
	ret
endp

code32 ends
