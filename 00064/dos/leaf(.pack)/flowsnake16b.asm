S: 
add al,0x11
sbb dx,cx		
adc cx,dx
int 0x10
sar dx,0x01	
adc dh,bl
mov ah,0x0C
jmp short S
