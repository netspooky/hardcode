;---------------------------------
; ElEssDee (256b)
; made by tm__, april 7th 2004
;
; nasmw elessdee.asm -fbin -oelessdee.com
;---------------------------------

org 100h

[section .text]
codestart:
	add dh, 10h
	mov es, dx
	mov ax, 13h
	int 10h
	push 0A000h
	pop fs
	makepal:
	mov dx, 3c8h
	xor ax, ax
	out dx, al
	inc dx
	mov bx, 0201h
	.cycle:
	mov ch, 31
	.nextcolor:
	mov cl, 4
	.nextindex:
	out dx, al
	out dx, al
	ror ax, 8
	out dx, al
	ror ax, 8
	dec cl
	jnz .nextindex
	add al, bl
	add al, bl
	dec ch
	jnz .nextcolor
	dec bl
	dec bl
	dec bh
	jnz .cycle
	fild word [x]
	fild word [y]
	fild word [_378]
	mainloop:
	xor di, di
	mov bx, 200
	.nextline:
	mov cx, 320
	.nextpixel:
	mov word [temp], cx
	fld st2
	fisub word [temp]
	fmul st0
	mov word [temp], bx
	fld st2
	fisub word [temp]
	fmul st0
	faddp st1
	fld st1
	fmul st0, st0
	fdivp st1
	fimul word [_255]
	fistp word [temp]
	mov ax, word [temp]
	mov byte [es:di], al
	inc di
	dec cx
	jnz .nextpixel
	dec bx
	jnz .nextline
	mov dx, 3dah
	vsync:
	in al, dx
	test al, 8
	jnz vsync
	.a:
	in al, dx
	test al, 8
	jz .a
	xor si, si
	xor di, di
	mov cx, 32000
	flip:
	mov ax, word [es:si]
	mov word [fs:di], ax
	inc si
	inc si
	inc di
	inc di
	dec cx
	jnz flip
	inc word [_255]
	in al, 60h
	dec al
	jnz mainloop
	mov ax, 3
	int 10h
	int 20h

[section .data]
_378	dw 20
_255	dw 500
x       dw 160
y       dw 100

[section .bss]
temp	resw 1