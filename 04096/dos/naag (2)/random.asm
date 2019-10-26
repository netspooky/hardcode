.386p
locals

code32 segment para public use32
	assume cs:code32,  ds:code32

;------------------------------------------------------------
;	in:	ecx - min
;		edx - max
;	out:	eax - random number
;------------------------------------------------------------

random proc
	mov	bx, random_seed
	add	bx, 9248h
	ror	bx, 3
	mov	random_seed, bx
	
	mov	ax, dx
	sub	ax, cx
	mul	bx
	mov	ax, dx
	add	ax, cx
	movsx	eax, ax
	ret
endp

random_seed	dw ?

code32 ends
