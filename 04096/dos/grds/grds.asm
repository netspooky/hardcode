; Mikolaj Felix 30/04/2001
; mfelix@polbox.com

.model tiny
.386c
.code
org 100h

start:
	finit
	mov ax,cs
	mov ds,ax
	mov es,ax
	call alloc_screen_buffer
	
	mov ax,13h
	int 10h
	call init_palette
main_loop:
	mov si,offset cube
	mov di,offset cube_rotated
	mov cx,MAX_POINTS*3
	cld
	rep movsd

	mov si,offset angle_x
	mov di,offset cube_rotated
	mov cx,MAX_POINTS
	call rotate_points
	
	mov si,offset cube_rotated
	mov di,offset coord2d
	mov cx,MAX_POINTS
	call translate_points
	
	call draw_faces
	call copy_screen_buffer
	call clear_screen_buffer
	call wait_for_frame

	fld angle_x
	fadd inc_angle
	fstp angle_x
	fld angle_y
	fadd inc_angle
	fadd inc_angle
	fadd inc_angle
	fstp angle_y
	fld angle_z
	fadd inc_angle
	fstp angle_z

	in al,60h
	cmp al,1
	jne main_loop

	mov ax,03h
	int 10h
	call free_screen_buffer
	mov ah,4ch
	int 21h
	ret

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

draw_faces proc
	mov si,offset cube_rotated
	mov di,offset colors
	mov cx,MAX_POINTS
dw_compute_color:
	fld dword ptr [si+8]		; coord_z
	frndint
	fchs
	fistp word ptr [di]
	add word ptr [di],64
	add si,12
	add di,2
	dec cx
	jnz dw_compute_color

	push bp
	mov bp,sp
	sub sp,16			; locals

	mov cx,MAX_FACES
	mov si,offset faces
dw_face_loop:
	mov bx,word ptr [si]
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov word ptr [bp-2],ax		; x1
	mov ax,word ptr coord2d[bx+2]
	mov word ptr [bp-4],ax		; y1

	mov bx,word ptr [si+2]
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov word ptr [bp-6],ax		; x2
	mov ax,word ptr coord2d[bx+2]
	mov word ptr [bp-8],ax		; y2

	mov bx,word ptr [si+4]
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov word ptr [bp-10],ax		; x3
	mov ax,word ptr coord2d[bx+2]
	mov word ptr [bp-12],ax		; y3

	mov bx,word ptr [si+6]
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov word ptr [bp-14],ax		; x4
	mov ax,word ptr coord2d[bx+2]
	mov word ptr [bp-16],ax		; y4

					; check if face is visible

	mov ax,word ptr [bp-4]		; y1
	sub ax,word ptr [bp-12]		; y3	ax = (y1-y3)
	mov bx,word ptr [bp-6]		; x2
	sub bx,word ptr [bp-2]		; x1	bx = (x2-x1)
	imul bx
	shl edx,16
	mov dx,ax
	push edx			; edx = (y1-y3)*(x2-x1)
	mov ax,word ptr [bp-2]		; x1
	sub ax,word ptr [bp-10]		; x3	ax = (x1-x3)
	mov bx,word ptr [bp-8]		; y2
	sub bx,word ptr [bp-4]		; y1	bx = (y2-y1)
	imul bx
	shl edx,16
	mov dx,ax			; edx = (x1-x3)*(y2-y1)
	pop ebx
	sub ebx,edx
	cmp ebx,0			; normal_z = (y1-y3)*(x2-x1)-(x1-x3)*(y2-y1)
	jge dw_next_face		; normal_z >= 0

	push cx
					; push arguments
	mov bx,word ptr [si+6]
	shl bx,1
	push word ptr colors[bx]	; k4
	mov bx,word ptr [si+4]
	shl bx,1
	push word ptr colors[bx]	; k3
	mov bx,word ptr [si+2]
	shl bx,1
	push word ptr colors[bx]	; k2
	mov bx,word ptr [si]
	shl bx,1
	push word ptr colors[bx]	; k1

	push word ptr [bp-16]		; y4
	push word ptr [bp-14]		; x4
	push word ptr [bp-12]		; y3
	push word ptr [bp-10]		; x3
	push word ptr [bp-8]		; y2
	push word ptr [bp-6]		; x2
	push word ptr [bp-4]		; y1
	push word ptr [bp-2]		; x1
	
	call draw_grds_polygon

	pop cx
dw_next_face:
	add si,8
	dec cx
	jnz dw_face_loop

	add sp,16
	pop bp
	ret
endp

include math3d.asm
include graphlib.asm
include grds_pol.asm

MAX_POINTS equ 8
MAX_FACES equ 6

inc_angle dd 0.01745329252			; 1rad = pi/180

angle_x dd 0.0
angle_y dd 0.0
angle_z dd 0.0

even

cube	dd -50.0,-50.0,-50.0, 50.0,-50.0,-50.0, -50.0,50.0,-50.0, 50.0,50.0,-50.0
	dd -50.0,-50.0,50.0, 50.0,-50.0,50.0, -50.0,50.0,50.0, 50.0,50.0,50.0

faces dw 0,1,3,2, 1,5,7,3, 4,6,7,5, 0,2,6,4, 0,4,5,1, 2,3,7,6
colors dw MAX_POINTS dup(?)

cube_rotated dd MAX_POINTS dup(?,?,?)
coord2d dw MAX_POINTS dup(?,?)

end start