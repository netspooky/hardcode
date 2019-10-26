; Mikolaj Felix 15/5/2001
; mfelix@polbox.com

textured_triangle proc

@@x1 equ [bp+4]
@@y1 equ [bp+6]
@@x2 equ [bp+8]
@@y2 equ [bp+10]
@@x3 equ [bp+12]
@@y3 equ [bp+14]

@@tex_off equ [bp+16]
@@tex_x1 equ [bp+18]
@@tex_y1 equ [bp+20]
@@tex_x2 equ [bp+22]
@@tex_y2 equ [bp+24]
@@tex_x3 equ [bp+26]
@@tex_y3 equ [bp+28]

@@dx12 equ [bp-2]
@@dx13 equ [bp-4]
@@dx23 equ [bp-6]

@@tex_dx12 equ [bp-8]
@@tex_dy12 equ [bp-10]
@@tex_dx13 equ [bp-12]
@@tex_dy13 equ [bp-14]
@@tex_dx23 equ [bp-16]
@@tex_dy23 equ [bp-18]

@@scan_x1 equ [bp-20]
@@scan_y1 equ [bp-22]
@@scan_x2 equ [bp-24]
@@scan_y2 equ [bp-26]

	push bp
	mov bp,sp
	sub sp,26
	push es
	mov es,buffer_seg

	mov ax,@@y1
	cmp ax,@@y3
	jb tt_check1

	xchg ax,@@y3
	mov @@y1,ax

	mov ax,@@x1
	xchg ax,@@x3
	mov @@x1,ax

	mov ax,@@tex_y1
	xchg ax,@@tex_y3
	mov @@tex_y1,ax

	mov ax,@@tex_x1
	xchg ax,@@tex_x3
	mov @@tex_x1,ax
tt_check1:
	mov ax,@@y2
	cmp ax,@@y3
	jb tt_check2

	xchg ax,@@y3
	mov @@y2,ax

	mov ax,@@x2
	xchg ax,@@x3
	mov @@x2,ax

	mov ax,@@tex_y2
	xchg ax,@@tex_y3
	mov @@tex_y2,ax

	mov ax,@@tex_x2
	xchg ax,@@tex_x3
	mov @@tex_x2,ax
tt_check2:
	mov ax,@@y1
	cmp ax,@@y2
	jb tt_check3

	xchg ax,@@y2
	mov @@y1,ax

	mov ax,@@x1
	xchg ax,@@x2
	mov @@x1,ax

	mov ax,@@tex_y1
	xchg ax,@@tex_y2
	mov @@tex_y1,ax

	mov ax,@@tex_x1
	xchg ax,@@tex_x2
	mov @@tex_x1,ax
tt_check3:

	mov bx,@@y2
	sub bx,@@y1
	jnz tt_dx12_make

	mov word ptr @@dx12,0
	mov word ptr @@tex_dx12,0
	mov word ptr @@tex_dy12,0
	jmp tt_dx12_done
tt_dx12_make:
	mov ax,@@x2
	sub ax,@@x1
	shl ax,7
	cwd
	idiv bx
	mov @@dx12,ax			; dx12 = (x2-x1)/(y2-y1)

	mov ax,@@tex_x2
	sub ax,@@tex_x1
	shl ax,7
	cwd
	idiv bx
	mov @@tex_dx12,ax		; tex_dx12 = (tex_x2-tex_x1)/(y2-y1)

	mov ax,@@tex_y2
	sub ax,@@tex_y1
	shl ax,7
	cwd
	idiv bx
	mov @@tex_dy12,ax		; tex_dy12 = (tex_y2-tex_y1)/(y2-y1)
tt_dx12_done:

	mov bx,@@y3
	sub bx,@@y1
	jnz tt_dx13_make

	mov word ptr @@dx13,0
	mov word ptr @@tex_dx13,0
	mov word ptr @@tex_dy13,0
	jmp tt_dx13_done
tt_dx13_make:
	mov ax,@@x3
	sub ax,@@x1
	shl ax,7
	cwd
	idiv bx
	mov @@dx13,ax			; dx13 = (x3-x1)/(y3-y1)

	mov ax,@@tex_x3
	sub ax,@@tex_x1
	shl ax,7
	cwd
	idiv bx
	mov @@tex_dx13,ax		; tex_dx13 = (tex_x3-tex_x1)/(y3-y1)

	mov ax,@@tex_y3
	sub ax,@@tex_y1
	shl ax,7
	cwd
	idiv bx
	mov @@tex_dy13,ax		; tex_dy13 = (tex_y3-tex_x1)/(y3-y1)
tt_dx13_done:

	mov bx,@@y3
	sub bx,@@y2
	jnz tt_dx23_make

	mov word ptr @@dx23,0
	mov word ptr @@tex_dx23,0
	mov word ptr @@tex_dy23,0
	jmp tt_dx23_done
