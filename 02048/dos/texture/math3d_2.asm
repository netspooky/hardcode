; Mikolaj Felix 20/06/2001
; mfelix@polbox.com

;------------------------------------------------------------
;	ds:si	- offset to angles (int)
;	ds:di	- offset to array of 3d points
;	cx	- number of points
;------------------------------------------------------------

rotate_points proc

@@sin_x equ dword ptr [bp-4]
@@cos_x equ dword ptr [bp-8]
@@sin_y equ dword ptr [bp-12]
@@cos_y equ dword ptr [bp-16]
@@sin_z equ dword ptr [bp-20]
@@cos_z equ dword ptr [bp-24]

@@x equ dword ptr [di]
@@y equ dword ptr [di+4]
@@z equ dword ptr [di+8]

	push bp
	mov bp,sp
	sub sp,24

	push di
	mov di,bp
	sub di,4
	mov dx,3
rp_sin_cos:
	mov bx,word ptr [si]
	and bx,MAX_DEGS-1
	shl bx,2

	mov eax,dword ptr sintab[bx] 	
	mov dword ptr ss:[di],eax

	mov eax,dword ptr costab[bx]
	mov dword ptr ss:[di-4],eax

	sub di,8
	add si,2
	dec dx
	jnz rp_sin_cos
	pop di

rp_rotate:
	fld @@y
	fmul @@cos_x
	fld @@z
	fmul @@sin_x
	fsubp st(1),st
	fld @@y
	fxch st(1)
	fstp @@y			; Yrotated = Cos (A)*Y - Sin (A)*Z
	fmul @@sin_x
	fld @@z
	fmul @@cos_x
	faddp st(1),st
	fstp @@z			; Zrotated = Sin (A)*Y + Cos (A)*Z
	
	fld @@x
	fmul @@cos_y
	fld @@z
	fmul @@sin_y
	fsubp st(1),st
	fld @@x
	fxch st(1)
	fstp @@x			; Xrotated = Cos (A)*X - Sin (A)*Z
	fmul @@sin_y
	fld @@z
	fmul @@cos_y
	faddp st(1),st
	fstp @@z			; Zrotated = Sin (A)*X + Cos (A)*Z
	
	fld @@x
	fmul @@cos_z
	fld @@y
	fmul @@sin_z
	fsubp st(1),st
	fld @@x
	fxch st(1)
	fstp @@x			; Xrotated = Cos (A)*X - Sin (A)*Y
	fmul @@sin_z
	fld @@y
	fmul @@cos_z
	faddp st(1),st
	fstp @@y			; Yrotated = Sin (A)*X + Cos (A)*Y

	add di,12
	dec cx
	jnz rp_rotate

	mov sp,bp
	pop bp
	ret
endp
					
;------------------------------------------------------------
;	ds:si	- offset to array of 3d points
;	ds:di	- offset to 2d points
;	cx	- number of points
;------------------------------------------------------------

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

init_sincos proc

@@temp1 equ dword ptr [bp-4]
@@temp2 equ dword ptr [bp-8]

	push bp
	mov bp,sp
	sub sp,8

	mov @@temp1,0
	fldpi
	mov @@temp2,MAX_DEGS/2
	fidiv @@temp2
	fstp @@temp2

	xor di,di
	mov cx,MAX_DEGS
isc_loop:
	fld @@temp1
	fld st(0)
	fld st(0)
	fsin
	fstp dword ptr sintab[di]
	fcos
	fstp dword ptr costab[di]
	fadd @@temp2
	fstp @@temp1

	add di,4
	dec cx
	jnz isc_loop
	
	mov sp,bp
	pop bp
	ret
endp

MAX_DEGS equ 512

perspective dd 256.0
correct_x dd 160.0
correct_y dd 100.0

sintab dd MAX_DEGS dup(?)
costab dd MAX_DEGS dup(?)