;ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ               RANDOM PROCEDURE by Agent Orange // trx               บ
;ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
;	IDEAL;
;-------------------------------------------------------------------------------

Random:
	push bx
	mov ax,[Seed1]
	mov bx,[Seed2]
	add ax,[Seed3]
	ror ax,9
	mov [Seed2],ax
	add [Seed1],bx	
	pop bx
	ret
Seed1	dw	00001h;0de45h
Seed2	dw	0A000h;04343h
Seed3	dw	0D94Bh

;-------------------------------------------------------------------------------

Randomize:
	mov ah,2Ch
	int 21h
	xor cx,cx
	mov cl,dl
Randomize_L1:
	call Random
	loop Randomize_L1
	mov [Seed3],ax
	ret