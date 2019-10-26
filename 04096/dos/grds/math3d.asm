; Mikolaj Felix 30/04/2001
; mfelix@polbox.com

					; si - offset to angles
					; di - offset to array of 3d points
					; cx - number of points
rotate_points proc
	push bp
	mov bp,sp
	sub sp,24
					; bp-4  - sin_x
					; bp-8  - cos_x
					; bp-12 - sin_y
					; bp-16 - cos_y
					; bp-20 - sin_z
					; bp-24 - cos_z
	push di
	push cx

	mov di,bp
	sub di,4
	mov cx,3
rp_sin_cos:
	fld dword ptr [si]
	fld st(0)
	fsin
	fstp dword ptr [di]
	fcos
	fstp dword ptr [di-4]
	sub di,8
	add si,4
	dec cx
	jnz rp_sin_cos

	pop cx
	pop si
rp_rotate:
	fld dword ptr [si+4]		; y
	fmul dword ptr [bp-8]		; cos_x
	fld dword ptr [si+8]		; z
	fmul dword ptr [bp-4]		; sin_x
	fsubp st(1),st
	fld dword ptr [si+4]		; y
	fxch st(1)
	fstp dword ptr [si+4]		; Yrotated = Cos (A)*Y - Sin (A)*Z
	fmul dword ptr [bp-4]		; sin_x
	fld dword ptr [si+8]		; z
	fmul dword ptr [bp-8]		; cos_x
	faddp st(1),st
	fstp dword ptr [si+8]		; Zrotated = Sin (A)*Y + Cos (A)*Z
	
	fld dword ptr [si]		; x
	fmul dword ptr [bp-16]		; cos_y
	fld dword ptr [si+8]		; z
	fmul dword ptr [bp-12]		; sin_y
	fsubp st(1),st
	fld dword ptr [si]		; x
	fxch st(1)
	fstp dword ptr [si]		; Xrotated = Cos (A)*X - Sin (A)*Z
	fmul dword ptr [bp-12]		; sin_y
	fld dword ptr [si+8]		; z
	fmul dword ptr [bp-16]		; cos_y
	faddp st(1),st
	fstp dword ptr [si+8]		; Zrotated = Sin (A)*X + Cos (A)*Z
	
	fld dword ptr [si]		; x
	fmul dword ptr [bp-24]		; cos_z
	fld dword ptr [si+4]		; y
	fmul dword ptr [bp-20]		; sin_z
	fsubp st(1),st
	fld dword ptr [si]		; x
	fxch st(1)
	fstp dword ptr [si]		; Xrotated = Cos (A)*X - Sin (A)*Y
	fmul dword ptr [bp-20]		; sin_z
	fld dword ptr [si+4]		; y
	fmul dword ptr [bp-24]		; cos_z
	faddp st(1),st
	fstp dword ptr [si+4]		; Yrotated = Sin (A)*X + Cos (A)*Y

	add si,12
	dec cx
	jnz rp_rotate

	add sp,24
	pop bp
	ret
endp
					
					; si - offset to array of 3d points
					; di - offset to 2d points
					; cx - number of points
translate_points proc
	fld dword ptr [si+8]
	fadd perspective

	fld dword ptr [si]
	fmul perspective
	fdiv st,st(1)
	fadd correct_x
	fistp word ptr [di]		; x2d = (x*persp)/(z+persp)+correct_x

	fld dword ptr [si+4]
	fmul perspective
	fdivrp st(1),st
	fadd correct_y
	fistp word ptr [di+2]		; y2d = (y*persp)/(z+persp)+correct_y

	add si,12
	add di,4
        dec cx
        jnz translate_points
        ret
endp

perspective dd 256.0
correct_x dd 160.0
correct_y dd 100.0