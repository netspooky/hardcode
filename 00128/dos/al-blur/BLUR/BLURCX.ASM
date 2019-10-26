;this is very size-optimized...but it's really slow!
.386
.model tiny
.code
org 100h
main	proc
	mov al,13h
	int 10h
;	mov al,210		;change only colors 210-255
	mov dx,3c9h
;	mov cl,3
;	push cx
palette3:
	dec dx
	out dx,al
	inc dx
	out dx,al
	out dx,al
	out dx,al
	inc ax			;inc ax is 1 byte, inc al is 2 bytes
	jnz palette3

	mov ah,080h		;same size as push & pop
	mov ds,ax
	push 0a000h
	pop es
	mov bp,317
a2:
	cbw			;AL here is 0, so cbw set AX to 0
	cwd			;AX here is 0, so cwd set DX to 0
	push si
	sub si,321
	mov cl,3
;	push cx
a1_c:
	lodsb
	add dx,ax
	loop a1_c
	lea si,[si+bp]
	lodsb
	add dx,ax
	inc si
	lodsb
	add dx,ax
	lea si,[si+bp]
;	pop cx
	mov cl,3
a2_c:
	lodsb
	add dx,ax
	loop a2_c
	pop si

	shr dx,3
	inc dx
	inc dx
a4:
	mov byte ptr ds:[si],dl
	inc si
	jnz a2

;	mov cx,((0ffffh/2)+1)
;	rep movsw

	dec cx				;since CX here is always 0,
					;CX-1=65535
	rep movsb
	movsb			;movsb increments both SI and DI

;	inc si				;SI=65535+1=0
;	inc di				;DI=65535+1=0
	mov ah,11h
	int 16h				;key pressed?
	jz a2
;	mov ah,07h			;grab key
;	int 21h
fine_main:
;	mov ah,49h			;deallocate memory
;	push ds
;	pop es
;	int 21h

;	mov ax,0003h
;	int 10h
	ret
main	endp

end	main
