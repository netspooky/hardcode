;zebate
;256 byte intro
;for WeCan 2012
;by frag/fsqrt
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;15-09-2012

;Simple z-buffered gears.
;Nasm compatible.

org 100h
	inc ax
	mov al, 13h
	int 10h
	les bp, [bx]
	mov ah, 80h
	mov fs, ax
	mov dx, 3c9h
P:	mov cl, 3
PL:	mov ax, bx
	sar al, cl
	jns C0
	and al, 63
	mul al
	shr ax, 6
C0:	out dx, al
	loop PL
	inc bx
	jnz P
	
c4 equ ($-$$+1)
L:	mov dx, 4
L1:	imul cx, dx, 6
L2:	mov di, dx
	sub di, 3
	imul di, 52
	mov bp, sp
	pusha
	fninit
	fild word [si+c4]		;>4
	fild dword [si-10]		;>4 s
	fld st0					;>4 s s
	jcxz S0
	fstp st0
	fild dword [bp-10]
S0:	fidiv dword [bp-10]		;>4 s r0
	fmul st0, st2
	fimul word [bp-6]		;>4 s r0
	fld st1					;>4 s r0 s
	fmul st0, st3
	fimul word [bp-6]		;>4 s r0 r
	fild word [bp-16]		;>4 s r0 r di
	fimul word [si-14]
	faddp st1, st0
	fsin					;>4 s r0 sin(a)
	fdiv dword [si-3]
	fadd st0, st3			;>4 s r0 sin(a)/2+4
	fmulp st1, st0			;>4 s r
	fldz					;>4 s r 0
	fxch st2				;>4 0 r s
	call rot				;>4 y x
	fiadd word [bp-16]		;>4 y x
	fild word [bp-4]		;>4 y x cx
	fimul dword [si-10]
	fidiv dword [bp-10]		;>4 y x z
	fild word [si-14]		;>4 y x z t
	fdiv st0, st4
	fdiv st0, st4			;>4 y x z t'
	call rot				;>4 y z x
	fld st1					;>4 y z x z
	fdiv st0, st4
	faddp st3, st0			;>4 y+z/4 z x
	fistp word [bp-12]		;store x
	fistp word [bp-2]		;store z
	fistp word [bp-16]		;store y
	popa
	imul di, 320
	add di, 320*100+160+16
	shr al, 1
	add al, 64
	bt dx, 1
	adc al, al
RE:	cmp [fs:di+bp], al		;z-buffer
	ja S1
	mov [fs:di+bp], al
S1:	lea bp, [bp+si+64]
	neg dx
	js RE
	neg cx
	js L3
	jz EX
	xor cx, cx
L3:	jmp L2
EX:	dec dx
	dec dx
	jnz L1
	inc word [si-10]
	jnz L4
	dec word [si-14]		;timer
	
C:	xor ax, ax
	xchg al, [fs:di]
	test al, al
	jnz ST
	mov ax, 1c1ch
	and ax, di
	xor al, ah
ST:	ror al, 1
	stosb
	loop C
	
R:	in al, 60h
	dec ax
L4:	jnz L
	ret
	
rot:				;>x y a
	fsincos			;>x y sin(a) cos(a)
	fld st0			;>x y sin(a) cos(a) cos(a)
	fmul st0, st3	;>x y sin(a) cos(a) y*cos(a)
	fxch st2		;>x y y*cos(a) cos(a) sin(a)
	fld st0			;>x y y*cos(a) cos(a) sin(a) sin(a)
	fmul st0, st5	;>x y y*cos(a) cos(a) sin(a) x*sin(a)
	faddp st3, st0	;>x y y' cos(a) sin(a)
	fmulp st3, st0	;>x y*sin(a) y' cos(a)
	fmulp st3, st0	;>x*cos(a) y*sin(a) y'
	fxch st2		;>y' y*sin(a) x*cos(a)
	fsubrp st1, st0	;>y' x'
	ret







