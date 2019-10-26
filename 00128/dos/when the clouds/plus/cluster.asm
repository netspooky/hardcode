;cluster // chemicals in the sky
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: ostara - bavaria

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        ;mov cx,256
        xor cx,cx
pal:    mov ax,cx
        out dx,al ;r
        shr al,1  ;
        out dx,al ;g
        shr al,1  ;
        out dx,al ;b
        loop pal

main:
add si,dx
inc byte[es:si]    ;only drop when area = 0

grid:

mov si,di          ;set position of pixel on vscreen

xor bx,bx
add bl,byte[es:di] ;don't work with black
jz drop

;create "grid" with rules on the fly
gate0:
sub ax,di  ;don't stay 0
add dx,si  ;don't stay 0
mul dx
shr al,5   ;256/32 [4..7 no movement]

jnz gate1
add si,320 ;move down
gate1:
cmp al,1   ;move left
jne gate2
dec si
gate2:
cmp al,2   ;move right
jne gate3
inc si
gate3:
cmp al,3   ;move up
jne gate4
sub si,320
gate4:

inc bx              ;rise color for shades
mov byte[es:si],bl  ;set new pixel

drop:
mov byte [fs:si],bl ;makes pulsate stuff above drop:
                    ;because only areas > 0 are drawn
                    ;below drop: it is constant speed
                    ;and everything looks powerfull
inc di
jnz grid            ;work with full screen

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret