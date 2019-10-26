;gitter
;256 byte intro
;for Chaos Constructions 2012
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;17-08-2012

;Sphere tracing with lighting and simple 'texturing',
;nasm compatible.

org 100h				;ah=0, bx=0, cx=255
	aas					;word [si-3] = 0.5
	mov al, 13h
	int 10h
	mov dx, 3c9h
P:	mov cl, 3			;four gradients
PL:	imul ax, bx, 2
	sar ax, cl
	out dx, al
	loop PL
	inc bx
	jnz P
						;ax = -1
	xchg ax, bp			;[bp-1] - stack top
	
						;word [si-5] - time
						;word [si-9] - c_small = 3c000000h = 0.0078
					
L:	mov bh, 80h
	mov ax, 0cccdh
	mul di
	mov cl, 25
	sub dx, 6480h
	mov ax, 0a000h		;al = 0
	mov es, ax
	pusha				;stack:
						;...[bl][bh][dl][dh][cl][ch][al][ah]
						;...[00][80][ x][ y][19][00][00][..]
						;word [bp-8] = -2^15
						;word [bp-4] = 25
	fninit
	fild word [si-5]	;>time
	fld st0				;>time time
	fsin				;>time sin(time)
	fldpi
	fsubp st1, st0
	fidiv word [bp-1-4]	;>time (sin(time)-3.14)/25. = column radius = c_r
	fstp dword [bx]		;store c_r
	fidiv word [bp-1-4]	;>t
	fst dword [bx+104]
	
	fild word [bp-1-7]	;load x<<8
	fidiv word [bp-1-8]	;>t x
	fadd st0, st1		;>t x+t
	fsincos				;>t sin(x+t) cos(x+t)
	fild word [bp-1-6]	;load y<<8
	fidiv word [bp-1-8]	;>t sin(x+t) cos(x+t) y
						;>t X Z Y 
	fld st3				;>t X Z Y t
	fsincos				;>t X Z Y sin(t) cos(t)
	fld st0				;>t X Z Y sin(t) cos(t) cos(t)
	fmul st0, st3		;>t X Z Y sin(t) cos(t) Y*cos(t)
	fxch st0, st3		;>t X Z Y*cos(t) sin(t) cos(t) Y
	fmul st0, st2		;>t X Z Y*cos(t) sin(t) cos(t) Y*sin(t)
	fxch st0, st2		;>t X Z Y*cos(t) Y*sin(t) cos(t) sin(t)
	fmul st0, st5		;>t X Z Y*cos(t) Y*sin(t) cos(t) X*sin(t)
	faddp st3, st0		;>t X Z Y0 Y*sin(t) cos(t)
	fmulp st4, st0		;>t X*cos(t) Z Y0 Y*sin(t)
	fsubp st3, st0		;>t X0 Z0 Y0				
	fnsave [bx+4]		;tword [bx+18] = Y0
						;tword [bx+28] = Z0
						;tword [bx+38] = X0
	fld dword [si-9]	;>c_small			
	fldz				;>c_small L=0
						;cx = 25 steps

TR:
	call dist
	fcomi st0, st2		;>c_small L dist
						;if (dist > 0.0078) continue tracing
	jnc TR_NEXT
	;===============	;we at the surface
	xor dx, dx
	fxch st0, st1		;>c_small dist L
	mov [si-6], dl		;c_small = 0.0
	call dist			;>c_small dist L dist2
	mov [bp-1-2], dh		;byte [bp-2] = texture
	mov byte [si-6], 3ch
	fsub st0, st2		;>c_small dist L ddist=dist(p+dp)-dist(p)
						;c_small = 0.0078
	fdiv st0, st3		;>c_small L lighting
	fld1
	fadd st2, st0
	fadd st1, st0
	faddp st1, st0
	fdiv st0, st1		;>c_small L+1 (li+2)/(L+1)
	;===============
	jmp TR_EXIT
TR_NEXT:
	faddp st1, st0		;>c_small L+dist
	loop TR
	fldz				;>c_small L+dist 0 - black
TR_EXIT:
	fimul word [bp-1-4]	;>c_small L+1 brightness
	fistp word [bp-1-1]	;>c_small L+1
	popa				;al = texture, ah = brightness
	and al, 192
	aad 1				;color = (texture & 11000000b) + brightness
						;al = color, ah = 0
	stosb
	;stosb				;for the fast version
	test di, di
E:	jnz L
	dec word [si-5]		;time update
	in al, 60h
	dec ax
	jnz E				;short jump
	
dist:					;distance function for the crossed cylinders is
						;sqrt(x^2+y^2+z^2-max(x^2,y^2,z^2))-r_c
	fldz
	fldz				;>c_small L sum=0 max=0
TR_AXIS:
	fld tword [bx+18]	;>c_small L sum max {Y0,Z0,X0}
	fmul st0, st3
	fsub dword [bx+104]
	fsub dword [si-9]	;>c_small L sum max {L*Y0+time,L*Z0,L*X0}+{c_small,0.0}=coord
	fld st0				;>c_small L sum max coord coord
	fimul word [bp-1-8]	;>c_small L sum max coord coord*8000h
	fistp dword [bx+si]	;unsigned word [bx+si+1] = coord*80h+19h
	add byte [bx+si+1], 32
						;unsigned word [bx+si+1] = coord*80h+20h
	xor dx, [bx+si]		;xor 'texture', two msb of [bx+si+1]
	fld st0				;>c_small L sum max coord coord
	fsub dword [si-3]	;>c_small L sum max coord coord-0.5
	frndint				;>c_small L sum max coord floor(coord)
	fsubp st1, st0
	fsub dword [si-3]	;>c_small L sum max coord'
	fmul st0, st0		;>c_small L sum max coord'^2
	fadd st2, st0		;update sum
	fcomi st0, st1
	fcmovb st0, st1		;update max
	fxch st0, st1
	fcomp				;>c_small L sum max
	dec bx
	lea bx, [bx+11]		;shift to next coordinate, 0, +10, +20
	jp TR_AXIS			;exit on +30
	mov bl, 0			;restore bx value
	fsubp st1, st0		;>c_small L sum-max=(dx^2+dy^2+dz^2)
	fsqrt				;>c_small L dr
	fadd dword [bx]		;>c_small L dr-c_r=dist
	ret

