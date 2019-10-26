; code by MathM

.model tiny
.code
.startup
		mov al,13h
		int 10h
		mov dx,321
		lds cx,[bx]
a:		dec cx
b:  		add di,dx
		jns c
		neg dx
		add dx,640
c:		xchg [di],bl
		loop b
		add bx,di
		in ax,60h
		dec ax
		jne a	
		ret
end

