; Mikolaj Felix 14/5/2001
; mfelix@polbox.com

filled_triangle proc

@@x1 equ [bp+4]
@@y1 equ [bp+6]
@@x2 equ [bp+8]
@@y2 equ [bp+10]
@@x3 equ [bp+12]
@@y3 equ [bp+14]
@@col equ [bp+16]

@@dx12 equ [bp-2]
@@dx13 equ [bp-4]
@@dx23 equ [bp-6]

	push bp
	mov bp,sp
	sub sp,6
	push es
	mov es,buffer_seg

	mov ax,@@y1
	cmp ax,@@y3
	jb ft_check1

	xchg ax,@@y3
	mov @@y1,ax

	mov ax,@@x1
	xchg ax,@@x3
	mov @@x1,ax
ft_check1:
	mov ax,@@y2
	cmp ax,@@y3
	jb ft_check2

	xchg ax,@@y3
	mov @@y2,ax

	mov ax,@@x2
	xchg ax,@@x3
	mov @@x2,ax
ft_check2:
	mov ax,@@y1
	cmp ax,@@y2
	jb ft_check3

	xchg ax,@@y2
	mov @@y1,ax

	mov ax,@@x1
	xchg ax,@@x2
	mov @@x1,ax
ft_check3:

	mov bx,@@y2
	sub bx,@@y1
	jnz ft_dx12_make

	mov word ptr @@dx12,0
	jmp ft_dx12_done
ft_dx12_make:
	mov ax,@@x2
	sub ax,@@x1
	shl ax,7
	cwd
	idiv bx
	mov @@dx12,ax			; dx12 = (x2-x1)/(y2-y1)
ft_dx12_done:

	mov bx,@@y3
	sub bx,@@y1
	jnz ft_dx13_make

	mov word ptr @@dx13,0
	jmp ft_dx13_done
ft_dx13_make:
	mov ax,@@x3
	sub ax,@@x1
	shl ax,7
	cwd
	idiv bx
	mov @@dx13,ax			; dx13 = (x3-x1)/(y3-y1)
ft_dx13_done:

	mov bx,@@y3
	sub bx,@@y2
	jnz ft_dx23_make

	mov word ptr @@dx23,0
	jmp ft_dx23_done
ft_dx23_make:
	mov ax,@@x3
	sub ax,@@x2
	shl ax,7
	cwd
	idiv bx
	mov @@dx23,ax			; dx23 = (x3-x2)/(y3-y2)
ft_dx23_done:

	mov ax,@@x1
	shl ax,7
	mov bx,ax
	mov cx,@@y1
ft_loop1:
	push ax
	push cx

	push word ptr @@col
	push cx
	mov dx,bx
	shr dx,7
	push dx
	mov dx,ax
	shr dx,7
	push dx
	call horizontal_line

	pop cx
	pop ax

	add ax,@@dx13
	add bx,@@dx12
	inc cx
	cmp cx,@@y2
	jb ft_loop1

	
	mov bx,@@x2
	shl bx,7
	mov cx,@@y2
ft_loop2:
	push ax
	push cx

	push word ptr @@col
	push cx
	mov dx,bx
	shr dx,7
	push dx
	mov dx,ax
	shr dx,7
	push dx
	call horizontal_line

	pop cx
	pop ax

	add ax,@@dx13
	add bx,@@dx23
	inc cx
	cmp cx,@@y3
	jb ft_loop2

	pop es
	add sp,6
	pop bp
	ret 14
endp

horizontal_line proc

@@x1 equ [bp+4]
@@x2 equ [bp+6]
@@y equ [bp+8]
@@col equ [bp+10]

	push bp
	mov bp,sp

	mov ax,@@x1
	cmp ax,@@x2
	je hl_quit
	jb hl_ok

	xchg ax,@@x2
	mov @@x1,ax
hl_ok:
	mov di,@@y
	mov ax,di
	shl di,6
	shl ax,8
	add di,ax
	add di,@@x1

	mov ax,@@col
	mov ah,al

	cld
	mov cx,@@x2
	sub cx,@@x1
	inc cx
	shr cx,1
	jnc hl_draw
	stosb
hl_draw:
	rep stosw
hl_quit:
	pop bp
	ret 8
endp