;Sea
	NumberOfLinesInSea	equ	110
	TextureSize	equ	128	;128
	TextureLength	equ	2048
	TextureLengthBits	equ	11
	SquareSizeX	equ	4
	SquareSizeY	equ	4
	MoonX	equ	70
	MoonY	equ	20
	Radius	equ	35;33
	MoonXS	equ	40h;40h
	MoonYS	equ	40h;40h
	SkyColor	equ	40h
	NumberOfStars	equ	100;800
	S_TextOffset	equ	320*10+120

	push 0A000h
	pop es
	xor eax,eax
	xor di,di
	mov cx,16000
	rep stosd

	push cs
	pop es

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
	mov cx,20h
	xor bx,bx
	xor si,si
	xor di,di
S_Pal1:
	xor al,al
	out dx,al
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	add bx,200
	add si,230
	loop S_Pal1
	
	mov cx,20h
S_Pal2:
	mov ax,di
	mov al,ah
	out dx,al
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	add di,170	;Red
	add bx,215	;Green
	add si,300	;Blue
	loop S_Pal2

	mov cx,40h-32
	xor bx,bx
S_Pal3:
	xor al,al
	out dx,al
	xor al,al
	out dx,al
	mov al,bh
	out dx,al
	add bx,255
	loop S_Pal3

	xor di,di
	mov si,bx
	xor bx,bx
	mov cx,32
S_Pal4:
	mov ax,di
	mov al,ah
	out dx,al
	mov al,bh
	out dx,al
	mov ax,si
	mov al,ah
	out dx,al
	add di,16320/32	;Red
	add bx,16320/32	;Green
	add si,255	;Blue
	loop S_Pal4


;Initialize timer
	xor ax,ax
	mov es,ax
	mov eax,[es:46ch]
	mov [S_StartTime],eax

	call DrawMoon

	call GeneratePlasma

;	mov si,offset Texture
;	xor di,di
;	mov cx,64000
;	rep movsb

MainLoop:

	push cs
	pop es
	mov di,offset Brightness
	mov cx,NumberOfLinesInSea
	xor al,al
	rep stosb
	mov di,offset Lines
	mov cx,NumberOfLinesInSea
	mov al,0ffh
	rep stosb

	push 0A000h
	pop es

;-------------- Calculate waves
	mov cx,TextureLength
CalculateWaves:


	push cx
	xor eax,eax
	mov ax,cx
	cwde
	mov ebx,eax
	imul eax,ebx
	sar eax,TextureLengthBits
	imul eax,eax
	sar eax,TextureLengthBits
	imul eax,eax
	sar eax,TextureLengthBits-1

	mov esi,eax
	shl esi,3
	sub esi,eax	;esi=eax*7

	neg cx
	add cx,TextureLength

	mov dx,[S_Time1]
	add ax,dx
	mov bx,ax

	and bx,1feh
	mov ax,[Sin256+bx]

	mov [Brightness1],ax
	neg ax
	cwde
	xor edx,edx
	mov dx,cx
	imul eax,edx	;Calculate amplitude from Y coordinate
	sar eax,TextureLengthBits
	imul eax,edx
	sar eax,TextureLengthBits
	imul eax,edx
	sar eax,TextureLengthBits+1	;10
	mov dx,cx
	mov bx,dx
	shr bx,2
	add dx,bx	;*1.25
	shr dx,TextureLengthBits-8

	add ax,dx	;draw from the top to the bottom
	cmp ax,NumberOfLinesInSea
	ja OutOfScreen
	mov bx,ax
	mov dx,cx
	shr dx,TextureLengthBits - 8
	and dl,7fh
;Calculate brightness of the wave
	mov ax,[Brightness1]
	add ax,-256-128
	sar ax,3
	mov bp,ax
	sar bp,1
	sub ax,bp	;*3/4

	add ax,bx
	sar ax,1
	mov bp,ax
	sar bp,2
	add ax,bp
	mov [Lines+bx],dl
	mov [Lines+bx+1],dl
	mov [Brightness+bx],al
	mov [Brightness+bx+1],al
TooDark:
OutOfScreen:
	pop cx
	dec cx
	jnz CalculateWaves


;-------------- Display water
	xor bx,bx
	inc bx
	mov di,(200-NumberOfLinesInSea)*320
	mov cx,NumberOfLinesInSea-1
	mov dx,0h
S_DisplayWater:
	push cx
	mov al,[Lines+bx]
	xor ah,ah
	push si
	mov si,ax
	lea si,[esi*4+esi]
	shl si,6
	add si,offset Texture
	mov cx,160
	sar dl,1
	xor dl,dl
	add dl,[Brightness+bx]
	mov dh,dl		;Soften
Copy:
	lodsw
	add ah,dh
	test ah,80h
	jne S_Black
	add al,dl
	test al,80h
	jne S_Black
	jmp S_NotBlack
S_Black:
	xor ax,ax
S_NotBlack:
	shr al,1
	shr ah,1
	stosw
	loop Copy
	pop si
	pop cx
	inc bx
	loop S_DisplayWater

