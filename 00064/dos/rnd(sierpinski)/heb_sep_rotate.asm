	mov al, 13h                 	;MCGA mode (320x200x256).
	int 10h                    	;Video interrupt request.

	push word 0xa000	;3b	;Video memory
	pop es			;1b

INIT	xor di, di
	mov [es:di], word 0		;attractor 1 angle
	mov [es:di+2], word 20		;radian devisor
	mov [es:di+4], word 41		;attractor 2 angle
	mov [es:di+6], word 99		;triangle radius
	mov [es:di+8], word 82		;attractor 3 angle

	mov [es:di+10], word 160	;attr_1_x
	mov [es:di+12], word 0		;attr_1_y
	mov [es:di+14], word 0		;attr_2_x
	mov [es:di+16], word 199	;attr_2_y
	mov [es:di+18], word 319	;attr_3_x
	mov [es:di+20], word 199	;attr_3_y

ROT	xor di, di			;di = 0
	inc word [es:di]		;
	inc word [es:di+4]		; update angles
	inc word [es:di+8]		;

	push si				;push some persistant values onto stack temporarily
	xor si, si

	push cx
	mov cx, 3

ROTT	fild word [es:di]		;load attr angle
	fidiv word [es:si+2]		;scale 0 - rad - 6.3
	fsincos				; angle sin - st1 | cos - st0

	fimul word [es:si+6]		;scale_x * radius
	fistp word [es:di+10]		;attr_x = radius * cos (angle)
	fimul word [es:si+6]		;scale_y * radius
	fistp word [es:di+12]		;attr_y = radius * sin (angle)

	add word [es:di+10], 160	; x + 160 | y + 100
	add word [es:di+12], 100	; to center on screen

	add di, 4			;offset to next pair of co-ords
	loop ROTT

	mov di, 22			;save the data pixels
	mov cx, 0xf9e9
	mov al, 0
	rep stosb			;clear everything else

	pop cx				; retrive persistant variables
	pop si

DRAW	mov di, cx			;
	imul di, 320			; di = x + (y * 320)
	add di, bx			;

					;update video memory
	inc byte [es:di]	;3b	; pallet scrolling
;	mov [es:di], byte 31	;4b	; 16-31 = black to white
;	stosb			;1b	; same as mov [es:di], al | inc di

RAND	rdtsc			;2b	; CPU Timestamp
	jmp RAND3

RAND2	in ax, 40h		;3b	; PIT timer

RAND3	add ax, di			; randomizer hax of dewm :(
 
	and ax, 3		;2b	;speedup rand [mask 00000011]

	xor di, di

	mov bp, word [es:di+10]		; ATTRACTOR 1 (160,0)
	mov dx, word [es:di+12]
	dec ax				; al = 1 jmp
	je ATTR

	mov bp, word [es:di+14]		; ATTRACTOR 2 (0,200)
	mov dx, word [es:di+16]
	dec ax				; al = 2 jmp
	je ATTR

	mov bp, word [es:di+18]		; ATTRACTOR 3 (320,200)
	mov dx, word [es:di+20]			
	dec ax				; al = 3 jmp
	jne RAND2			


ATTR	sub bp, bx			; (DI - x)
	sar bp, 1			; ((DI - x) / 2)
	add bx, bp			; x + ((DI - x) / 2)

	sub dx, cx			; (DX - y)
	sar dx, 1			; ((DX - y) / 2
	add cx, dx			; y + ((DX - y) / 2)

	dec si
	jne DRAW 

	mov si, 0x19ff			; redraw timer
	
DRAWEND	in ax, 60h			;Read value from port 60h (keyboard)
	dec ax				;See if the ESC key was pressed (scancode 1)
	jnz ROT				;Zero, END

END	ret                        	;DIE