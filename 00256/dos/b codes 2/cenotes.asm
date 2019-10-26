;cenotes
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;side product of my intro evk.7e0 ... but basically
;"hic sunt dracones" with another appearence.

;assuming: ax = bx = 0 cx = 255 cs = si = di = 0100h

org 100h
use16

start:   push 0a000h
         pop es
         push 08000h
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

pal:    shrd ax,cx,17;mov al,bl ;first half
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        inc cx
        cmp cl,127
        jne pal
mov bl,63
pal2:   shrd ax,cx,17 ;second half
        out dx,al ;r
        out dx,al ;g
        mov al,bl
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

main:
inc bp
;create a bit variation in timing and explosion
;in al,40h
mul bp
cmp ah,127
jne boom
adc byte[ds:bp],al


;di = 0 here after 1st run
boom:
inc ax   ;avoid 0 over a longer time span
sub dx,bp
mul dx
shr al,5;6 makes "moon"       ;6=256/64 = 4
movzx bx,al
shl bx,1      ;word
mov al,byte[ds:di]
add byte[es:di],al ;creates the pattern, sub makes it sparkly
cmp al,ch;0
je nopey
mov bx,word[cs:ways+bx]
inc ax
mov byte[ds:bx+di],al ;draw explosion
mov byte[es:bx+di],al ;skipping that makes "sand"
nopey:
dec di
jnz boom ;whole screen



mov dx, 3dah           ;wait for vsync for constant speed
;vsync1:                ;to make things smoother and not
;in al,dx               ;rushed
;test al,8              ;vsync1 not needed for result
;jnz vsync1             ;so 5b for another crystal in the scene :)
vsync2:
in al,dx
test al,8
jz vsync2

         in al,60h ;read keyboard
         dec al    ;check it, dammit!
         jnz main               ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h               ;dies anyway on real/free dos
         ret
;for the boom
ways dw 1,-1,320,-320,319,-319,321,-321