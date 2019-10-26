;journey to the 17th colossus // stomp!
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: treha sektori - ah estereh komh derah

;i am sorry. not :D messy code, not much design but a lot of fun while
;coding. the first rough and running version was about 325 bytes which sucked.
;different (and better) ending than in the original version.

;tbh this one was meant to be released at evoke 2o17 but it was not shown. maybe
;it got lost or it simply did not pass the quality check ... well, for good
;reasons no? ;) so i sent it on its way to function to support the compo and to
;release it because i like it :D

;for more story prods!

;beware of the 17th colossus, tiny human. can you handle the tension?

;esc is needed to exit even after the end.

org 100h
use16

;assuming cx = 255

start:   push 08000h ;buffer
         pop ds
         push 0a000h ;vga
         pop es
         mov al,13h
         int 10h

xor bp,bp ;scene #
;mov bp,6 ;testing
main:

mov ax,1d0fh;29/15 ;saving bytes below while setting colors

;floor is always shown
mov bx,320
bottom:
mov byte[ds:bx+320*181-1],al
dec bx
jnz bottom

movzx dx,byte[cs:scenedatasets0+bp] ;read data of scene

bt dx,3      ;test if stairs
jnc nostairs
;xor bx,bx ;bx = 0 here
mov cl,174      ;ch always 0 here
stairs:
mov word[ds:bx+320*7],ax
add bx,321
loop stairs
nostairs:

mov cx,0e2ah         ;14/42 so save bytes on colors of torches
bt dx,2           ;test if torches on stairs
jnc nostairstorch
mov bx,12*15*321
torch2:
mov byte[ds:bx+10-321*10],ch
mov byte[ds:bx+320+10-321*10],cl
sub bx,15*321
jnz torch2
nostairstorch:

bt dx,1            ;test if torches on floor
jnc nonormaltorch
mov bx,20*15
torch1:
mov byte[ds:bx+320*171],ch
mov byte[ds:bx+320*172],cl
sub bx,15
jnz torch1
nonormaltorch:

mov cx,4      ;save 1b below

bt dx,0       ;test if doof availiable
jnc nodoor
;mov bx,320*100 ;=7d00
mov bh,7dh      ;save 1b and it works
door1:
mov di,cx;5        ;how wide is ze dooar?
door2:
mov byte[ds:bx+di+320*80+260],al
dec di
jnz door2
sub bx,320
jnz door1
nodoor:

;hero moves to the right until there is something in front
;if +321 is free he moves there (stairs)

;mov cx,4  ;ch not 0 here
xor bx,bx ;bx not always 0 here
body:
mov si,bp
mov di,word[cs:herodatasets+si+bp] ;word access
add di,bx
mov byte[ds:di],ah
add bx,320
loop body

inc di
cmp byte[ds:di],al;15 ;hero runs into something
je next               ;which triggers next screen

again:
in al,40h
mul al
cmp ah,254 ;slow the hero down
jne again
;mov si,bp
inc word[cs:herodatasets+si+bp] ;word access

cmp byte[ds:di+320],cl;0 ;space below ( = walking on stairs) ?
jne nope
add word[cs:herodatasets+si+bp],319 ;word access; 319 to stay on stairs!
nope:

;xor si,si ;not needed so save those 2b
;cx = 0 here
flip:
xor ax,ax
xchg al,byte[ds:di]  ;grab data + delete background
stosb;mov byte[es:di],al  ;drop to screen
loop flip
jmp check

next:
inc bp       ;next scene
cmp bp,7     ;reached last scene?
jae breaker  ;yes so show the colossus :D

check:
in al,60h   ;esc?
dec ax      ;ah = 0
jnz main    ;no esc so go on

breaker:
;mov bx,320*184 ;e600h
mov bh,0e6h;
foot1:
mov al,28
mov di,230
;cmp bx,320*80 ;6400h
cmp bh,64h
ja foot2
inc ax
mov di,95
foot2:
mov byte[es:bx+di+70-320*4],al
dec di
jnz foot2
sub bx,320
jnz foot1

waiting:      ;make wait until esc is pressed
in al,60h
dec al
jnz waiting
ret          ;exit


;0 = inactive 1 = active
;                 0      1       2            3            4
;                 bgcol  stairs  stair torch  normal torch door
;scenedatasets0 db 42,    0,      0,           0,           0        ;scene 0
;scenedatasets1 db 42,    0,      0,           0,           1        ;scene 1
;scenedatasets2 db 0,     1,      0,           0,           0        ;scene 2
;scenedatasets3 db 0,     0,      0,           1,           0        ;scene 3
;scenedatasets4 db 0,     1,      1,           0,           1        ;scene 3


scenedatasets0 db      00000000b ;nothing
scenedatasets1 db      00000001b ;door
scenedatasets2 db      00001000b ;stairs+torches
scenedatasets3 db      00000010b ;torches
scenedatasets4 db      00001101b ;stairs+torches+door
scenedatasets5 db      00000010b ;torches
scenedatasets6 db      00000001b ;door

;start pos of hero on start of a scene
;                  0       1     2    3    4    5    6
herodatasets  dw 320*176,320*176,0,320*176,0,320*176,320*176