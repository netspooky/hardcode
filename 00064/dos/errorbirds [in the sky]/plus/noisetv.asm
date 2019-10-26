;noise.tv
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: dj shadow - dark days

org 100h
use16

start:   push 0a000h
         pop es
         mov al,13h
         int 10h
;assuming:
;cx = 255

;make pal black-white-black
        mov dx,0x3C9
        inc cx ;ch = 1 cl = 0
pal:    shrd ax,cx,17
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        cmp cl,127
        jne okay
        neg ch ;-1
okay:   add cl,ch
        jnz pal

mov bx,320
main:

add ax,di
xor dx,dx
div bx   
sub ax,dx
mul dx   
sub ax,cx
mov al,ah
add ax,si
stosb
loop main

dec si

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

;         mov ax,03h            ;keep it clean :)
;         int 10h               ;5b
         ret                    ;1b