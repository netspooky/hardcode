org 0x100		
bits 16
xchg bp,ax		
imul dx,[bp+si+101],59*457
inc di
outsb
add sp,[si]
mov dx,si
int 33 
