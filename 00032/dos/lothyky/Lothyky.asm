mov	al,13h
int	10h
lds	cx,[bx]
or	[bx+si-39h],ax
add	[bx+di+012Ch],bh
dec	bx
add	al,0F4h
rol	byte [bx+si-56h],01h
inc	cx
jmp	000000006h
nop	
