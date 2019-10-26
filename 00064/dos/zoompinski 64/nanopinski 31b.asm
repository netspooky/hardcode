T: cwd
or al,0x13			; mode 13
int 0x10			; set mode
mov bp,320
mov ax,cx
idiv bp				; [x,y] = [dx,ax]
mul bl				; zoom
imul dx,bx			; zoom
and ah,dh			; zoompinski ;)
mov ax,[si]
G:jz G-1
loop T				; next pixel
or bl,128			; keep zoom range
dec bx	 			; next frame
jmp short T		
