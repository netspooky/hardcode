org 100h
mov al,0x13
push 0xa000-90
pop es
int 0x10
inc cx
P:
mov dx,0x3c9
mov ax,cx
out dx,al
out dx,al
out dx,al
out dx,al
salc
out dx,al
out dx,al
loop P
X:
add dh,[si]
mov ax,bp
add dl,al
shl al,3
imul al
sub dh,ah
pusha
fild word [bx-8]
fmul st0
fild word [bx-9]
fst st2
fmul st0
faddp st1
fsubr dword [byte si -0x100+newnum-2+1]
fsqrt
fist word [bx-5]
fpatan
fmul dword [byte si-0x100+num4-2]
fistp word [bx-6]
popa
shr dx,10
add cx,bp
xor dx,cx
ror dl,4
rcl al,1
stosb
mov ax,0xCCCD
mul di
jc X
lea dx,[bp+12] 
test dl,0x1f
jnz soundskip
mov dx,0x0331
mov al,0x3F
out dx,al
dec dx
mov al,0xc9
out dx,al
mov al,56
out dx,al
mov al,0x99
out dx,al
mov al,87
out dx,al
mov al,127
out dx,al
soundskip:
newnum:
in al,0x60	
dec bp
dec ax
jnz X
ret
num4:
dw 0x4199