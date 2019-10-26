W: adc al,0x13
S: int 0x10
shr ax,1
push cx
sub cx,dx
sar cx,1
pop di
add dx,di
sar dx,1
rcl ebp,1
jnc B
or al,0x20
sbb cl,37
xchg cx,dx
B: 
mov ah,0x0c
jmp short S
