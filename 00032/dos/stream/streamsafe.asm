org 100h
mov al,0x13
int 0x10
;lds bx,[bx]
push 0xa000
pop ds
L: imul bx, byte 53
lea si,[bx-321]
lodsb
mul byte [si-1]
or al,[si]
dec ax
mov [bx],al
dec bx			
mov ah,1
int 0x16
jz L
ret