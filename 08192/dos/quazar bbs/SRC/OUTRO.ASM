TextOutro:
        push cs
        pop ds
	push 0b800h
	pop es
	mov ax,3
	int 10h
	mov dx,3d4h
	mov ax,80 shl 8 + 13h
	out dx,ax
        call WaitVB
;	mov eax,2080
;	call Scroll

	mov si,offset QendS
	mov di,160
	mov bx,25
tol1:
	mov cx,160/4
	rep movsd
	add di,160
	dec bx
	jnz tol1

	mov bp,61
	mov si,offset JumpTab
tol2:
        lodsw
        mov cx,ax
        lodsw
        mov dx,ax
	call TxtScroll
	dec bp
	jnz tol2
tol3:
	in al,60h
        dec al
        jnz tol3
	ret

Scroll:
	mov dx,3d4h
	push ax
	mov al,0ch
	out dx,ax
	pop ax
	mov ah,al
	mov al,0dh
	out dx,ax
	ret

TxtScroll:
	push dx
	and dx,-10h
	shr dx,4
	imul dx,160
	mov ax,cx
	and ax,0fff8h
	shr ax,3
	add ax,dx
	call Scroll
	call WaitVB
	pop ax

	and ax,0fh
	mov ah,al
	mov al,8
        mov dx,3d4h
	out dx,ax

	mov dx,3c0h
	mov al,33h
	out dx,al
	mov ax,cx
	and ax,07h
	out dx,al
	ret
