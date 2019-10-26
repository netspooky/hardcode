;	mov cx,NumberOfTriangles
;	mov si,offset ContourVertexes
;	mov bx,256

Proc	DrawTriangles

	push [GraphBuffer]
	pop es

Triangles:

	lodsw
	imul bx
	mov al,ah
	mov ah,dl
	add ax,160
	mov [StopX1],ax

	lodsw
	imul bx
	mov al,ah
	mov ah,dl
	add ax,100
	mov [StopY1],ax

	lodsw
	imul bx
	mov al,ah
	mov ah,dl
	add ax,160
	mov [StopX2],ax

	lodsw
	imul bx
	mov al,ah
	mov ah,dl
	add ax,100
	mov [StopY2],ax

	lodsw
	imul bx
	mov al,ah
	mov ah,dl
	add ax,160
	mov [StopX3],ax

	lodsw
	imul bx
	mov al,ah
	mov ah,dl
	add ax,100
	mov [StopY3],ax

	pusha

	mov ax,[StopX1]
	shl eax,16
	mov ax,[StopY1]

	mov bx,[StopX2]
	shl ebx,16
	mov bx,[StopY2]

	mov dx,[StopX3]
	shl edx,16
	mov dx,[StopY3]

	mov cx,bp
	call Triangle

	popa

;	loop Triangles
	dec cx
	jnz Triangles

	ret
EndP
