org 100h

	mov al,13h
	int 10h
	;palette
	        mov dx, 3c8h
        xor ax,ax
        out dx,al
        inc dx
        mov cx,ax
		
		mov bx,400h
		xor ax,ax
		mov cx,10h
clear:
		mov [bx],ax
		inc bx
		loop clear
		
		
PAL:
		mov bx,400h
		
        mov ax,cx
		out dx,al
        shr ax,1
		and ax,cx
		out dx,al
        shr ax,1
		and ax,cx
        mov bx,dx
		
	out dx,al
		
        
        inc cl
        jne PAL
	
	;palette
	
	
main:
	push 04000h
	pop es;
	;push 05000h
	;pop ds;
	
	xor di,di
	
	mov bx,200
row:
	mov cx,320
pixel:
	
	xor al,al
	;mov ax,cx
	call f
	shl ax,1
	mov dx,bp
	shr dx,1
	shl dh,4
	add al,dh
	
	xor ah,ah
	add ax,[200]
	shr ax,1
	stosb
	mov [200],ax
	
	loop pixel
	dec bx
	jnz row
	
	;frame
	inc bp

	push ds
	push es
	pop ds
	push 0a000h
	pop es
	xor di,di
	xor si,si
	mov cx,320*50
	
	;;wait for retrace
        xor ax,ax
        mov dx,03DAh
    pmw1:
        in al,dx;
        and al,8
        jnz pmw1
    pmw2:
        in al,dx
        and al,8
        jz pmw2
	
	rep movsd ;blit to video ram
	pop ds
	inc dx
	
	in al,60h
	dec al
	jnz main
	
	ret;

f:
	push cx
	push bx
	
	mov dx,cx
	shr dx,1
	push dx
	mov dx,bx
	shr dx,1
	sub cx,dx
	pop dx
	add bx,dx
	
	;add or sub
	mov dx,bp
	bt bp,9
	jc	 op2
		add bx,bp
		sub cx,bp
		add bl,dh
	jmp op2end
	op2:
		sub bl,dh
		sub cx,dx
		sub bx,dx
	op2end:
	
	;escape logic
	mov dx,bp
	shr dx,11
	cmp al,dl
	jl nextit
	
	mov ah,cl
	
	bt bp,10
	jc br10
		bt bp,9
		jc brend
			br00:
			xor ah,bl
			jmp brend;
		br10:
		bt bp,9
		jc br11
			;br10:
			and ah,bl
			jmp brend;
			br11:
			add ah,7
			and ah,cl
			;jmp brend
	brend:	
		
	and ah,0f0h
	jz endf
	
	mov ah,bl
	and ah,0f0h
	jz endf
	
	mov dx,bp
	cmp al,dh
	je endf
	
nextit:	
	inc al
	xor ch,ch
	xor bh,bh
	call f
	
endf:	
	pop bx
	pop cx

	ret
	