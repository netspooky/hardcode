org 100h
use16

mov al,13h
int 10h
mov bh,0A0h
mov es,bx
mov bh,90h
mov fs,bx

mov dx,03C8h
xor al,al
out dx,al
inc dx
xor cl,cl
pallp:
mov al,cl
out dx,al

xor al,al
out dx,al

or cl,cl
je step3
mov al,03Fh
sub al,cl
step3:
out dx,al
inc cl
cmp cl,03Fh
jne pallp

mov ax,1919h
mov [es:162+100*320],ax
mov [es:162+99*320],al

mainlp:
mov di,321

mov dx,199
ylp:
mov cx,319
xlp:
 mov al,[es:di]
 mov [fs:di],al
 xor ax,ax;ah=0,al=counter
 cmp ah,[es:di-321]
 je test2
 inc al
test2:
 cmp ah,[es:di-320]
 je test3
 inc al
test3:
 cmp ah,[es:di-319]
 je test4
 inc al
test4:
 cmp ah,[es:di-1]
 je test5
 inc al
test5:
 cmp ah,[es:di+1]
 je test6
 inc al
test6:
 cmp ah,[es:di+319]
 je test7
 inc al
test7:
 cmp ah,[es:di+320]
 je test8
 inc al
test8:
 cmp ah,[es:di+321]
 je test9
 inc al

test9:

 cmp ah,[es:di]
 jne noborn
 cmp al,2
 jne noborn
 mov byte [fs:di],23


noborn:
 cmp al,2
 je nodec
 cmp ah,[fs:di]
 je nodec
 dec byte [fs:di]
nodec:

 inc di
 loop xlp
 inc di
 dec dx
 jne ylp
 xor di,di
; xor ebx,ebx
swap:
 mov eax,[fs:di]
; mov ebx,[es:di]
; mov [fs:di],ebx
 stosd
 cmp di,64000
 jne swap
 in al,60h
 dec al
 jne mainlp
 ret