cwd
mov al,0x13
L: int 0x10
rol cx,1
adc cl,8
ror al,cl
mov ah,0x0C
jmp short L
