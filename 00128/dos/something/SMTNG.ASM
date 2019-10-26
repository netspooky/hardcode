;
; Something by TNSe, tnse@online.no
;

	mov al,013h
	int 10h

	mov ax,0a000h
	mov ds,ax

	xor ax,ax
	mov dx,03c8
	out dx,al
	inc dx

	mov cx,0ffffh

	call PalSet

	mov ch,00h

	call PalSet

	mov cx,0ff00h

	call PalSet

	xor cx,cx
	push PalFin
	
PalSet:
	xor bx,bx
	mov si,64
Make_Pal:
	mov al,bl
	inc bl
	and bl,cl
	out dx,al
	mov al,bh
	inc bh
	and bh,ch
	out dx,al
	mov al,ah
	out dx,al
	dec si
	jnz Make_Pal
	ret

PalFin:
	xor si,si

MainProgramLoop:

	xor di,di
	mov bx,200	; 200 scanlines
OneFrame:
	mov cx,320	; 320 pixels
OneScanline:
	lea ax,[si+bx]
	mul cx
;	add ax,si
	
	mov [di],ah
	inc di
	loop OneScanline

	dec bx
	jnz OneFrame

	add si,4

	mov ah,6
	mov dl,0ffh
	int 21h
	je MainProgramLoop

	mov ax,3
	int 10h

	push cs
	pop ds

	mov dx,offset message
	mov ah,9
	int 21h

	ret

message: db 'Something, TNSe$'
	
