les bx,[bx]
mov al,0x13
int 0x10
mov ah,0x80
mov ds,ax
S: 
sbb dx,bx		
mov ax,[fs:0x46c]
test al,0x40
jnz FF
not al
FF:
and ax, byte 0x3f
sar dx,0x01	
rcr ebp,1
jnc F
adc dx,ax
F:
adc bx,dx
imul si,dx,320
sub al,bl
and al,dl
jz G
mov byte [bx+si+320*100+110],56
G:
loop S
mov di,si
B:
movsb
mov [si-1],ah
loop B
jmp short S


