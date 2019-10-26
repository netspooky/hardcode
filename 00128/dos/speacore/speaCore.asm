; this is a fastprod, no comments here
; any questions? contact me directly
; helmut.toedtmann@gmail.com

org 100h
push 0x9FE2
pop es
or al,0x13
int 0x10

X:
mov al,7
out 0x40,al

mov ax,[fs:0x046C]
mov bp,ax

test al,64+32+16
jnz G
test al,0x80
jz G

mov bx,music2
jmp short H

G:
cmp al,13
jg F

mov bx,music
H:
mov al,ah
and al,15
xlat


F:
out 0x42,al
mov al,3
out 0x61,al

xor bx,bx

mov ax,0xCCCD
mul di
sub dh,[si]
; test dl,dh
; jz E
pusha
fild word [bx-9]
fild word [bx-8]
fpatan
fimul word [si]
fistp word [bx-5]
popa
E: 
shr bp,6
sub ax,bp
aam 23
add al,0x38
stosb
; inc di
; inc di

imul di,byte 37
; jnz X
; dec bp
in al,0x60
dec al
jnz X
out 0x61,al
ret
; jmp short X

music:
db 0x40,0x36,0x40,0x36,0x40,0x50,0x48,0x55
db 0x40,0x36,0x2B,0x36,0x40,0x50,0x48,0x48
music2:
db 0x08,0x08,0x08,0x04,0x06,0x06,0x07,0x07
db 0x10,0x11,0x10,0x10,0x0A,0x0A,0x0E,0x0E

