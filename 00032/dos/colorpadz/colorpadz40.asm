; Matrix
; 32/40 byte colorpad
org 256
		 mov al,$13
		 int 10h
		 lds di,[bx]
xlabel1:	 mov ax,bx
		 cdq
		 mov cx,$140
		 div cx
		 shr dx,4
		 shr ax,4
		 imul ax,$14
		 add al,dl
		 mov [bx],al
		 dec bx
		 jnz xlabel1
		 cbw
		 int 16h
		 mov ax,3
		 int 10h
		 ret
