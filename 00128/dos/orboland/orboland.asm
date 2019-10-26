;orboland
;128 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;27-05-2012

;Time for the sphere marching!
;Well, not exactly, here is simplified variation:
;distant function is used for the ray progression,
;but number of steps is fixed due to the lack of space.
;Veeery slow, but can be much faster with the cost of dozen bytes.
;Enjoy!


org 100h
	mov al, 13h
	int 10h
	push 0a000h
	pop es
	mov dx, 3c9h
P:	out dx, al			;ugly grayscale palette
	inc ax
	jns P
	mov bl, 3fh;
						;variables:
						;[bx] - timer
						;[si] - R
						;[si+bx] - 0.5f
L:	mov si, 320
	mov ax, di
	xor dx, dx
	div si
	shr si, 1
	mov byte [si+bx+3], bl
						;dword [si+bx] = 0.5f
	sub dx, [bx]		;rotation
	mov bp, sp
	pusha
	lea di, [bp-14]		;[di] = 160
	mov [si], bx		;clear R
	mov cx, bx			;iteration number, 63
T:						;ax - y
	fild word [bp-2]	;ax
	fidiv word [di]		;theta
	fadd dword [si+bx]	;theta += 0.5
	fsincos				;sin(theta) cos(theta)
						;dx - x
	fild word [bp-6]	;sin(theta) cos(theta) dx
	fidiv word [di]		;sin(theta) cos(theta) phi
	fsincos				;sin(theta) cos(theta) sin(phi) cos(phi)
	fmul st0, st3		;sin(theta) cos(theta) sin(phi) sin(theta)*cos(phi)
	fxch st0, st3		;sin(theta)*cos(phi) cos(theta) sin(phi) sin(theta)
	fmulp st1, st0		;sin(theta)*cos(phi) cos(theta) sin(theta)*sin(phi)
						;X Z Y
	
						;next distance function runs three times
						;for R.x, R.y, R.z
	fldz				;X Z Y 0
						;1) X Z dry^2
						;2) X dry^2+drz^2
						;3) drx^+dry^2+drz^2
	mov al, 3			;al < 200
R:	fxch st1, st0		;... [sum] {X,Z,Y}
	fimul word [si]		;... [sum] R*{X,Z,Y}
	fiadd word [bx]		;... [sum] R*{X,Z,Y} T
	fidiv word [di]		;... [sum] R*{X,Z,Y} t
	fld st0				;... [sum] R*{X,Z,Y}+t R*{X,Z,Y}+t
	fsub dword [si+bx]	;... [sum] R*{X,Z,Y}+t R*{X,Z,Y}+t-0.5
						;-0.5 is needed here due to 'near' default rounding mode
	frndint				;... [sum] R*{X,Z,Y}+t floor(R*{X,Z,Y}+t-0.5)
	fsubp st1, st0		;... [sum] mod(R*{X,Z,Y}+1, 1.0)
	fsub dword [si+bx]	;... [sum] dr{x,z,y}
	fmul st0, st0		;... [sum] dr{x,z,y}^2
	faddp st1, st0		;... [sum]
	dec ax
	jnz R
	
	fsqrt				;r
	fimul word [di]		;dR
	fiadd word [si]		;R+dR
	fistp word [si]		;R+dR
	sub word [si], 30	;spher radius
	loop T
	popa				;[si] - distance
	mov ah, 11111000b
	add ax, [si]
	jnc Z
	salc				;depth of field < 2048
Z:	stosb
	loop L
	inc word [bx]		;update timer
	in al, 60h
	dec al
	jnz L
	ret					;that's all =)


