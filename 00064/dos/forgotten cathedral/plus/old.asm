;forgotten cathedral [realm of the water shadows]

;old 66b version + 5b esc support

org 100h
use16

start:   ;push 0a000h
         ;pop es       ;4b

         les bp,[bx]   ;2b

         mov al,13h
         int 10h

;first version of pal gen
;        mov dx,0x3C9
;        inc cx;xor cx,cx
;pal:    shrd ax,cx,17
;        out dx,al ;r
;        out dx,al ;g
;        out dx,al ;b
;        inc cl
;        cmp cl,127
;        jne pal
;pal2:   shrd ax,cx,17
;        out dx,al ;r
;        out dx,al ;g
;        out dx,al ;b
;        dec cl
;        jnz pal2

;second version (saves 7b compared to 1st)
;        mov dx,0x3C9
;        inc cx ;ch = 1
;pal:    xor al,al
;        out dx,al ;r
;        shrd ax,cx,17 ;mov ax,cx ;shr al,1; = same size
;        out dx,al ;g
;        out dx,al ;b
;        add cl,ch
;        jz main
;        cmp cl,127
;        jne pal
;        neg ch ;-1
;        jmp pal

;third version (saves 2b compared to 2nd)
        mov dx,0x3C9
        inc cx ;ch = 1 cl = 0
pal:    xor al,al
        out dx,al ;r
        shrd ax,cx,17 ;mov ax,cx ;shr al,1; = same size
        out dx,al ;g
        out dx,al ;b
        cmp cl,127
        jne okay
        neg ch ;-1
okay:   add cl,ch
        jnz pal


;cl = 0 here
main:
mov bx,320
mov ch,0D2h ;2b / mov cx,64000-320*16*2 = 0D200h 3b
            ;for non flickering caused by overwriting upper parts of screen
reset:
mov di,320*16+16 ;start below upper bar ;+16 adjust difference from les bp,[bx]
                 ;still one row on left failure but ...
water:
mov ax,cx ;get (last) value
xor dx,dx ;init for div otherwise error
div bx
or ax,dx  ;make floor of flooded cathedral out of shapes
mul dx

sub ax,di

mov al,ah

add ax,si ;movement

stosb     ;incl. inc di ... at least at "correct" direction flag

cmp di,64000-320*15 ;reached top of lower bar
je reset

loop water

dec si ;mover

;jmp main ;2b

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on 7b

;         mov ax,03h            ;keep it clean :)
;         int 10h               ;5b
         ret                    ;1b