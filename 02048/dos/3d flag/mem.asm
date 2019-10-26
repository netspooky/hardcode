.code

;------------------------------------------------------------
;	in:	none
;	out:	ax - segment number (0 if error occured)
;------------------------------------------------------------

alloc_seg proc near
	mov	ah, 4ah
	mov	bx, 1000h
	int	21h
	mov	ah, 48h
	mov	bx, 1000h
	int	21h
	jc	as_no_mem
	ret
as_no_mem:
	xor	ax, ax
	ret
endp

;------------------------------------------------------------
;	in:	ax - segment number
;	out:	none
;------------------------------------------------------------

free_seg proc near
	push	es
	mov	es, ax
	mov	ah, 49h
	int	21h
	pop	es
	ret
endp