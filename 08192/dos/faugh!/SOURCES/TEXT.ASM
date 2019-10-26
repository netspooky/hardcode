;Write text
;-------------- Display text -------------------------------------------------
Proc	DisplayText
;	push [TextSegment]
;	pop es
;	mov si,offset Text1

;	mov di,TextOffset
;	mov edx,40404040h
	mov bp,di
@@DisplayText:
	lodsb
	cmp al,1
	je NoMoreText
	or al,al
	jnz NotNewString
	add bp,320*16*2
	mov di,bp
	jmp @@DisplayText
NotNewString:
	cmp al,2
	jne NotHalfChar
	add di,10
	jmp @@DisplayText
NotHalfChar:
	cmp al,3
	jne NotNextColor
;	add edx,40404040h
	add edx,ebx
	jmp @@DisplayText
NotNextColor:
	push si
	xor ah,ah
	shl ax,4	;*16 (font size)
	mov si,ax
	add si,offset Font
	mov cx,16
;	mov ah,[TextBrightness]
Font_Ver:
	push cx
	lodsb
	push si
	mov cx,8
Font_Hor:
	rol al,1
	test al,1
	jz Font_Black
;	mov dx,4040h
	mov [es:di],dx
	mov [es:di+320],dx
Font_Black:
	add di,2	;1
	loop Font_Hor
	pop si
	pop cx
	add di,320*2-8*2
	loop Font_Ver
	add di,-320*16*2+8*2+4
	pop si

	jmp @@DisplayText
NoMoreText:

;Remove corners
	xor si,si
	mov cx,64000
RemoveCorners:
	cmp [byte ptr es:si],0
	je NotCorner1
	cmp [byte ptr es:si+642],0
	je NotCorner1
	mov al,[es:si]
	mov [es:si+321],al
NotCorner1:
	cmp [byte ptr es:si+2],0
	je NotCorner2
	cmp [byte ptr es:si+640],0
	je NotCorner2
	mov al,[es:si+2]
	mov [es:si+321],al
NotCorner2:
	inc si
	loop RemoveCorners

	ret
EndP	DisplayText
