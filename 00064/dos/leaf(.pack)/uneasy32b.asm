W mov al,0x12
S
int 0x10
push cx
sub cx,dx
sar cx,1
pop di
add dx,di
sar dx,1
rcr ebp,1
jnc B
sub ch,2
not dx
B: 
neg cx
aam 7
mov ah,0x0c
jmp short S
