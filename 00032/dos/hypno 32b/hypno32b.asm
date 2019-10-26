mov al,0x13
f: inc di
p: cwd
int 0x10
mov bx,0x140
mov ax,cx		
div bx			
mul dx
add ax,di
aam 0x17
add al,0x20
mov ah,0x0C
loop p
in al,0x60
dec al
jnz f
ret
