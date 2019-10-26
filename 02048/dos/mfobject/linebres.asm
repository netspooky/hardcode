; Mikolaj Felix 5/5/2001
; mfelix@polbox.com
					; +4  x1
					; +6  y1
					; +8  x2
					; +10 y2
					; +12 color
draw_line proc
	push bp
	mov bp,sp
	sub sp,12
					; bp-2 inc1_d
					; bp-4 inc2_d
					; bp-6 inc1_x
					; bp-8 inc2_x
					; bp-10 inc1_y
					; bp-12 inc2_y
	push ds
	mov ds,buffer_seg

	mov ax,word ptr [bp+8]		; x2
	sub ax,word ptr [bp+4]		; x1
	cwd
	xor ax,dx
	sub ax,dx
	mov bx,ax			; bx = delta_x

	mov ax,word ptr [bp+10]		; y2
	sub ax,word ptr [bp+6]		; y1
	cwd
	xor ax,dx
	sub ax,dx			; ax = delta_y

	cmp bx,ax			; cmp delta_x,delta_y
	jb dl_bigger_delta_y

	mov dx,ax
	shl dx,1
	mov word ptr [bp-2],dx		; inc1_d = delta_y*2

	sub dx,bx			; dx = delta = (delta_y*2)-delta_x

	mov cx,ax
	sub cx,bx
	shl cx,1
	mov word ptr [bp-4],cx		; inc2_d = (delta_y-delta_x)*2

	mov cx,bx
	inc cx				; lenght of line

	mov word ptr [bp-6],1		; inc1_x
	mov word ptr [bp-8],1		; inc2_x
	mov word ptr [bp-10],0		; inc1_y
	mov word ptr [bp-12],1		; inc2_y

	jmp dl_check_xy

dl_bigger_delta_y:

	mov dx,bx
	shl dx,1
	mov word ptr [bp-2],dx		; inc1_d = delta_x*2

	sub dx,ax			; dx = delta = (delta_x*2)-delta_y
	
	mov cx,bx
	sub cx,ax
	shl cx,1
	mov word ptr [bp-4],cx		; inc2_d = (delta_x-delta_y)*2

	mov cx,ax
	inc cx

	mov word ptr [bp-6],0		; inc1_x
	mov word ptr [bp-8],1		; inc2_x
	mov word ptr [bp-10],1		; inc1_y
	mov word ptr [bp-12],1		; inc2_y

dl_check_xy:

	mov ax,word ptr [bp+4]		; x1
	cmp ax,word ptr [bp+8]		; x2
	jl dl_ok_x			; x1 < x2
	
	neg word ptr [bp-6]		; inc1_x
	neg word ptr [bp-8]		; inc2_x
dl_ok_x:
	mov ax,word ptr [bp+6]		; y1
	cmp ax,word ptr [bp+10]		; y2
	jl dl_ok_y			; y1 < y2

	neg word ptr [bp-10]		; inc1_y
	neg word ptr [bp-12]		; inc2_y
dl_ok_y:

	mov ax,word ptr [bp+4]		; x
	mov bx,word ptr [bp+6]		; y
dl_loop:
	or ax,ax
	jl dl_next_pixel
	cmp ax,319
	jg dl_next_pixel
	or bx,bx
	jl dl_next_pixel
	cmp bx,199
	jg dl_next_pixel

	push bx
	mov di,bx
	shl di,6
	shl bx,8
	add di,bx
	add di,ax
	mov bx,word ptr [bp+12]		; color
	mov byte ptr [di],bl		; set pixel
	pop bx

dl_next_pixel:
	or dx,dx
	jge dl_jump1			; delta >= 0

	add dx,word ptr [bp-2]		; delta+=inc1_d
	add ax,word ptr [bp-6]		; x+=inc1_x
	add bx,word ptr [bp-10]		; y+=inc1_y
	jmp dl_jump2
dl_jump1:
	add dx,word ptr [bp-4]		; delta+=inc2_d
	add ax,word ptr [bp-8]		; x+=inc2_x
	add bx,word ptr [bp-12]		; y+=inc2_y
dl_jump2:
	dec cx
	jnz dl_loop

	pop ds
	add sp,12
	pop bp
	ret 10
endp