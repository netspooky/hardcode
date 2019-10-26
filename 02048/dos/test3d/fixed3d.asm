; Mikolaj Felix 25/5/2001
; mfelix@polbox.com

;------------------------------------------------------------
;	ds:si	- offset to angles
;	ds:di	- offset to 3d points
;	cx	- number of points
;------------------------------------------------------------

rotate_points proc

@@sin_x equ word ptr [bp-2]
@@cos_x equ word ptr [bp-4]
@@sin_y equ word ptr [bp-6]
@@cos_y equ word ptr [bp-8]
@@sin_z equ word ptr [bp-10]
@@cos_z equ word ptr [bp-12]

@@x equ word ptr [di]
@@y equ word ptr [di+2]
@@z equ word ptr [di+4]

	push bp
	mov bp,sp
	sub sp,12

	push di
	mov di,bp
	sub di,2
	mov dx,3
rp_sin_cos:
	mov bx,word ptr [si]
	and bx,511
	shl bx,1
	mov ax,word ptr sin_table[bx]
	mov word ptr [di],ax
	mov ax,word ptr cos_table[bx]
	mov word ptr [di-2],ax

	add si,2
	sub di,4
	dec dx
	jnz rp_sin_cos
	pop di

rp_rotate:

	; rotate around x-axis

	mov ax,@@y
	imul @@cos_x
	mov bx,ax
	mov si,dx

	mov ax,@@z
	imul @@sin_x
	sub bx,ax
	sbb si,dx
	shrd bx,si,14
	push bx

	mov ax,@@y
	imul @@sin_x
	mov bx,ax
	mov si,dx

	mov ax,@@z
	imul @@cos_x
	add bx,ax
	adc si,dx
	shrd bx,si,14

	pop @@y
	mov @@z,bx

	; rotate around y-axis

	mov ax,@@x
	imul @@cos_y
	mov bx,ax
	mov si,dx

	mov ax,@@z
	imul @@sin_y
	sub bx,ax
	sbb si,dx
	shrd bx,si,14
	push bx

	mov ax,@@x
	imul @@sin_y
	mov bx,ax
	mov si,dx

	mov ax,@@z
	imul @@cos_y
	add bx,ax
	adc si,dx
	shrd bx,si,14

	pop @@x
	mov @@z,bx

	; rotate around z-axis

	mov ax,@@x
	imul @@cos_z
	mov bx,ax
	mov si,dx

	mov ax,@@y
	imul @@sin_z
	sub bx,ax
	sbb si,dx
	shrd bx,si,14
	push bx

	mov ax,@@x
	imul @@sin_z
	mov bx,ax
	mov si,dx

	mov ax,@@y
	imul @@cos_z
	add bx,ax
	adc si,dx
	shrd bx,si,14

	pop @@x
	mov @@y,bx

	add di,6
	dec cx
	jnz rp_rotate

	mov sp,bp
	pop bp
	ret
endp

;------------------------------------------------------------
;	ds:si	- offset to 3d points
;	es:di	- offset to 2d points
;	cx	- number of points
;------------------------------------------------------------

translate_points proc
	
	mov bx,word ptr [si+4]
	add bx,256

	mov ax,word ptr [si]
	shl ax,8
	cwd
	idiv bx
	add ax,160
	stosw

	mov ax,word ptr [si+2]
	shl ax,8
	cwd
	idiv bx
	add ax,100
	stosw

	add si,6
	dec cx
	jnz translate_points
	ret
endp

init_sin_cos proc
	push bp
	mov bp,sp
	sub sp,4

	finit
	fldz
	fstp dword ptr [bp-4]
	xor di,di
	mov cx,512
isc_make:
	fld dword ptr [bp-4]
	fld st(0)
	fld st(0)
	fsin
	fmul fixed_point_const
	fistp word ptr sin_table[di]
	fcos
	fmul fixed_point_const
	fistp word ptr cos_table[di]

	fadd inc_angle
	fstp dword ptr [bp-4]

	add di,2
	loop isc_make

	mov sp,bp
	pop bp
	ret
endp

fixed_point_const dd 16384.0
inc_angle dd 0.01227184630309			; pi/256

sin_table dw 512 dup(?)
cos_table dw 512 dup(?)