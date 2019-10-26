assume cs:code,ds:code

code	segment

	org 100h

start:	mov	ax,13h
	int	10h

	call    vsync
	call	migaj

	mov	dx,3c8h
	mov	al,2
	out	dx,al
	inc	dx
	xor	al,al
	out	dx,al
	mov	al,60
	out	dx,al
	xor	al,al
	out	dx,al

	mov	dx,0a000h
	mov	es,dx
	xor	di,di
	mov	ax,0101h
	cld
	mov	cx,16000
	rep	stosw

	call	migaj

	xor	di,di
	mov	dx,100
x1:	mov	ax,0101h
	mov	cx,160
	cld
	rep	stosb
	mov	cx,160
	mov	ax,0h
	cld
	rep	stosb
	dec	dx
	cmp	dx,0
	jne	x1

	mov	dx,100
x2:	mov	ax,0h
	mov	cx,160
	cld
	rep	stosb
	mov	cx,160
	mov	ax,0101h
	cld
	rep	stosb
	dec	dx
	cmp	dx,0
	jne	x2

	call	migaj

	push	cs
	pop	ds
	mov	si,offset napis1
	mov	di,320*96+50
	xor	bx,bx
	xor	cx,cx
ptl:	mov	al,ds:[si]
	inc	bx
	cmp	al,1
	je	pisz
	add	di,4
	inc	si
bc:	cmp	bx,55
	je	nxtlin
	jmp	ptl	
pisz:	mov	ax,0202h
	cld
	stosw
	stosw
	inc	si
	jmp	bc
nxtlin:	add	di,100
	xor	bx,bx
	inc	cx
	cmp	cx,8
	jne	ptl
		
	call	migaj


	mov	cx,4
	mov	dx,3c8h
	mov	al,1
n_c:	out	dx,al
	inc	dx
	push	ax
	xor	al,al
	out	dx,al
	out	dx,al
	out	dx,al
	dec	dx
	pop	ax
	inc	al
	loop	n_c

	mov	al,6
	out	dx,al
	inc	dx
	mov	al,63
	out	dx,al
	xor	al,al
	out	dx,al
	out	dx,al


        mov     ax,0a000h
        mov     es,ax
	xor	di,di

	mov	cx,4
n_l:	push	cx
	mov	bl,5
	sub	bl,cl
	mov	al,bl
	mov	ah,bl

	mov	cx,8000
	rep	stosw
	
	pop	cx
	loop	n_l

	push	cs
	pop	ds
	mov	si,offset napis2
	mov	di,320*96+92
	xor	bx,bx
	xor	cx,cx
ptl2:	mov	al,ds:[si]
	inc	bx
	cmp	al,1
	je	pisz2
	add	di,4
	inc	si
bc2:	cmp	bx,34
	je	nxtlin2
	jmp	ptl2	
pisz2:	mov	ax,0606h
	cld
	stosw
	stosw
	inc	si
	jmp	bc2
nxtlin2:	add	di,320-34*4
	xor	bx,bx
	inc	cx
	cmp	cx,8
	jne	ptl2
	
	mov	byte ptr ds:akt,0
	mov	byte ptr il,0
	mov	byte ptr last,255

	mov	cx,15*32
wesc:	push	cx

	add	il,2
	cmp	il,62
	jb	dal
	mov	il,0
	inc	last
	and	last,11b
	inc	akt
	and	akt,11b
dal:
	call	vsync

	mov	dx,3c8h
	mov	al,last
	inc	al
	out	dx,al
	inc	dx
	mov	al,63
	sub	al,il
	out	dx,al
	out	dx,al
	out	dx,al

	dec	dx
	mov	al,akt
	inc	al
	out	dx,al
	inc	dx
	mov	al,il
	out	dx,al
	out	dx,al
	out	dx,al

	pop	cx
	loop	wesc


	mov	ax,3
	int	10h

	mov	ah,9
	mov	dx,offset info
	int	21h

	mov	cx,100
op1:	call	vsync
	loop	op1


        mov     ah,4ch
        int     21h

migaj	proc

	mov	bx,04

bil:	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	out	dx,al
	out	dx,al
	out	dx,al
	mov	al,63
	out	dx,al
	out	dx,al
	out	dx,al

	mov	cx,16
loop1:  call	vsync
	loop	loop1

	mov	dx,3c8h
	mov	al,0
	out	dx,al
	inc	dx
	mov	al,63
	out	dx,al
	out	dx,al
	out	dx,al
	xor	al,al
	out	dx,al
	out	dx,al
	out	dx,al

	mov	cx,16
loop2:	call	vsync
	loop	loop2

	dec     bx
	cmp	bx,0
	jne     bil

	ret

migaj	endp

vsync proc
	mov dx,3dah
vsl:	in  al,dx
	test al,8
	jnz vsl
vsl2:	in al,dx
	test al,8
	jz vsl2
	ret
vsync endp 
           
napis2	db 1,1,1,1,0,0,0,1,1,0,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,1,1,0,1,1,1,1,1,1
	db 1,1,1,1,1,0,0,1,1,0,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,1,1,0,1,1,1,1,1,1
	db 1,1,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0
	db 1,1,0,0,1,1,0,1,1,0,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,0,1,1,0,0
	db 1,1,1,1,1,0,0,1,1,0,0,1,1,0,1,1,0,0,0,0,0,1,1,1,1,0,0,0,0,1,1,0,0,0
	db 1,1,1,1,1,0,0,1,1,0,0,1,1,0,1,1,0,0,0,0,0,1,1,0,0,0,0,0,1,1,0,0,0,0
	db 1,1,0,0,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1
	db 1,1,0,0,1,1,0,0,1,1,1,1,0,0,1,1,1,1,1,1,0,1,1,1,1,1,1,0,1,1,1,1,1,1

napis1	db 1,1,1,0,0,0,1,1,0,0,1,1,1,0,0,1,1,1,1,1,0,1,0,0,1,0,0,0,0
	db 0,1,1,1,0,0,1,1,0,0,1,1,1,0,0,1,0,1,0,0,1,0,0,1,1,1

	db 1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0
	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0

	db 1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0
	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,1,0,1,0,1,0,0,0   

	db 1,0,0,1,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,1,0,0,1,0,0,0,0
	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,1,1,0,1,0,0,0

	db 1,1,1,0,0,1,1,1,1,0,1,1,1,0,0,0,0,1,0,0,0,0,1,1,1,0,0,0,0
	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,0,1


	db 1,1,1,0,0,1,1,1,1,0,1,1,1,0,0,0,0,1,0,0,0,0,1,1,1,0,0,0,0
	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,0,1

	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0
	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,1,0,1,0,0,1,0,1,0,0,1

	db 1,0,0,0,0,1,0,0,1,0,1,0,0,1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0
	db 0,1,1,1,0,0,1,1,0,0,1,1,1,0,0,1,0,1,0,0,1,0,0,1,1,1
last	db	?
akt	db	?
il	db	?
info	db 'Coded by Key G and SebL', 13, 10
	db 'Great thanx for Yarpen/Substance for vsync procedure', 13, 10
	db 'And remember 4ever: PartyCoding RULEZ$'
code ends

	end start
