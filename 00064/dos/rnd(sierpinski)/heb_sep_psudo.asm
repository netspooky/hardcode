	mov ax, 13h                 	;MCGA mode (320x200x256).
	int 10h                    	;Video interrupt request.

	push word 0xa000		;Video memory
	pop es

DRAW	mov di, cx
	imul di, 320			; di = x + (y * 320)
	add di, bx
					
					;update video memory
	inc byte [es:di]	;3b	;- paxlet scrolling
;	mov [es:di], byte 31	;4b	;- 16-31 = black to white
;	stosb			;1b	;- same as mov [es:di], ax | inc di

					; temp = ax [reset by keyboard scan]
					; temp2 = si
					; x = bx
					; y = cx
					; atr_x = di
					; atr_y = dx

;RAND	in ax, 40h			; PIT timer
;RAND	rdtsc				; CPU Timestamp

RAND	adc si, di			; Psudo Random
	rol si, 3
	push si
	pop ax

	and ax, 3		;3b	;speedup rand [mask 00000011]

	mov di, 159			; ATTRACTOR 1 (160,0)
	xor dx, dx
	dec ax				; ax = 1 jmp
	je ATTR

	xor di, di			; ATTRACTOR 2 (0,200)
	mov dx, 199
	dec ax				; ax = 2 jmp
	je ATTR

	mov di, 319			; ATTRACTOR 3 (320,200)
	dec ax				; ax = 3 jmp
	jne RAND			

ATTR	sub di, bx			; (DI - x)
	sar di, 1			; ((DI - x) / 2)
	add bx, di			; x + ((DI - x) / 2)

	sub dx, cx			; (DX - y)
	sar dx, 1			; ((DX - y) / 2
	add cx, dx			; y + ((DX - y) / 2)


DRAWEND	in ax, 60h                  	;Read vaxue from port 60h (keyboard)
	dec ax                     	;See if the ESC key was pressed (scancode 1)
	jnz DRAW			;Zero, END

;	mov ax, 03h
;	int 10h

END	ret                        	;DIE
