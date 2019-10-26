org 100h
aas
shl byte [di-0x3b],4
N: cmp [ss:bp+di],di
db 0x3E
mov al,0x13       		
L: mov ch,bl
test bl,0x40
jz F
not ch
F: mov dh,ch
int 0x10
mov ax,0x1010
inc bx
jnz L
mov ax,0x251C
mov dx,MM
int 0x21
mov  dx,331h
outsb
dec dx
mov cx,4
push cx
rep
outsb
pop cx
t: mov  al,90h
out  dx,al
outsb
mov al,127
out  dx,al  
loop t
lds si,[bx]
T: imul si,byte 117		
lodsb					
adc al,[si-0x140]		
sar al,0x01				
sbb al,0				
mov [si],al				
in al,0x60				
dec al					
jnz T					
mov al,176
out dx,al
mov al,123
out dx,al
out dx,al
ret
MM: inc cx
q2: test cl,11111b
call check
q3: test cl,1111b
call check
iret
check:
jnz qqq
mov al,0x95
out dx,al
ror dword [cs:N],8
mov al,[cs:N]
out dx,al
mov al,127
out dx,al
qqq:
ret