inc ax
L add [si],bx
repnz
cwd
add al,0x12
int 0x10
mov ax,cx		
div word [si]
add ax,di
xor ax,dx
add ax,di
shr ax,0x03
aam 0x17
mov ah,0x0C
loop L+1
inc di
jmp short L+1
