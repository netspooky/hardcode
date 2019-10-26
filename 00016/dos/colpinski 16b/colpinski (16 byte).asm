org 100h
T:
add al,0x13
L:
int 0x10
M:
mov al,cl
and al,ch
loopnz M
mov ah,0x0C
in al,0x60
jmp short T

