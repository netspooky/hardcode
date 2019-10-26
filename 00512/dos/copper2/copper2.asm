mov ax,0x13
int 0x10

mov dx,0x3D4
mov ax,0x1F01
out dx,al

mov ax,0xa000
mov es,ax
mov si,0
mov di,0

mov cx,0x100
mov al,0
rep stosb

mov cx,0x100
mov al,17
rep stosb

mov cx,0x100
mov al,18
rep stosb


mov cx,0x100
mov al,19
rep stosb

mov cx,0x100
mov al,20
rep stosb

mov cx,0x100
mov al,21
rep stosb

mov cx,0x100
mov al,22
rep stosb

mov cx,0x100
mov al,23
rep stosb

mov cx,0x100
mov al,24
rep stosb

mov cx,0x100
mov al,25
rep stosb

mov cx,0x100
mov al,26
rep stosb

mov cx,0x100
mov al,27
rep stosb

mov cx,0x100
mov al,28
rep stosb

mov cx,0x100
mov al,29
rep stosb

mov cx,0x100
mov al,28
rep stosb

mov cx,0x100
mov al,27
rep stosb

mov cx,0x100
mov al,26
rep stosb

mov cx,0x100
mov al,25
rep stosb

mov cx,0x100
mov al,24
rep stosb

mov cx,0x100
mov al,23
rep stosb

mov cx,0x100
mov al,22
rep stosb

mov cx,0x100
mov al,21
rep stosb

mov cx,0x100
mov al,20
rep stosb

mov cx,0x100
mov al,19
rep stosb

mov cx,0x100
mov al,18
rep stosb

mov cx,0x100
mov al,17
rep stosb

mov cx,0x100
mov al,0
rep stosb

mainloop:

mov dx,0x3da
in al,dx
test al,8
jne loop2
je mainloop

loop2:
in al,dx
test al,8
jne loop3
je mainloop

loop3:
in al,dx
test al,8
jne loop4
je mainloop

loop4:
in al,dx
test al,8
jne loop5
je mainloop

loop5:
in al,dx
test al,8
jne loop6
je mainloop

loop6:
in al,dx
test al,8
jne loop7
je mainloop

loop7:
in al,dx
test al,8
jne loop8
je mainloop

loop8:
in al,dx
test al,8
jne loop9
je mainloop

loop9:
in al,dx
test al,8
jne loop10
je mainloop

loop10:
in al,dx
test al,8
jne loop11
je mainloop

loop11:
in al,dx
test al,8
jne loop12
je mainloop

loop12:
in al,dx
test al,8
jne loop13
je mainloop

loop13:
in al,dx
test al,8
jne loop14
je mainloop

loop14:
in al,dx
test al,8
jne loop15
je mainloop

loop15:
in al,dx
test al,8
jne loop16
je mainloop

loop16:
in al,dx
test al,8
jne loop17
je mainloop

loop17:
in al,dx
test al,8
jne loop18
je mainloop

loop18:
in al,dx
test al,8
jne loop19
je mainloop

loop19:
in al,dx
test al,8
jne loop20
je mainloop

loop20:
in al,dx
test al,8
jne copper
je mainloop

copper:

push ax

mov dx,0x3d4
mov al, 0x0C
out dx,al
inc dx
in al,dx
dec al
and al,0x3f
out dx,al

pop ax

jmp mainloop