push 0x9FBA
pop es
or al,0x13
L: int 0x10
mov ax,0x1010
inc ch
inc bx
jnz L
X: mov ax,0xCCCD
mul di
sub dh,[si]
pusha
fninit
fild word [byte bx-8]	
fmul st0
fild word [byte bx-9]	
fmul st0
faddp st1
fsqrt
fidivr dword [si]
fist word [byte bx-5]
popa
add al,dh
sub ax,bp
test al,0x40
jnz F
not al
F: stosb
sub di,[si]
jnz X
inc bp
jmp short X
