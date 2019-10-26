; Y(et)A(nother)Z(oom)B(lur)255
; Optimus/Dirty Minds^Nasty Bugs^Anubis
; 17/06/2005

org 100h

	MOV	AL,13h
	INT	10h

	xor di,di
	push word 07000h
	pop gs
sinegen:
	mov [gs:di],ch
	add cx,si
	mov ax,40
	imul cx
	sub si,dx
	inc di
	jnz sinegen


; ----------- Palgen ---------------

	mov	bx,1010h

	MOV	DX,3C8h
	XOR	AL,AL
	OUT	DX,AL
	INC	DX

loop0:

	MOV	AL,16
	SUB	AL,bh
	SHL	AL,2
	OUT	DX,AL

	shr	al,1
	OUT	DX,AL

	MOV	AL,16
	SUB	AL,BL
	SHL	AL,2
	OUT	DX,AL

	DEC	BL
	JNZ	loop0

	MOV	BL,16
	DEC	BH
	JNZ	loop0


here:

	push word 0a000h
	pop es

	push word 09000h
	pop ds

	push word 08000h
	pop fs

main:
	inc bp
	mov cx,128
bobs:
	mov di,cx
	shl di,4
	add di,bp
	mov bl,[gs:di]
	mov al,bl
	add bl,[gs:di+bp]
	add bl,156
	xor bh,bh

	add al,96
	xor ah,ah
	imul ax,320
	add bx,ax

	xor di,di
	mov eax,3f3f3f3fh
	mov [di+bx],eax
	mov [di+320+bx],eax
	mov [di-320+bx],eax

	dec cx
	jnz bobs

	xor di,di
	mov dx,205
zoomy:
	mov cx,320
zoomx:
	mov bx,cx

	shr bx,3
	sub bx,20

	mov ax,dx

	shr ax,3
	sub ax,12

	push dx
	imul ax,320
	add bx,ax
	pop dx

	mov al,[di+bx]
	mov [fs:di],al
	inc di
	loop zoomx
	dec dx
	jnz zoomy

	xor di,di
copyi:
	mov al,[fs:di]
	mov [di],al
	inc di
	jnz copyi

	xor bx,bx
bluri:
	add al,[di+1]
	add al,[di-320]
	add al,[di+320]
	shr al,2
	mov [di],al
	shr al,2
	mov cl,al
	shl al,1
	mov ch,[bx+63999]
	shr ch,2
	shl ch,4
	or cl,ch
	mov [es:di],cl
	dec bx
	inc di
	jnz bluri

	mov dx,3DAh
vsync:
	in al,dx
	and al,8
	jz vsync

	in al,60h
	dec al
	jnz main

	MOV	AX,3
	INT	10h
RET