.data?
	font_data db 2048 dup(?)

.code

init_font proc
	push	bp
	push	ds
	push	es
	
	mov	ax, 01130h
	mov	bh, 03h
	int	10h
	
	mov	ax, es
	mov	ds, ax
	mov	si, bp

	mov	ax, cs
	mov	es, ax
	mov	di, offset font_data

	mov	cx, 2048/4
	cld
	rep	movsd

	pop	es
	pop	ds
	pop	bp
	ret
endp