; Mikolaj Felix 1/05/2001
; mfelix@polbox.com

.model tiny
.386
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

	call make_random
	mov si,offset model_object
	mov di,offset current_object
	mov cx,MAX_POINTS*3
	cld
	rep movsd

	call make_circle
main_loop:
	mov si,offset text1
	mov ah,31
	mov cx,160-(28*8)/2
	xor dx,dx
	call put_string
	mov si,offset text2
	mov ah,31
	mov cx,160-(17*8)/2
	mov dx,191
	call put_string

	inc morph_counter
	cmp morph_counter,600
	jb m_continue
	mov morph_counter,0

	cmp morph_number,0
	je morph1
	cmp morph_number,1
	je morph2
	cmp morph_number,2
	je morph3

	call make_circle
	mov morph_number,0
	jmp m_continue
morph1:
	call make_random
	mov morph_number,1
	jmp m_continue
morph2:
	call make_spiral
	mov morph_number,2
	jmp m_continue
morph3:
	call make_cube
	mov morph_number,3
m_continue:
	call morph_object

	mov si,offset current_object
	mov di,offset rotated_object
	mov cx,MAX_POINTS*3
	cld
	rep movsd

	mov si,offset angle_x
	mov di,offset rotated_object
	mov cx,MAX_POINTS
	call rotate_points

	mov si,offset rotated_object
	mov di,offset coord2d
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

	call copy_screen_buffer
	call clear_screen_buffer
	call wait_for_frame
	in al,60h
	cmp al,1
	jne main_loop

	mov ax,03h
	int 10h
	call free_screen_buffer
	mov ax,4c00h
	int 21h
	ret

draw_points proc
	push es
	mov es,buffer_seg

	mov si,offset coord2d
	mov cx,MAX_POINTS
	mov dx,1f1fh			; dl = 31d, dh = 31d
dp_loop:
	mov bx,word ptr [si+2]
	cmp bx,0
	jb dp_next
	cmp bx,198
	ja dp_next
	
	mov ax,word ptr [si]
	cmp ax,0
	jb dp_next
	cmp ax,318
	ja dp_next

	mov di,bx
	shl bx,6
	shl di,8
	add bx,di
	add bx,ax

	mov word ptr es:[bx],dx
	mov word ptr es:[bx+320],dx
dp_next:
	add si,4
	dec cx
	jnz dp_loop
	pop es
	ret
endp

morph_object proc
	push bp
	mov bp,sp
	sub sp,2			; bp-2 status of copro

	mov si,offset model_object
	mov di,offset current_object
	mov cx,MAX_POINTS*3
mo_loop:
	fld dword ptr [di]
	fcom dword ptr [si]
	fstsw word ptr [bp-2]
	mov ah,byte ptr [bp-1]
	sahf
	ja mo_dec_coord
	jb mo_inc_coord
	jmp mo_write

mo_dec_coord:
	fsub delta_coord
	jmp mo_write
mo_inc_coord:
	fadd delta_coord

mo_write:
	fstp dword ptr [di]
	add si,4
	add di,4
	dec cx
	jnz mo_loop

	add sp,2
	pop bp
	ret
endp

make_circle proc
	push bp
	mov bp,sp
	sub sp,4			; bp-4 angle

	mov dword ptr [bp-4],0

	mov si,offset model_object
	mov cx,MAX_POINTS
mc_loop:
	fld dword ptr [bp-4]
	fld st(0)
	fld st(0)
	fsin
	fmul circle_radius
	fstp dword ptr [si]
	fcos
	fmul circle_radius
	fstp dword ptr [si+4]

	mov dword ptr [si+8],0

	fadd circle_inc_angle
	fstp dword ptr [bp-4]

	cmp cx,(MAX_POINTS/2)+1
	jb mc_next

	mov eax,dword ptr [si+4]
	mov dword ptr [si+8],eax
	mov dword ptr [si+4],0
mc_next:
	add si,12
	dec cx
	jnz mc_loop

	add sp,4
	pop bp
	ret
endp

make_random proc
	push bp
	mov bp,sp
	sub sp,2			; bp-2 temp value
	
	mov si,offset model_object
	mov cx,MAX_POINTS*3
