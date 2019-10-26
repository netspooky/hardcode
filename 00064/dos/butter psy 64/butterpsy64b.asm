push 0xa000-70
pop es
mov al,0x13
int 0x10
X: sub dh,[si]
pusha
fild word [byte bx-8]
fmul st0
fidiv word [byte bx-9]
fmul st0
fild word [byte bx-9]
fmul st0
fidiv word [byte bx-8]
fmul st0
faddp
fsqrt
fistp word [byte bx-5]
popa
test al,0x80
jnz S
sub ax,bp
aam 43
add al,32
S: stosb
mov ax,0xcccd
mul di
jc X
inc bp
in al,0x60
dec ax
jnz X
ret


