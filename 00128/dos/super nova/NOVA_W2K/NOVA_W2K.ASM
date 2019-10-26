mov ax,0x13
int 0x10
push word 0xa000
pop es
mov di,0x789c
mov ax,0xeb5
mov [es:di],ax
mov cx,0x100
label2:
cmp cx,byte +0x0
jz label1
cli
mov dx,0x3c8
mov ax,cx
out dx,al
inc dx
mov ah,0x0
mov al,0x0
out dx,al
mov al,ch
out dx,al
mov al,cl
out dx,al
sti
dec cx
jmp short label2
label1:
mov di,0x2711
mov dx,0x3e9
label4:
cmp di,0xfa00
ja label3
mov ah,0x0
mov al,[es:di]
cmp al,0x0
jz label3
inc al
mov [es:di+0x13f],al
mov [es:di+0xfec1],al
mov [es:di+0x141],al
mov [es:di+0xfebf],al
mov [es:di+0x1],al
mov [es:di-0x1],al
mov [es:di+0x140],al
mov [es:di+0xfec0],al
mov [es:di],al
label3:
add di,dx
inc dx
;in al,0x60
;cmp al,0x80
jmp short label4 ;jnc label4
;mov ax,0x3
;int 0x10
;ret
