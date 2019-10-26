	mov ax, 13h                 	;MCGA mode (320x200x256).
	int 10h                    	;Video interrupt request.

	push word 0xa000		;Video memory
	pop es

DRAW	mov di, cx
	imul di, 320			; di = x + (y * 320)
	add di, bx
	stosb
	
RAND	rdtsc				; only seems to work on some systems

	xor di, di			; ATTRACTOR 1 (160,0)
	xor dx, dx
	test al, 34
	je ATTR

	mov dx, 199			; ATTRACTOR 2 (0,200)
	test al, 33
	je ATTR

	mov di, 319			; ATTRACTOR 3 (320,200)
	test al, 32
	jne RAND			; atr_x = di
					; atr_y = dx
					; x = bx
					; y = cx

ATTR	sub di, bx			; (DI - x)
	sar di, 1			; ((DI - x) / 2)
	add bx, di			; x + ((DI - x) / 2)

	sub dx, cx			; (DX - y)
	sar dx, 1			; ((DX - y) / 2
	add cx, dx			; y + ((DX - y) / 2)

	jmp DRAW
