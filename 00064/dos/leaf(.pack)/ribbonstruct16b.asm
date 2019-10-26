S: add al,0x12
sub dx,cx		
add cx,dx
sar dx,1	
rcl cx,1
int 0x10
mov ah,0x0C
jmp short S
