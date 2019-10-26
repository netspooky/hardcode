
licznikBump dw 0

calc_bump:
	
	mov bx,licznikBump
	add licznikBump,4
	shl bx,2
	mov ax,[trasaBump+0][bx]
	mov yayoX,ax
	mov ax,[trasaBump+2][bx]
	mov yayoY,ax
	
	cmp licznikBump,360
	jl sluchamy_tiamata
	mov licznikBump,0
 sluchamy_tiamata:





  	mov ax,Segment0
 	mov gs,ax
	mov ax,0a000h
	mov es,ax
	xor di,di
	mov ax,Segment1
	mov ds,ax
	xor si,si
	mov bp,o kolo
	add si,321
	add di,321

	mov ax,YayoY
	mov [bump_y],ax
	mov ecx,198
 L001bump:
	push cx
	mov ax,yayoX
	mov [bump_x],ax
	mov cx,318
 L002bump:
	push cx
	cmp [bump_x],-128
	jl nBumpZ
	cmp [bump_x],128
	jg nBumpZ
	cmp [bump_Y],-128
	jl nBumpZ
	cmp [bump_Y],128
	jg nBumpZ
	
	xor ax,ax
	xor bx,bx
	xor cx,cx
	xor dx,dx
	mov al,[si+1]
	mov bl,[si-1]
	mov cl,[si+320]
	mov dl,[si-320]
	sub ax,bx
	sub cx,dx
	sub ax,[bump_x]
	jge oke1bump
	neg ax
 oke1bump:
	sub cx,[bump_y]
	jge oke2bump
	neg cx
 oke2bump:
	mov bx,127
	mov dx,127
	sub bx,ax
	jge oke3bump
	xor bx,bx
 oke3bump:	
	sub dx,cx
	jge oke4bump
	xor dx,dx
 oke4bump:
	shl bx,7
	add bx,dx
	mov al,cs:[kolo][bx]
	mov bl,gs:[si]
	or bl,bl
	jz iopek
	mov es:[di],bl
	jmp nbump
 iopek:
	mov es:[di],al
 nBump:
	jmp oifd
 nBumpZ:
	mov bl,gs:[si]
	or bl,bl
	jnz barh	
	mov bl,0
 barh:
	mov b es:[di],bl
 oifd:
	inc di
	inc si
	inc [bump_x]
	pop cx
	dec cx
	jnz L002bump

	inc [bump_y]
	pop cx
	add di,2
	add si,2
	dec cx
	jnz L001bump
	
	ret


