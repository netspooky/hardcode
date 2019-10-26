	IDEAL

model tiny
p386
CODEseg

org 100h

LINETEST:
	mov ax, 13h
	int 10h		;Init mode 320x200
	push 0A000h
	pop es
	mov cx,128
	mov ebx, 0100060h	;(10,20)
	mov edx, 0800050h	;(80,50)
	mov al,15
L1:
	pushad
	call DrawLine
	mov cx,0ffffh
pause:
	ror ax,1
	loop pause
	popad
	inc dx
	ror ebx,16
	add bx,2
	rol ebx,16
	loop L1
	ret

Include "Graph.asm"


End LINETEST

