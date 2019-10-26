.MODEL TINY

	public  RandSeed
	public	GetKey

	extrn   InitScreen:near
	extrn 	Bottom:near
	extrn	PrintLong:near
	extrn  	Print:near
	extrn	TestSpace:near
	extrn	GameOverPrompt:near
	extrn	PrintPause:near
	extrn	RemovePause:near

LEVEL_WAIT_INIT	equ		700
START_POS		equ		280

HISCORE_POS     equ		24
SCORE_POS		equ		264
LEVEL_POS		equ		424


PREVIEW_POS		equ		380


.CODE
ORG 100h

Start   proc    near

; 	INITIALIZATION
;   **************

	cld

;	Test command line
	xor		bx,bx
	xor		dl,dl
	mov     cl,byte ptr ds:[80h]            ; Command line length
cmd_loop:
	and		cl,cl							;cl=0?
	je		short cmd_loop_end
	mov		al,byte ptr ds:[81h+bx]
	dec		cl
	inc		bx
	cmp 	al,' '							;skip space
	jne     short not_space
	cmp		dl,10
	jne		short cmd_loop
	xor		dl,dl
	jmp		short cmd_loop
not_space:
	cmp		dl,0
	je		short get_minus
	push	ax
	mov		ax,	word ptr StartLevel
	mov		dl, 10
	mul		dl
	mov		word ptr StartLevel, ax
	pop		ax
	sub		al, byte ptr '0'
	add		StartLevel,ax
	jmp		short cmd_loop
get_minus:
	cmp		al,'-'
	jne		cmd_error
	and		cl,cl
	je      cmd_error
	mov		al,byte ptr ds:[81h+bx]
	dec		cl
	inc		bx
	cmp		al,'p'							; preview mode
	je		preview_mode
	cmp		al,'l'
	jne		cmd_error
	inc		dx								; dx type boolean
	jmp		short cmd_loop
preview_mode:
	inc		word ptr PreView
	jmp		short cmd_loop
cmd_loop_end:
	cmp		word ptr StartLevel,0
	je		short set_level
	cmp 	word ptr StartLevel,17
	jbe		short level_ok
cmd_error:
	lea		dx, ErrorText
	mov		ah,09h
	int		21h
	mov		ax,0h
	int		21h
set_level:
	mov		word ptr StartLevel,1
level_ok:

;	Get old int 1ch
	mov		ax,351ch                       ; Function 35 interrupt 1c
	int     21h                 			; Get interrupt adress
	mov     word ptr OldInt1c,bx           ; 1c clock tick
	mov     ax,es
	mov     word ptr OldInt1c+2,ax

;	Store new int 1ch
	mov     dx,offset _NewInt1c            ; Set clock tick
	mov     ax,251ch                       ; to point to NewInt1c
	int     21h

;	Set ctrl/break int
	mov		dx,offset quit
	mov		al,23h
	int		21h

;	Play again starts here
restart:
	mov		ax,word ptr StartLevel
	mov		word ptr Level,ax
	mov		word ptr Score,0
	mov		word ptr Score+2,0

	call    near ptr RandInit  				; Initialize random numbers
	call    near ptr InitScreen	   			; Initialize screen

;	Print hiscore holder
	mov		ah,02h
	mov		dl,10
	int		21h
	mov		dl,13
	int		21h
	lea		dx, HiScoreName
	mov		ah,09h
	int		21h

;	Print first preview
	cmp		PreView,0
	je		no_init_preview
	mov		ax,OldRand
	shl		ax,1
	shl		ax,1
	mov		PreItem,ax
	mov		si,1
	mov		di,PREVIEW_POS
	call	Print
no_init_preview:

;	Calculate clicks before next level change
	mov		ax, LEVEL_WAIT_INIT             ; wait level*700 clicks
	mov		dx,	word ptr Level				; befor next level change
	mov		word ptr TimerInit,18
	sub		word ptr TimerInit,dx
	mul		dx
	mov		word ptr LevelWait,ax           ; set LevelWait to 18-level

