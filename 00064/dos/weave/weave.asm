;weave
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;06-11-2011


org 100h
	mov al, 13h
	int 10h
	les bx, [bx]
	mov si, 320

L:	mov bx, 6020h
	mov ax, di
	xor dx, dx
	div si
R:	imul ax, ax
	sub ah, dl
	mov al, ah
	add al, [si]
	xchg ax, dx
	neg si
	js R
	push dx
	or dl, al
	test dl, bl
	pop dx
	jz A
	test dl, bl 
	jz B
	and dl, bh
	add dl, al
	test bh, dl
	jz B
	inc bx
B:	inc bx
A:	xchg ax, bx
	aaa
	stosb
	loop L
	dec byte [si]
	jmp L
