;black hole sun // gamma flash
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: fait - snow glow

;wait and maybe there will be an energy flash in your face ...

org 100h
use16

start:   push 09000h ;star screen
         pop es
         push 08000h ;vscreen
         pop gs
         push 0a000h ;vga
         pop fs
         mov al,13h
         int 10h

;assuming bx = 0 cx = 255

;make palette
;routine taken from "blue fusion"
;i was trying different colors. i liked the ones
;from "blue fusion" but did not want to use them
;again. i ended up with 2 different blue types
;and white in the middle. they got a cold feeling
;and don't create too much chaos for the eye on
;the screen (e.g. like green and blue; warm colors
;like red, yellow and pink were no option). and it
;looks nice how the dark blue comes out of the black.

        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

pal:    mov al,bl ;first half
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

;make a bit more design
;fat block will become 2 smooth lines
mov si,320*47
lines:
mov byte[fs:si],160 ;could use a register to save 1b but this color is
                    ;more appealing
inc si
cmp si,320*149
jb lines

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

;variables used:
;word[bp+10..512]: stars
;bp:               length of ray
;bp+2:             degrees
;bp+6:             x after calc
;bp+8:             y after calc
;bx:               for color cycling
;dx:               for drawing the ray
;cx:               stays 0 and saves some bytes

;create stars for correct run under dosbox (12b)
;setting random number at [bp+2] does not seem to have any negative effect
mov si,512*2
init:
in al,40h
mul si
adc word[bp+si],ax
dec si
jnz init

fninit ;erase fpu stack to keep it clean this time (2b)
       ;might not be needed in most intros under xp/dosbox ...

main:

;cx = 0 all the time
;xor dx,dx         ;init "marcher"
;mov word[bp],cx  ;init length of ray
                  ;not needed since it seems to be not visible at first run
                  ;if there is a value < 171

loop1:

fld dword[bp+2]  ;load degrees

inc word[bp]     ;length of ray
cmp word[bp],171 ;reached max = full screen in all corners ?
jna nothing       ;nope

xor dx,dx        ;yes so kill "marcher"
mov word[bp],cx  ;set new start for next part of circle

fadd dword[adder];add adder
fst dword[bp+2]  ;save degrees (no pop)
                 ;checking degrees at bottom so no error
                 ;because of wrong length of ray
nothing:
fsincos            ;cos sin
fimul word[bp]     ;cos*x/y sin
fistp word[bp+6]   ;new x + pop to empty fpu stack

fimul word[bp]     ;sin*x/y
fmul dword[shrink] ;do the shrink
fistp word[bp+8]   ;new y + pop to empty fpu stack

;test x if tooo large so now error on screen
;mov di,word[bp+6]
;add di,160       ;-159 becomes 0 ---> okay, within screen
;cmp di,319       ;smaller than -159 will stay larger number than 319
;ja skip          ;if it is larger = out of screen then skip

;y check not needed because it is hidden behind black bars
;mov di,word [bp+8]
;add di,100
;cmp di,199
;ja skip

;create pos of pixel
imul di,word[bp+8],320
add di,word[bp+6]     ;y*320+x = pos pixel

;test x if tooo large so now error on screen
add word[bp+6],160  ;code from above down here to save 1b
cmp word[bp+6],319
ja skip

cmp dx,cx ;cx = 0
jne active ;marcher is active

;marcher is inactive
mov ax,word[bp] ;set start color for ray
                ;using length of ray
add al,bl       ;making colors cycle

cmp byte[es:di+320*98+160],cl ;is there a star in visible area at star screen? cx = 0
je skip                       ;no it is not so drop and draw nothing
inc dx                        ;found a star ---> activate marcher

active:
dec ax ;create colorful ray
       ;ax is only changed here within full run of a singe ray

mov byte[gs:di+320*98+160],al ;drop ray to vscreen

skip:
cmp dword[bp+2],6.28 ;360° = 2 x pi
jnae loop1           ;work with whole circle
;mov dword[bp+2],0    ;start new circle
mov word[bp+2],cx     ;saves 2b
mov word[bp+4],cx

;flip + bars (that are empty areas at vga)
mov di,320*48
flip:
xor ax,ax
;mov byte[es:di],al  ;clear star screen in visible area is enough
xchg ah,byte[gs:di] ;get vscreen
mov byte[fs:di],ah  ;drop to screen
stosb               ;clear star screen + inc di
;inc di
cmp di,320*148
jb flip

;set stars on cleared screen + move them
mov si,10 ;don't overwrite degrees since they are 0 at this point
stars:
mov di,word[bp+si]  ;get pos star
sub word[bp+si],321 ;move star
inc byte[es:di]     ;set star on cleared star screen
inc si              ;word!
inc si
cmp si,256*2
jna stars

inc bx ;make colors cycle

         ;mov ah,01h            ;read keyboard
         ;int 16h               ;read, dammit!
         ;jz main               ;nothing so go on

         in al,60h              ;since ah (almost everytime!) 0 here
         dec ax                 ;save 1b and only respond to ESC
         jnz main               ;but maybe several hits will be needed to quit

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

adder dd 0.0038
shrink dd 0.84 ; x-y-ratio