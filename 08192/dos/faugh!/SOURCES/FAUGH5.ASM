;Blow up!
	FadeWhiteTime	equ	60;220
	BlowEndTime	equ	83

	push cs
	pop es

;	mov di,offset Palette
;	mov dx,3c7h
;	xor al,al
;	out dx,al
;	mov dx,3c9h
;	mov cx,768
;	rep insb

	mov [Time],0

	call ClearScreenBuffers
	push [GraphBuffer]
	pop es

	mov cx,16384
	xor eax,eax
	xor di,di
	rep stosd

	call DisplayScreenBuffers

	call WaitVR

;	push [GraphBuffer]
;	pop es

Blow:

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	mov ah,[BlowScreenBrightness]
	mov si,offset Palette
	mov cx,768
BlowPalette:
	lodsb
	add al,ah	
	cmp al,63
	jl BlowPalNotOverflow
	mov al,63
BlowPalNotOverflow:
	out dx,al
	loop BlowPalette

	mov cx,16
	mov si,[Angle]	;si - angle
	mov di,[Word ptr BlowRadius+2]
	mov bp,di
	shl di,1
	xor bp,di
DrawRays:
	xor di,bp
	and si,01feh
	mov ax,[ds:Sin256+si]
	imul di
	mov al,ah
	mov ah,dl
	add ax,160
	shl eax,16
	mov ebx,eax
	add si,80h
	and si,01feh
	mov ax,[ds:Sin256+si]
	sub si,80h
	imul di
	mov al,ah
	mov ah,dl
	add ax,100
	mov bx,ax
	mov eax,0A00064h
	pusha
	mov cl,[Byte ptr BlowBrightness+1]
	call DrawLine
	popa
	pusha
	mov cl,[Byte ptr BlowBrightness+1]
	mov eax,0A00064h
	add eax,00010001h
	add ebx,00010001h
	call DrawLine
	popa
	pusha
	mov cl,[Byte ptr BlowBrightness+1]
	mov eax,00A00064h
	add eax,00010000h
	add ebx,00010000h
	call DrawLine
	popa
	pusha
	mov cl,[Byte ptr BlowBrightness+1]
	mov eax,00A00064h
	add eax,00000001h
	add ebx,00000001h
	call DrawLine
	popa

	add si,20h
	dec cx
	jnz DrawRays

;Blow soften
	mov cx,64000
	xor si,si
BlowSoften:
	xor ah,ah
	mov al,[es:si]
	xor bh,bh
	mov bl,[es:si-1]
	add ax,bx
	mov bl,[es:si+1]
	add ax,bx
	mov bl,[es:si-320]
	add ax,bx
	mov bl,[es:si+320]
	add ax,bx
	mov bl,[es:si-1-320]
	add ax,bx
	mov bl,[es:si-1+320]
	add ax,bx
	mov bl,[es:si+1-320]
	add ax,bx
	mov bl,[es:si+1+320]
	add ax,bx
	mov bl,9	;5
	div bl
;	sub al,2
;	sub al,1
;	jnc BlowNotOverflow
;	xor ax,ax
;BlowNotOverflow:
	mov [es:si],al
	inc si
	loop BlowSoften

	add [Angle],6

	mov ax,[BlowBrightness]
	add ax,200*4
	jnc NotBlowTooBright
	mov ax,0ffffh
NotBlowTooBright:
	mov [BlowBrightness],ax

	mov eax,[BlowRadiusSpeed]
	add [BlowRadius],eax
	shr eax,3
	add [BlowRadiusSpeed],eax	;150
;	add [BlowRadiusSpeed],250*6	;150
	cmp [BlowRadius],0ff0000h
	jl NotBlowStop
	mov [BlowRadiusSpeed],0
NotBlowStop:

	call DisplayScreenBuffers

	inc [Time]
	cmp [Time],FadeWhiteTime
	jl NotFadeWhite
	cmp [BlowScreenBrightness],63
	jnl NotFadeWhite
	add [BlowScreenBrightness],3
NotFadeWhite:

	cmp [Time],BlowEndTime
	je BlowEnd

	mov ah,1
	int 16h
	jz Blow

	xor ax,ax
	int 16h

BlowEnd:
