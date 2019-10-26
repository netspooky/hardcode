;Watery waves
	NumberOfSplashes	equ	40h
	Fading			equ	0
	ChangeColorNumber	equ	5
	SplashesTimeLimit	equ	160
	Text1FadeIn		equ	100
	Text2FadeIn		equ	120
	Text3FadeIn		equ	140
	WavesEndTime		equ	180
	TextOffset	equ	40*320+22

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	mov cx,64
Pal:
	xor al,al
	out dx,al
	out dx,al
	mov al,cl
	neg al
;	shr al,2
	out dx,al
	loop Pal
	
	mov cx,64
Pal2:
	mov al,3fh
	out dx,al
	xor al,al
	out dx,al
	mov al,cl
	neg al
	out dx,al
	loop Pal2

	call ClearScreenBuffers

;Write text
;-------------- Display text -------------------------------------------------
	push [TextSegment]
	pop es

	mov si,offset Text1
	mov di,TextOffset
	mov edx,40404040h
	mov ebx,40404040h

	call DisplayText

Waves:
;Change palette
	mov dx,3c8h
	mov al,64
	out dx,al
	inc dx
	mov cx,64
	mov bl,[Text1Brightness]
Palette1:
	mov al,bl
	out dx,al
	xor al,al
	out dx,al
	mov al,cl
	neg al
	out dx,al
	loop Palette1

	mov bl,[Text2Brightness]
	mov cx,64
Palette2:
	mov al,bl
	out dx,al
	xor al,al
	out dx,al
	mov al,cl
	neg al
	out dx,al
	loop Palette2

	mov bl,[Text3Brightness]
	mov cx,64
Palette3:
	mov al,bl
	out dx,al
	xor al,al
	out dx,al
	mov al,cl
	neg al
	out dx,al
	loop Palette3


	push [WaterSegment]
	pop es
	push [TextSegment]
	pop fs

;Generate the splashes on the water
	cmp [SplashesTime],SplashesTimeLimit
	jg NoSplashes
	mov al,[Splashes]
	xor ah,ah
	add ax,NumberOfSplashes
	mov [Splashes],al
	mov cl,ah
	xor ch,ch
	jcxz NoSplashes
GenerateSplashes:
	call Random
	cmp ax,64000-320*8
	jnb GenerateSplashes
	mov di,ax
	add di,320*4
	xor [byte ptr es:di],0ffh;80h
;	xor [word ptr ds:di+Water],8080h
;	xor [word ptr ds:di+Water+320],8080h
	loop GenerateSplashes
NoSplashes:

;	mov cx,64000-320*2
	mov bp,196
	mov di,320+320+1
W_Soften2:
	mov cx,318
;	mov di,offset Water+320
W_Soften:
;     1		;1
;   12321	;9
;   13431	;12
;   12321	;9
;     1 	;1	;1+9+12+9+1=32
	xor ah,ah
	xor bh,bh

	mov al,[es:di]
	mov dl,al
	shl ax,2	;*4

	mov bl,[es:di+1]
	add ax,bx
	add ax,bx
	add ax,bx
	mov bl,[es:di-1]
	add ax,bx
	add ax,bx
	add ax,bx
	mov bl,[es:di+320]
	add ax,bx
	add ax,bx
	add ax,bx
	mov bl,[es:di-320]
	add ax,bx
	add ax,bx
	add ax,bx


	mov bl,[es:di-320-1]
	add ax,bx
	add ax,bx
	mov bl,[es:di-320+1]
	add ax,bx
	add ax,bx
	mov bl,[es:di+320-1]
	add ax,bx
	add ax,bx
	mov bl,[es:di+320+1]
	add ax,bx
	add ax,bx

	mov bl,[es:di-2]
	add ax,bx
	mov bl,[es:di+2]
	add ax,bx
	mov bl,[es:di-320-2]
	add ax,bx
	mov bl,[es:di-320+2]
	add ax,bx
	mov bl,[es:di+320-2]
	add ax,bx
	mov bl,[es:di+320+2]
	add ax,bx
	mov bl,[es:di-320*2]
	add ax,bx
	mov bl,[es:di+320*2]
	add ax,bx
	add ax,Fading
	shr ax,5

;	sub al,1
;	jnc NotBlack
;	xor al,al
;NotBlack:

;	mov bx,ChangeColorNumber
;ChangeColor:
;	cmp dl,al
;	jg Dark
;	jb Bright
;	jmp Equals
;Dark:
;	sub dl,2
;Bright:
;	inc dl
;Equals:
;	dec bx
;	jnz ChangeColor

	xor dh,dh
	xor ah,ah
	sub ax,dx
	cmp ax,ChangeColorNumber
	jb NotTooHigh
	mov ax,ChangeColorNumber
NotTooHigh:
	cmp ax,-ChangeColorNumber
	jg NotTooLow
	mov ax,-ChangeColorNumber
NotTooLow:
	add dx,ax

	mov [es:di],dl
	inc di
	dec cx
	jnz W_Soften

	add di,2
	dec bp
	jnz W_Soften2

	push [GraphBuffer]
;	push 0A000h
	pop es
	push [WaterSegment]
	pop gs
;	mov si,offset Water
	xor si,si
	xor di,di
	mov cx,64000/4
	mov bl,[Sharpness]
	shr bl,1
	mov bh,bl
	ror ebx,8
	mov bh,bl
	ror ebx,8
	mov bh,bl
DisplayWater:
	mov eax,[gs:si]
	add si,4
;	and eax,7f7f7f7fh
	mov dx,4
RotateDWord:
	test al,80h	;40h
	je NotReverse1
	xor al,0ffh	;07fh
NotReverse1:
	shr al,1
	rol eax,8
	dec dx
	jnz RotateDWord
	or eax,ebx
	or eax,[fs:di]
	stosd
	loop DisplayWater

	call DisplayScreenBuffers

;	xor ax,ax
;	int 16h

;Text brightness routines
	mov al,[Text1Brightness]
	add al,[Text1BrightnessSpeed]
	cmp al,62
	jl NotText1BrightnessMax
	mov [Text1BrightnessSpeed],0
NotText1BrightnessMax:
	mov [Text1Brightness],al

	mov al,[Text2Brightness]
	add al,[Text2BrightnessSpeed]
	cmp al,62
	jl NotText2BrightnessMax
	mov [Text2BrightnessSpeed],0
NotText2BrightnessMax:
	mov [Text2Brightness],al

	mov al,[Text3Brightness]
	add al,[Text3BrightnessSpeed]
	cmp al,62
	jl NotText3BrightnessMax
	mov [Text3BrightnessSpeed],0
NotText3BrightnessMax:
	mov [Text3Brightness],al


	mov al,[Sharpness]
	add al,[SharpnessSpeed]
	cmp al,15
	jne SharpnessDown
	mov [SharpnessSpeed],-1
SharpnessDown:
	cmp al,0
	jne SharpnessUp
	mov [SharpnessSpeed],1
SharpnessUp:
;	mov [Sharpness],al

	inc [SplashesTime]

	inc [Time]
	cmp [Time],Text1FadeIn
	jne NotText1FadeIn
	mov [Text1BrightnessSpeed],2
NotText1FadeIn:
	cmp [Time],Text2FadeIn
	jne NotText2FadeIn
	mov [Text2BrightnessSpeed],2
NotText2FadeIn:
	cmp [Time],Text3FadeIn
	jne NotText3FadeIn
	mov [Text3BrightnessSpeed],2
NotText3FadeIn:
	cmp [Time],WavesEndTime
	je WavesEnd

	mov ah,1h
	int 16h
	jz Waves

	xor ax,ax
	int 16h

WavesEnd:
	call FadeOut	

