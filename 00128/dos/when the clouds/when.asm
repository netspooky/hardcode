;when the clouds // rise from the sea
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: h.u.v.a. network - dissolving

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,cx
pal:    mov ax,cx
        shr al,2
        out dx,al ;r
        out dx,al ;g
        mov al,63
        out dx,al ;b
        loop pal


main:

inc cl
jnz grid
add si,dx
mov byte[es:si],1   ;drop a cloud
add si,ax
inc byte[es:si]    ;only drop when area = 0


grid:

mov si,di          ;set position of pixel on vscreen

xor bx,bx
add bl,byte[es:di] ;don't work with black
jz drop

;mov cx,2 ;make clouds bigger
;create "grid" with rules on the fly
gate0:
sub ax,di  ;don't stay 0
add dx,ax  ;don't stay 0
mul dx
shr al,5   ;256/32

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
;loop gate0 ;make eg -1 +320 possible in one run

go:
cmp ah,121          ;keep color?
ja stay
inc bx              ;rise color for shades
stay:
mov byte[es:si],bl  ;set new pixel

;bars 12b
;cmp si,320*28
;jb drop
;cmp si,320*170
;ja drop

mov byte [fs:si],bl ;makes stuff more dynamic above drop:
                    ;because only areas > 0 are drawn
                    ;below drop: it is constant speed
drop:
dec di
jnz grid            ;work with full screen

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret