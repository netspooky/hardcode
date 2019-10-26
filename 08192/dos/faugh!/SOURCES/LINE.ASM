Proc	DrawLine	;eax high, low : X1,Y1
			;ebx high, low : X2,Y2
			;cl - color
	
	mov [DWord ptr LineY1],eax
	mov [DWord ptr LineY2],ebx
	mov [LineColor],cl
	mov ax,[LineX2]
	sub ax,[LineX1]
	or ax,ax
	jns LineAbs1
	neg ax
LineAbs1:
	mov bx,[LineY2]
	sub bx,[LineY1]
	or bx,bx
	jns LineAbs2
	neg bx
LineAbs2:
	mov cx,ax
	cmp bx,ax
	jl LineNotVertLonger
	mov cx,bx
LineNotVertLonger:
	inc cx
	and ecx,0ffffh
	mov ax,[LineX2]
	sub ax,[LineX1]
	shl eax,16
	mov edx,eax
	sar edx,31
	idiv ecx
	mov [LineXStep],eax
	mov ax,[LineY2]
	sub ax,[LineY1]
	shl eax,16
	mov edx,eax
	sar edx,31
	idiv ecx
	mov [LineYStep],eax

	mov bx,[LineX1]
	mov dx,[LineY1]
	shl ebx,16
	shl edx,16
	mov al,[LineColor]
	mov esi,[LineXStep]
	mov ebp,[LineYStep]
LineDraw:
	add ebx,esi
	add edx,ebp

	cmp ebx,319*10000h
	ja LineOutOfScreen
	cmp edx,199*10000h
	ja LineOutOfScreen

	mov edi,edx
	shr edi,16
	lea di,[edi*4+edi]
	shl di,6
	ror ebx,16
	add di,bx
	rol ebx,16
	stosb
LineOutOfScreen:
	loop LineDraw
	ret

LineY1		dw	?
LineX1		dw	?
LineY2		dw	?
LineX2		dw	?
LineColor	db	?
LineXStep	dd	?
LineYStep	dd	?

EndP	DrawLine	
