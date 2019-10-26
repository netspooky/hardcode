;	Mikolaj Felix 27/06/2001
;	mfelix@polbox.com

.model tiny
.386
.code
org 100h

start:
	call alloc_screen_buffer
	call init_sincos	

	mov ax,13h
	int 10h
	call init_palette

	mov counter,0
main_loop:

	cmp counter,0
	jne c_next
	mov counter,400
	
	call start_points
c_next:
	dec counter

	call move_points
	call draw_points

	call wait_for_frame
	call blur
	call copy_screen_buffer

	in al,60h
	dec al
	jnz main_loop

	mov ax,03h
	int 10h
	call free_screen_buffer
	mov ax,4c00h
	int 21h

blur proc
	push ds
	mov ds,buffer_seg
	xor si,si

	xor eax,eax
	mov cx,320/4
@@clear1:
	mov dword ptr [si],eax
	add si,4
	dec cx
	jnz @@clear1

	xor bx,bx
	mov cx,64000-2*320
@@blur_loop:
	mov al,byte ptr [si-1]
	mov bl,byte ptr [si+1]
	add ax,bx
	mov bl,byte ptr [si-320]
	add ax,bx
	mov bl,byte ptr [si+320]
	add ax,bx
	shr ax,2
	jz @@next
	dec al
	mov byte ptr [si],al
@@next:
	inc si
	dec cx
	jnz @@blur_loop

	xor eax,eax
	mov cx,320/4
@@clear2:
	mov dword ptr [si],eax
	add si,4
	dec cx
	jnz @@clear2

	pop ds
	ret
endp

init_palette proc
	mov dx,03c8h
	xor ax,ax
	out dx,al
	inc dx
	mov cx,64
g_color1:
	xor al,al
	out dx,al
	mov al,ah
	out dx,al
	xor al,al
	out dx,al
	inc ah
	loop g_color1

	xor ax,ax
	mov cx,64
g_color2:
	xor al,al
	out dx,al
	mov al,63
	out dx,al
	mov al,ah
	out dx,al
	inc ah
	loop g_color2

	xor ax,ax
	mov cx,64
g_color3:
	mov al,ah
	out dx,al
	mov al,63
	out dx,al
	out dx,al
	inc ah
	loop g_color3

	mov al,63
	mov cx,64
g_color4:
	out dx,al
	out dx,al
	out dx,al
	loop g_color4
	ret
endp

move_points proc
	mov di,offset points
	mov cx,MAX_POINTS
@@move:
	fld dword ptr [di].x
	fcom min_x
	fstsw ax
	sahf
	jae @@ok1				; x >= min_x
	ffree st
	mov eax,min_x
	mov dword ptr [di].x,eax
	fld dword ptr [di].x
	fld dword ptr [di].vx
	fchs
	fstp dword ptr [di].vx			; vx = vx*(-1)
@@ok1:
	fcom max_x
	fstsw ax
	sahf
	jbe @@ok2				; x <= max_x
	ffree st
	mov eax,max_x
	mov dword ptr [di].x,eax
	fld dword ptr [di].x
	fld dword ptr [di].vx
	fchs
	fstp dword ptr [di].vx			; vx = vx*(-1)
@@ok2:
	fadd dword ptr [di].vx
	fstp dword ptr [di].x			; x+=vx

	fld dword ptr [di].y
	fcom min_y
	fstsw ax
	sahf
	jae @@ok3				; y >= min_y
	ffree st
	mov eax,min_y
	mov dword ptr [di].y,eax
	fld dword ptr [di].y
	fld dword ptr [di].vy
	fchs
	fstp dword ptr [di].vy			; vy = vy*(-1)
@@ok3:
	fcom max_y
	fstsw ax
	sahf
	jbe @@ok4				; y <= max_y
	ffree st
	mov eax,max_y
	mov dword ptr [di].y,eax
	fld dword ptr [di].y
	fld dword ptr [di].vy
	fmul gravity
	fstp dword ptr [di].vy			; vy = vy*(-1)*0.5
@@ok4:
	fadd dword ptr [di].vy
	fstp dword ptr [di].y			; y+=vy

	fld dword ptr [di].vy
	fadd delta_vy
	fstp dword ptr [di].vy			; vy+=delta_vy

	add di,type POINT
	dec cx
	jnz @@move
	ret
endp

draw_points proc

@@temp equ word ptr [bp-2]

	push bp
	mov bp,sp
	sub sp,2

	push es
	mov es,buffer_seg
	mov di,offset points
	mov cx,MAX_POINTS
	mov dx,0ffffh
@@draw:
	fld dword ptr [di].y
	fistp @@temp
	mov bx,@@temp
	mov ax,bx
	shl bx,6
	shl ax,8
	add bx,ax
	fld dword ptr [di].x
	fistp @@temp
	add bx,@@temp
	mov word ptr es:[bx],dx
	mov word ptr es:[bx+320],dx

	add di,type POINT
	dec cx
	jnz @@draw
	pop es

	mov sp,bp
	pop bp
	ret
endp

init_sincos proc

@@angle equ dword ptr [bp-4]
@@delta_a equ dword ptr [bp-8]
	
	push bp
	mov bp,sp
	sub sp,8

	finit
	mov @@temp,MAX_POINTS/2
	fldpi
	fidiv @@temp
	fstp @@delta_a
	mov dword ptr @@angle,0

	xor di,di
	mov cx,MAX_POINTS
isc_loop:
	fld @@angle
	fld st(0)
	fld st(0)
	fsin
	fstp dword ptr sintab[di]
	fcos
	fstp dword ptr costab[di]
	fadd @@delta_a
	fstp @@angle
	add di,4
	dec cx
	jnz isc_loop

	mov sp,bp
	pop bp
	ret
endp

start_points proc

@@temp equ word ptr [bp-2]

	push bp
	mov bp,sp
	sub sp,2

	push word ptr 310
	push word ptr 10
	call random
	push ax
	push word ptr 190
	push word ptr 10
	call random
	pop bx					; ax - y, bx - x

	mov di,offset points
	xor cx,cx
@@init:
	mov @@temp,bx
	fild @@temp
	fstp dword ptr [di].x
	mov @@temp,ax
	fild @@temp
	fstp dword ptr [di].y

	mov si,cx
	shl si,2
	mov edx,dword ptr sintab[si]
	mov dword ptr [di].vx,edx
	mov edx,dword ptr costab[si]
	mov dword ptr [di].vy,edx

	add di,type POINT
	inc cx
	cmp cx,MAX_POINTS
	jne @@init

	mov sp,bp
	pop bp
	ret
endp

random proc

@@min equ word ptr [bp+4]
@@max equ word ptr [bp+6]

	push bp
	mov bp,sp

	mov bx,random_seed
	add bx,9248h
	ror bx,3
	mov random_seed,bx
	mov ax,@@max
	sub ax,@@min
	mul bx
	mov ax,dx
	add ax,@@min				; ax - random number

	pop bp
	ret 4
endp

include graphlib.asm

POINT struc
	x dd ?
	y dd ?
	vx dd ?
	vy dd ?
ends

MAX_POINTS equ 180

min_x dd 5.0
max_x dd 314.0
min_y dd 5.0
max_y dd 194.0
gravity dd -0.5
delta_vy dd 0.01

random_seed dw 1111h
counter dw ?

sintab dd MAX_POINTS dup(?)
costab dd MAX_POINTS dup(?)

points POINT MAX_POINTS dup(?,?)

end start