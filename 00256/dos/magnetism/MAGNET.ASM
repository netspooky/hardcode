				; set origin for .COM file
	org 0100h
				; initialize graphics mode
	mov ax,0013h
        int 10h
				; set es
        mov ax,0a000h
	mov es,ax
;				; initialize palette
;	mov cx,03fh
;palinit:
;	mov al,cl
;	mov dx,03c8h
;	out dx,al
;	inc dx
;	out dx,al
;	out dx,al
;	out dx,al
;	loop palinit
				; start of loop
main:
;				; wait until start of next retrace
;	mov dx,03dah
;	mov ah,08h
;watendtrc:
;	in al,dx
;	and al,ah
;	jnz watendtrc
;watstrtrc:
;	in al,dx
;	and al,ah
;	jz watstrtrc
				; change palette
	mov bl,03eh
palchnge:
	mov bh,[direc]
	mov dx,03c7h
	mov al,bl
	out dx,al
	inc dx
	inc dx
	in al,dx
	mov ch,al
	in al,dx
	mov cl,al
	in al,dx
	push ax
	mov al,cl
	push ax
	mov al,ch
	push ax
	dec dx
	mov al,bl
	out dx,al
	inc dx
				; change RGB values
	mov cx,03h
chngergb:
	pop ax

	mov ah,bl
	inc ah
	shr ah,1

	ror bh,1
	jc paldecp
	ror bh,1
	jc palincp2
	cmp al,bl
	je palset
	jb palinc
	dec al
	jmp palset

paldecp:
	cmp al,ah
	je palincp
paldec:
	dec al
palincp:
	ror bh,1
	jnc palset
palincp2:
	cmp al,03fh
	je palset

	shl ah,2
	cmp al,ah
	je palset

palinc:
	inc al
				; set RGB values
palset:
	out dx,al
	loop chngergb
	dec bl
	jnz palchnge
				; move magnets
	mov cx,06h
	mov si,magdata
				; direction byte already in bh
movemag:
				; fetch magnet co-ordinate
	mov ax,[si]
				; move magnet\adjust direction
				; byte
	cmp bh,07fh
	ja incmag
decmag:
	cmp ax,0
	je chngedirec
	dec ax
	jmp finmove
chngedirec:
	xor bh,0a4h
;	inc bh
	jmp finmove
incmag:
	mov dx,0c7h
	cmp cl,04h
	jb incmagtst
	mov dx,13fh
incmagtst:
	cmp ax,dx
	je chngedirec
	inc ax
				; rotate direction byte,
				; set co-ord, loop
finmove:
	rol bh,1
	mov [si],ax
	inc si
	inc si
	loop movemag
				; set direction byte
	mov [direc],bh
				; write to screen section
				; set up draw loop
	mov cx,0f9ffh
	xor di,di
draw:
				; set up distcalc loop
	xor dx,dx
	mov ax,cx
        mov bx,0140h
	div bx
	push ax
	push ax
	push ax
	push dx
	push dx
	push dx
	mov si,magdata
	xor ax,ax
				; ax=sum of differences between
				; pixel at cx and positions of
				; magnets
distcalc:
	mov bx,[si]
	pop dx
	cmp bx,dx
	jnb subpoint
	xchg bx,dx	

subpoint:
	sub bx,dx
	add ax,bx
	inc si
	inc si
	cmp si,direc		
	jne distcalc
				; check if (ax\3)>03fh
	cmp ax,02fdh
	jbe divide
	mov ax,02fdh
				; division
divide:
	mov bl,0ch
	div bl	
				; convert distance to palette
				; number
	not al
	sub al,0c0h
				; write and loop
	stosb
	dec cx
	jnz draw
				; loop back/return control to DOS
	mov ah,01h
	int 16h
	jz gomain
	mov ax,0003h
	int 10h
        mov ax,04c00h
	int 21h
gomain:
	jmp main
				; magnet data
magdata:
	dw 06ah,09fh,0d5h,085h,042h,085h
				; 1x, 2x, 3x, 1y, 2y, 3y
direc:
	db 093h
				; 1x2x3x1y2y3y0o0o