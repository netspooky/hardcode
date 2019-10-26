       .586
code   SEGMENT use16
       ASSUME  cs:code,ds:code,es:code
       ORG     100h

;-----------------------------------------------------------------------------
start:
	mov	bl,81h
	mov	cl,20h

	; - open an input file
	mov	ah,3Dh
	call	file
	jc		Exit
	mov	InHandle,ax

	; - create an output file
	mov	ah,3Ch
	call	file
	jc		Exit
	mov	OutHandle,ax

	; - set up the table
   mov	ax,cs
   add	ah,10h
   mov	es,ax

   xor	di,di
   xor	cx,cx
TableIni:
	mov	ax,256
	sub	ax,cx
	cld
	stosb
	loop	TableIni

	xor	di,di	
	xor	bp,bp
Main:
	; - read one byte from file
   mov  	ah,3Fh                  
	mov	bx,InHandle
   mov	cx,1
   mov  	dx,offset InChar
	int	21h                     
	or		ax,ax
	jz		Done

	; - search for symbol
	mov	cx,256
	mov	al,InChar
	push	di
	cld
	repne	scasb
	sub	cx,256
	neg	cx
	dec	cx
	pop	di

	; - put out the index
	mov	bx,cx
	call	putvalue

	; - update the table
	jcxz	_update
	add	di,cx
update:
	std
	mov	al,es:[di-1]
	stosb
	loop	update
_update:
	mov	al,InChar
	stosb

	; - set a context
	shl	ax,8
	mov	di,ax

	push	040h
	pop	fs
	mov	bx,fs:[6ch]
	mov	cx,bx
	sub	bx,bp
	cmp	bx,1
	jb		_dot
	mov	ah,2
	mov	dl,'.'
	int	21h	
	mov	bp,cx
_dot:

	jmp	Main

Done:
	mov	bx,0100h
	call	putvalue

flush:
	cmp	OutBits,8
	je		_flush
	clc
	call	putbit
	jmp	flush
_flush:

Exit:
	ret
;-----------------------------------------------------------------------------
putvalue:
	pusha
	; - get valued bits number
	xor	ax,ax
	bsr	ax,bx
	setnz	cl
	add	al,cl

	mov	cx,ax
	ror	bx,cl
	jcxz	_putvalue
_put:
	clc
	call	putbit
	rol	bx,1
	call	putbit
	loop	_put
_putvalue:

	stc
	call	putbit

	popa
	ret
;-----------------------------------------------------------------------------
putbit:
	rcl	OutChar,1
	dec	OutBits
	jnz	_putbit
	mov	OutBits,8

	pusha
   mov  	ah,40h
	mov	bx,OutHandle
   mov  	dx,offset OutChar
   mov	cx,1
	int	21h
	popa
_putbit:
	ret	
;-----------------------------------------------------------------------------
file:
	mov	dx,bx
	inc	bx
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
OutChar		db	0
OutBits		db 8		
InChar		db	?
InHandle		dw ?
OutHandle	dw ?
;-----------------------------------------------------------------------------
code   ENDS
       END start
