;Blue dots
	WarpingEndTime	equ	300

	push 00
	pop gs

	mov eax,[gs:046Ch]
	mov [StartTime],eax

	push cs
	pop ds

	call ClearScreenBuffers
	call DisplayScreenBuffers
	push 0A000h
	pop es
	xor eax,eax
	mov cx,16000
	xor di,di
	rep stosd

	call WaitVR

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	mov cx,64
BPal1:
	xor al,al
	out dx,al
	out dx,al
	mov al,cl
	neg al
;	shr al,1
	out dx,al
	loop BPal1

	mov cx,64
BPal2:
	mov al,cl
	neg al
	out dx,al
	out dx,al
	mov al,3fh
	out dx,al
	loop BPal2

	mov cx,256-128
	mov al,3fh
BPal3:
	out dx,al
	out dx,al
	out dx,al
	loop BPal3

;Generate background
	push [WaterSegment]
;	push 0A000h
;	push [GraphBuffer]
	pop es
	xor eax,eax
	xor di,di
	mov cx,16384
	rep stosd
	mov bp,9000
Background4:
	call Random
	mov di,ax
	mov ax,0001h
	mov bx,8
Vert4:
	mov cx,8
Hor4:
	add [es:di],al
	inc di
	loop Hor4
	add di,320-8h
	add ah,0B0h
	adc di,-1
	dec bx
	jnz Vert4

	dec bp
	jne Background4

	call DisplayScreenBuffers

;Draw 'Faugh!'
;	push [GraphBuffer]
;	push 0A000h
	push [WaterSegment]
	pop es

	mov si,offset FlameVertexes
	mov cx,NumberOfFlameVertexes
	inc cx
ShadeFaugh:
	lodsw
	mov bx,ax
	lodsw
	cmp ax,0
	jne ShadeNotNewLine
	lodsw
	mov bx,ax
	lodsw
	mov [Word ptr FlameX],bx
	mov [Word ptr FlameY],ax
	dec cx
	loop ShadeFaugh
;	jmp ShadeFaughEnd
ShadeNotNewLine:
	push ax
	push bx
	push cx
	push si

	shl ebx,16
	mov bx,ax
	mov ax,[Word ptr FlameX]
	shl eax,16
	mov ax,[Word ptr FlameY]
	mov cl,3
	call DrawBobLine

	pop si
	pop cx
	pop bx
	pop ax
	mov [Word ptr FlameX],bx
	mov [Word ptr FlameY],ax
	loop ShadeFaugh
ShadeFaughEnd:

	call DisplayScreenBuffers


Warping:
;	add [WarpingY],10
;	add [WarpingX],10
	push 0h
	pop gs
	mov eax,[gs:46ch]
	shl ax,3
	mov [WarpingX],ax
	mov [WarpingY],ax


	push [WaterSegment]
	pop fs
	push 0A000h
	pop es

	mov cx,200
	xor di,di
;	xor si,si
	mov si,[WarpingY]
	xor bx,bx
WarpingVert:
;	xor bx,bx
	mov bx,[WarpingX]
	push cx
	mov cx,320
WarpingHor:
	and si,1feh
	and bx,1feh
	mov bp,[ds:Sin256+si]
	sar bp,6
	lea bp,[ebp*4+ebp]
	shl bp,6

	mov ax,[ds:Sin256+bx]
	sar ax,6
	add bp,ax
	mov al,[fs:di+bp]
	mov [es:di],al

	inc di
	add bx,8
	loop WarpingHor
	pop cx
	add si,16
	loop WarpingVert


	mov eax,[gs:46Ch]
	sub eax,[StartTime]
	cmp eax,WarpingEndTime
	ja WarpingEnd

	mov ah,1h
	int 16h
	jz Warping

	xor ax,ax
	int 16h

WarpingEnd:
	call FadeOut