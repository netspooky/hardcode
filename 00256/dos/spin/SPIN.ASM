;       
; שsשpש°שnש byשbaze/3SC
;            256Bשintro
; ששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששש
; This source code is written to be compiled by Netwide Assembler (NASM).
; ששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששש
; SPIN can run smoothly on P2/333 Mhz. To make it run faster you may wish
; to uncomment MOV CH,180 (eventually tweak that value). However, it will
; cause lower fractal quality. Feel free to e-mail: baze@decef.elf.stuba.sk
; ששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששש
; I would like to send my regards to these superb coders: Serzh (nu pogodi!),
; loveC (thanks for hints), bEETLE, Astex, riXta, Zilog, Busy, Omega, Yerzemey
; Thanks for keeping 8-bit spirit alive :)
; ששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששששש

[org 100h]
[segment .text]

SINTAB	equ	3*16*256

	mov	al,13h
	int	10h

	mov	ax,1300h
	mov	bx,224
	mov	cx,4
	xor	dx,dx
	mov	bp,LOGO
	int	10h

	mov	bx,SINTAB
	mov	si,395
SINGEN	mov	[bx],ch
	add	cx,si
	mov	ax,40
	imul	cx
	sub	si,dx

PALETTE	mov	al,bl
	mov	dx,3C8h
	out	dx,al
	inc	dx
	shr	al,1
	out	dx,al
	out	dx,al
	shr	al,2
	out	dx,al
RETCODE	inc	bl
	jnz	SINGEN

	mov	ah,4Ah
	int	21h
	jc	RETCODE+1

	mov	ax,cs
	add	ah,16
	mov	ds,ax
	add	ah,16
	mov	es,ax

MAIN	push	ds
	push	es

SMOOTH	mov	al,[di]
	mov	bl,[di-254]
	add	bl,[di-256]
	shr	bl,1
	add	al,bl
	shr	ax,1
	stosb
	and	[di],byte 127
	loop	SMOOTH

	push	cs
	pop	ds

	mov	di,VERT
	mov	bx,[di]
	mov	al,[di+2]
;	mov	ch,180		; speedup for slower machines

SIERP	add	bp,cx
	ror	bp,cl
	push	bp
	and	bp,byte 1100b

	add	bl,[bp+di]
	rcr	bl,1
	add	bh,[bp+di+1]
	rcr	bh,1
	add	al,[bp+di+2]
	rcr	al,1

	pop	bp
	cmp	al,[es:bx]
	jc	ZBUFF
	mov	[es:bx],al
ZBUFF	loop	SIERP

	mov	dl,0DAh
FRAME	in	al,dx
	test	al,8
	jz	FRAME

	push	cs
	pop	es

	mov	si,PHASES
	mov	bh,SINTAB/256
	mov	cl,4
MOVE	mov	al,160
	call	AXIS
	mov	al,70
	call	AXIS
	call	AXIS
	inc	di
	loop	MOVE

	pop	ds
	push	word 0A000h
	pop	es

	xor	si,si
	mov	di,10*320+32
DRAW	mov	cl,128
	rep	movsw
	add	di,byte 64
	dec	ax
	jnz	DRAW

	xor	bx,bx
	mov	di,137*320
ZOOM	mov	al,[bx]
	or	al,128
	stosb
	inc	di
	add	bl,4
	jnz	ZOOM
	add	bh,5
	add	di,640-128
	jnc	ZOOM

	pop	es

	in	al,60h
	dec	ax
	jnz	near MAIN

	mov	al,03h
	int	10h

AXIS	mov	bl,[si]
	add	al,[bx]
	inc	byte [si]
	inc	si
	stosb
	mov	al,190
	ret

LOGO	db	"sp°"

PHASES	db	0+"n",170+"n",170+"n"
	db	85+"n",0+"n",0+"n"
	db	170+"n",85+"n",85+"n"
	db	128+"n",128+"n",0+"n"

VERT
