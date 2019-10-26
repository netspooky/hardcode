;Stop sign zooming
	StopSizeMax	equ	700
	StopEndTime	equ	120

	mov [Time],0

	call ClearScreenBuffers

	push 0A000h
	pop es
	xor eax,eax
	mov cx,16384
	rep stosd

	mov dx,3c8h
	mov al,1
	out dx,al
	inc dx
	mov al,3fh
	out dx,al
	xor al,al
	out dx,al
	out dx,al

	mov al,3fh
	out dx,al
	out dx,al
	out dx,al

StopZoom:

	call ClearScreenBuffers

	mov cx,NumberOfTriangles
	mov si,offset ContourVertexes
	mov bx,[StopSize]
	shr bx,2
	mov bp,1h
	call DrawTriangles

	mov cx,NumberOfTriangles2
	mov si,offset SignVertexes
	mov bx,[StopSize]
	shr bx,2
	mov bp,2h
	call DrawTriangles

	mov ax,[StopSizeSpeed]
	add [StopSize],ax
	add [StopSizeSpeed],1

	cmp [StopSize],StopSizeMax
	jl NotStopStop
	mov [StopSize],StopSizeMax-1
	neg [StopSizeSpeed]
;	sar [StopSizeSpeed],1
	mov ax,[StopSizeSpeed]
	cwd
	mov bx,3
	idiv bx
	mov [StopSizeSpeed],ax
NotStopStop:

	call WaitVR
	call DisplayScreenBuffers

	inc [Time]
	cmp [Time],StopEndTime
	je StopEnd

	mov ah,1
	int 16h
	jz StopZoom

	xor ax,ax
	int 16h

StopEnd:
	call FadeOut
