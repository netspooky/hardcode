org 100h
dw -0x0140
X: xor al,bh
cwd
or al,0x13
int 10h
mov ax,cx
idiv word [si]
mov bx,ax
imul bx,bp
add bh,dl
imul dx,bp
sub al,dh
mov ah,0x0c
loop X
dec bp
jmp short X