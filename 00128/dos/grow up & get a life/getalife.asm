org 100h
cli
push 0xa000
pop es
mov bp,8000
mov al,0x13
int 0x10
L: xor dx,dx
mov bx,320
mov ax,di
sub ax,bp
div bx			
xchg bx,ax
xchg dx,ax		
shr bx,3
shl bx,1
test bl,96
jnz T
shr ax,3
shl ax,1
test al,16
jz F
not al
dec ax
F: test al,32
jz T
xchg cx,ax
mov ax,[byte bx+si+sprite-256]
T:
shr ax,cl
and al,3
mov bx,colors
xlat
stosb
inc di
inc di
jnz L
inc bp
mov ax,bp
shr ax,3
aam 23
add al,32
mov byte [bx+2],al
in al,0x60
dec al
jnz L
ret
sprite:
dw 0000000000111111b
dw 0000001111010110b
dw 0000111001010110b
dw 0011101001011010b
dw 0011011010101010b
dw 1101010110100101b
dw 1101010110010101b
dw 1101010110010101b
dw 1101011010010101b
dw 1110101010100101b
dw 1110101111111111b
dw 0011111101011101b
dw 0000110101011101b
dw 0000110101010101b
dw 0000001101010101b
dw 0000000011111111b
colors:
db 9,15,4,0