alloc_seg proc near
	mov ah,4ah
	mov bx,1000h
	int 21h
	mov ah,48h
	mov bx,1000h
	int 21h
	jc @@no_mem
	ret
@@no_mem:
	xor ax,ax
	ret
	ret
endp

free_seg proc near
	push es
	mov es,ax
	mov ah,49h
	int 21h
	pop es
	ret
endp