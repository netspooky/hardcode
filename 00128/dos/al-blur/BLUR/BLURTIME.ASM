;this is the original version
.386
.model tiny
.code
org 100h
main	proc
	mov al,13h		;set vga mode 13h
	int 10h

	mov al,1		;don't change 0...
	mov dx,3c9h		;palette register
palette3:
	dec dx
	out dx,al
	inc dx
	push ax
	push ax
	xor al,al		;don't set red
	out dx,al
	pop ax
	cmp al,210
	ja pal4
	mov al,15
pal4:
	out dx,al		;set only green
	shr al,1
	out dx,al		;and some blu
	pop ax
;	inc al
	inc ax
	jnz palette3

	push 8000h
	pop ds			;free memory somewhere
	push 0a000h
	pop es			;video segment in ES
	mov bp,317		;we need to add 317 to SI 2 times, and using
				;lea si,[si+bx] is better
a2:
	cbw			;since al here is always 0, cbw will set ax to 0
	xor dx,dx
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

	shr dx,3		;calculate the average of pixels around
;	add dl,2		;and add 2
	inc dx
	inc dx
a4:
	mov byte ptr ds:[si],dl	;store the pixel
	inc si
	jnz a2

;this is byte-to-byte flipping version:
;	dec cx			;since CX here is always 0,
;				;CX-1=65535
;	call waitretrace
;	rep movsb		;flip page to vga memory
;	movsb			;DI and SI are
				;both incremented (and it takes only
				;1 byte)
;and this is word-to-word flipping version (takes 1 more byte but it's faster)
	mov cx,0ffffh/2+1	;CX=...+1 so at the end of the rep,
				;SI and DI are both 0
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
	int 16h			;key pressed?
	jz a2
fine_main:
;	mov ah,49h		;deallocate memory
;	push ds
;	pop es
;	int 21h

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