;-------------- Display the moon
	push 0A000h
	pop es

	mov ax,[CloudsX]
	add ax,19
	cmp ax,320*16
	ja NotCloudsLoop
	sub ax,320*16
NotCloudsLoop:
	mov [CloudsX],ax

	mov bx,[CloudsX2]
	add bx,9
	cmp bx,320*16
	ja NotCloudsLoop2
	sub bx,320*16
NotCloudsLoop2:
	mov [CloudsX2],bx

	shr ax,4
	shr bx,4

	mov di,(MoonY)*320+MoonX-MoonXS/2
	mov bp,offset Texture
	add bp,ax				;Texture+CloudsX
	add bx,offset Texture+320*20		;Texture[MoonYs*320]+CloudsX2
	mov si,offset Moon
	mov cx,MoonYS
DMoonY:
	push cx
	mov cx,MoonXS/2
DMoonX:
	lodsw
	mov dx,[ds:bp]
	shr dl,1
	shr dh,1
	sub al,dl
	sub ah,dh

	mov dx,[ds:bx]

	shr dl,1
	shr dh,1
	sub al,dl
	sub ah,dh

	cmp al,40h
	jb NotTooDarkSky1
	xor al,al
NotTooDarkSky1:
	cmp ah,40h
	jb NotTooDarkSky2
	xor ah,ah
NotTooDarkSky2:

	add ax,SkyColor+SkyColor shl 8
	stosw
	add bp,2
	add bx,2
	loop DMoonX
	pop cx
	add di,320-MoonXS
	add bp,320-MoonXs
	add bx,320-MoonXS
	loop DMoonY

;-------------- Display text -------------------------------------------------
	push 0A000h
	pop es

	mov al,[S_Time]
	sub al,[S_OldTime]
;	and ax,0ffh
;	jnz NotNextPage
	jnc NotNextPage
	mov bx,[PageNumber]
	inc bx
	cmp bx,TotalPages
	jne NotWrap
;	xor bx,bx
	jmp ExitSea
NotWrap:
	mov [PageNumber],bx
NotNextPage:
	mov bx,[PageNumber]
	mov si,bx
	add si,si
	mov ax,[PagesOffs+si]
	mov si,ax

	mov di,S_TextOffset
	mov bp,di
S_DisplayText:
	lodsb
	cmp al,1
	je S_NoMoreText
	or al,al
	jnz S_NotNewString
	add bp,320*16*2
	mov di,bp
	jmp S_DisplayText
S_NotNewString:
	push si
	xor ah,ah
	shl ax,4	;*16 (font size)
	mov si,ax
	add si,offset Font
	mov cx,16
	mov ah,[TextBrightness]
S_Font_Ver:
	push cx
	lodsb
	push si
	mov cx,8
S_Font_Hor:
	rol al,1
	test al,1
	je S_Font_Black
	mov dl,ah
	mov si,di
	mov si,[CloudsX]
	shr si,4
	add si,di
	sub dl,[ds:si+Texture]
	cmp dl,3fh
	jb NotTooDarkText
	xor dl,dl
NotTooDarkText:
	add dl,SkyColor
	mov [es:di],dl
	mov dl,ah
	sub dl,[ds:si+Texture+320]
	cmp dl,3fh
	jb NotTooDarkText2
	xor dl,dl
NotTooDarkText2:
	add dl,SkyColor
	mov [es:di+320],dl
S_Font_Black:
	add di,1	;2
	loop S_Font_Hor
	pop si
	pop cx
	add di,320*2-8	;*2
	loop S_Font_Ver
	add di,-320*16*2+8	;*2
	pop si

	jmp S_DisplayText
S_NoMoreText:


;-------------- Time passes
	mov al,[S_Time]
	mov [S_OldTime],al
	push es
	xor ax,ax
	mov es,ax
	mov eax,[es:046Ch]
	sub eax,[S_StartTime]
	pop es

	add eax,eax
;	shl eax,2
;	lea eax,[eax*2+eax]

	mov dx,ax
	shr ax,1	;1
	mov [S_Time],al

	lea dx,[edx*4+edx]
	shl dx,1
	mov [S_Time1],dx

	mov al,[S_Time]
	cmp al,1
	jl S_NotFadeIn
	cmp al,32
	jnl S_NotFadeIn
;	mov [TextBrightnessSpeed],2
	mov ah,al
;	neg ah
	add ah,ah
	mov [TextBrightness],ah
S_NotFadeIn:
;	cmp al,32
;	jne NotFadeStop
;	mov [TextBrightnessSpeed],0
;NotFadeStop:
	cmp al,-30
	jl NotFadeOut
	cmp al,-1
	jnl NotFadeOut
;	mov [TextBrightnessSpeed],-2
	mov ah,al
	neg ah
	add ah,ah
	mov [TextBrightness],ah
NotFadeOut:

;	mov al,[TextBrightnessSpeed]
;	add [TextBrightness],al

	in al,60h
	test al,80h
	je Exit
	jmp MainLoop
Exit:

	xor ax,ax
	int 16h

ExitSea:

	call FadeOut

;	ret

