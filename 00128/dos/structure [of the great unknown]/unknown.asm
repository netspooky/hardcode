;structure [of the great unknown]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: sabled sun - signals II

;####################################################################
;
;logfile k3-sl.7
;
;passed planet named x334-8-rho while on maintenance.
;tested sensors and scanners. x334-8-rho is about 1.73 times larger
;than earth. no life detected. no atmosphere. no water. ice under the
;surface near south pole. discovered unknown structure near equator.
;decided examination.
;
;discovered huge ring. origin unknown. unkown alloy used.
;diameter about 700 metres. partly hidden under boulder/dust.
;discovered platform/entrance. presence causes reaction of
;surface of inner structure. structure has organic/round forms.
;team tried to examinate inner area of structure. depth unknown.
;team disappeared.
;
;rescue teams 1 + 2 disappeared after life transmissions stopped.
;
;sent emergency call. arrival of armed auxilary forces in aprox.
;87hrs.
;
;only 3 crew members left.
;
;going down into structure. can't wait for back up.
;might be too late.
;
;will place camera on edge of platform.
;
;run live stream by executing "unknown.com"
;
;who reads this: stay alert.
;
;#################################################################

;Info: See palette generation/fpu-part/exit for difference between
;      compo version and normal version.

;#################################################################

org 100h
use16

start:   push 0a000h ;vga
         pop ds
         mov al,13h
         int 10h

;used variables:
;bp   = amplitude
;bp+2 = cos(sin(amplitude))
;bp+4 = degrees
;bp+6 = 57 = 180/pi normally

;make palette
        mov dx,0x3C9
        ;xor cx,cx    ;keep it clean since cx might be <> 255 at start on older machines [compo]
        inc cx       ;no problem under xp/dosbox since you can assume cx = 255 at start [normal]
pal:    mov ax,cx
        out dx,al ;r
        out dx,al ;g
        shr al,3  ;make a nice mix
        out dx,al ;b
        in al,40h ;create start pattern so most starts are [normal]
        adc bx,ax ;different from the previous one         [normal]
        ;mov bx,56500 ;set fixed value for compo [compo]
                     ;so no fugly stuff will appear ^_^
        inc cl
        jnz pal

;ch stays 0 all the time

mov word[bp+6],67 ;looks a bit more epic than 57
main:

;mov dx,-300 ;amplitude (working -299 to 300 for complete filling of screen)
neg dx       ;in worst case the first time blank screen
             ;makes -300 after first run
             ;saves 1b
             ;no error because of check below

loop2:
mov cl,120        ;height of column (y)
mov word[bp+4],bx ;start degree for movement
loop1:
mov word[bp],dx   ;get amplitude to work with

;fninit           ;enable for [compo]
fild word[bp+4]   ;degrees
fidiv word[bp+6]  ;round and round
fsin
fcos
fimul word[bp]   ;amplitude
fistp word[bp+2] ;new value x + emptry stack

;create correct pos
imul di,cx,320    ;y
add di,word[bp+2] ;+x

;check so no wrong output / check if range -159 -- value -- 160
;cmp word[bp+2],160
;jb noskip                ;no overflow on the right
;cmp word[bp+2],65535-159
;jb skip                  ;overflow at the left!

add word[bp+2],160 ;-159 gets 0
cmp word[bp+2],320 ;so range 0 .. 320
jae skip           ;-2b compared to above

noskip:
mov ax,dx ;amplitude as base for color
sub ax,bx ;move texture!

or al,bh          ;change pattern every 256 frames and have "oral" in code
xor ax,word[bp+4] ;texturize

mov byte[ds:di+160+320*36],al ;drop to screen

mov byte[ds:250+320*156],ch ;set little body to screen 4b
mov byte[ds:250+320*155],ch ;set little head to screen 4b
mov byte[ds:250+320*154],ch ;set little head to screen 4b

skip:
inc word[bp+4]     ;change degrees (adds value of cx)

loop loop1 ;draw from bottom to top

inc dx
cmp dx,300 ;worked with full amplitude?
jne loop2

dec bx     ;change start degree for movement downwards + value for sidewards movement

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;cut out for [compo] to get bytes for fninit
         int 10h               ;cut out for [compo] to get bytes for fninit
         ret