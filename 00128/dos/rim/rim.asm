;rim
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;30-04-2012

;Have no time for more.
;Enjoy!

org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es

L:	mov ax, di
	xor dx, dx
	mov si, 320
	div si
	sub ax, 100
	sub dx, 160
	mov bp, sp
	pusha
	fild word [bp-14]
	fild word [bp-8]
	fdiv st0, st1		;t
	fsincos			;cos(t)
	fild word [bp-2]	;y	
	fild word [bp-6]	;x
	fld st0
	fmul st0, st0		;x^2
	fld st2
	fmul st0, st0		;y^2
	faddp st1, st0		;x^2 + y^2
	fsqrt			;r
	fist word [bp-12]	;bp <- r
	fxch st0, st2
	fpatan			;f
	fld st0
	fmul st0, st5
	fistp word [bp-14]	;si <- f
	fadd st0, st2		;cos(t) + f
	fsincos
	fdiv st0, st2		;cos(cos(t) + f)/r
	faddp st4, st0		;X_TEXTURE = sin(t) + cos(cos(t) + f)/r
	fdivrp st1, st0		;sin(cos(t) + f)/r
	faddp st1, st0		;Y_TEXTURE = cos(t) + sin(cos(t) + f)/r
	fmul st0, st2
	fistp word [bp-6]
	fmulp st1, st0
	fistp word [bp-2]
	popa
	test bl, 32
	jnz B
	sub al, bl
B:	mul dl			;texture function
	and al, 00011111b
	jz Z
	lea dx, [si+bp]		;background spiral
	sub dx, bx
	add dl, dl
	cwd
	mov dl, 16
Z:	xchg ax, dx
	adc al, 0
	stosb
	loop L
	inc bx
	in al, 60h
	dec ax
	jnz L
	ret

