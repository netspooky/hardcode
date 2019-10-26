;Greets
	GreetsEndTime	equ	250

	call ClearScreenBuffers
	call DisplayScreenBuffers

	mov [Time],0

	push [TextSegment]
	pop es
	xor di,di
	xor eax,eax
	mov cx,16000
	rep stosd

	mov si,offset Greets
	mov edx,20202020h
	mov ebx,20202020h
	mov di,GreetsOffset
	call DisplayText

	push ds
	pop es
	mov di,offset Pal
	xor bx,bx
	xor si,si
	xor dx,dx

	mov cx,16
Pal3_1:
	mov al,bh
	stosb
	mov ax,si
	mov al,ah
	stosb
	mov ax,dx
	mov al,ah
	stosb
	add bx,0ffh*4
;	add si,0ffh
	loop Pal3_1

	mov cx,16
Pal3_2:
	mov al,bh
	stosb
	mov ax,si
	mov al,ah
	stosb
	mov ax,dx
	mov al,ah
	stosb
	add bx,0;0ffh
	add si,0;-0ffh
	add dx,0ffh*4
	loop Pal3_2


	xor bp,bp
Redraw:
	push [TextSegment]
	pop fs

	mov cx,7
	xor di,di
	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
GreetsBrightnessSet:
	mov si,offset Pal
	mov ah,[ds:GreetsBrightness+di]
	mov bx,32*3
GreetsBrightnessSet2:
	lodsb
	add al,ah
	cmp al,63
	jl NotColorOverflow
	mov al,63
NotColorOverflow:
	out dx,al
	dec bx
	jnz GreetsBrightnessSet2
	add ah,[ds:GreetsBrightnessSpeed+di]
	mov [ds:GreetsBrightness+di],ah
	cmp ah,62
	jl GreetsBrightnesSpeedNotStop
	mov [ds:GreetsBrightnessSpeed+di],0
GreetsBrightnesSpeedNotStop:
	cmp ah,0FFh
	jne GreetsBrightnessSpeedNotStop2
	mov [ds:GreetsBrightness+di],0
	mov [ds:GreetsBrightnessSpeed+di],0
GreetsBrightnessSpeedNotStop2:
	mov eax,[Time]
	mov si,di
	add si,si
	cmp [ds:GreetsBrightnessTime+si],ax
	jne NotFadeIn
	mov [ds:GreetsBrightnessSpeed+di],2
NotFadeIn:

	inc di
	loop GreetsBrightnessSet

	mov cx,64000
	mov bx,-160
	mov dx,-100
	xor di,di
	push 0A000h
	pop es
DrawPattern:
	push dx
	mov ax,bx
	imul dx
	pop dx
	shr ax,2
	add ax,bp
	test al,80h
	je NotBackward
	not al
NotBackward:
	shr al,2
	or al,[fs:di]
	stosb
	inc bx
	cmp bx,160
	jne NotNewScanLine
	sub bx,320
	inc dx
NotNewScanLine:
	loop DrawPattern

	add bp,4
	inc [Time]

	cmp [Time],GreetsEndTime
	je GreetsEnd

	mov ah,1
	int 16h
	jz Redraw

	xor ax,ax
	int 16h

GreetsEnd:
	call FadeOut
