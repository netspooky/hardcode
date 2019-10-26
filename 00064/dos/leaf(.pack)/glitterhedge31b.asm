S: 
xor al,0x13
X:
int 0x10
sbb dx,cx   ;  1	1	0	1
sar dx,1	;  .5	.5	0	1
pushf
adc cx,dx	;  .5	.5	-.5 .5
popf
rcl si,1
jc F
xchg dx,cx
add cx, 175
or si,byte 1
F:
mov ax,si
mov ah,0x0c
jmp short S
