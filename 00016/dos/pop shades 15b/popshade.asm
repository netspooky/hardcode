les bp,[bx]
P:
add al,0x13
int 0x10
mov ax,di
stosb
stosw
mov ax,0x10FF
jmp short P
