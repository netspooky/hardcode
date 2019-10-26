;chroma
;32 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;03-10-2011

org 100h
	mov al, 13h
	int 10h
	les cx, [bx]
	rep stosb

A:	xchg [es:di], bl
	add di, 321
	test di, 2010h
	jnz A
	dec bl
	in al, 60h
	dec al
	jnz A
	ret
