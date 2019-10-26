mov al,0x13
L int 0x10
mov ax,cx
xor al,ah
sub ax,dx
and al,0x3F
imul ax,byte 0x03
mov ah,0x61
shr ax,0x03
loop L
dec dx
mov ah,0x01
int 0x16
jz L
ret
