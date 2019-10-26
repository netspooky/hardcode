;
; nois 12
; by rudi of yaphan~darklite
;
org 100h
	mov al, 13h
	int 10h							
	les bp, [bx]
L:	xchg ax, di
	sbb ax, di
	stosb
	jmp L
