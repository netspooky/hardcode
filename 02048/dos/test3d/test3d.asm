; Mikolaj Felix 25/5/2001
; mfelix@polbox.com

.model tiny
.386
.code
org 100h

start:
	call init_sin_cos
	call alloc_screen_buffer
	mov ax,13h
	int 10h
main_loop:
	mov si,offset object
	mov di,offset object_rotated
	mov cx,MAX_POINTS*3
	cld
	rep movsw

	mov si,offset angle_x
	mov di,offset object_rotated
	mov cx,MAX_POINTS
	call rotate_points

	mov si,offset object_rotated
	mov di,offset object_translated
	mov cx,MAX_POINTS
	call translate_points

	call draw_faces

	call wait_for_frame
	call copy_screen_buffer
	call clear_screen_buffer

	add angle_x,2
	add angle_y,3
	add angle_z,1

	in al,60h
	cmp al,1
	jne main_loop

	mov ax,03h
	int 10h
	call free_screen_buffer
	mov ax,4c00h
	int 21h

draw_faces proc

@@x1 equ word ptr [bp-2]
@@y1 equ word ptr [bp-4]
@@x2 equ word ptr [bp-6]
@@y2 equ word ptr [bp-8]
@@x3 equ word ptr [bp-10]
@@y3 equ word ptr [bp-12]

	push bp
	mov bp,sp
	sub sp,12

	mov si,offset link
	mov cx,MAX_FACES
df_draw:
	push cx
	mov cx,3
	mov di,bp
	sub di,2
df_get_point:
	xor bh,bh
	mov bl,byte ptr [si]
	shl bx,2
	mov ax,word ptr object_translated[bx]
	mov word ptr ss:[di],ax
	mov ax,word ptr object_translated[bx+2]
	mov word ptr ss:[di-2],ax
	inc si
	sub di,4
	dec cx
	jnz df_get_point

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
	sub ebx,edx
	or ebx,ebx
	jge df_next

	xor ah,ah
	mov al,byte ptr [si]
	
	push ax
	push @@y3
	push @@x3
	push @@y2
	push @@x2
	push @@y1
	push @@x1
	call filled_triangle
df_next:
	inc si
	pop cx
	dec cx
	jnz df_draw

	mov sp,bp
	pop bp
	ret
endp

include graphlib.asm
include triangle.asm

MAX_POINTS equ 8
MAX_FACES equ 12

angle_x dw 0
angle_y dw 0
angle_z dw 0

object	dw -50,-50,-50, 50,-50,-50, 50,50,-50, -50,50,-50
	dw -50,-50,50, 50,-50,50, 50,50,50, -50,50,50

link	db 0,1,2,45, 0,2,3,45, 5,4,7,32, 5,7,6,32, 1,5,6,40, 1,6,2,40
	db 4,0,3,80, 4,3,7,80, 4,5,1,60, 1,0,4,60, 3,2,6,94, 3,6,7,94

include fixed3d.asm

object_rotated dw MAX_POINTS dup(?,?,?)
object_translated dw MAX_POINTS dup(?,?)

end start