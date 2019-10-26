;universe 8000
;by Rudi

org 100h
	mov al,13h
	int 10h
	les bp,[bx]
	mov ds,bp
l:	mov cl,0
	mov bp,6
k:	mov bx,[t+bp-2]
	add cl,[bx+di]
	neg bx
	add cl,[bx+di]
	dec bp
	dec bp
	jnz k
	shr cl,1
	not cl
	mov al,[di]
	dec ax
	and al,7
	add al,cl
	jge m
	add ax,di
	and al,1
	neg al
	add al,[di]
	and al,7
	mov [di],al
m:	lodsb
	add al,0x14
	stosb
	jmp l
t:	dw 0x140,0x141,1