; Mikolaj Felix 16/5/2001, 20/06/2001
; mfelix@polbox.com

.model tiny
.386
.code
org 100h

start:
	finit

	call alloc_screen_buffer
	call init_texture
	call init_sincos
	
	mov ax,13h
	int 10h
	call init_palette

main_loop:
	mov si,offset cube
	mov di,offset cube_rotated
	mov cx,MAX_POINTS*3
copy_object:
	fild word ptr [si]
	fstp dword ptr [di]
	add si,2
	add di,4
	dec cx
	jnz copy_object

	mov si,offset angle_x
	mov di,offset cube_rotated
	mov cx,MAX_POINTS
	call rotate_points
	
	mov si,offset cube_rotated
	mov di,offset coord2d
	mov cx,MAX_POINTS
	call translate_points

	call draw_textured_faces

	call wait_for_frame
	call copy_screen_buffer
	call clear_screen_buffer

	add angle_x,1
	add angle_y,3
	add angle_z,1

	in al,60h
	dec al
	jnz main_loop

	mov ax,03h
	int 10h
	call free_screen_buffer
	mov ax,4c00h
	int 21h

init_texture proc
	mov di,offset texture
	xor dx,dx
it_y:
	xor cx,cx
it_x:
	mov ax,cx
	xor ax,dx
	stosb
	inc cx
	cmp cx,128
	jne it_x
	inc dx
	cmp dx,128
	jne it_y
	ret
endp

init_palette proc
	mov dx,03c8h
	xor ax,ax
	out dx,al
	inc dx
	mov cx,256
ip_color:
	out dx,al
	out dx,al
	out dx,al
	inc ah
	mov al,ah
	shr al,2
	loop ip_color
	ret
endp

draw_textured_faces proc

@@x1 equ [bp-2]
@@y1 equ [bp-4]
@@x2 equ [bp-6]
@@y2 equ [bp-8]
@@x3 equ [bp-10]
@@y3 equ [bp-12]
@@x4 equ [bp-14]
@@y4 equ [bp-16]
	
	push bp
	mov bp,sp
	sub sp,16

	mov si,offset link
	mov cx,MAX_FACES
dtf_loop:
	push cx

	xor bh,bh
	mov bl,byte ptr [si]		; point 1
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov @@x1,ax
	mov ax,word ptr coord2d[bx+2]
	mov @@y1,ax

	xor bh,bh
	mov bl,byte ptr [si+1]		; point 2
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov @@x2,ax
	mov ax,word ptr coord2d[bx+2]
	mov @@y2,ax

	xor bh,bh
	mov bl,byte ptr [si+2]		; point 3
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov @@x3,ax
	mov ax,word ptr coord2d[bx+2]
	mov @@y3,ax

	xor bh,bh			; point 4
	mov bl,byte ptr [si+3]
	shl bx,2
	mov ax,word ptr coord2d[bx]
	mov @@x4,ax
	mov ax,word ptr coord2d[bx+2]
	mov @@y4,ax

	mov ax,@@y1
	sub ax,@@y3
	mov bx,@@x2
	sub bx,@@x1
	imul bx
	shl edx,16
	mov dx,ax
	push edx
	mov ax,@@x1
	sub ax,@@x3
	mov bx,@@y2
	sub bx,@@y1
	imul bx
	shl edx,16
	mov dx,ax
	pop ebx
	sub ebx,edx			; normal_z = (y1-y3)*(x2-x1)-(x1-x3)*(y2-y1)
	or ebx,ebx
	jl dtf_next_face		; normal_z < 0	

	push word ptr 127
	push word ptr 127
	push word ptr 0
	push word ptr 127
	push word ptr 0
	push word ptr 0

	push offset texture
	push word ptr @@y3
	push word ptr @@x3
	push word ptr @@y2
	push word ptr @@x2
	push word ptr @@y1
	push word ptr @@x1
	call textured_triangle

	push word ptr 127
	push word ptr 0
	push word ptr 127
	push word ptr 127
	push word ptr 0
	push word ptr 0

	push offset texture
	push word ptr @@y4
	push word ptr @@x4
	push word ptr @@y3
	push word ptr @@x3
	push word ptr @@y1
	push word ptr @@x1
	call textured_triangle
dtf_next_face:
	add si,4
	pop cx
	dec cx
	jnz dtf_loop

	add sp,16
	pop bp
	ret
endp

include graphlib.asm
include tex3.asm

MAX_POINTS equ 8
MAX_FACES equ 6

angle_x dw 0
angle_y dw 0
angle_z dw 0

cube	dw -50,-50,50, 50,-50,50, 50,50,50, -50,50,50	
	dw -50,-50,-50, 50,-50,-50, 50,50,-50, -50,50,-50

link db 0,1,2,3, 5,4,7,6, 1,5,6,2, 4,0,3,7, 4,5,1,0, 3,2,6,7

include math3d_2.asm

cube_rotated dd MAX_POINTS dup(?,?,?)
coord2d dw MAX_POINTS dup(?,?)

texture db 128*128 dup(?)

end start