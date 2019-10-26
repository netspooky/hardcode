	org 100h
	mov al, 3h
	int 10h
	
	push 0b800h
	pop es
mainloop:
	mov dx, 3dah ; Load the port
h1:
    in al, dx    ; Input a byte
    and al, 08h  ; 'And' it with a set bit 4.
    jz h1       ; Continue looping while bit 4 = 0 (i.e. in retrace)
h2:
    in al, dx    ; Input a byte.
    and al, 08h  ; 'And' it with a set bit 4.
    jnz h2        ; Continue looping while bit 4 = 1 (i.e. not in retrace)

	mov ax, 0F01H
	mov si, torso
	mov cx, 7
callloop:
	call teken
	loop callloop
	
	inc bp
	test bp, 32
	jz noswap
	xchg ax, cx  ;swap tussen zwart en wit
noswap:
	call teken
	call teken
	xchg ax, cx
	call teken
	call teken
	
	; ax = tekenkleur
	; cx = erasekleur
	
	mov ah, 1
	int 16h
	jz mainloop
	ret
;	jmp mainloop
	
data:
torso:
dw	960 + 80       ;offset
db  158, 10   ;stepsize, amount

shoulders:
dw	960 +160 + 64       ;offset
db  0, 17   ;stepsize, amount

leftleg:
dw	2560 + 78       ;offset
db  156, 4   ;stepsize, amount
	
rightleg:
dw	2560 + 82       ;offset
db  160, 4   ;stepsize, amount
	
kop1:
dw	800+78       ;offset
db  0, 3   ;stepsize, amount
kop2:	
dw	640 + 76       ;offset
db  0, 5   ;stepsize, amount
kop3:	
dw	480 + 78       ;offset
db  0, 3   ;stepsize, amount

linksboven:
dw	640 + 64       ;offset
db  158, 3   ;stepsize, amount
rechtsonder:
dw	1280 + 12 + 84       ;offset
db  158, 3   ;stepsize, amount
linksonder:
dw	1280 + 64       ;offset
db  158, 3   ;stepsize, amount
rechtsboven:
dw	640 +12 + 84       ;offset
db  158, 3   ;stepsize, amount

	
	
teken:
	pusha
	; si = adres van line
	mov di, [si]
	mov bl, [si+2]
	;xor cx, cx
	;mov cl, [si+3]
	movzx cx, byte[si+3]
	;mov ch, 0
	;mov bh, 0
	; why are you reading this?
	;mov ax, 0F01H
tekenloop:
	stosw
	add di, bx
	loop tekenloop
	popa
	add si, 4
	ret




	