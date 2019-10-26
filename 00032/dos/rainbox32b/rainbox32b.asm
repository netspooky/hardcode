mov al,0x13
P: dec cx
dec cx
int 0x10
mov ax,cx
add ax,bp
and ax,63
imul ax,byte 96
mov al,ah
add al,32
mov ah,0x0C
loop P
inc bp
mov ah,0x01
int 0x16
jz P
ret
