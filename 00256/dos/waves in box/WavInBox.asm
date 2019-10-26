
.model tiny
.code
.386

org 100h

start:
mov ax,12h
int 10h	; start+4 = 10 BA DA 03 ...

koeff:
mov dx,3dah		
in ax,dx

mov dx,3c0h
mov al,0fh
m0:
out dx,al
out dx,al
dec al
jns m0

mov al,20h
out dx,al

mov di,offset pal
mov cx,14*3
fldz

m1:
fld st
fsin
fld st
fmul
fimul f63
fistp word ptr[di]
inc di
fiadd word ptr koeff-1
loop m1


main_loop:

mov cx,0	;x
mov bx,r0
neg bx
mov dx,bx	;y
inc bx
shl bx,1	;d

circ_loop:

m2:
call dot
neg cx
call dot
neg dx
jg m2
jz next_r

mov ax,bx	;d1
cmp ax,cx
jg m3

inc cx
inc bx
add bx,cx
add bx,cx
cmp ax,dx
jle circ_loop

m3:
inc dx
inc bx
add bx,dx
add bx,dx
jmp circ_loop

next_r:
inc r0
dec n0
jnz m6
	
mov n0,2
inc c0
cmp c0,15
jnz m4

mov c0,1
m4:
std
mov si, offset pal + 14*3 - 1
mov di, offset pal - 1
movsb
movsb
movsb
mov di, si
add di, 3
mov cx, 14*3
rep movsb

cld
mov si, offset pal
mov cx, 14*3
mov dx, 3c8h
mov al, 1
out dx, al
inc dx
m5:
lodsb
out dx,al
loop m5


m6:
in al, 60h
dec al
jnz main_loop

retn


dot proc near
pusha
mov ax,1280
add cx, 320	;x0
jns m7
neg cx
m7:
cmp cx,ax	;1280
jl m8
sub cx,ax	;1280
jmp m7

m8:
cmp cx,640
jl m9
not cx	
add cx,ax	;1280	

m9:
mov ax,960
add dx, 240	;y0
jns m10
neg dx
m10:
cmp dx,ax	;960
jl m11
sub dx,ax	;960
jmp m10
m11:
cmp dx,480
jl m12
not dx	
add dx,ax	;960	

m12:
xor bh, bh
mov ah, 0ch
mov al, c0
int 10h
ext:
popa
retn
dot endp

f63	dw 63
r0	dw 0
c0	db 14
n0	db 2

temp	dw ?
	db 3 dup (?)
pal	db 14*3+1 dup (?)

end start
