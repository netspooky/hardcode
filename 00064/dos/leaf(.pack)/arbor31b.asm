S: 
xor al,0x13
X:
int 0x10
sbb cx,dx   ;  1	1	0	1
sar cx,1	;  .5	.5	0	1
rcr ebx,1
adc dx,cx	;  .5	.5	-.5 .5
test bh,ah
jnz F
xchg cx,dx
adc cx, byte 127
F:
mov al,bl
and al,15
or ax,0x0c10
jmp short X