;	Print out level
	xor		dx,dx
	mov		ax,word ptr Level               ; print level
	mov		di,LEVEL_POS
	call	PrintLong

;	Print Hiscore
	mov		dx, word ptr HiScore+2
	mov		ax, word ptr Hiscore
	mov		di, HISCORE_POS
	call	PrintLong

;	Main loop
;	*********

	jmp     short while_kbhit
for_ever:
	cmp 	word ptr Timer,0
	jne		short while_kbhit
	mov		ax,word ptr TimerInit
	mov		Timer,ax
	call    near ptr Down                  ; go down
	or		ax,ax
	jne		while_kbhit
	jmp		game_over

while_kbhit:
	mov   	ah,0bh
	int   	21h
	or      al,al
	je      short for_ever

	call    near ptr GetKey        	  		; al=getkey

	cmp		al,'p'
	jne		short not_p
	xor		PreView,1
	jnz		short prev_on
	call	near ptr RemovePreView
	jmp		not_p
prev_on:
	call 	near ptr PrintPreView
not_p:
	or 		al,al
	je		zero_key
	xor 	ah,ah
	sub		ax,'2'
	mov		bx,ax
	cmp		bx,7
	ja		short while_kbhit
	shl		bx,1
	jmp		word ptr cs:jump_table2[bx]
zero_key:

	call    near ptr GetKey        			; al=getkey

   ;                    switch(ch)
	cbw                                     ; ax=al
	sub     ax,72
	mov     bx,ax
	cmp     bx,8
	ja      short while_kbhit
	shl     bx,1
	jmp     word ptr cs:jump_table[bx]
go_left:
	push	si
	mov		si,-2
	call    Move
	pop		si
	jmp     short while_kbhit
go_right:
	push	si
	mov		si,2
	call    Move
	pop		si
	jmp     short while_kbhit
go_drop:
	call    Drop
	or		ax,ax
	je		short game_over
	jmp     short while_kbhit
go_rotate:
	call    Rotate
	jmp     short while_kbhit
inc_level:
	cmp		Level,17
	jge		short while_kbhit
	add		LevelWait,LEVEL_WAIT_INIT
	inc		word ptr Level
	dec		word ptr TimerInit
	xor		dx,dx
	mov		ax,word ptr Level
	mov		di,LEVEL_POS
	call	PrintLong
	jmp     while_kbhit
game_over:
	mov		Timer,0
	mov		Paused,1

;	Test for new hiscore
	mov		dx,word ptr Score+2
	mov		ax,word ptr Score
	cmp		word ptr HiScore+2,dx
	ja		no_hiscore
	jb		short new_hi
test_lsw:
	cmp		word ptr HiScore,ax
	jb		short new_hi
	jmp		short no_hiscore
new_hi:
	mov		word ptr HiScore,ax
	mov		word ptr Hiscore+2,dx

;	Get name of hiscore holder
	lea		dx, EnterName
	mov		ah,09h
	int		21h
	mov		dx, offset HiScoreData
	mov		ah,0ah
	int		21h
	mov		bl,HiScoreData+1
	inc		bl
	xor		bh,bh
	mov		HiscoreName[bx],13
	inc		bl
	mov		HiscoreName[bx],'$'


;	Get tetris filename
	push    ds
	mov     ah,30h
	int     21h
	mov     ax,ds:[002ch]
	mov     es,ax
	xor     di,di
	mov     ax,di
	mov     cx,07fffh
	cld
