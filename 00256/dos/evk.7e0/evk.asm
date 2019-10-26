;evk.7e0 // the logo boom
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: custom model - frothin' (roboclip remix)

;most of the code reused from other intros (like pal gen + explosion routine)
;but i wanted to make an invitro for evoke which simply looks nice. so i hope
;i hit that goal. i love the evoke logo of 2o16 so i had to put it into 256b.

;the original logo was done by chunna, pixtur and susencrusen.

;the intro uses vsync and was tested under xp (real + vmware), dosbox and freedos.

;assuming: ax = bx = 0 cx = 255 cs = si = di = 0100h

org 100h
use16

start:   push 0a000h
         pop es
         push 09000h
         pop ds
         push 08000h
         pop gs
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

;blue colors don't make eyes bleed and it is a decent
;combination. and most of all i like it.
pal:    mov al,bl ;first half black ---> blue ---> white
        out dx,al ;r
        out dx,al ;g
        shrd ax,cx,17
        out dx,al ;b
        cmp cl,64
        jb allright
        inc bx
        allright:
        inc cx
        cmp cl,127
        jne pal
pal2:   shrd ax,cx,17 ;second half white ---> brighter blue ---> black
        out dx,al ;r
        out dx,al ;g
        mov al,bl
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

;force a clean start (xp/freedos ...) for the cost of 6b
;since memory = ?
cls:
mov byte[gs:bx],cl
dec bx
jnz cls

main:

;create a bit variation in timing and explosion
in al,40h
mul al
cmp ah,180
jb boom
mov byte[gs:320*98+162],al ;origin of explosion = middle of logo
                           ;also al is the power of the explosion
                           ;since colors add up from 1 to 255 and 0
                           ;x+2 for a little adjustment

;di = 0 here after 1st run
;yes, heavy reuse.
boom:
inc ax   ;avoid 0 over a longer time span
adc dx,di
mul dx
shr al,6       ;6=256/64 = 4
movzx bp,al
shl bp,1      ;word
mov al,byte[gs:di]
mov byte[ds:di],al ;copy every byte to 2nd buffer
cmp al,bl;0
je nopey
mov bp,word[cs:ways+bp]
inc ax
mov byte[gs:bp+di],al ;do explosion
nopey:
dec di
jnz boom ;whole screen

;drop the evoke logo to the 2nd screen
;di = 0 here
loopsie:
;mov bp,di
;shl bp,1 ;word!
shld bp,di,16+1 ;same size

mov ax,word[cs:how+bp]    ;direction of drawing
mov bp,word[cs:where+bp]  ;pos
mov cl,byte[cs:when+di] ;length ;ch = 0 here
draw:
add bp,ax
rol byte[ds:bp+320*44+16],1 ;draw slightly out of y center
;mov byte[gs:bp+320*44+16],ch
loop draw
inc di
cmp di,7
jna loopsie
;rol byte[ds:320*98+160],1 ;center

;bl = always 0 here
;bars ... not the ones to get swole arms with
;setting only bh instead of bx saves 1b each time.
mov bh,4bh;mov bx,320*60;4b00h
bars:
mov al,byte[gs:bx+15]
mov byte[ds:bx],al
dec bx
cmp bh,0afh;cmp bx,320*140 ;af00h
jne bars

mov bh,0cdh;mov bx,320*164 ;cd00h
bars2:
xchg al,byte[gs:bx];BURNOUT BITCH
add byte[ds:bx],al ;leave the bytes & double the fun :)
inc bx
cmp bh,2dh;cmp bx,320*36 ;2d00h
jne bars2

mov bh,0e1h;mov bx,320*180;e100h
bars3:
neg byte[ds:bx]
inc bx
cmp bh,19h;cmp bx,320*20;1900h
jne bars3

mov dx,3dah ;wait for vsync for constant speed/slowing down
vsync2:
in al,dx
test al,8
jz vsync2

;don't care about the first 7 bytes since di = 7 here
;der_erdnussflip:
;mov al,byte[ds:di]  ;grab
;mov byte[es:di],al  ;drop
;inc di
;jnz der_erdnussflip

mov si,di ;make it even
sub cx,di ;set the correct counter
rep movsb

         in al,60h ;read keyboard
         dec al    ;check it, dammit!
         jnz main               ;nothing so go on
breaker: ;for finding the bug. am i the only too lazy to use a debugger?
;         mov ax,03h            ;keep it clean :)
;         int 10h               ;dies anyway on real/free dos
         ret
         nop;256

;directions for the boom
ways dw 1,-1,320,-320;,319,-319,321,-321

;the evoke logo ... kinda. the 2 E are 3 lines instead of 6 and the left ones are 1 pixel
;below the right ones because of the jump when overriding the screen size of 320 on x.
;but this saves 15 bytes compared to 6 single lines. and who is there to judge? stand up
;and speak - or stay silent forever. wait. what? you did read this? congrats. nerd :D

;        left \      left |      right |      right /     right \     upper -    middle -    lower -

;starting pos of line to be drawn
where dw 320*30+90, 320*42+123, 320*42+163, 320*30+196, 320*54+172, 320*50+184, 320*54+179, 320*58+184

;direction in which the line has to be drawn
how   dw 321      , 320       , 320       , 319       , 321       , 1         , 1         , 1

;length of the line
when  db  33      , 20        , 20        , 33        , 17        , 237       , 247        ,247