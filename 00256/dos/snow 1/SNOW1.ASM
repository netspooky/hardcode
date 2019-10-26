				; set origin for .COM file
	org 0100h
				; initialize chain 4 graphics mode
	mov ax,0013h
        int 10h
	mov dx,03c5h
	mov al,06h
	out dx,al
	mov dx,03d4h
	mov al,013h
	out dx,al
	inc dx
	mov al,028h
	out dx,al

	mov al,02h
	mov dx,03c4h
	out dx,al
	mov al,0fh
	inc dx
	out dx,al
				; set es
	mov ax,0a000h
	mov es,ax
				; set up screen write loop
	xor di,di
	mov cx,0fa00h
				; write to screen loop
scrwrite:

				; calculate colour
	mov ax,cx
	xor dx,dx
	div word [dividenum]
				; dx=x, ax=y
	div byte [dividenum3]
	xchg ax,dx
	div byte [dividenum2]
	shl al,2
	add al,dl
				; write
	stosb
	loop scrwrite

				; main loop
main:
				; obtain frostbyte
	mov bl,[frostbyte]
				; palette change
	mov cx,01ah
	xor bh,bh
	xor ah,ah
palchnge:
				; write values
	mov dx,03c8h
	mov al,cl
	out dx,al
	inc dx
	rol bl,1
	jc normal
				; b\w
	push cx
	mov cl,ch
	xor ch,ch
	add cl,bh
	add cl,ah
	xchg ax,cx
	mov cl,03h
	div cl
	mov ah,ch
	out dx,al
	out dx,al
	out dx,al
	pop cx
	jmp chngenext
				; normal
normal:
	mov al,ch
	out dx,al
	mov al,bh
	out dx,al
	mov al,ah
	out dx,al
				; change next values
chngenext:
	mov al,01fh
	mov dl,03fh
	add ch,al
	cmp ch,dl
	jna looppal
	add bh,al
	cmp bh,dl
	jna looppal
	add ah,al
				; loop
looppal:
	dec cl
	jnz palchnge
				; set up scroll loop
	mov al,01h
	mov cx,0208h
	cmp bl,01fh
	ja passclchn
	xor byte [scrollbyte],0ffh
passclchn:
	cmp byte [scrollbyte],1
	ja toporbot
	rol bl,1
	jc slscrl1
	shl al,1
	shr cx,1
slscrl1:
	rol bl,1
	jc slscrl2
	shl al,1
	shr cx,1
slscrl2:
	shr al,1
	mov dl,0a0h
	mul dl
	mov [scrollword],ax
toporbot:
	xor ax,ax
	rol bl,1
	jnc scrollloop
	mov ax,07cb0h
				; scroll loop
scrollloop:
				; set viewport
	mov dx,03d4h
	mov bh,0ch
	xchg bh,al
	out dx,al
	inc dx
	mov al,ah		; high byte
	out dx,al
	dec dx
	mov al,0dh
	out dx,al
	inc dx
	mov al,bh		; low byte
	out dx,al
	add ax,word [scrollword]
	loop scrollloop
				; set frostbyte
	mov [frostbyte],bl
				; loop back\return to DOS
	mov ah,01h
	int 16h
	jz gomain
	mov ax,0003h
	int 10h
        mov ax,04c00h
	int 21h
gomain:
	jmp main
scrollbyte:
	db 0
dividenum:
	dw 0140h
dividenum2:
	db 02eh
dividenum3:
	db 032h
frostbyte:
	db 001011010b
scrollword: