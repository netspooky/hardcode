S: add al,0x13
int 0x10
add dx,cx		
sar dx,0x01	
jnc B
sub cx,0x7B
B: sub cx,dx
mov ah,0x0C
jmp short S
