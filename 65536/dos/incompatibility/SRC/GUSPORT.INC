;
; get gusport base adress, and return in bx
;

assume ds:code

gusport:
push ds cs
pop ds
;
mov dx,offset gustext1
mov ah,9
int 21h
cik1_gusport:
xor ax,ax
int 16h
cmp al,'Y'
je ecik1_gusport
cmp al,'y'
jne cik1_gusport
ecik1_gusport:
;
mov dx,offset gustext2
mov ah,9
int 21h
mov cx,8
cik2_gusport:
push cx
mov ah,9
mov dx,offset gustext3
int 21h
inc byte ptr ds:modify1gus
inc byte ptr ds:modify2gus
pop cx
loop cik2_gusport
mov dx,offset gustext4
mov ah,9
int 21h
;
cik3_gusport:
xor ax,ax
int 16h
cmp al,'0'
jb cik3_gusport
cmp al,'7'
ja cik3_gusport
sub al,'0'
shl al,4
xor ah,ah
mov bx,200h
add bx,ax
mov ah,2
mov dl,0dh
int 21h
mov dl,0ah
int 21h
pop ds
retn

gustext1 db 13,10,'have you got a GUS anywhere [y/y] ?? $'
gustext2 db 13,10,'and where do you have it ??$' 
gustext3 db 13,10,' '
modify2gus db '0 - baseport 2'
modify1gus db '00h$'
gustext4 db 13,10,' 8 - on the shelf:)'
         db 13,10,'please select: $'

            
assume ds:data1