EnvLoop:
	repnz scasb
	cmp     es:[di],ah
	jne     EnvLoop
	or      ch,10000000b
	neg     cx

	mov     si,cx
	inc     si
	inc     si

	push	ds
	push    es
	pop     ds
	mov     dx,si
	mov     ax,3d00h + 010b                 ; 010b = read/write
	int     21h								; open tetris.com
	pop		ds

	mov		bx,ax							; file handle
	mov		ax,4200h						; lseek from start of file
	mov		dx,offset HiscoreName
	sub		dx,0100h
	xor		cx,cx							; cx:dx=hiscorename
	int		21h

	mov		ah,40h
	mov		cx,offset OldInt1c-offset HiScoreName ; number of bytes to write
	mov		dx,offset	HiScoreName
	int		21h

	mov		ah,3eh							; close file
	int		21h

no_hiscore:
	call	near ptr GameOverPrompt
yesno:
	call	near ptr GetKey
	cmp		al,'n'
	je		quit
	cmp		al,'y'
	jne		yesno
;  	Play again!
	jmp restart

;	Close down
;	**********
quit:
	mov     dx,word ptr OldInt1c					; restore old
	mov     bx,word ptr OldInt1c+2					; interrupt 1c vector
	push    ds
	mov     ds,bx
	mov     ax,251ch
	int     21h
	pop		ds

	mov		ax,0003h
	int		10h
;	Enter dos
	mov ax,0
	int 21h
Start   endp

jump_table      label   word
	dw      go_rotate
	dw      inc_level
	dw      while_kbhit
	dw      go_left
	dw      while_kbhit
	dw      go_right
	dw      while_kbhit
	dw      while_kbhit
	dw      go_drop
jump_table2		label word
	dw		go_drop
	dw		while_kbhit
	dw		go_left
	dw		go_rotate
	dw		go_right
	dw		while_kbhit
	dw		inc_level

_NewInt1c       proc    far
	push	ax
	push	bx
	push	cx
	push	dx
	push	di
	push	si
	push	bp
	push	ds
	push	es

	mov     bp,cs
	mov     ds,bp
	pushf
	call    dword ptr OldInt1c

	inc		word ptr randseed
	cmp		word ptr Timer,0
	je		short pause
	cmp		Paused,0
	je		short pause_ok
	call	RemovePause
	mov		Paused,0
pause_ok:
	dec     word ptr Timer
	dec		word ptr LevelWait
	jne		short return
	mov		word ptr LevelWait,LEVEL_WAIT_INIT
	cmp		TimerInit,0
	je		short return
	dec		word ptr TimerInit
	inc		word ptr Level
	xor		dx,dx
	mov		ax,word ptr Level
	mov		di,LEVEL_POS
	call	PrintLong
	jmp		return
pause:
	cmp		Paused,0
	jne		short return
	call	PrintPause
	mov		Paused,1
return:
	pop 	es
	pop 	ds
	pop 	bp
	pop 	si
	pop 	di
	pop 	dx
	pop 	cx
	pop 	bx
	pop 	ax

	iret
_NewInt1c       endp




Move proc near					; si=dPos
	push 	si

	xor		si,si
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Print				; remove old

	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov 	di,word ptr Pos
	pop 	si
	add		di,si
	push 	si
	call	near ptr TestSpace				; test if room
	pop     si
	push	ax
	or		ax,ax
	je		short no_room
	add		word ptr Pos,si				; ok, add Pos
no_room:
	push	si
	mov 	si,1
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Print
	pop		si
	pop		ax
	ret
Move endp

Rotate	proc	near
	push si
	xor 	si,si
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Print

	mov		ax,word ptr Rotated
	inc		ax
	mov		bx,4
	cwd
	idiv	bx
	mov		ax,word ptr Item
	add		ax,dx
	mov		di,word ptr Pos
	call	near ptr TestSpace
	or		ax,ax
	je		short no_room1
	mov		ax,word ptr Rotated
	inc		ax
	mov		bx,4
	cwd
	idiv	bx
	mov		word ptr Rotated,dx
no_room1:

	mov		si,1
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,Pos
	call	near ptr Print
	pop		si
	ret
Rotate	endp

