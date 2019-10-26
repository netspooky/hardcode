;errorbirds [in the sky]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: glorie - the lotus

;piece of code from working on "forgotten cathedral".
;there are errorbirds in the digital sky.

;DosBox: about 60.000 cycles should do their job

org 100h
use16

start:   ;push 0a000h
         ;pop es      ;4b
         les bp,[bx] ;2b
         mov al,13h
         int 10h

;assuming: cx = 255

;make nice palette (=
        mov dx,0x3C9
        inc cx ;ch = 1 cl = 0
pal:    shrd ax,cx,18
        out dx,al ;r
        shr al,1
        out dx,al ;g
        mov al,63
        out dx,al ;b
        dec cl
        jnz pal

mov bx,317     ;about that much to make birds
main:

mov cx,320*160  ;screen
mov di,cx       ;bars
add di,320*65-48;bars

doit:
sbb ax,di      ;bla
xor dx,dx      ;prepare for div
div bx         ;bla
sbb ax,dx      ;bla
mul dx         ;bla
mov al,ah      ;bla
or ax,si       ;add "movement" ;add for normal noise
stosb          ;output + dec/inc di
loop doit

dec si         ;"movement"

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

;         mov ax,03h            ;keep it clean :)
;         int 10h               ;5b
         ret                   ;1b