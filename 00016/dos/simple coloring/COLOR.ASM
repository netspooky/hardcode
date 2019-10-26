org 100h
mov al,13h
int 10h
push word 0xa000
pop ds
xenofex:
dec byte[bx]
xchg bx,ax
inc ax
jmp xenofex