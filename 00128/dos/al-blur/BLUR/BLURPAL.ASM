;this is palette-rotating version
.386
.model tiny
.code
org 100h
main	proc
	mov al,13h
	int 10h

	push 8000h
	pop ds
	push 0a000h
	pop es
	mov bh,01h
	mov bp,317
a1:
	add bl,bh
	jnz pal2
	neg bh
	add bl,bh
pal2:
	mov al,210		;change only colors 210-255
	mov dx,3c9h
palette3:
	dec dx
	out dx,al
	inc dx
	push ax
	push ax
	xor al,al
	out dx,al
	pop ax
;	mov al,bl
;	shr al,2
	out dx,al
;	pop ax
	mov al,bl
	shr al,2
	out dx,al
	pop ax
	inc al
	jnz palette3
a2:
	cbw
;	xor dx,dx
	cwd
	push si
	sub si,321
	call loadsb
	lea si,[si+bp]
	lodsb
	add dx,ax
	inc si
	lodsb
	add dx,ax
	lea si,[si+bp]
	call loadsb
	pop si

	shr dx,3
;	add dl,2
	inc dx
	inc dx
a4:
	mov byte ptr ds:[si],dl
	inc si
	jnz a2

;	dec cx				;since CX here is always 0,
					;CX-1=65535
;	rep movsb
;	movsb				;with a new movsb, SI and DI are
					;both incremented (and it takes only
					;1 byte)
	mov cx,(0ffffh/2+1)

	mov dx,3DAh
l1:
	in al,dx
	and al,08h
	jnz l1
l2:
	in al,dx
	and al,08h
	jz  l2

	rep movsw

	mov ah,11h
	int 16h				;key pressed?
	jz a1

;	mov ax,0003h
;	int 10h
	ret
main	endp

loadsb	proc
	lodsb
	add dx,ax
	lodsb
	add dx,ax
	lodsb
	add dx,ax
	ret
loadsb	endp

end	main