tt_dx23_make:
	mov ax,@@x3
	sub ax,@@x2
	shl ax,7
	cwd
	idiv bx
	mov @@dx23,ax			; dx23 = (x3-x2)/(y3-y2)

	mov ax,@@tex_x3
	sub ax,@@tex_x2
	shl ax,7
	cwd
	idiv bx
	mov @@tex_dx23,ax		; tex_dx23 = (tex_x3-tex_x2)/(y3-y2)

	mov ax,@@tex_y3
	sub ax,@@tex_y2
	shl ax,7
	cwd
	idiv bx
	mov @@tex_dy23,ax		; tex_dy23 = (tex_y3-tex_y2)/(y3-y2)
tt_dx23_done:


	mov ax,@@x1
	shl ax,7
	mov bx,ax
	mov cx,@@y1

	mov dx,@@tex_x1
	shl dx,7
	mov @@scan_x1,dx
	mov @@scan_x2,dx
	mov dx,@@tex_y1
	shl dx,7
	mov @@scan_y1,dx
	mov @@scan_y2,dx
tt_loop1:
	push ax
	push bx
	push cx

	mov dx,@@scan_y2
	shr dx,7
	push dx
	mov dx,@@scan_x2
	shr dx,7
	push dx
	mov dx,@@scan_y1
	shr dx,7
	push dx
	mov dx,@@scan_x1
	shr dx,7
	push dx
	push word ptr @@tex_off

	push cx
	mov dx,bx
	shr dx,7
	push dx
	mov dx,ax
	shr dx,7
	push dx
	call textured_horizontal_line

	pop cx
	pop bx
	pop ax

	mov dx,@@tex_dx13
	add @@scan_x1,dx
	mov dx,@@tex_dx12
	add @@scan_x2,dx
	mov dx,@@tex_dy13
	add @@scan_y1,dx
	mov dx,@@tex_dy12
	add @@scan_y2,dx

	add ax,@@dx13
	add bx,@@dx12
	inc cx
	cmp cx,@@y2
	jb tt_loop1

	mov bx,@@x2
	shl bx,7
	mov cx,@@y2

	mov dx,@@tex_x2
	shl dx,7
	mov @@scan_x2,dx
	mov dx,@@tex_y2
	shl dx,7
	mov @@scan_y2,dx
tt_loop2:
	push ax
	push bx
	push cx

	mov dx,@@scan_y2
	shr dx,7
	push dx
	mov dx,@@scan_x2
	shr dx,7
	push dx
	mov dx,@@scan_y1
	shr dx,7
	push dx
	mov dx,@@scan_x1
	shr dx,7
	push dx
	push word ptr @@tex_off

	push cx
	mov dx,bx
	shr dx,7
	push dx
	mov dx,ax
	shr dx,7
	push dx
	call textured_horizontal_line

	pop cx
	pop bx
	pop ax

	mov dx,@@tex_dx13
	add @@scan_x1,dx
	mov dx,@@tex_dx23
	add @@scan_x2,dx
	mov dx,@@tex_dy13
	add @@scan_y1,dx
	mov dx,@@tex_dy23
	add @@scan_y2,dx

	add ax,@@dx13
	add bx,@@dx23
	inc cx
	cmp cx,@@y3
	jb tt_loop2

	pop es
	add sp,26
	pop bp
	ret 26
endp

textured_horizontal_line proc
	
@@x1 equ [bp+4]
@@x2 equ [bp+6]
@@y equ [bp+8]

@@tex_off equ [bp+10]
@@tex_x1 equ [bp+12]
@@tex_y1 equ [bp+14]
@@tex_x2 equ [bp+16]
@@tex_y2 equ [bp+18]

@@tex_dx equ [bp-2]
@@tex_dy equ [bp-4]

	push bp
	mov bp,sp
	sub sp,4

	mov ax,@@x1
	cmp ax,@@x2
	je thl_quit
	jb thl_ok

	xchg ax,@@x2
	mov @@x1,ax

	mov ax,@@tex_x1
	xchg ax,@@tex_x2
	mov @@tex_x1,ax

	mov ax,@@tex_y1
	xchg ax,@@tex_y2
	mov @@tex_y1,ax
thl_ok:
	mov di,@@y
	mov ax,di
	shl di,6
	shl ax,8
	add di,ax
	add di,@@x1

	mov cx,@@x2
	sub cx,@@x1

	mov ax,@@tex_x2
	sub ax,@@tex_x1
	shl ax,7
	cwd
	idiv cx
	mov @@tex_dx,ax			; tex_dx = (tex_x2-tex_x1)/(x2-x1)

	mov ax,@@tex_y2
	sub ax,@@tex_y1
	shl ax,7
	cwd
	idiv cx
	mov @@tex_dy,ax			; tex_dy = (tex_y2-tex_y1)/(x2-x1)

	cld
	inc cx
	mov ax,@@tex_x1
	shl ax,7
	mov bx,@@tex_y1
	shl bx,7
thl_loop:
	mov dx,ax
	push bx

	and bx,0ff80h
	shr ax,7
	add bx,ax
	add bx,@@tex_off
	mov al,byte ptr [bx]
	stosb

	pop bx
	mov ax,dx

	add ax,@@tex_dx
	add bx,@@tex_dy
	dec cx
	jnz thl_loop
thl_quit:
	add sp,4
	pop bp
	ret 16
endp