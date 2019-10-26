org 100h

pontdb equ 9

start:
	fninit
	mov al,13h
	int 10h

	xor ax,ax
	mov dx,3c8h
	out dx,al
	inc dx
@palcyc:
	out dx,al
	out dx,al
	out dx,al
	sbb al,41h
	loop @palcyc

gen:
	mov cl,pontdb*2
	mov di,pontok
@rndcik:
xmul:	imul ax,8497h
	inc ax
	push ax
	and ax,127			; x/y koordinata <128
	stosw
	pop ax
	push ax
	cbw
	mov al,ah
	or al,1
	mov word [di+pontdb*4-2],ax
	pop ax
	loop @rndcik

tabla:
	mov ah,80h
	mov es,ax
	mov bx,pontok+100	; nagyon hasznalva lesz
	mov di,768		; tabla eleje [64000]
	mov bp,-128
@tablay:
	mov dx,-128
@tablax:
	mov [bx+2],bp
	mov [bx],dx
	fild word [bx+2]		; x
	fmul st0			; x2
	fild word [bx]			; x2 y
	fmul st0			; x2 y2
	faddp st1			; xy
	fdivr dword [ezer]
	fistp word [bx]
	mov al,[bx+1]
	stosb				; letaroljuk =)

	inc dx
	cmp dx,127
	jng @tablax

	inc bp
	cmp bp,127
	jng @tablay


	push es
	pop fs
	push word 0xA000
	pop es
frame:

@mezocik:
	mov dx,159		; Y
;	mov dx,199
@MYcik:
	mov bp,219		; X
;	mov bp,319
@MXcik:
	mov si,pontok
	mov cl,pontdb
	xor ax,ax
@MPcik:
	push bp
	push ax
	lodsw			; ld X
	sub ax,127
	xchg ax,di
	lodsw			; ld Y
	sub ax,127

	sub bp,di

	imul bp,bp,256
	sub bp,ax
	pop ax
	add bp,dx
	movzx bx,[fs:bp]
	add ax,bx
;	jnc @nsat
;	mov al,-1
;@nsat:
	pop bp
	loop @MPcik

	cmp ax,70			; 180
	jb @nerajz
;;	mov al,100
;;	jns @nerajz
	mov al,0
;	mov ax,bp
	jmp @nerajz
@rajz:
	add ax,bp
	xor ax,dx
@nerajz:
	imul di,dx,320
	add di,bp		; screen address
	stosb

	dec bp			; X++
	ja @MXcik

	dec dx			; Y++
	ja @MYcik

;	mov si,768
;	xor di,di
;	mov cx,32000
;	fs rep movsw

	mov si,pontok
	mov cl,pontdb
mozgat:
	lodsw			; X
	add ax,[si+pontdb*4-2]
	mov [si-2],ax
	cmp ax,199
	jna @nxinv
	neg word [si+pontdb*4-2]
@nxinv:
	lodsw			; Y
	add ax,[si+pontdb*4-2]
	mov [si-2],ax
	cmp ax,158
	jna @nyinv
	neg word [si+pontdb*4-2]
@nyinv:
	loop mozgat

;	mov ah,1
;	int 16h
;	jnc near frame

	in al,60h
	dec al
	jnz near frame

	mov ax,3
	int 10h
	ret

ezer: dd 2000000.0		; 8M
;ezer: dd -180000.0

pontok:
;	resw 2*6
iranyok:
;	resw 2*6
seed equ pontok+200
