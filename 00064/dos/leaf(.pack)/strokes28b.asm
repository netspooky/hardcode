W: 
adc al,0x13
S:
int 0x10
shr ax,1
sub cx,dx
sar cx,1
sar dx,1
rcl ebp,1
jnc B
xor al,32
sbb cl,137
xchg cx,dx
B: 
mov ah,0x0c
jmp short S
