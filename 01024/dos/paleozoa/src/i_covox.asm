;Set timer to ~15 kHz
;and set sound procedure.

T_HOOK:
	mov dx, T_HAND
	mov al, 36h
	out 43h, al
	mov al, 80	;1193180/80 ~ 15 kHz
	out 40h, al
	mov al, 0
	out 40h, al
	mov ax, 2508h
	int 21h
	ret

T_HAND:
	pusha
		;sound function
		;(t&((t>>8)+t)) ^ (t*3)&(t>>9) ^ ((t*3)&(t>>9))>>4
	mov di, TIMER
	mov ax, [cs:di]
	imul bx, ax, 3
	mov dx, [cs:di+1]
	push dx
	add dx, ax
	and ax, dx
	pop dx

	shr dx, 1
	and dx, bx
	xor ax, dx
	shr dx, 4
	xor ax, dx

	mov dx, 378h
	out dx, al
	inc dword [cs:di]
	mov al, 20h
	out 20h, al
	popa
	iret



	

