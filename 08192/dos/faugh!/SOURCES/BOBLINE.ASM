Proc	DrawBobLine	;eax high, low : X1,Y1
			;ebx high, low : X2,Y2
			;cl - color
	
	mov [DWord ptr BLineY1],eax
	mov [DWord ptr BLineY2],ebx
	mov [BLineColor],cl
	mov ax,[BLineX2]
	sub ax,[BLineX1]
	or ax,ax
	jns BLineAbs1
	neg ax
BLineAbs1:
	mov bx,[BLineY2]
	sub bx,[BLineY1]
	or bx,bx
	jns BLineAbs2
	neg bx
BLineAbs2:
	mov cx,ax
	cmp bx,ax
	jl BLineNotVertLonger
	mov cx,bx
BLineNotVertLonger:
	inc cx
	and ecx,0ffffh
	mov ax,[BLineX2]
	sub ax,[BLineX1]
	shl eax,16
	mov edx,eax
	sar edx,31
	idiv ecx
	mov [BLineXStep],eax
	mov ax,[BLineY2]
	sub ax,[BLineY1]
	shl eax,16
	mov edx,eax
	sar edx,31
	idiv ecx
	mov [BLineYStep],eax

	mov bx,[BLineX1]
	mov dx,[BLineY1]
	shl ebx,16
	shl edx,16
	mov al,[BLineColor]
	mov ah,al
	ror eax,16
	mov al,[BLineColor]
	mov ah,al
	mov esi,[BLineXStep]
	mov ebp,[BLineYStep]
BLineDraw:
	add ebx,esi
	add edx,ebp

	cmp ebx,319*10000h
	ja BLineOutOfScreen
	cmp edx,199*10000h
	ja BLineOutOfScreen

	mov edi,edx
	shr edi,16
	lea di,[edi*4+edi]
	shl di,6
	ror ebx,16
	add di,bx
	rol ebx,16
;	stosb
;  0000
;00000000 
;00000000
;00000000
;00000000
;  0000
;	add [es:di+1],ax
;	add [es:di+320],eax
;	add [es:di+640],eax
;	add [es:di+961],ax

	add [es:di+2],eax
	add [es:di+320],eax
	add [es:di+324],eax
	add [es:di+640],eax
	add [es:di+644],eax
	add [es:di+960],eax
	add [es:di+964],eax
	add [es:di+1280],eax
	add [es:di+1284],eax
	add [es:di+1602],eax


BLineOutOfScreen:
	loop BLineDraw
	ret

BLineY1		dw	?
BLineX1		dw	?
BLineY2		dw	?
BLineX2		dw	?
BLineColor	db	?
BLineXStep	dd	?
BLineYStep	dd	?

EndP	DrawBobLine
