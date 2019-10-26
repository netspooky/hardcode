;-------------------------------------------------;
;Tiniest DPMI (69b) by Tyler Durden               ;
;For use with your 256b Protected mode intros :)  ;
;Tiny DPMI by Maxwell Sayles ? Forget about it ;) ;
;Compile with Fasm 1.49                           ;
;Delete checks and other stuffs to make it smaller;
;-------------------------------------------------;
;email: dpmi@tylerdurden.net.ru                   ;
;site: www.tylerdurden.net.ru                     ;
;-------------------------------------------------;
org 100h
mov ax,1687h
int 2fh
test ax,ax ;You can delete this...
jnz .exit ;this...
mov word [dpmi_switch],di
mov word [dpmi_switch+2],es
push cs
pop ax
shl eax,4
mov [address_flat],eax
or dword [descriptor_flat+2],eax
mov al,1
mov es,ax;Not really important, delete this !
call dword [dpmi_switch];Can you do something with this (eg. call es:di) ?
push cs
pop es
xor ax,ax
mov cl,1 ;And this...
int 31h
push ax
xchg ax,bx
mov edi,descriptor_flat
mov al,0ch
int 31h
pop es
;------------------------------------------------------------------------;
;This code is from Tiny DPMI by Maxwell Sayles just for comparing...     ;
;Your program begins here.                                               ;
;You have complete access to all DPMI functions                          ;
;ES:Base=Linear address of cs,Limit=4Gb                                  ;
;CS:Old 16b code segment address so...                                   ;
;You need db 67h before commands that uses 32b registers (loop/stos etc.);
;But who cares ? If you need 32b code segment write me an email...       ;
;------------------------------------------------------------------------;
mov ax,13h
int 10h
mov edi,0a0000h
sub edi,[address_flat]
xor esi,esi
.yloop:
xor ebp,ebp
.xloop:
mov eax,ebp
sub eax,159
imul eax
mov ebx,eax
mov eax,esi
sub eax,99
imul eax
add eax,ebx
mov ecx,eax
xor ebx,ebx
xor eax,eax
inc ebx
jmp .20
.10:
inc ebx
inc eax
inc ebx
.20:
sub ecx,ebx
jae .10
db 67h
stosb
inc ebp
cmp bp,320
jb .xloop
inc esi
cmp si,200
jb .yloop
xor eax,eax
int 16h
mov ax,03h
int 10h
;------------------------------------------------------------------------;
.exit:
mov ah,4ch
int 21h
descriptor_flat db 0ffh,0ffh,0,0,0,0f2h,0cfh,0
selector_flat dw ?
address_flat dd ?
dpmi_switch dd ?
dpmi_data: