mov al,0x12
S: int 0x10
push cx			
sub cx,dx		
inc ch
sar cx,1			
rcl al,1
pop di				
add dx,di 
sar dx,1
jc B
push cx
mov cx,639
sub cx,dx
pop dx
B: or ax,0x0c80
jmp short S

