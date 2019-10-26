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

	call	getbyte
	xor	di,di
	xor	bp,bp
			
Main:
	; - decoding
   call	getvalue
	or		bh,bh
	jnz	Exit

	; - store the index
	mov	cx,bx

	; - get the symbol
	mov	al,es:[di+bx]
	mov	OutChar,al

	; - put out the symbol
	pusha
   mov  	ah,40h
	mov	bx,OutHandle
   mov  	dx,offset OutChar
   mov	cx,1
	int	21h
	popa

	; - update the table
	jcxz	_update
	add	di,cx
update:
	std
	mov	al,es:[di-1]
	stosb
	loop	update
_update:
	mov	al,OutChar
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

Exit:
	ret
;-----------------------------------------------------------------------------
getbit:
	shl	InChar,1
	pushf
	dec	InBits
	jnz	_getbit
	mov	InBits,8
	call	getbyte
_getbit:
	popf
	ret	
;-----------------------------------------------------------------------------
getvalue:
	xor	bx,bx
_get:
	call	getbit
	jc		_getvalue
	call	getbit
	adc	bx,bx
	jmp	_get
_getvalue:
	ret
;-----------------------------------------------------------------------------
getbyte:
	pusha
   mov  	ah,3Fh                  
	mov	bx,InHandle
   mov	cx,1
   mov  	dx,offset InChar
	int	21h
	popa
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
InChar		db	0
InBits		db 8		
OutChar		db	?
InHandle		dw ?
OutHandle	dw ?
;-----------------------------------------------------------------------------
code   ENDS
       END start
