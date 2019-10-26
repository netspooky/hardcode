mov al,0x13
L:inc cx
int 0x10
mov ax,0x1010
inc bx
inc dh
jnz L
L2: int 0x10
mov al,cl
add al,ch
test al,0x20
jz F
not al
F: mov ah,0x0C
loop L2
inc dx
jmp short L2
