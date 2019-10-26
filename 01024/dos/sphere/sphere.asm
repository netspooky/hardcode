; Mikolaj Felix 18/5/2001
; mfelix@polbox.com

.model tiny
.386
.code
org 100h

start:
	finit
	call alloc_screen_buffer
	call init_sphere

	mov ax,13h
	int 10h
	call init_palette
main_loop:
	mov si,offset sphere
	mov di,offset sphere_rotated
	mov cx,MAX_POINTS*3
	cld
	rep movsd

	mov si,offset angle_x
	mov di,offset sphere_rotated
	mov cx,MAX_POINTS
	call rotate_points

	mov si,offset sphere_rotated
	mov di,offset sphere_translated
	mov cx,MAX_POINTS
	call translate_points

	call draw_points

	fld angle_x
	fadd inc_angle
	fstp angle_x
	fld angle_y
	fadd inc_angle
	fstp angle_y
	fld angle_z
	fadd inc_angle
	fstp angle_z

	call wait_for_frame
	call copy_screen_buffer
	call clear_screen_buffer
	in al,60h
	dec al
	jnz main_loop

	mov ax,03h
	int 10h
	call free_screen_buffer
	mov ax,4c00h
	int 21h

draw_points proc

@@tmp16 equ word ptr [bp-2]

	push bp
	mov bp,sp
	sub sp,2

	push es
	mov es,buffer_seg
	mov si,offset sphere_rotated
	mov di,offset sphere_translated
	mov cx,MAX_POINTS
dp_draw:
	fld dword ptr [si+8]
	frndint
	fchs
	fistp @@tmp16
	mov ax,@@tmp16
	add ax,100
	mov ah,al

	mov bx,word ptr [di+2]
	mov dx,bx
	shl bx,6
	shl dx,8
	add bx,dx
	add bx,word ptr [di]
	mov word ptr es:[bx],ax
	mov word ptr es:[bx+320],ax

	add si,12
	add di,4
	dec cx
	jnz dp_draw

	pop es
	add sp,2
	pop bp
	ret
endp

init_palette proc
	mov dx,03c8h
	xor ax,ax
	out dx,al
	inc dx
	mov cx,256
next_color:
	out dx,al
	out dx,al
	out dx,al
	inc ah
	mov al,ah
	shr al,2
	dec cx
	jnz next_color
	ret
endp

init_sphere proc

@@sph_angle1 equ dword ptr [bp-4]
@@sph_angle2 equ dword ptr [bp-8]
	
	push bp
	mov bp,sp
	sub sp,8

	mov si,offset sphere
	mov cx,MAX_POINTS/20
	fldz
	fstp @@sph_angle1
is_circle:
	push cx
	mov cx,MAX_POINTS/20
	fldz
	fstp @@sph_angle2
is_make_circle:
	fld @@sph_angle2
	fld st(0)
	fsin
	fmul sph_radius
	fstp dword ptr [si]
	fcos
	fmul sph_radius
	fstp dword ptr [si+4]

	fld @@sph_angle1
	fld st(0)
	fcos
	fmul dword ptr [si]
	fxch st(1)
	fsin
	fmul dword ptr [si]
	fstp dword ptr [si+8]
	fstp dword ptr [si]

	fld @@sph_angle2
	fadd sph_inc_angle
	fstp @@sph_angle2

	add si,12
	loop is_make_circle

	fld @@sph_angle1
	fadd sph_inc_angle
	fstp @@sph_angle1
	pop cx
	loop is_circle

	mov sp,bp
	pop bp
	ret
endp

include graphlib.asm
include math3d.asm

MAX_POINTS equ 400

sph_radius dd 80.0
sph_inc_angle dd 0.3490658503989		; (pi/180)*sqrt(MAX_POINTS)

inc_angle dd 0.0174532925199
angle_x dd 0.0
angle_y dd 0.0
angle_z dd 0.0

sphere dd MAX_POINTS dup(?,?,?)
sphere_rotated dd MAX_POINTS dup(?,?,?)
sphere_translated dw MAX_POINTS dup(?,?)

end start