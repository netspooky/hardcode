org 100h
push 0xa000
pop es
mov al,0x13
L: dec bx
mov dh,bl
int 0x10
mov ax,0x1010
loop L
mov ax,0x251C
mov dx,MM
int 0x21
LLL: mov ax,0xCCCD
mul di
mov al,dh
sub al,100
mul al
xchg dx,ax
mul al
add ax,dx
sar ax,1
sub ax,bp
test al,0x40
jz F
not al
F: stosb
inc di
inc di
jnz LLL
in al,0x60
dec al
jnz LLL
ret
p: push di
scasw
stosb
stosw
stosb
inc si
push bp
push bp
push bp
push bp
sbb al,0x22
and ah,[bp+si]
and ah,[bx]
or [bx+si],cx
or ax,8108h
db 0x10
MM: add bp,16
neg si
jns nofx
mov dx,331h
mov al,0x3f
out dx,al
dec dx
mov cx,4
mov bx,p
LL: mov al,0x99
out dx,al
mov al,[cs:bx]
inc bx
rol dword [cs:bx],1
jnc nonote
out dx,al
mov al,127
out dx,al
nonote:
add bl,4
loop LL
nofx:
iret
