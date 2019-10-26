S: 
xor al,0x10
X:
int 0x10
Y:
adc dx,cx			;  1  1   0  1 	
sbb cx,dx			; .5 .5  -.5 .5
sar dx,1			; .5 .5   0  1
rcr bp,1
jnc F
shl al,1
not cx
F:
aaa
out 42h,al
out 61h,al	
inc ch				; .5 .5   0  1
js Y
mov ah,0x0C
jmp short S
