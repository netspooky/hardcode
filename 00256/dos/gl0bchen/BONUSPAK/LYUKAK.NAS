org 100h

pontdb equ 9

start:
	fninit
	mov al,13h
	int 10h

	mov ch,3
	xor ax,ax
	mov dx,3c8h
	out dx,al
	inc dx
@palcyc:
;	out dx,al
;	out dx,al
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
	and ax,127
	stosw
	pop ax
	push ax
	cbw
	mov al,ah
	or al,3
	mov word [di+pontdb*4-2],ax
	pop ax
	loop @rndcik

frame:
	push word 0xA000
	pop es
	mov bx,pontok+100
	fstcw [bx]		; kis pontossag, gyorsabb!!!
	and word [bx],0xFCFF
	fldcw [bx]

@mezocik:
	mov dx,159		; Y
@MYcik:
	mov bp,219		; X
@MXcik:
	mov word [bx],0
	mov si,pontok
	mov cl,pontdb
	fldz
@MPcik:
	lodsw			; ld X
	xchg ax,di
	lodsw			; ld Y
	pusha
	sub bp,di
	sub dx,ax

	mov [bx+2],dx
	mov [bx+4],bp
	fild word [bx+2]		; 0 x
	fmul st0			; 0 x2
	fild word [bx+4]		; 0 x2 y
	fmul st0			; 0 x2 y2
	faddp st1			; 0 xy
	fdivr dword [ezer]
	fiadd word [bx]
	fistp word [bx]
	faddp st1			; 0+
	popa
	loop @MPcik


	mov al,[bx+1]
	cmp al,180
	jb @rajz
	xor ax,bp
	jmp @nerajz
@rajz:
	xor ax,dx
@nerajz:
	imul di,dx,320
	add di,bp		; screen address
	stosb

	dec bp			; X++
	ja @MXcik

	dec dx			; Y++
	ja @MYcik

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
	in al,60h
	dec al
	jnz near frame

	mov ax,3
	int 10h
	ret

ezer: dd -8000000.0
;ezer: dd -180000.0

pontok:
;	resw 2*6
iranyok:
;	resw 2*6
seed equ pontok+200
