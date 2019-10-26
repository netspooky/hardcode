; Mikolaj Felix 7/04/2001
; mfelix@polbox.com

					; x1  +4	y1 +6
					; x2  +8	y2 +10
					; x3 +12	y3 +14
					; x4 +16	y4 +18

					; k1 +20
					; k2 +22
					; k3 +24
					; k4 +26
draw_grds_polygon proc
	push bp
	mov bp,sp

	mov di,offset polygon_left
	mov ax,32000
	shl eax,16
	mov ax,32000
	mov cx,100
	cld
	rep stosd
	mov ax,-32000
	shl eax,16
	mov ax,-32000
	mov cx,100
	rep stosd

	push word ptr [bp+22]		; k2
	push word ptr [bp+20]		; k1
	push word ptr [bp+10]		; y2
	push word ptr [bp+8]		; x2
	push word ptr [bp+6]		; y1
	push word ptr [bp+4]		; x1
	call grds_scan_side

	push word ptr [bp+24]		; k3
	push word ptr [bp+22]		; k2
	push word ptr [bp+14]		; y3
	push word ptr [bp+12]		; x3
	push word ptr [bp+10]		; y2
	push word ptr [bp+8]		; x2
	call grds_scan_side

	push word ptr [bp+26]		; k4
	push word ptr [bp+24]		; k3
	push word ptr [bp+18]		; y4
	push word ptr [bp+16]		; x4
	push word ptr [bp+14]		; y3
	push word ptr [bp+12]		; x3
	call grds_scan_side
	
	push word ptr [bp+20]		; k1
	push word ptr [bp+26]		; k4
	push word ptr [bp+6]		; y1
	push word ptr [bp+4]		; x1
	push word ptr [bp+18]		; y4
	push word ptr [bp+16]		; x4
	call grds_scan_side

	push es
	mov es,buffer_seg

	xor di,di
	xor cx,cx
grds_pol_loop:
	mov ax,word ptr polygon_left[di]
	cmp ax,32000
	je grds_pol_next

	push cx
	push di

	push word ptr colors_right[di]
	push word ptr colors_left[di]
	push cx
	push word ptr polygon_right[di]
	push word ptr polygon_left[di]
	call grds_line

	pop di
	pop cx
	
grds_pol_next:
	add di,2
	inc cx
	cmp cx,200
	jne grds_pol_loop

	pop es
	pop bp
	ret 24
endp

					; x1 +4
					; y1 +6
					; x2 +8
					; y2 +10
					; k1 +12
					; k2 +14
grds_scan_side proc
	push bp
	mov bp,sp

	mov ax,word ptr [bp+6]
	cmp ax,word ptr [bp+10]
	je grds_scan_quit		; y1 = y2
	jb grds_scan_ok			; y1 < y2

	xchg ax,word ptr [bp+10]	; xchg y1,y2 
	mov word ptr [bp+6],ax

	mov ax,word ptr [bp+4]
	xchg ax,word ptr [bp+8]		; xchg x1,x2
	mov word ptr [bp+4],ax

	mov ax,word ptr [bp+12]
	xchg ax,word ptr [bp+14]	; xchg k1,k2
	mov word ptr [bp+12],ax
grds_scan_ok:

	sub sp,4			; bp-2 delta_x
					; bp-4 delta_c

	mov cx,word ptr [bp+10]
	sub cx,word ptr [bp+6]		; cx = y2-y1

	mov ax,word ptr [bp+8]
	sub ax,word ptr [bp+4]		; ax = x2-x1
	shl ax,7
	cwd
	idiv cx
	mov word ptr [bp-2],ax

	mov ax,word ptr [bp+14]
	sub ax,word ptr [bp+12]		; ax = k2-k1
	shl ax,7
	cwd
	idiv cx
	mov word ptr [bp-4],ax

	mov ax,word ptr [bp+4]
	shl ax,7			; ax = x1<<7

	mov bx,word ptr [bp+12]
	shl bx,7			; bx = k1<<7
	
	mov di,word ptr [bp+6]
	shl di,1

grds_scan_loop:
	mov dx,ax
	shr dx,7
	cmp dx,word ptr polygon_left[di]
	jg grds_scan_next1			; x > polygon_left[di]

	mov word ptr polygon_left[di],dx	; polygon_left[di] = x
	mov dx,bx
	shr dx,7
	mov word ptr colors_left[di],dx		; colors_left[di] = k

grds_scan_next1:
	mov dx,ax
	shr dx,7
	cmp dx,word ptr polygon_right[di]
	jl grds_scan_next2			; x < polygon_right[di]

	mov word ptr polygon_right[di],dx	; polygon_right[di] = x
	mov dx,bx
	shr dx,7
	mov word ptr colors_right[di],dx	; colors_right[di] = k

grds_scan_next2:
	add ax,word ptr [bp-2]		; x+=delta_x
	add bx,word ptr [bp-4]		; k+=delta_c
	add di,2
	dec cx
	jnz grds_scan_loop

	add sp,4

grds_scan_quit:
	pop bp
	ret 12
endp

					; x1 +4
					; x2 +6
					; y  +8
					; k1 +10
					; k2 +12
grds_line proc
	push bp
	mov bp,sp

	mov ax,word ptr [bp+4]
	cmp ax,word ptr [bp+6]
	je grds_line_quit		; x1 = x2
	jb grds_line_ok			; x1 < x2

	xchg ax,word ptr [bp+6]		; xchg x1,x2
	mov word ptr [bp+4],ax

	mov ax,word ptr [bp+10]
	xchg ax,word ptr [bp+12]	; xchg k1,k2
	mov word ptr [bp+10],ax
grds_line_ok:

	mov di,word ptr [bp+8]
	mov ax,di
	shl ax,6
	shl di,8
	add di,ax
	add di,word ptr [bp+4]		; di = offset

	mov cx,word ptr [bp+6]
	sub cx,word ptr [bp+4]		; cx = x2-x1
	mov ax,word ptr [bp+12]
	sub ax,word ptr [bp+10]		; ax = k2-k1
	shl ax,7
	cwd
	idiv cx
	mov dx,ax			; dx = delta_c

	inc cx
	mov bx,word ptr [bp+10]
	shl bx,7			; bx = color<<7
grds_line_loop:
	mov ax,bx
	shr ax,7
	stosb
	add bx,dx			; color+=delta_c
	dec cx
	jnz grds_line_loop

grds_line_quit:
	pop bp
	ret 10
endp

polygon_left dw 200 dup(?)
polygon_right dw 200 dup(?)
colors_left dw 200 dup(?)
colors_right dw 200 dup(?)