lodsb
S: 
sbb dx,cx
sar dx,1	
rcr bp,1
daa
sbb dh,[si]
adc cx,dx		
int 0x10
mov ah,0x0C
jmp short S
