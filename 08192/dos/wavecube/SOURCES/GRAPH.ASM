	IDEAL
Proc	DrawLine	;al - color
			;ebx high - X1
			;ebx low - Y1
			;edx high - X2
			;edx low - Y2
			;es - output segment

	mov ah,al

	xor cx,cx
	mov [XErr],cx
	mov [YErr],cx


	ror ebx,16
	ror edx,16
	mov cx,dx
	sub cx,bx
	mov [Delta_X],cx
	rol ebx,16
	rol edx,16
	mov cx,dx
	sub cx,bx
	mov [Delta_Y],cx

	cmp [Delta_X],0
	jnl HorRight
	jl HorLeft
	mov [IncX],0
	mov [IncX2],0
	jmp HorisontalOk
HorRight:
	mov [IncX],1
	mov [IncX2],1
	jmp HorisontalOk
HorLeft:
	mov [IncX],-1
	mov [IncX2],-1
HorisontalOk:

	cmp [Delta_Y],0
	jnl VertDown
	jl VertUp
	mov [IncY],0
	mov [IncY2],0
	jmp VerticalOk
VertDown:
	mov [IncY],1
	mov [IncY2],320
	jmp VerticalOk
VertUp:
	mov [IncY],-1
	mov [IncY2],-320
VerticalOk:

	test [Delta_X],8000h
	je Abs_1
	neg [Delta_X]
Abs_1:
	test[Delta_Y],8000h
	je Abs_2
	neg [Delta_Y]
Abs_2:



	mov cx,[Delta_X]
	cmp cx,[Delta_Y]
	jnl XLonger
	mov cx,[Delta_Y]
XLonger:
	inc cx

	mov si,cx		;cx & si - distance

	lea di,[ebx*4+ebx]
	shl di,6
	ror ebx,16
	add di,bx
	rol ebx,16		;Calculate starting point

DrawLoop:
	cmp bx,199
	jnb OutOfScreen
	ror ebx,16
	cmp bx,318
	jnb OutOfScreen2
	ror ebx,16

;Draw a dot
	add [es:di+1],al
	add [es:di+320],al
	add [es:di+321],al
	add [es:di+322],al
	add [es:di+641],al
	add [es:di],al
	add [es:di+2],al
	add [es:di+640],al
	add [es:di+642],al

	jmp Drawn

OutOfScreen2:
	rol ebx,16
OutOfScreen:
Drawn:

	mov dx,[XErr]
	add dx,[Delta_X]
	cmp dx,si
	jl NotCarry1
	sub dx,si
	ror ebx,16	;get access to X
	add bx,[IncX]	;Change X
	add di,[IncX2]
	rol ebx,16
NotCarry1:
	mov [XErr],dx

	mov dx,[YErr]
	add dx,[Delta_Y]
	cmp dx,si
	jl NotCarry2
	sub dx,si
	add bx,[IncY]	;Change Y
	add di,[IncY2]
NotCarry2:
	mov [YErr],dx

	dec cx
	jnz DrawLoop

	ret
XErr	dw	0
YErr	dw	0
Delta_X	dw	0
Delta_Y	dw	0
IncX	dw	0
IncY	dw	0
IncX2	dw	0
IncY2	dw	0

EndP

