mov bx,0x0107
X: add ax,0x4F02
S: int 0x10
pop ax
W: add dx,cx
shr al,1
sar dx,1		
jnc B
or al,0x80
add cx,749
B: sub cx,dx
js W
test dh,[bx]
jnz W
push ax
add ax,di
aam 23
add al,32
mov ah,0x0C
inc esi
cmp esi,65536 * 3
jnz S
xor esi,esi
inc di
FF:
in al,0x60
dec al
jnz S
int 0x20


