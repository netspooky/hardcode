;zacatón / streams of gaia 2
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: tsunenori - diamond sea

;# # #

;June 19th, 2o15: A team of divers located a hole at the bottom of the El Zacatón
;sinkhole, Mexico. Unfortunately it's diameter of about 23cm made it
;impossible to investigate the phenomenon any further.

;June 29th, 2o15: A team of scientists send a probe head equipped with a camera
;into the hole to analyze the unknown environment. Experiencing mysterious
;circumstances the scientists lost contact at a depth of about 597m.

;July 11th, 2o15: The computers received visual data of the camera.

;What you are about to see is an unedited feed directly from the camera. The exact
;coordinates of the probe head are unknown up to this date. Analytical results are
;not part of the transmission. Scientists believe the glowing particles being the
;results of bacteria emitting light; some people believing in ley lines say that
;those visuals - along with the visible distortions - are a direct result of energy
;reacting with the visual sensors of the probe head.

;# # #

;not much to say except that i took an idea i had and combined it with some
;older code of a starfield based thingie. i wanted some sort of distortion
;but then one thing led to another and this is the result. made in a few
;hours after finding out about the possibility of a remote entry at
;solskogen 2o15. the pressure of the deadline made it possible \:D/

org 100h
use16

;assuming: cx = 255
;using bp as global variable

start:   push 0a000h ;vga
         pop es
         push 09000h ;original screen
         pop fs
         push 08000h ;screen with extra elements
         pop gs
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx    ;cl = 0 / ch = 1
pal:    xor ax,ax
        out dx,al ;r
        shrd ax,cx,17
        out dx,al ;g
        shr al,3
        out dx,al ;b
        inc cl
        jnz pal

mov bx,16000*2       ;create positions + speed
makedata:            ;of floating particles
inc ax               ;always the same
mul bx
adc word[pos+bx],ax
dec bx
jnz makedata

main:
mov di,7000 ;enough (in theory)

draw:
mov ax,word[speed+di] ;get speed
shr ax,13
sub ax,319            ;force movement
add word[pos+di],ax   ;move

mov si,word[pos+di]   ;get pos
okay:
mov cl,5              ;size of side a of square; ch = 1 at 1st frame only
loop2:
inc si                ;move right in square
mov bx,320*5          ;size of side b of square
loop1:
add byte[fs:si+bx],8  ;draw
sub bx,320            ;move up in square
jnz loop1
loop loop2

dec di
dec di
jnz draw ;draw all floating particles

;add bars
mov di,320*165
bars:
shr byte[fs:di],1
inc di
cmp di,320*30
jne bars

in al,40h ;random movement of screen
mul al
dec ah    ;cmp ah,1;
jnz noway ;ja noway;
add bp,si ;set new pos ;si = pos of last particle

noway:
xor di,di
copie:
xor al,al
xchg al,byte[fs:di]   ;erase original screen
mov byte[gs:di+bp],al ;drop to screen with elements
mov si,di
shr si,1
mov byte[gs:si+bp],al ;add shinked screen
inc di
jnz copie

;add overlay/vertical scanlines
mov di,256 ;320
over1:
mov cx,201
over2:
imul bx,cx,320
add bx,di
mov ax,cx
add ax,di
shr ax,3                      ;don't jump over ax = 255
add byte[gs:bx-321+67-320],al ;adjusting + drawing
loop over2
dec di
dec di                ;add aesthetics by 1 extra dec
jnz over1

;make it smooth with vsync
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;add a radiation detector
;cx = 0 here
mov bx,196
values:
mov cl,byte[meter+bx] ;get height
inc cx                ;never 0
in al,40h             ;ah = 0
mul al
shr al,6              ;al / 64 = 0...3
dec ax                ;-1 so max 2 or -1
seto dl               ;if overflow set dl = 1
sbb al,dl             ;more change of value including cf?
add byte[meter+bx],al ;change height
cmp byte[meter+bx],56 ;too high?
jna nonew
mov byte[meter+bx],56 ;max height
nonew:
imul si,bx,320
add si,cx
add byte[gs:si-320],cl;blend colors in
add byte[gs:si],cl    ;make a fat bar
loop nonew

sub bx,4
jnz values

;flip
;di = cx = bx = 0 here
flip:
mov ax,word[gs:di] ;grab vscreen
stosw              ;drop + inc di
cmp di,cx
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

nop                            ;256

pos dw 8000 dup ?
speed dw 8000 dup ?
meter db 200 dup ?