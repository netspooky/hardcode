;machina [nuclearis]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: morbid orbit - stones of years

;gets more and more noisy ... but who watches THAT long? :D

;assuming bx = cx = 0

org 100h
use16

start:   push 0a000h ;screen
         pop es
         push 09000h ;buffer1
         pop ds
         push 08000h ;buffer2
         pop fs
         mov al,13h
         int 10h

;make pal fade out of black and back into black
;including changing from green to blue
        mov dx,0x3C9
        inc cx
pal:    shrd ax,cx,18
        out dx,al ;r
        shl al,1  ;
        out dx,al ;g
        mov al,bl
        out dx,al ;b
        cmp cl,64
        jb allright
        inc bl
        allright:
        inc cl
        cmp cl,127
        jne pal
pal2:   neg bl
        mov al,bl
        out dx,al ;r
        shrd ax,cx,17
        out dx,al ;g
        out dx,al ;b
;        cmp cl,63
;        ja allright2
        dec bl
        allright2:
        dec cl
        jnz pal2

;used vars:
;bp    = pi*degrees/180 = grad/57 (180/3.14... = 57,...)
;bp+2  = degrees
;bp+4  = amplitude
;bp+6  = sin*amplitude
;bp+8  = saving pos
;bp+10 = movement
;bx    = saved position of moving pixel on buffer#1

;for happy fading into the scene a.k.a. without it buffer#1 will be random shit
xor si,si
clrscr:
mov byte[fs:si],cl ;cl = 0 here so save 1b
dec si
jnz clrscr

mov word[bp],57   ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
mov word[bp+4],53 ;amplitude = thickness

;cl = 0 here
main:
in al,40h         ;seed every whole run so no slow down
;dec cl            ;=255
mov cx,1024+512      ;won't take forever to notice change of color + movement not tooo obviously
mov di,bx ;get saved position

;move the drawing pixel by recycled code to get a nice background
bringer:
;dec dl    ;won't stay 0
inc dh
add ax,cx ;won't stay 0
mul dx
shr al,6  ;256/64 [which way do you prefer, sire?]
jnz gate1
add di,320 ;move down
gate1:
cmp al,1
jne gate2
dec di     ;move left
gate2:
cmp al,2
jne gate3
inc di     ;move right
gate3:
cmp al,3
jne gate4
sub di,320 ;move up
gate4:
inc byte[fs:di]  ;change pixel
loop bringer

mov bx,di ;save position

;create values for the tubes
looper:
fild word[bp+2]      ;degrees
fidiv word[bp]       ;pi*grad
fsin
fimul word[bp+4]     ;sin*amplitude
fistp word[bp+6]     ;save new x + push ---> no finit

xor si,si                  ;make 0 before next loop
tube:
mov di,word[bp+2]          ;get pixel from vscreen via degrees
add di,word[bp+10]         ;add movement
add di,si                  ;add pos for correct displaying
mov al,byte[fs:di]         ;get pixel for tube 1
add di,65535/2
mov dl,byte[fs:di]         ;get different pixel for tube 2
neg di
mov ah,byte[fs:di]         ;get different pixel for tube 3
mov di,si                  ;save bytes by using di for further calulation
add di,word[bp+6]          ;add sin*amplitude
mov byte[ds:di+160+6],al   ;tube 1
mov byte[ds:di-54+6],dl    ;tube 2
neg di
mov byte[ds:di-320*5+2],ah ;tube 3
add si,321                 ;diagonal movement
cmp si,64000
jnae tube

;change degrees
inc word[bp+2]             ;visible area is 270 ... 90 degrees
cmp word[bp+2],270
jnae looper                ;do it again
mov word[bp+2],90

;movement
add word[bp+10],322
okay:

;add bars
mov di,320*30-1    ;-1 because of 1 pixel ^^
bar:
mov byte[ds:di],cl ;cl = 0 here so save 1b
dec di
cmp di,320*168-1   ;-1 because of 1 pixel
jne bar

;flip to screen // si >= 64000 here
flip:
mov al,byte[ds:si]
mov byte[es:si],al
dec si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret