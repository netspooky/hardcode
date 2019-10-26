mov al,0x13			; mode 13
X:
cmpsw				; next frame (with skip)

S:
xor dx,dx			; int10 overflow
					; also, dx=0 for DIV
int 0x10			; set mode/pixel

inc cx
inc cx
inc cx				; next pixel
					; edge noise as effect
					; and flicker prevent
					
jz X				; frame done?

mov bx,320 			; make x and y
mov ax,cx			; from counter
div bx				; dx = y , ax = x

mov bx,di			; framecounter for offset

mov bp,64			; init recursive value

xor si,si			; init pixel value

i:					
	push ax
	push dx
		sub al,bl
		add dx,di	
		sub dl,bl
		and al,dl	; the magic
		and ax,bp
		or si,ax
		shr bx,1
		shr bp,1
	pop dx
	pop ax
jnz i

in al,0x60			
dec ax
jz R				; quit on ESC

shr si,2
xchg si,ax			; get pixel value in al
add al,16			; palette offset

mov ah,0x0c			; = set pixel
jmp short S
R:
ret
