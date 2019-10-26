;neon // the billboard intro
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: first aid kit - wolf

;welcome to my 1st prod of 2o17. coded between christmas
;and new years eve, finished/polished a bit later. too
;much candy was killed during that time. yummy!

;i wanted to make something with hexagons. while optimizing
;(the first drawing routine was about 40 bytes larger) i
;tried the shape of an arrow. but since i could not decide
;between hexagons and arrows i went with including both. ok,
;this costs some bytes but i think it turned out pretty neat.
;the whole thing reminded me on neon lights/ads in
;some video game background (streets of rage 2 ftw!).
;hardest part was to chose the colors (like so many times
;before ... it is the never ending story)

;the result: it's not simple - it's minimalistic ;)

;i was in the mood (bored? egg nog?) to comment this one
;quite heavily.

;###########################################################

;so if you read this i hope you'll find a lot of inspiration
;in 2o17 to create some nice/interesting/good looking
;intros/demos on your platform of choice :) or maybe it is
;finally time to code+release a 256b dos intro that will
;surprise us all :D

;###########################################################

;assuming: ax = bx = 0 / cx = 255

org 100h
use16

start:   push 0a000h     ;vga
         pop es
         push 08000h     ;vscreen
         pop fs
         mov al,13h      ;set 320*200*256
         int 10h         ;now!

        mov dx,0x3C9  ;set rgb values of color table
        inc cx        ;cl = 0 / ch = 1
pal:    xor ax,ax      ;green/blue
        out dx,al ;r   ;not that video game like compared
        shrd ax,cx,18  ;to pink/red/blue but more demoish
        out dx,al ;g   ;and less brothel like :D
        shl ax,1       ;since i had to decide i went
        out dx,al ;b   ;with this one
        nop            ;i tried other color combinations
        nop            ;but they did look boring or ugly

;        shrd ax,cx,18 ;pink/red/blue is very neon and video game like
;        out dx,al ;r  ;but it looks cheap at the same time :\
;        xor ax,ax     ;skipping xor = yellow/blue which
;        out dx,al ;g  ;has clean transitions like green/blue
;        shrd ax,cx,17 ;and looks very polished
;        out dx,al ;b  ;but somehow boring as fuck

        mov word[sze+bx],bx ;setup sizes of elements
        inc bx              ;eats some bytes
        inc bx              ;but provides fixed variation

        inc cl
        jnz pal             ;change ze whole pal

main:
mov word[hlp],42 ;number of elements*2 because of word access
                 ;so 20 elements are a nice amount

all:
mov si,word[hlp]     ;get number of element to access correct data set
shrd ax,si,16+4      ;calc parallax scrolling
;inc ax ;always movement
imul ax,ax,320       ;calc change
;sub word[pos+si],ax ;change pos ;moved down below "ok" to save 4b
mov dx,word[sze+si] ;get size
inc dx              ;increase size
cmp dl,61           ;max size? dh = 0 (always)
                    ;62..64 makes darker area at last step/biggest sizes
                    ;which is annoying as fuck
                    ;60/61 blends right in the background
jbe ok              ;no
mov dl,4            ;set min size
                    ;a smaller value gives an underflow
                    ;and eyecancer
in al,40h           ;rnd
mul al              ;rnd for dosbox +2b
                    ;no mul 16bit since dx already used!
;sbb word[pos+si],ax ;change the pos where the element
                    ;will grow next time
ok:
sub word[pos+si],ax ;change pos/set new rnd pos

mov word[sze+si],dx ;save changed size

mov ax,dx           ;take the size
shr ax,1            ;element will grow to left and right
imul ax,ax,-321     ;and to top and bottom
add ax,word[pos+si] ;so adjust the pos of the element

mov word[hlp2],ax   ;save final pos to free ax for further use
xor si,si           ;steps/lines (data sets)
xor bx,bx           ;pos of drawing
draw:
xor bp,bp           ;access data of arrow
test byte[hlp],2    ;hexagon or arrow?
jz fine             ;bit not set so stay arrow
mov bp,6            ;set to access data of hexagon
fine:
mov ax,dx              ;size from above
mov di,si              ;get the right part/line
shr di,1               ;accessing byte
mov cl,byte[shrs+di+bp];changer for length of line to be drawn
shr ax,cl              ;change length
mov cx,ax              ;setup loop counter
shl bp,1               ;for word access of directions
draw2:
mov di,word[hlp2]      ;set center of the element
;mov al,dl ;color
;shl al,2
shld ax,dx,18          ;save 1b
neg al                 ;fading
mov byte[fs:bx+di],al  ;draw
mov byte[fs:bx+di+1],al;make it thicker (word will cause runtime error)
add bx,word[ways+si+bp];move drawing pixel
loop draw2             ;done full length of line?
inc si
inc si
cmp si,14              ;done all lines/segments of element?
jne draw

sub word[hlp],2
jnz all                ;all elements done?

;traditional element of designement ;)
mov di,60              ;width
bars:
xor bx,bx              ;height
bars2:
add word[fs:bx+di],si    ;si = 14, no error so save 1b
;add word[fs:bx+di+70],si ;use remaining 4b to make it a bit better
;shr word[fs:bx+di+70],1 ;use remaining 4b to make it a bit better
;mov byte[fs:bx+di+70],cl ;change lines to triangular pixels
mov word[fs:bx+di+70],cx ;fake worse resolution :)
add bx,319*2             ;make it look like crt
jnc bars2                ;until it reaches the top of memory
dec di                   ;move it like mick jagger
dec di                   ;not really needed but it sharpens the look
jnz bars

mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;cx = di = 0 here
mov di,320*35 ;copy only a part of the screen
              ;to have pal bars
;mov cx,320*64 ;=5000h
;mov cx,320*48 ;=3c00h
mov ch,50h ;-1b
flip:
mov ax,si           ;si = 14 so use it to make stripes on the billboard
xchg ax,word[fs:di] ;grab vscreen and drop stripes to it
stosw               ;drop data to vga + inc di
;cmp di,320*164
;jne flip
loop flip           ;do ze whole visible area

         in al,60h            ;read keyboard buffer
         ;cmp al,1             ;ESC?
         ;jne main               ;nothing so go on
         dec ax               ;save 1b because ax = 0 is possible
         jnz main
breaker: ret                  ;byebye

;directions of drawing
ways dw  -319,321, -1,320,  -1,-320,-1 ;arrow
ways2 dw    1,321,319, -1,-321,-319    ;hexagon

;this makes length of drawing/line by shr ?
shrs db   1,1,2,1,1,1,2               ;arrow
shrs2 db  0,1,1,0,1,1                 ;hexagon

hlp dw ?           ;number of elements
hlp2 dw ?          ;helpa helpa
pos dw 300 dup ?   ;what it is
sze dw 300 dup ?   ;exactly what it is