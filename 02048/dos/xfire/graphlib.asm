; Mikolaj Felix 9/12/2000
; mfelix@polbox.com

copy_screen_buffer proc
	push	ds
	push	es
	mov	ax, buffer_seg
	mov	ds, ax
	xor	si, si
	mov	ax, 0a000h
	mov	es, ax
	xor	di, di
	mov	cx, 16000
	cld
	rep	movsd
	pop	es
	pop	ds
	ret
endp

clear_screen_buffer proc
	push	es
	mov	ax, buffer_seg
	mov	es, ax
	xor	di, di
	xor	eax, eax
	mov	cx, 16000
	cld
	rep	stosd
	pop	es
	ret
endp

alloc_screen_buffer proc
	mov	ah, 4ah
        mov	bx, 1000h
        int	21h
        mov	ah, 48h
        mov	bx, 1000h
        int	21h
        jc	asb_out_of_mem
	mov	buffer_seg, ax
	ret
asb_out_of_mem:
	mov	ah, 09h
        mov	dx, offset oom_string
        int	21h
	mov	ah, 4ch
	int	21h
	ret
endp

free_screen_buffer proc
	push	es
	mov	ax, buffer_seg
        mov	es, ax
        mov	ah, 49h
        int	21h
	pop	es
	ret
endp

wait_for_frame proc
	mov	dx, 03dah
c1:
	in	al, dx
	test	al, 8
	jz	c1
c2:
	in	al, dx
	test	al, 8
	jnz	c2
	ret
endp

oom_string db 'Memory error!', 10, 13, '$'
buffer_seg dw ?