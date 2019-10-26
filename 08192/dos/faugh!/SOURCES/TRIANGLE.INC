	XSize	equ	320
;Triangle drawing procedure, fixed point method
;34.385 secs
;           .
;          / \ 2
;         /   \
;      1 /    ,'
;       /   ,'
;      /  ,' 3
;     / ,'
;    /,'
;   /'
Proc	Triangle	;eax high, low - first corner x,y
			;ebx high, low - second corner x,y
			;edx high, low - third corner x,y
			;cl - color

	mov [Color],cl
;Sort angles by height
	cmp ax,bx
	jl Flip1
	xchg eax,ebx
Flip1:
	cmp ax,dx
	jl Flip2
	xchg eax,edx
Flip2:
	cmp bx,dx
	jl Flip3
	xchg ebx,edx
Flip3:

	mov [Angle1],eax
	mov [Angle2],ebx
	mov [Angle3],edx
;Calculate the first (longest by height) line
	mov bp,1	;Forward
	mov di,ax	;Start drawing from Y1
	mov [StartLine],ax
	shl di,1	;*2 (Words)
	mov cx,dx
	sub cx,ax
	inc cx
	mov [NumberOfLines],cx
	ror eax,16
	ror edx,16
	mov si,ax	;Start drawing from X1
	sub ax,dx
	neg ax
;Backward1:
	cwde
	sal eax,16
	mov edx,eax
	sar edx,31	;cwde for dx
	and ecx,0ffffh
	idiv ecx
	shl esi,16
Line1:
	or di,di
	js Higher1
	cmp di,199*2
	jnb OutOfScreen1
	rol esi,16
	mov [LinesStart+di],si
	ror esi,16
Higher1:
	add esi,eax
	add di,2
	loop Line1
OutOfScreen1:

;Calculate the second line
	mov eax,[Angle1]
	mov edx,[Angle2]
	mov bp,1	;Forward
	mov di,ax	;Start drawing from Y1
	shl di,1	;*2 (Words)
	mov cx,dx
	sub cx,ax
	inc cx
	ror eax,16
	ror edx,16
	mov si,ax	;Start drawing from X1
	sub ax,dx
	neg ax
	cwde
	sal eax,16
	mov edx,eax
	sar edx,31	;cwde for dx
	and ecx,0ffffh
	idiv ecx
	shl esi,16
Line2:
	or di,di
	js Higher2
	cmp di,199*2
	jnb OutOfScreen2
	rol esi,16
	mov [LinesEnd+di],si
	ror esi,16
Higher2:
	add esi,eax
	add di,2
	loop Line2
OutOfScreen2:

;Calculate the third line
	mov eax,[Angle2]
	mov edx,[Angle3]
	mov bp,1	;Forward
	mov di,ax	;Start drawing from Y2
	shl di,1	;*2 (Words)
	mov cx,dx
	sub cx,ax
	inc cx
	ror eax,16
	ror edx,16
	mov si,ax	;Start drawing from X2
	sub ax,dx
	neg ax
	cwde
	sal eax,16
	mov edx,eax
	sar edx,31	;cwde for dx
	and ecx,0ffffh
	idiv ecx
	shl esi,16
Line3:
	or di,di
	js Higher3
	cmp di,199*2
	jnb OutOfScreen3
	rol esi,16
	mov [LinesEnd+di],si
	ror esi,16
Higher3:
	add esi,eax
	add di,2
	loop Line3
OutOfScreen3:

;Draw the triangle
;	push 0A000h
;	pop es
	mov di,[StartLine]
	mov si,[StartLine]
	add si,si
	lea edi,[edi*4+edi]
	shl edi,6
	mov cx,[NumberOfLines]
	mov al,[Color]
Draw:
;Clipping routines
	cmp si,199*2
	jnb OutOfScreen4
	mov bx,[LinesStart+si]
	mov dx,[LinesEnd+si]
	or bx,bx
	jns NotOutLeft
	or dx,dx
	js OutOfScreen4
NotOutLeft:
	cmp bx,XSize-1
	jl NotOutRight
	cmp dx,XSize-1
	jnl OutOfScreen4
NotOutRight:
	or bx,bx
	jns NotCutLeft1
	xor bx,bx
NotCutLeft1:
	or dx,dx
	jns NotCutLeft2
	xor dx,dx
NotCutLeft2:
	cmp bx,XSize-1
	jb NotCutRight1
	mov bx,XSize-1
NotCutRight1:
	cmp dx,XSize-1
	jb NotCutRight2
	mov dx,XSize-1
NotCutRight2:

	cmp bx,dx
	jnb Reverse
	xchg bx,dx
Reverse:
	mov bp,bx
	sub bp,dx
	inc bp
	xchg cx,bp
	add di,dx	;bx
	mov bx,dx
	add bx,cx
;	mov al,1
	rep stosb
	sub di,bx
	xchg cx,bp
OutOfScreen4:
	add si,2
	add di,XSize
	loop Draw
	ret

Even
Angle1	dd	?
Angle2	dd	?
Angle3	dd	?
StartLine	dw	?
NumberOfLines	dw	?
;LinesStart	dw	200 dup (?)
;LinesEnd	dw	200 dup (?)
Color	db	?
EndP	Triangle

