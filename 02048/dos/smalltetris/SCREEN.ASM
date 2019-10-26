.MODEL TINY

	public	Print
	public	TestSpace
	public	Bottom
	public	InitScreen
	public	PrintLong
	public	GameOverPrompt
	public	RemovePause
	public	PrintPause
	extrn	RandSeed:word
	extrn	Items:word

BORDER_CHAR			equ		32
BORDER_COLOR		equ     29

HISCORE_TEXT_POS	equ		0
SCORE_TEXT_POS		equ		240
LEVEL_TEXT_POS		equ		400
LOGO_POS			equ		800
BY_POS				equ 	970
TORE_POS			equ 	1128
BAST_POS			equ		1202
PREVIEW_TEXT_POS	equ		134
GAME_OVER_POS		equ		934
PLAY_AGAIN_POS		equ     1654
PAUSE_POS			equ 	934

.DATA
TetrisLogo	label word
	db	'S',1
	db	'm',2
	db	'a',3
	db	'l',4
	db	'l',5
	db	'T',6
	db	'e',7
	db	't',8
	db	'r',9
	db	'i',10
	db	's',11
	dw	0

	db	'b',7
	db	'y',7
	dw	0

	db	'T',1
	db	'o',2
	db	'r',3
	db	'e',4
	dw	0
	db	'B',6
	db	'a',7
	db	's',8
	db	't',9
	db	'i',10
	db	'a',11
	db	'n',12
	db	's',13
	db	'e',14
	db	'n',15
	dw	0

	db	'HISCORE:',0
	db	'SCORE:',0
	db	'LEVEL:',0
	db	'Preview:',0

GameOverText label word
	db	'GAME OVER',0
	db 	'Play again?',0
RemovePauseText label byte
	db	5 dup (' ')
	db	0
PauseText db	'PAUSE',0

RowFill		db	25 dup (?)


.CODE
InitScreen	proc	near
	mov	ax,0001h						; Screen mode 1
	int	 10h

	xor 	di,di
	mov		ax,0b800h
	mov		es,ax
	mov		cx,1000
	xor		ax,ax
	rep		stosw								; Fill screen with 0

	mov		ax,BORDER_CHAR+256*BORDER_COLOR		; Horisontal lines
	mov		di,28
	mov 	cx,12
	rep	stosw                           		; Upper
	mov		di,28+24*80
	mov		cx,12
	rep stosw                           		; Lower

	mov 	cx,23
	mov		ax,BORDER_CHAR+256*BORDER_COLOR     ; Vertical lines
	mov		di,80+28
loop_s1:
	mov		es:[di],ax
	add		di,22
	mov		es:[di],ax
	add		di,58
	loop	loop_s1


	push		es
	push		ds
	pop		es
	mov		cx,25
	mov		di, offset RowFill
	mov		ax,0
	rep stosb									; Clear buffer
	pop		es

;	Print text
	mov		di,LOGO_POS
	mov		si,offset TetrisLogo
	call	PrintColorString
	mov		di,BY_POS
	call    PrintColorString
	mov		di,TORE_POS
	call    PrintColorString
	mov		di,BAST_POS
	call    PrintColorString
	mov		ah,1
	mov		di,HISCORE_TEXT_POS
	call    PrintMonoString
	mov		di,SCORE_TEXT_POS
	call    PrintMonoString
	mov		di,LEVEL_TEXT_POS
	call    PrintMonoString
	mov		di,PREVIEW_TEXT_POS
	call	PrintMonoString
	ret

InitScreen	endp

DeleteRow	proc	near				;bx=Row

	mov		dx,0b800h
	mov		es,dx

	dec		bx
	mov		cx,bx
	mov		ax,bx

	mov		dx,80
	imul	dx
	add		ax,30						   		; ax=source offset

	mov		si,ax
loop_d1:
	mov		di,si
	add		di,80
	push 	cx
	mov     cx,10
	push	ds
	push	es
	pop		ds
	rep	movsw
	pop 	ds
	sub		si,100

	mov 	cl,byte ptr RowFill[bx]
	mov		byte ptr RowFill[bx+1],cl
	dec		bx

	pop		cx
	loop   	loop_d1

	ret
