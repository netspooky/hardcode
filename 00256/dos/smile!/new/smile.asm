       .586
code   SEGMENT use16
       ASSUME  cs:code,ds:code,es:code
       ORG     100h

;-----------------------------------------------------------------------------
start:
	mov	bl,81h
	mov	cl,20h

	; - set up the table`s segment
   mov	ax,cs
   add	ah,cl
   mov	es,ax

	; - open an input file
	mov	ah,3Dh
	call	file
	mov	InHandle,ax

	; - create an output file
	mov	ah,3Ch
	call	file
	mov	OutHandle,ax

	; - set up the table
   xor	ax,ax
   xor	di,di
TableIni:
	stosb
	inc	ax
	jnz	TableIni

	xchg	ax,bp
Main:
   or		si,si
   jnz	decode

   ;////////////////////////////////////// encoding ///////////////////////////////////////
	; - read one byte from file
	call	getput
	or		ax,ax
	jz		Done

	; - search for symbol
	xchg	ch,cl
	mov	al,InChar
	mov	bl,al
	add	di,cx
	dec	di
	std
	repne	scasb
	inc	di

	; - put out the index
	push	cx
	call	putvalue
	pop	cx
	jmp	update_table

decode:
   ;////////////////////////////////////// decoding ///////////////////////////////////////
   call	getvalue
	or		ch,ch
	jnz	Exit

	; - store the index
	add	di,cx

	; - get the symbol
	movzx	ax,es:[di]
	mov	OutChar,al
	xchg	bx,ax

	; - put out the symbol
	pusha
	stc
	call	getput
	popa
	;///////////////////////////////////////////////////////////////////////////////////////

update_table:
	; - update the table
	jcxz	_update
update:
	mov	al,es:[di-1]
	std
	stosb
	loop	update
_update:
	xchg	ax,bx
	stosb

	; - set a context
	xchg	ah,al
	xchg	di,ax

	jmp	Main

Done:
	xchg	ch,cl
	call	putvalue
	dec	cl
	call	putvalue

Exit:
	ret
;-----------------------------------------------------------------------------
putvalue:
	; - get valued bits number
	jcxz	_putvalue
	mov	dx,cx
	bsr	cx,dx
	inc	cx

	ror	dx,cl
_put:
	clc
	call	putbit
	rol	dx,1
	call	putbit
	loop	_put
_putvalue:

	stc
	call	putbit

	ret
;-----------------------------------------------------------------------------
putbit:
	rcl	OutChar,1
	inc	bp
	cmp	bp,8
	jb		_putbit
	xor	bp,bp

	pusha
	stc
	call	getput
	popa
_putbit:
	ret	
;-----------------------------------------------------------------------------
getvalue:
	xor	cx,cx
_get:
	call	getbit
	jc		_getvalue
	call	getbit
	adc	cx,cx
	jmp	_get
_getvalue:
	ret
;-----------------------------------------------------------------------------
getbit:
	or		bp,bp
	jnz	_getbit
	mov	bp,8
	pusha
	call	getput
	popa
_getbit:
	dec	bp
	shl	InChar,1
	ret	
;-----------------------------------------------------------------------------
getput:
	; - CF=0 read, CF=1 write
	setnc	bl
	xor	bh,bh
   mov  	ah,40h				; - 40h-write, 3Fh-read
   sub	ah,bl
   mov	cx,1
	shl	bx,2
   lea  	dx,[OutChar+bx]
	mov	bx,[OutHandle+bx]
	int	21h
	ret	
;-----------------------------------------------------------------------------
file:
	mov	dx,bx
	inc	bx
 	cmp	byte ptr [bx-1],'-'
 	jnz	noKey
 	movzx si,byte ptr [bx]
 	sub	si,'e'
 	inc	bx
 	inc	bx
noKey:
 	cmp	[bx-1],cl
	jbe	file
_file:
	inc	bx
	cmp	[bx-1],cl
	ja		_file
	dec	bx
	mov	[bx],ch
	int	21h
	ret
;-----------------------------------------------------------------------------
OutChar		db	?,?
OutHandle	dw ?
InChar		db	?,?
InHandle		dw ?
;-----------------------------------------------------------------------------
code   ENDS
       END start
