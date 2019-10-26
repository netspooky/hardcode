les bx,[bx]
mov al,0x13
int 0x10
mov ah,0x80
mov ds,ax
S: 
sbb bx,dx		
add dx,bx
mov ax,[fs:0x46c]
test al,0x40
jnz FF
not al
FF:
and ax, byte 0x3f
inc ax
sar bx,0x01	
rcr bp,1
jc F
adc bx,ax
F:
imul si,dx,320
add al,bl
xor al,dl
and al,8
add al,23
mov [bx+si+320*70+160-20],al
loop S
mov di,si
B:
movsb
mov [si-1],ah
loop B
jmp short S