Down	proc	near
	push 	si
	mov     si,80
	call	Move

	or		ax,ax						; room?
	je		get_new							; no
	pop		si
	ret
get_new:
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,word ptr Pos
	call	near ptr Bottom			; reached the bottom

	call	near ptr Rand7			; get new item
	shl		ax,1
	shl		ax,1
	mov		word ptr Item,ax
	mov		word ptr Pos,START_POS
	mov		word ptr Rotated,0

;	Calculate score
	mov		ax,word ptr Drops
	shr		ax,1
	add		ax,2
	sub		ax,PreView
	mov		dx,word ptr Level
	mul		dx
	add		Score,ax
	adc		Score+2,dx
	mov		di,SCORE_POS
	mov		ax,Score
	mov		dx,Score+2
	call	PrintLong
	mov		word ptr Drops,0

;	Test if new tetris can be printed
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,Pos
	call	TestSpace
	or		ax,ax
	jne		place_new

;	There was no room. Return false!
	pop		si
	ret

; 	There was room. Print tetris.
place_new:
	mov		si,1
	mov		ax,word ptr Item
	add		ax,word ptr Rotated
	mov		di,Pos
	call	Print
	mov		ax,	word ptr TimerInit
	mov		word ptr Timer,ax

;	Display preview tetris
	cmp		PreView,0
	je		short no_preview
	call	near ptr RemovePreView
	call	near ptr PrintPreview
;	Return true.
no_preview:
	mov     ax,1
	pop 	si
	ret
Down	endp

Drop	proc	near
	push	si
	mov		si,80
drop_more:
	call	Move
	inc		word ptr Drops
	or		ax,ax
	jne		drop_more

	call	near ptr Down
	pop		si
	ret
Drop	endp

PrintPreView	proc near
	mov		si,1
	mov		ax,OldRand
	shl		ax,1
	shl		ax,1
	mov		PreItem,ax
	mov		di,PREVIEW_POS
	call	Print
	ret
PrintPreView	endp

RemovePreView	proc near
	xor 	si,si
	mov		ax,word ptr PreItem
	mov		di,PREVIEW_POS
	call	Print
	ret
RemovePreView	endp


GetKey proc    near
	mov      ah,07h
	mov      dl,0ffh
	int      21h
	ret
GetKey endp

RandInit       proc    near
	mov     bp,sp
	sub     sp,4
	mov      ah,02h
	int      1ah
	mov      [bp-2],cl
	mov      [bp-4],dh
	mov     ax,word ptr [bp-2]
	imul    word ptr [bp-4]
	mov     word ptr randseed,ax
	mov     sp,bp
	call    near ptr Rand7
	ret
RandInit       endp

Rand7  proc    near
	mov     ax,word ptr randseed
	imul    word ptr randseed

	test    ax,1
	je      short even_number
	add     ax,3172
	mov     word ptr randseed,ax
	jmp     short skip_even
even_number:
	shl		ax,1
	add		ax,Score
skip_even:
	mov     word ptr randseed,ax
	mov     bx,7
	xor     dx,dx
	div     bx
	mov     ax, word ptr OldRand
	mov		word ptr OldRand, dx
	ret
Rand7  endp

.DATA
Timer 		dw 	0
LevelWait   dw	LEVEL_WAIT_INIT
Level		dw	1
StartLevel	dw	0
Pos			dw	START_POS
Item		dw	0
Rotated		dw	0
Drops		dw  0
RandSeed    dw	0
PreView		dw	0
Paused      db  0
ErrorText	db	'Bad arguments',10,'$'
EnterName	db	'Enter name:',10,13,'$'
HiScoreData db	14,0
HiScoreName db	15 dup ('$')
HiScore 	dd	0
OldInt1c 	db  4 dup (?)
Score		dw	2 dup (?)
OldRand		dw	1 dup (?)
PreItem		dw	1 dup (?)
TimerInit	dw	1 dup (?)

end Start

