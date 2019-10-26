;down
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;07-11-2011

org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
	mov si, 320

L:	mov ax, di
	xor dx, dx
	div si
	imul ax, dx
	mov al, ah
	add ax, bp
	or al, dl
	stosb
	loop L
	inc bp
	jmp L
