Proc	GeneratePlasma

	push cs
	pop es

	mov di,offset Texture
	mov cx,TextureSize/SquareSizeY
Gen:
	push cx
	mov cx,320/SquareSizeX
Gen2:
	call Random
	and al,1fh	;3fh
	mov ah,al
	push cx
	mov cx,SquareSizeY
Gen3:
	push cx
	mov cx,SquareSizeX/2
	rep stosw
	pop cx
	add di,320-SquareSizeX
	loop Gen3
	pop cx
	add di,-320*SquareSizeY+SquareSizeX
	loop Gen2
	pop cx
	add di,320*(SquareSizeY-1)
	loop Gen

;Draw light vertical line.
	mov di,offset Texture+MoonX-20/2	;Line position
	mov cx,TextureSize*3/10	;draw line only on a part of the texture
	mov dx,5050h
MoonReflection:
	sub dx,0202h
	push cx
	mov cx,20/2	;width of the line
HorLine:
	add [word es:di],dx
	add di,2
	loop HorLine
	pop cx
	add di,320-20
	loop MoonReflection


	mov cx,10	;12
S_Soften2:
	mov dx,TextureSize*320-642
	call Soften
	loop S_Soften2
	ret
EndP	GeneratePlasma

Proc	DrawMoon

;Draw a circle
	push cs
	pop es
	mov di,offset Texture
;	mov ax,(SkyColor) shl 8 + (SkyColor)
;	mov cx,320*(200-NumberOfLines)/2+160*20
;	rep stosw

;	mov di,320*MoonY+MoonX-(MoonXS/2)+offset Texture
	mov di,offset Moon
	mov bx,MoonYS
CircleY:
	mov cx,MoonXS
CircleX:
	mov ax,cx
	sub ax,MoonYS/2
	imul ax,ax
	mov bp,ax
	mov ax,bx
	sub ax,MoonXS/2
	imul ax,ax
	add bp,ax
	xor al,al
	not bp
	add bp,Radius*Radius*2
	cmp bp,Radius*Radius
	jl OutOfCircle
	mov ax,bp
	sub ax,Radius*Radius
	shr ax,4
	cmp ax,3eh
	jne NotBorder
	mov ax,3Ah*2	;Border color
	jmp OutOfCircle
NotBorder:
	jb NotWhite
	mov ax,3fh*2
NotWhite:
OutOfCircle:
	shr ax,1
	stosb
	loop CircleX
	dec bx
	jnz CircleY

;Draw stars
	mov cx,NumberOfStars
Stars:
	call Random
	and ax,7fffh	;star coordinate
	mov di,ax
	add di,offset Texture

	call Random
	and ax,3fh	;Color
	add ax,SkyColor

	mov [byte ptr es:di],al
	loop Stars

	mov cx,4	;10
SoftenSky:
	mov dx,NumberOfLinesInSea*320
;	call Soften
	loop SoftenSky

	push 0A000h
	pop es

;	mov si,offset Texture
;	xor di,di
;	mov cx,320*(200-NumberOfLinesInSea)/2
;	rep movsw

	ret
EndP	DrawMoon

Proc	Soften	;dx - texture size
	push cx
	mov cx,dx
	mov si,TextureSize*320-321
	mov di,si
SoftenL:
	xor ah,ah
	xor bx,bx
	mov al,[Texture+si]
	mov bl,[Texture+si-1]
	add ax,bx
	mov bl,[Texture+si+1]
	add ax,bx
	mov bl,[Texture+si-320]
	add ax,bx
	shr ax,2
	mov [ds:Texture+di],al
	dec si
	dec di
	loop SoftenL
	pop cx
	ret
EndP	Soften

;Include "Random2.Inc"



S_Time1	dw	0
S_Time	db	0
S_OldTime	db	0
S_StartTime	dd	0
CloudsX		dw	0
CloudsX2	dw	0
TextBrightness	db	0
TextBrightnessSpeed	db	0

TotalPages	equ	3
PageNumber	dw	0
PagesOffs	dw	offset Page1, offset Page2, offset Page3
Page1	db	'This intro was coded',0
	db	'by Agent Orange',1
Page2	db	'Stop sign was drawn',0
	db	'by Noob Saibot :-)',1
Page3	db	'Thanks to Karina',0
	db	'for inspiring me',1

;Palette:
;	include "pal.inc"
;Sine
;Sin256 dw	256 dup (?)
;	include "sine.inc"
;Texture:
;	include "texture.inc"
;Texture	db	TextureSize*320 dup (?)
;Moon	db	MoonXS*MoonYS dup (?)
;Font	db	4096 dup (?)

Lines		db	NumberOfLinesInSea+2 dup (?)
Brightness	db	NumberOfLinesInSea+2 dup (?)
Brightness1	dw	?

