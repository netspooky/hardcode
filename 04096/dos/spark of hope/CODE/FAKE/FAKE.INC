TurnOnFake	PROC
mov ax,13h
int 10h
;{------ turn on 4-plane-mode ------
mov dx,3c4h
mov al,4
out dx,al
inc dx
in  al,dx
and al,0F7h
or  al,4
out dx,al
;{--}
mov dl,0D4h
mov al,9
out dx,al
mov al,14h
out dx,al
inc dx
in  al,dx
and al,0Bfh
out dx,al
dec dx
mov al,17h
out dx,al
inc dx
in  al,dx
or  al,40h
out dx,al
;{------ turn on 320x400-----------}
dec dx
mov al,9
out dx,al
inc dx
in  al,dx
and al,0Feh
out dx,al

mov dl,0C4h
mov ax,0F02h
out dx,ax
xor ax,ax
xor di,di
push es
push 0a000h
pop  es
mov  cx,64000/2
rep  stosw
pop es

    mov  di,offset Pal
    push ds
    pop  es
    mov  cx,14*256
@MkFakePal1:
    mov  al,63
    mul  cl
    div  ch
    mov  dl,al

mov     bx,15*256
@MkFakePal2:
mov     al,dl
stosb
xor     al,al
stosb
mov     al,63
mul     bl
div     bh
stosb
inc     bl
cmp     bl,16
jnz     @MkFakePal2

    inc  cl
    cmp  cl,15
    jnz  @MkFakePal1

mov     bx,15*256
@MkFakePal3:
xor     al,al
stosb
mov     al,63
mul     bl
div     bh
stosb
xor     al,al
stosb
inc     bl
cmp     bl,16
jnz     @MkFakePal3

    mov  si,offset Pal
    mov  cx,768
    mov  dx,3c8h
    out  dx,al
    inc  dx
    rep  outsb
	ret
TurnOnFake	ENDP

;-------------------------------------------------------------------------------
FakeScreen	dw 0,32000

CopyScr	PROC
	push	es
	mov	esi,ds:[TabPtr]
	shr	esi,1
	push	0a000h
	pop	es
	xor	cl,cl
FakeW:	
	mov	di,word ptr ds:[FakeScreen]
	mov	dx,3c4h
	mov	ax,102h
	shl	ah,cl
	out	dx,ax
	pushad
	mov	bp,200
FakeY:
	push	bp
	mov	bp,80
FakeX:
	mov	ax,[esi+esi]
	add	si,4
	mov	dx,ax
	and	dx,01111100000b
	mov	bx,ax
	and	ax,1111000000000000b
	shr	dx,6
	and	bx,11110b
	shr	bx,1
	shr	ax,8
	cmp	ax,11110000b
	jnz	NoI
	mov	ax,11100000b
NoI:
	or	al,bl
	mov	es:[di],al
	add	dl,240
	mov	es:[di+80],dl
	inc	di
	dec	bp
	jnz	FakeX

	add	di,80
	pop	bp
	dec	bp
	jnz	FakeY
	popad	
	inc	si
	inc	cl
	cmp	cl,4
	jnz	FakeW

	mov	ax,di
	mov	al,0ch
	mov	dx,3d4h
	out	dx,ax
	mov	ax,di
	mov	ah,al
	mov	al,0dh
	out	dx,ax

	ror	dword ptr ds:[FakeScreen],16

	pop	es
	ret
CopyScr	ENDP
