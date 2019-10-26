; Mikolaj Felix 1/05/2001
; mfelix@polbox.com
					; al - ascii code
					; ah - color
					; cx - x
					; dx - y
put_char proc
	sub al,32
	cmp al,0
	jb pc_quit
	cmp al,63
	ja pc_quit

	push es
	mov es,buffer_seg
	mov di,dx
	shl di,6
	shl dx,8
	add di,dx
	add di,cx

	mov dl,ah
	mov si,offset font
	xor ah,ah
	shl ax,3
	add si,ax

	mov ch,8
pc_loop_y:
	mov cl,8
	mov al,byte ptr [si]
pc_loop_x:
	rcl al,1
	jae pc_next
	mov es:[di],dl
pc_next:
	inc di
	dec cl
	jnz pc_loop_x
	inc si
	add di,312
	dec ch
	jnz pc_loop_y
	pop es
pc_quit:
	ret
endp

					; si - offset to null terminated string
					; cx - x
					; dx - y
					; ah - color
put_string proc
	push es
	mov es,buffer_seg
	mov di,dx
	shl di,6
	shl dx,8
	add di,dx
	add di,cx

	mov dl,ah
ps_char_loop:
	mov bl,byte ptr [si]
	or bl,bl
	jz ps_quit

	sub bl,32
	cmp bl,0
	jb ps_next_char
	cmp bl,63
	ja ps_next_char

	xor bh,bh
	shl bx,3
	add bx,offset font

	push di
	mov ch,8
ps_char_y:
	mov al,byte ptr [bx]
	mov cl,8
ps_char_x:
	rcl al,1
	jae ps_next_pixel
	mov es:[di],dl
ps_next_pixel:
	inc di
	dec cl
	jnz ps_char_x
	inc bx
	add di,312
	dec ch
	jnz ps_char_y
	pop di

ps_next_char:
	inc si
	add di,8
	jmp ps_char_loop
ps_quit:
	pop es
	ret
endp

include font.inc