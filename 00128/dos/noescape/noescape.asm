;noescape
;128 byte intro
;for Outline 2012
;by fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;05-10-2012

;Just wanted to make tunnel for the long time.
;Nasm compatible.

org 100h
	mov al, 13h
	int 10h
	les bp, [bx]
	
	xchg ax, bx
	mov dx, 3c9h
P:	mov cl, 12
P1:	out dx, al
	loop P1
	inc ax
	jnz P

L:	mov ax, 0cccdh
	mul di
	sub dx, 648ch
	mov bp, sp
	mov ah, 28h
	mov bl, 5
	pusha					;[  sp  ][bl][bh][dl][dh][cl][ch][al][ah]
							;[FE][FF][05][00][ x][ y][  ][  ][  ][28][00]
	fild word [bp-1]		;>40			
LD:	fild word [bp-6]
	fidiv word [bx-9]		;bx-9 = -4, word [-4] = 28xxh
	fild word [si]
	dec bp
	jnp LD
							;>40 y t0 x t0
	fdiv st0, st4			;>40 y t0 x t
	fsincos					;>40 y t0 x sin(t) cos(t)
	fld st0					;>40 y t0 x sin(t) cos(t) cos(t)
	fmul st0, st5			;>40 y t0 x sin(t) cos(t) y*cos(t)
	fsub st0, st2			;>40 y t0 x sin(t) cos(t) y'
	fxch st5				;>40 y' t0 x sin(t) cos(t) y
	fmulp st2, st0			;>40 y' t0 x y*sin(t) cos(t)
	faddp st1, st0			;>40 y' t0 x z'
	fld st1					;>40 y' t0 x z' x
	fmul st2, st0			;>40 y' t0 x^2 z' x
	fld st4					;>40 y' t0 x^2 z' x y'
	fmul st5, st0			;>40 y'^2 t0 x^2 z' x y'
	fpatan					;>40 y'^2 t0 x^2 z' ang
	fmul st0, st5			;>40 y'^2 t0 x^2 z' ang*40
	fadd st0, st3			;>40 y'^2 t0 x^2 z' a01
	fist word [si+bx]
	fidiv word [bp-8+2]		;>40 y'^2 t0 x^2 z' a02
	fsin					;>40 y'^2 t0 x^2 z' sin(a02)
	fisub word [bp-10+2]	;>40 y'^2 t0 x^2 z' sin(a02)+2
	fmulp st1, st0			;>40 y'^2 t0 x^2 z'*(sin(a02)+2)
	fmul st0, st4			;>40 y'^2 t0 x^2 z'*(sin(a02)+2)*40
	fxch st3				;>40 z'*(sin(a02)+3)*40 t0 x^2 y^2
	faddp st1, st0			;>40 z'*(sin(a02)+3)*40 t0 x^2+y^2
	fsqrt					;>40 z'*(sin(a02)+3)*40 t0 r
	fdiv st2, st0			;>40 z'*(sin(a02)+3)*40/r t0 r
	fmulp st3, st0			;>r*40 z'*(sin(a02)+3)*40/r t0
	faddp st1, st0			;>r*40 b01
	fistp word [bp-2+2]		;>r*40
	fistp word [bx]			;>
	popa
	xor al, [si+bx]
	aam 1
	mul word [bx]
	xchg ax, dx
	stosb
	loop L
	
	inc word [si]
	in al, 60h
	dec ax
	jnz L
	ret

