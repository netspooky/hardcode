;cassini
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;30-10-2011

org 100h
	mov al, 13h
	int 10h
	les ax, [bx]
	mov si, 320
	mov bp, sp

L:	mov ax, di
	xor dx, dx
	div si
	pusha
	
pr:	fild word [bp-8]
	fisub word [bp-2]
	fmul st0
	not byte [bp-8]
	fild word [bp-8]
	fisub word [bp-6]
	fmul st0
	faddp st1
	fsqrt
	neg si
	js pr
	
	fmulp st1
	fsqrt
	fistp word [bp-2]
	popa
	stosb
	loop L
	inc bl
	in al, 60h
	dec ax
	jnz L
	ret
