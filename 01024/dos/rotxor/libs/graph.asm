.data?
	buffer_seg dw ?

.code

copy_buffer proc
	push	ds
	push	es
	mov	ds,buffer_seg
	xor	si,si
	mov	ax,0a000h
	mov	es,ax
	xor	di,di
	mov	cx,64000/8
cb_copy:
	fld	qword ptr [si]
	add	si,8
	fstp	qword ptr es:[di]
	add	di,8
	dec	cx
	jnz	cb_copy
	pop	ds
	pop	es
	ret
endp

clear_buffer proc
	push es
	mov es,buffer_seg
	xor di,di
	xor eax,eax
	mov cx,65536/4
	cld
	rep stosd
	pop es
	ret
endp

retrace proc
	mov dx,03dah
c1:
	in al,dx
	test al,8
	jz c1
c2:
	in al,dx
	test al,8
	jnz c2
	ret
endp

;------------------------------------------------------------
;	in:	si - offset to palette
;	out:	none
;------------------------------------------------------------

set_palette proc
	mov dx,03c8h
	xor ax,ax
	out dx,al
	inc dx
	mov cx,768
	cld
	rep outsb
	ret
endp