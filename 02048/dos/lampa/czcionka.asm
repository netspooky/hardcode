;code by Mikolaj Felix 9/12/2000
;mfelix@polbox.com

KOLOR_START equ 64
KOLOR_SKOK equ 15

pisz_znak proc			;kod_ascii, x, y
	mov	bp, sp
	mov	ax, ds:[bp+6]
	sub	ax, 32
	cmp	ax, 0
	jb	znak_koniec
	cmp	ax, 63
	ja	znak_koniec
	shl	ax, 3
	mov	si, offset font
	add	si, ax

	mov	di, ds:[bp+2]
	mov	bx, di
	shl	di, 6
	shl	bx, 8
	add	di, bx
	add	di, ds:[bp+4]

	mov	dl, KOLOR_START
	mov	ch, 8
znak_pion:
	mov	cl, 8
	mov	al, byte ptr [si]
znak_poziom:
	rcl	al, 1
	jae	znak_dalej
	mov	es:[di], dl
znak_dalej:
	inc	di
	dec	cl
	jnz	znak_poziom
	inc	si
	add	di, 312
	add	dl, KOLOR_SKOK
	dec	ch
	jnz	znak_pion
znak_koniec:
	ret	6
endp

pisz_string proc		;si- str_offset,  cx- x,  dx- y
	push	es
	mov	ax, bufor_segment
	mov	es, ax
litera:
	push	si
	push	cx
	push	dx

	mov	al, ds:[si]
	cbw
	push	ax
	push	cx
	push	dx
	call	pisz_znak

	pop	dx
	pop	cx
	pop	si
	add	cx, 8
	inc	si
	cmp	byte ptr ds:[si], 0
	jne	litera
	pop	es
	ret
endp

include font.inc