mr_loop:
	push word ptr 50
	push word ptr -50
	call random
	mov word ptr [bp-2],ax
	fild word ptr [bp-2]
	fstp dword ptr [si]
	add si,4
	dec cx
	jnz mr_loop

	add sp,2
	pop bp
	ret
endp

make_spiral proc
	push bp
	mov bp,sp
	sub sp,8			; bp-4 angle
					; bp-8 z coordinate
	mov dword ptr [bp-4],0
	fld spiral_start_z
	fstp dword ptr [bp-8]

	mov si,offset model_object
	mov cx,MAX_POINTS
ms_loop:
	fld dword ptr [bp-4]
	fld st(0)
	fld st(0)
	fsin
	fmul spiral_radius
	fstp dword ptr [si]
	fcos
	fmul spiral_radius
	fstp dword ptr [si+4]

	fadd spiral_inc_angle
	fstp dword ptr [bp-4]

	fld dword ptr [bp-8]
	fld st(0)
	fstp dword ptr [si+8]
	
	fadd spiral_inc_z
	fstp dword ptr [bp-8]

	add si,12
	dec cx
	jnz ms_loop

	add sp,8
	pop bp
	ret
endp

make_cube proc
	push bp
	mov bp,sp
	sub sp,12
					; bp-4  coordinate x
					; bp-8  y
					; bp-12 z
	mov si,offset model_object

	fld cube_start_coord
	fstp dword ptr [bp-4]		; start x
	mov cx,5
mc_loop_x:
	fld cube_start_coord
	fstp dword ptr [bp-8]		; start y
	push cx
	mov cx,5
mc_loop_y:
	fld cube_start_coord
	fstp dword ptr [bp-12]		; start z
	push cx
	mov cx,5
mc_loop_z:
	fld dword ptr [bp-4]
	fstp dword ptr [si]		; write x

	fld dword ptr [bp-8]
	fstp dword ptr [si+4]		; write y

	fld dword ptr [bp-12]
	fld st(0)
	fstp dword ptr [si+8]		; write z
	fadd cube_inc_coord		; update z
	fstp dword ptr [bp-12]

	add si,12
	dec cx
	jnz mc_loop_z

	fld dword ptr [bp-8]
	fadd cube_inc_coord		; update y
	fstp dword ptr [bp-8]
	pop cx
	dec cx
	jnz mc_loop_y

	fld dword ptr [bp-4]
	fadd cube_inc_coord		; update x
	fstp dword ptr [bp-4]
	pop cx
	dec cx
	jnz mc_loop_x

	add sp,12
	pop bp
	ret
endp

random proc				; +4 min, +6 max
	push bp
	mov bp,sp

	mov bx,random_seed
	add bx,9248h
	ror bx,3
	mov random_seed,bx
	mov ax,word ptr [bp+6]
	sub ax,word ptr [bp+4]
	mul bx
	mov ax,dx
	add ax,word ptr [bp+4]		; ax - random number

	pop bp
	ret 4
endp

include graphlib.asm
include math3d.asm
include font.asm

MAX_POINTS equ 125

text1 db '3D MORPHING BY MIKOLAJ FELIX',0
text2 db 'MFELIX@POLBOX.COM',0

morph_counter dw 0
morph_number dw 0

angle_x dd 0.0
angle_y dd 0.0
angle_z dd 0.0

inc_angle dd 0.0174533
delta_coord dd 0.4

circle_radius dd 75.0
circle_inc_angle dd 0.100530965		; 360/MAX_POINTS*2*PI/180

spiral_radius dd 20.0
spiral_start_z dd -125.0
spiral_inc_z dd 2.0
spiral_inc_angle dd 0.628319		; 0.0628319*10

cube_inc_coord dd 20.0
cube_start_coord dd -40.0

random_seed dw ?

even

model_object dd MAX_POINTS dup(?,?,?)
current_object dd MAX_POINTS dup(?,?,?)
rotated_object dd MAX_POINTS dup(?,?,?)

coord2d dw MAX_POINTS dup(?,?)

end start