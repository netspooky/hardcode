; --------------------
;       SiTehDrei
;  a multipart 256btro
;      by Optimus
; --------------------


org 100h

	mov al,13h
	int 10h

; ----------- Sinegen ------------

	xor di,di
	push word 08000h
	pop ds
sinegen:
	mov [di],ch
	add cx,si
	mov ax,40
	imul cx
	sub si,dx
	inc di
	jnz sinegen

	push word 07000h
	pop es

	xor cx,cx
	xor di,di
xorgen:
	mov ax,di
	xor al,ah
	stosb
	loop xorgen

	push es
	pop gs

	push word 0a000h
	pop es

	push word 09000h
	pop fs

	mov di,320*4
	xor bp,bp
main:

	mov bx,bp

	cmp bh,4
	jnc firepart

; Color Tunnel

	mov di,32
	mov ch,200
yloop:
	mov cl,0
xloop:
	mov al,cl
	sub al,128
	imul al
	mov dx,ax

	mov al,ch
	sub al,100
	imul al
	add ax,dx
	inc ax
	inc ax

	mov bx,ax
	xor dx,dx
	mov ax,65535
	idiv bx
	add ax,bp
	mov bx,ax

	mov al,[ds:bx]
	and al,127
	add al,16
	stosb
	dec cl
	jnz xloop
	add di,64
	dec ch
	jnz yloop

	jmp edw


; Blurry Stars

firepart:

	cmp bh,10
	jnc lastpart

	mov dx,3c8h
	xor al,al
	out dx,al
	inc dx
pal256:
	out dx,al
	out dx,al
	out dx,al
	inc al
	jnz pal256


; Writting shit

	mov di,160
	xor ch,ch
	mov cl,200
ayloop:

	mov al,[ds:bx]
	add al,[ds:di+bx]

	xor ah,ah
	add di,ax
	add di,cx
	mov dl,64

	mov [fs:di+bx],dl
	add di,320
	mov [fs:di+bx],dl
	sub di,ax

	dec cx
	jnz ayloop


; Blurring shit

	mov di,320
loopi:
	mov al,[fs:di]
	inc di
	add al,[fs:di]
	dec di
	add al,[fs:di-320]
	add al,[fs:di+320]
	shr al,2
	mov [fs:di],al
	stosb
	or di,di
	jnz loopi

	jmp edw


; XOR texture distort

lastpart:

	cmp bh,15
	jnc tehend

	xor di,di
	xor cx,cx

iloop2:
	mov bl,ch
	xor bh,bh
	add bx,bp
	mov bl,[ds:bx]
	mov al,[gs:di+bx]
	stosb
	dec cx
	jnz iloop2

edw:
	inc bp


; Vsync and check for escape

	mov dx,3DAh
vsync:
	in al,dx
	and al,8
	jz vsync

	xor ax,ax
	in al,60h
	dec al
	jnz main

tehend:
	mov al,03h
	int 10h
	ret
