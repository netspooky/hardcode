;mess
;64 byte intro
;
;by frag
;http://fsqrt.blogspot.com/
;pzagrebin@gmail.com
;10-12-2011

;Quick saturday coding.
;NASM compatible.
;Simple code, nothing to comment.
;Enjoy!

org 100h
	mov al, 13h
	int 10h
	
	push 0a000h
	pop es
	push 09000h
	pop ds

L0:	mov cl, 80
LC:	mov bx, 319
LX:	push bx
	imul bx, cx
	mov al, cl
	add al, dl
	xor al, bh
	or al, dh
	push ax
	add ax, cx
	imul di, ax, 320
	pop ax
	pop bx
	mov [di+bx], al
	dec bx
	jns LX
	inc cl
	jnz LC

COPY:	xor ax, ax
	xchg al, [di]
	stosb
	loop COPY
	inc dx
	
	in al, 60h
	dec ax
	jnz L0
	ret



