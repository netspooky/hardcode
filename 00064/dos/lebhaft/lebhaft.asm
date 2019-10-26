;lebhaft
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;17-12-2011

;Dynamic Julia set.
;Enjoy!


org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es

L:	cwd
	mov si, 320
	mov ax, di
	div si
	mov cx, 30
L0:	mov si, ax
	mov bp, dx
	sub dx, ax
	add ax, bp
	imul dx
	mov al, ah
	mov ah, dl
	xchg ax, si
	imul bp
	shrd ax, dx, 7
	lea dx, [si-192]	;x = (x^2 - y^2) / 256 - 192
	sub ax, bx		;y = 2 * x * y / 256 - bx
	test ah, ah		;do while y < 256
	jg A
	loop L0
A:	xchg ax, cx
	or al, 32
	stosb
	test di, di
	jnz L
	inc bl
	jmp L
	