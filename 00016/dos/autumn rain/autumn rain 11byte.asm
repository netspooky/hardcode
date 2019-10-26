org 100h
top:
add al,0x13
int 0x10 
inc dx
inc cx
aaa
mov ah,0x0C
jmp short top
