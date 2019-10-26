;[rise and fall of] byte vegas
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: Karafuto - Untitled (A)

;actually this intro is older  than "byteropolis" but i got stuck
;almost forever at 33b.  while trying  to get this 1b off  i came
;across this intros big 31b brother: "byteropolis". and i decided
;to release it because i really like(d) it.

;after getting not only 1b away but 3b i did not really know what
;to do.  release or not?  first i  wanted to add it as some bonus
;to "hic sunt leones" since the code is almost the same. but then
;i found out that outline  accepts remote entries and there i had
;had my  answer no  matter how similar the code is. and i think a
;contribution  to  a compo  is better  than a  bonus if  you just
;can't decide.  and because this  is byteropolis' little sister i
;made the visible area a bit smaller ;)

;after a  while the  viewer drowns  in a lake of colors where the
;city reveales its secret too:  it is only an illusion.  and 30b.

;assuming: ax = bx = 0

org 100h
use16

start:   ;push 0a000h
         ;pop ds       ;[4b]
         lds bx,[bx] ;ds=0a000h bx=offset
                     ;bx saves 1b compared to bp [2b]
                     ;since the intro has 30b it would be possible
                     ;to use a clean init but that won't affect the
                     ;intro itself so ... sizes does matter :D

         mov al,13h ;[2b]
         int 10h    ;[2b]

reset:
mov bh,06eh    ;320*88 = 06e00h ;[2b]
dec cx         ;changes seed 2 every "frame" [1b]

main:
mov al,byte[ds:bx+320*51+15] ;get seed 1 from above [4b]
add ax,cx                    ;[2b] add seed 2
xor dx,dx                    ;[2b] prepare div
div bx                       ;[2b] do
shl dl,1                     ;[2b] mul 2

mov byte[ds:bx+320*52+15],dl ;to screen + adjust for upper bar
                             ;+ adjust because of lds (+15)
                             ;[4b]

dec bx                       ;work with visible area [1b]
jz reset                     ;no more inside visible area ---> reset
                             ;[2b]

jmp main                     ;still inside visible area ---> just go on
                             ;[2b]

;         mov ah,01h            ;read keyboard
;         int 16h               ;read, dammit!
;         jz main               ;nothing so go on 7b

;         mov ax,03h            ;keep it clean :)
;         int 10h               ;5b
;         ret                   ;1b