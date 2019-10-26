org 100h
use16


mov al,13h
int 10h

mov dx,03C8h
xor al,al
out dx,al
inc dx
 mov cl,40h
pallp:
 mov al,50h
sub al,cl
 add al,al
 out dx,al
; xor al,al
 out dx,al
 out dx,al
 loop pallp

;mov bh,0A0h
;mov es,bx
les bp,[bx]
;mov bh,90h
mov ds,bp

xor di,di


fillp:
mov ax,si
mov bl,15
mul bx
xchg ah,al
mov si,ax
and al,bl
mov [ds:di],al
stosb
or di,di
jne fillp

ca_lp:
mov di,321+16
mov si,199
ylp:
mov cx,319
xlp:

 mov bx,-321
 call check
 call check3
; call check2

 neg bx
 call check

 call check3;2
; call check2

 mov bx,1
 call check
 neg bx
 call check
 inc di
loop xlp
inc di
dec si
jne ylp
xor di,di
;xor si,si
mov ch,0FAh;mov cx,64000
rep movsd
in al,60h
dec al
jne ca_lp

check3:
call check2
check2:
inc bx

check:
mov al,[es:di+bx]
mov ah,al
inc al
and al,0Fh
cmp al,[es:di]
jne noeat
 mov [ds:di],ah
noeat:
ret
    