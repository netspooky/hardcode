org 100h
use16

mov al,13h
int 10h

mov bh,0a0h
mov es,bx
sub bh,al;mov bh,090h
mov ds,bx
sub bh,al;mov bh,080h
mov fs,bx

out_pal:
 mov dx,03c8h
 mov al,bl
 out dx,al
 inc dx
 xor al,al
 out dx,al
 out dx,al

; and al,127
; cmp al,64
; jl noneg
; neg al
;noneg:
 mov al,bl
 and al,63
; out dx,al
; out dx,al
; xor al,al
 out dx,al
 inc bl
 jne out_pal


doi:
; mov byte [fs:160+100*320],255
mov dl,199
mov di,321
ylp:
 mov cx,318
; push di

xlp:
xor ax,ax
xor bx,bx
mov al,[fs:di-320]
mov bl,[fs:di+320]
add ax,bx
mov bl,[fs:di-1]
add ax,bx
mov bl,[fs:di+1]
add ax,bx
shr ax,1

mov bl,[ds:di]
sub ax,bx
jns putw
xor al,al
putw:
mov [ds:di],al

stosb
;mov [es:di],al
; inc di

 loop xlp


 dec byte [fs:si]
;- mov byte [fs:si],dl

; inc si
 add si,bp
; inc bp
; inc bp
 add bp,4
 
 inc di
 inc di
; add di,320
 dec dl
 jne ylp

push ds
push fs
pop ds
pop fs

  in al, 60h
  dec al
  jnz doi

 ret
