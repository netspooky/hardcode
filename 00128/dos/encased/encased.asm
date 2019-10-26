;encased
;128 byte intro
;for Function 2012
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;28-09-2012

;z-buffered stuff again.
;Nasm compatible.
;BTW one year of fsqrt!

org 100h
	mov al, 13h
	les bp, [bx]
	lds cx, [si]
	int 10h

	mov dx, 3c9h
P:	mov cl, 12
P1:	out dx, al
	loop P1
	inc ax
	jnz P
	
L:	mov dl, 11100000b
L1:	mov bp, -1
	pusha			;[di][si][bp][sp][bl][bh][dl][dh][cl][ch][al][ah]
LD:	fild word [bp-5]
	fidiv word [cs:si+c632]
	dec bp
	jnp LD
					;							>x y z
					;1st pass, SF=1, PF=1		>x y z
					;2st pass, SF=1, PF=0		>z y x
					;3st pass, SF=0, PF=1		>x z y
	shl byte [bp-4], 1
c632 equ ($-$$)
	js X0
	fxch st1
X0:	jp X1
	fxch st2
X1:
rot:				;>x y a
	fild dword [si+bp]
	fidiv word [bp+4]
	fsincos			;>x y sin(a) cos(a)
	fld st3			;>x y sin(a) cos(a) x
	fmul st0, st1	;>x y sin(a) cos(a) x*cos(a)
	fxch st3		;>x x*cos(a) sin(a) cos(a) y
	fmul st1, st0	;>x x*cos(a) sin(a) y*cos(a) y
	fmul st0, st2	;>x x*cos(a) sin(a) y*cos(a) y*sin(a)
	fsubp st3, st0	;>x x' sin(a) y*cos(a)
	fxch st3		;>y*cos(a) x' sin(a) x
	fmulp st1, st0	;>y*cos(a) x' x*sin(a)
	faddp st2, st0	;>y' x'
	fxch st2
					;CF=1
	cmc
	jnc rot
	
	fistp word [bp-8+2]
	fistp word [bp-16+2]
	fistp word [bp-2+2]
	popa
	imul di, 320
	add al, 110
	cmp [di+bx], al
	ja S
	mov [di+bx], al
S:	test dl, dl
	jnz L1
	not dh
	loop L
	inc word [si+bp-2]
	inc dh
	
C:	xor ax, ax
	xchg al, [di+32000-256+16]
	stosb
	loop C
	
	in al, 60h
	dec ax
	jnz L
	ret
	




