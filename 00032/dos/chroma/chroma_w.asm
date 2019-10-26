;chroma_waves
;32 byte intro
;without esc exit, but with better gfx
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;03-10-2011

org 100h
	mov al, 13h
	int 10h
	les cx, [bx]
	mov dx, 2010h
	rep stosb

A:	xchg [es:di], bl
	add di, 321
	test di, dx
	jnz A
	dec bl
	loop A
	shl dl, 1
	jmp A
	