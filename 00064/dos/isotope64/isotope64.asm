;isotope64
;by Rudi
org 100h
	mov al,13h
	int 10h
	les bp, [bx]
	push 01000h
	pop ds
L0:	lodsb
	shl al, 3
	mov cl, al
	lodsb
	shl al, 2
	add cl, al
	add si, 318
	lodsb
	shl al, 1
	add cl, al
	lodsb
	add cl, al
	sub si, 321
	mov ax, bx
	shr ax, cl
	and al, 1
	mov [ds:bp], al
	or al, cl
	dec bp
	stosb
	jnz L0
	add bx, 6
	jmp L0