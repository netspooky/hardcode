;Flaming 'FAUGH'
	FlameFadeOut	equ	440
	FlameEndTime	equ	500

	call ClearScreenBuffers
	call DisplayScreenBuffers

	mov [Time],0

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	xor bx,bx
	xor si,si
	xor di,di

	mov cx,64
FlamePal4:
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	mov ax,di
	mov al,ah
	out dx,al	
	add bx,0FFh
	add si,0
	add di,0
	loop FlamePal4

	mov cx,64
FlamePal5:
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	mov ax,di
	mov al,ah
	out dx,al	
	add bx,0
	add si,0FFh
	add di,0
	loop FlamePal5

	mov cx,64
FlamePal6:
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	mov ax,di
	mov al,ah
	out dx,al	
	add bx,0
	add si,0
	add di,0FFh
	loop FlamePal6

	mov cx,64
FlamePal7:
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	mov ax,di
	mov al,ah
	out dx,al	
	add bx,0
	add si,0
	add di,0
	loop FlamePal7


Flame:

	push [TextSegment]
	pop fs
	push [GraphBuffer]
	pop es

;Display flame dots
	mov cx,[NumberOfFlameDots]
	jcxz NoFlameDots
	xor si,si
FlameDots:
	mov di,[fs:si]
	call Random
	mov [es:di],ax
	call Random
	mov [es:di+320],ax
	add si,2
	loop FlameDots
NoFlameDots:

	mov si,[FlameVertex]
	shl si,2	;*4 (2 word coordinates)
	cmp [ds:FlameVertexes+si],0
	jne NotNewLine
	mov ax,[ds:FlameVertexes+si+4]
	shl eax,16
	mov [FlameX],eax
	mov ax,[ds:FlameVertexes+si+6]
	shl eax,16
	mov [FlameY],eax
	xor eax,eax
	mov [FlameXVel],eax
	mov [FlameYVel],eax
	add [FlameVertex],1
	add si,4
	jmp NewVertex
NotNewLine:
	mov eax,[FlameXVel]
	add [FlameX],eax
	mov eax,[FlameYVel]
	add [FlameY],eax

;	mov ax,[Word ptr FlameX+2]
;	cmp ax,[ds:FlameVertexes+si]
;	jl MoveLeft
;	ja MoveRight
;	jmp DontMoveHor
;MoveLeft:
;	add [FlameXVel],1
;	jmp DontMoveHor
;MoveRight:
;	sub [FlameXVel],1
;DontMoveHor:

;Have it reached the destination point?
	mov ax,[word ptr FlameX+2]
;	shr ax,2
;	mov bx,[ds:FlameVertexes+si]
;	shr bx,2
	sub ax,[ds:FlameVertexes+si]
	inc ax
	shr ax,2
	jnz NotStop
;	cmp ax,bx
;	jne NotStop
	mov ax,[word ptr FlameY+2]
;	shr ax,2
;	mov bx,[ds:FlameVertexes+si+2]
;	shr bx,2
;	cmp ax,bx
;	jne NotStop
	sub ax,[ds:FlameVertexes+si+2]
	inc ax
	shr ax,2
	jnz NotStop

;New line
NewVertex:
	inc [FlameVertex]	;Next vertex
	add si,4
	mov ax,[ds:FlameVertexes+si]
	sub ax,[Word ptr FlameX+2]
	or ax,ax
	jns Abs1
	neg ax
Abs1:
	mov bx,[ds:FlameVertexes+si+2]
	sub bx,[Word ptr FlameY+2]
	or bx,bx
	jns Abs2
	neg bx
Abs2:
	mov cx,ax
	cmp bx,ax
	jl NotVertLonger
	mov cx,bx
NotVertLonger:
	shr cx,1
;	mov ax,cx
;	shr ax,2
;	sub cx,ax
	inc cx
	and ecx,0ffffh
	mov ax,[ds:FlameVertexes+si]
	sub ax,[Word ptr FlameX+2]
	shl eax,16
	mov edx,eax
	sar edx,31
;	mov edx,eax
;	xor eax,eax
	idiv ecx
	mov [FlameXVel],eax
	mov ax,[ds:FlameVertexes+si+2]
	sub ax,[Word ptr FlameY+2]
	shl eax,16
	mov edx,eax
	sar edx,31
	idiv ecx
	mov [FlameYVel],eax

	mov [Word ptr FlameX],0h
	mov [Word ptr FlameY],0h

NotStop:

;Generate dots coordinates
	mov ax,[NumberOfFlameDots]
	mov di,ax
	add di,di
	cmp [FlameVertex],NumberOfFlameVertexes
	ja NoMoreFlameDots
	mov ax,[Word ptr FlameY+2]
	lea ax,[eax*4+eax]
	shl ax,6
	add ax,[Word ptr FlameX+2]
	mov [fs:di],ax
	inc [NumberOfFlameDots]
NoMoreFlameDots:




;Flame routine
	mov dx,[FlameIntensity]
	mov cx,64000-640
;	mov si,320
	xor si,si
FlameIt:
;    *
;  000 
;   0
	xor ah,ah
	mov al,[es:si+320]
	xor bh,bh
	mov bl,[es:si-1+320]
	add ax,bx
	mov bl,[es:si-2+320]
	add ax,bx
	mov bl,[es:si+320+320-1]
	add ax,bx
	or ax,ax
	jz NotBlack
	sub ax,dx
	jnc NotBlack
	xor ax,ax
NotBlack:
	shr ax,2
	mov [es:si],al
	inc si
	loop FlameIt

	call DisplayScreenBuffers

	inc [Time]
	cmp [Time],FlameFadeOut
	jl NotFlameFadeOut
	add [FlameIntensity],1
NotFlameFadeOut:
	cmp [Time],FlameEndTime
	je FlameEnd

	mov ah,1h
	int 16h
	jz Flame

	xor ax,ax
	int 16h

FlameEnd:
	push cs
	pop es
	mov di,offset Palette
	mov dx,3c7h
	xor al,al
	out dx,al
	mov dx,3c9h
	mov cx,768
	rep insb

	call FadeOut
