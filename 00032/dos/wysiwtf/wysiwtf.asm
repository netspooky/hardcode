add al,0x13
L: int 0x10
mov al,cl
add al,ch
test al,0x10
jz F
not al
F: aam 0x10
add al,0x10
mov ah,0x0C
dec cx
dec cx
loop L
inc dx
mov ah,1
int 0x16
jz L
ret