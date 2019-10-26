bits 16
org 0x100

mov al,0x13
int 0x10
mov ah,0xa0
mov es,ax
main:
mov ax,[es:di]
adc ax,di
stosw
jmp short main
