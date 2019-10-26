;[life and death of] byteropolis
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: hauschka with kai angermann - brighton one

;i wanted to make a 32b that is not fullscreen. so i made up the
;routine and used the remaining bytes to make something happen
;between the black bars.

;after a while the viewer drowns in a lake of colors where the
;city reveales its secret: it is only an illusion. and 31b.


org 100h
use16

start:   ;push 0a000h
         ;pop es       ;4b
         lds bx,[bx] ;ds=0a000h bx=offset
                     ;bx saves 1b compared to bp
         mov al,13h
         int 10h

reset:
mov bh,0A5h ;320*132 = A500h ;lower bar [2b]
            ;was mov bx,320*130         [3b]
            ;bx = 0 after first run

dec cx         ;changes every "frame" [1b]

main:
xor ax,ax                    ;[2b] set up so no fragments inside ax
add ax,cx                    ;[2b] add change thingie
xor dx,dx                    ;[2b] init for div to avoid overflow
div bx                       ;[2b] never 0 (=
imul ax,dx,2                 ;[3b] shoop da whoop ;mul 2 looks best at least for me
or al,dh                     ;[2b] make texture to minimalize flickering + making houses

mov byte[ds:bx+320*34+15],al ;drop to screen [4b]
                             ; + adjust for upper bar
	                         ; + adjust because of lds (+15)
dec bx                       ;[1b]
jz reset

jmp main

;         mov ah,01h            ;read keyboard
;         int 16h               ;read, dammit!
;         jz main               ;nothing so go on 7b

;         mov ax,03h            ;keep it clean :)
;         int 10h               ;5b
;         ret                    ;1b