DeleteRow	endp

Bottom	proc	near      	;ax=ItemNr			di=scroffset
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06

	imul    dx
	add 	ax, offset Items     			; ax=ax*6

	xor 	cx,cx                           ; for cx=0 to 3
loop_b1:
	mov 	bx,ax
	add 	bx,cx
	push	ax
	mov 	al,byte ptr [bx+2]
	cbw
	shl		ax,1
	add 	di,ax
	mov		ax,di
	xor		dx,dx
	mov		bx,80
	div		bx
	mov		bx,ax
	inc		byte ptr RowFill[bx]
	pop		ax
	inc     cx
	cmp		cx,4
	jne	    loop_b1

	xor		bx,bx
loop_b2:
	cmp		byte ptr RowFill[bx],10
	jne		not_full
	push	bx
	call	DeleteRow
	inc		word ptr randseed
	pop		bx
not_full:
	inc 	bx
	cmp		bx,24
	jne		loop_b2

	ret
Bottom	endp

TestSpace	proc	near		;ax= item_nr    di=scroffs
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06
	imul    dx
	add 	ax, offset Items     			; ax=ax*6

	xor 	dx,dx                           ; for dx=0 to 3
loop1:
	mov 	bx,ax
	add 	bx,dx
	push	ax
	mov 	al,byte ptr [bx+2]
	cbw
	shl		ax,1
	add 	di,ax
	pop		ax
	cmp 	word ptr es:[di],0
	jne	 	bad
	inc     dx
	cmp		dx,4
	jne	    loop1
	mov		ax,01
	ret
bad:
	xor		ax,ax
	ret
TestSpace	endp

Print	proc	near					;ax= item_nr    di=scroffs si=T/F
	mov		dx,0b800h
	mov		es,dx
	mov 	dx,06
	imul    dx                      	; ax=ax*6
	add 	ax, offset Items      		; ax+=[_items]

	xor		dx,dx		   				; for dx=3 to 0

	cmp		si,0
	je 		loop2
	mov 	bx,ax
	mov		si,ds:[bx]
loop2:
	mov 	bx,ax
	add 	bx,dx
	push	ax
	mov 	al,byte ptr [bx+2]
	cbw
	shl		ax,1
	add		di,ax
	pop		ax
	mov 	es:[di],si
	inc     dx
	cmp		dx,4
	jne	    loop2
	ret
Print	endp

PrintLong	proc near

	mov		bx,0b800h
	mov		es,bx

	mov		bx,10
more_digits:
	div		bx
	add		dx,'0'+256*7
	mov		es:[di],dx
	sub		di,2
	mov		dx,0
	cmp		ax,0
	jne		short more_digits
	ret
PrintLong	endp

PrintColorString	proc near
	mov		bx,0b800h
	mov		es,bx
color_loop:
	mov		ax,ds:si
	inc		si
	inc		si
	and		ax,ax
	jz		color_done
	mov		es:di,ax
	inc		di
	inc		di
	jmp		color_loop
color_done:
	ret
PrintColorString 	endp

PrintMonoString		proc near
	mov		bx,0b800h
	mov		es,bx
mono_loop:
	mov		al,ds:si
	inc		si
	and		al,al
	jz		mono_done
	mov		es:di,ax
	inc		di
	inc		di
	jmp		mono_loop
mono_done:
	ret
PrintMonoString		endp


GameOverPrompt		proc near
	mov		ah,1
	mov		di,GAME_OVER_POS
	mov		si,offset GameOverText
	call	near ptr PrintMonoString
	mov		di,PLAY_AGAIN_POS
	call	near ptr PrintMonoString
	ret
GameOverPrompt		endp

RemovePause proc near
	xor		ah,ah
	mov		di,PAUSE_POS
	mov		si,offset RemovePauseText
	call	PrintMonoString
	ret
RemovePause endp

PrintPause proc near
	mov		ah,1
	mov		di,PAUSE_POS
	mov		si,offset PauseText
	call	PrintMonoString
	ret
PrintPause endp


end
