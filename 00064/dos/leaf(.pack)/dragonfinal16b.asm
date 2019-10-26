S: 
adc al,0x10
sbb dx,cx		
sar dx,0x01	
adc dh,bl
add cx,dx
int 0x10
mov ah,0x0C
jmp short S