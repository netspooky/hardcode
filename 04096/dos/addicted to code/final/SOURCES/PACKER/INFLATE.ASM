.386

ASSUME cs:CODE

CODE	SEGMENt USE16
	org	100h
Start:
	mov	di,offset ARTTAB
	mov	ax,288
MkArtTab:
	stosw
	dec	ax
	jge	MkArtTab

	mov	si,offset COMPRESSED_DATA
;	mov	di,offset DECOMPRESSED_DATA
	mov	di,2100h
	lodsw
	xchg	bp,ax
	mov	cx,8000h
	xor	dx,dx
	jmp	Decompress
;/////////////////////////////////////////////////////////////////////////////;
ReadBitUpload:
	mov	dl,[si]
	inc	si
	mov	dh,1
ReadBit:
	shr	dx,1
	jz	ReadBitUpload
	ret
;--------------------------------------;
ReadInt:
	xchg	ax,cx
	mov	ax,1
ReadInt2:
	or	cx,cx
	jz	ReadIntDone
ReadIntLoop:
	call	ReadBit
	rcl	ax,1
	loop	ReadIntLoop
ReadIntDone:
	ret
;/////////////////////////////////////////////////////////////////////////////;
Coded:
	push	cx

	dec	ax
	cmp	al,8
	ja	No2bStr
	push	0002h
	jmp	ReadDist
No2bStr:
;	sub	al,6
;	cmp	al,16
	sub	ax,16+6
	jbe	LengDone
;	sub	al,17
	dec	ax
	call	ReadInt
;	add	ax,16
LengDone:
	add	ax,16
	push	ax

	xor	ax,ax
	mov	cx,4
	call	ReadInt2
	
ReadDist:
	dec	ax
	js	LastDist
	call	ReadInt
	xchg	ax,bx
LastDist:
	pop	cx
	push	si
	mov	si,di
	sub	si,bx
	rep	movsb
	pop	si

	pop	cx
;--------------------------------------;
Decompress:
	push	di
	push	bx

	mov	bx,offset ARTTAB
	push	dx

	mov	ax,bp
	inc	ax
	mul	word ptr [bx]
	sub	ax,1
	sbb	dx,0
	div	cx
	
	mov	di,bx
Find:
	inc	di
	inc	di
	cmp	[di],ax
	jg	Find

	mov	ax,cx
	mul	word ptr [di]
	div	word ptr [bx]
	sub	bp,ax
	xchg	ax,cx
	mul	word ptr [di-2]
	div	word ptr [bx]
	sub	ax,cx

	pop	dx

ReadBits:
	cmp	ax,4000h
	ja	EndRB
	shl	ax,1
	call	ReadBit
	rcl	bp,1
	jmp	ReadBits
EndRB:
	xchg	ax,cx

	mov	ax,288
Update:
	dec	di
	dec	di
	dec	ax
	inc	word ptr [di]
	cmp	di,bx
	jnz	Update

	pop	bx
	pop	di
;----------- symbol read ---------

	sub	ax,256
	jz	DecodeEnd
	ja	Coded
	stosb
	jmp	Decompress
DecodeEnd:
	push	2100h
	ret
AllEnd:


COMPRESSED_DATA:
	include	comp.inc
ARTTAB:
	dw 289 dup (?)
DECOMPRESSED_DATA:
	db 2000h dup (?)
CODE	ENDS

END	Start	
