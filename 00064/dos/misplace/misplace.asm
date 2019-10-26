;misplace
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;29-02-2012

;Postprocessed cellular automata.
;Enjoy!

org 100h
	mov al, 13h
	les di, [bx]
	int 10h
	lds di, [si]
	mov bx, 224

L:	lodsb
	or al, [si]
	or al, [si+bx+95]
	or al, [si+bx+96]
	jnp A
	test bp, bx
	jz A
	inc ax
A:	mov [si-1], al
	mov al, [si]
	mov ah, al
	xor al, [si+15]
	xor ah, [si+320*15]
	or al, ah
	mov [es:si+bp], al
	loop L
	imul di, 53
	dec di
	inc bp
	mov [di], di
	in al, 60h
	dec al
	jnz L
	ret
	