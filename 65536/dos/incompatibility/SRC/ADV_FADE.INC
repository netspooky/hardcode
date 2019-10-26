;
; advanced fade routines - (c) 1994 byteam - coded by blala 
; for incompatibility - include version - datas in code segment! 
; 
; use:
;  DS:SI - fade from  
;  ES:DI - fade to
;  CX - colors*3
;  CALL FADE_INSTALL
;  MOV CX,63
;  CIK:
;  PUSH CX
;  CALL VSYNC
;  CALL FADE_STEP
;  POP CX
;  LOOP CIK
;

fade_install:
mov cs:fade_colors,cx
push es di si
mov ax,cs
mov es,ax
mov di,offset fade_buf1
mov cx,fade_colors
cik1_fade:
xor ax,ax
lodsb
sal ax,6
stosw
loop cik1_fade
pop si di es
mov bp,offset fade_buf2
mov cx,cs:fade_colors
cik2_fade:
mov al,es:[di]
sub al,ds:[si]
cbw
mov cs:[bp],ax
inc si
inc di
add bp,2
loop cik2_fade
retn

fade_step:
push ds
mov dx,3c8h
xor ax,ax
out dx,al
inc dx
mov cx,cs:fade_colors
push cs
pop ds
mov si,offset fade_buf1
mov di,offset fade_buf2
cik3_fade:
lodsw
add ax,ds:[di]
add di,2
mov ds:[si-2],ax
sar ax,6
out dx,al
loop cik3_fade
pop ds
retn

fade_colors dw ?
fade_buf1 dw 768 dup (?)
fade_buf2 dw 768 dup (?)
