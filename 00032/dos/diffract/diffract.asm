;diffract
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;07-10-2011

org 100h
	mov al, 13h
	int 10h
	les dx, [bx]
	mov si, 320

L:	mov ax, di
	xor dx, dx
	div si
	mul al
	imul dx, dx
	add ax, dx
	add ah, bl
	and al, ah
	stosb
	loop L
	inc bx
	jmp L
