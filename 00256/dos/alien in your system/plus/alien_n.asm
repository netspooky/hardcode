;alien.in.your.system // noiseless
;www.sensenstahl.com


;hmmmmmmmmmmm just added to the archive. so not part of the original release --> files.nfo


org 100h
use16

start:   push 0a000h
         pop es
         push 08000h  ;z-buffer
         pop gs
         mov al,13h
         int 10h

          mov dx,03C9h ;^^
          mov cx,256 ;inc ch (save ?)
palette:  mov ax,cx
          shl ax,1  ;- for rainbow
          out dx,al
;          shl ax,1  ;+ for rainbow
          out dx,al
;          shl ax,1  ;+ for rainbow
          out dx,al
          loop palette

main:

;around z axis | x=cos*x-sin*y | y=sin*x+cos*y        [1]
;in: z(in1) x(in2) y(in3)
;out:z(in1) x'     y'

;around y axis | x=cos*x-sin*z | z=sin*x+cos*z        [2]
;in: y(in1) x(in2) z(in3)
;out:y(in1) x'     z'

;around x axis | y=cos*y-sin*z | z=sin*y+cos*z        [original]
;in: x(in1) y(in2) z(in3)
;first:  c*in2-s*in3 = y'
;second: s*in2+c*in3 = z'
;out: x(in1) y' z'


fild word [y] ;load (in3)
fldz;fild word [x] ;load (in2)
fldz;fild word [z] ;load (in1)

call rotation

fistp [z2] ;grab new value
fistp [x2] ;grab new value
fistp [y2] ;grab new value


sub word [x2],80 ;make torus


push word [grad] ;save
mov word [grad],360
roundandround:

fild word [z2] ;load
fild word [x2] ;load
fild word [y2] ;load

call rotation

fistp [y3] ;grab new value
fistp [x3] ;grab new value
fistp [z3] ;grab new value

add word [z3],260

cmp word [z3],185
jb nope

mov ax,200
imul word [x3]

idiv word [z3]
mov di,ax;mov word [x2d],ax ;save calculated 2d value

mov ax,200
imul word [y3]

idiv word [z3]
;mov word [y2d],ax ;y2d is in ax

mov dx,320
mul dx     ;mul word [y2d]
add di,ax  ;di contains x value now add y
add di,320*100+160   ;centerize
mov ax,word [z3]     ;check z
cmp al, byte [gs:di]
jb nope
mov byte [gs:di],al  ;set new checkbyte @ buffer

mov ax, word [grad]
shr ax,2

sub ax, bx ;bx = color

mov ah,al
stosw ;mov byte [fs:di],al; --> stosb to es:di because of size (no buffer)
mov word [es:di+318],ax
nope:


inc bx ;bx = color

dec word [grad]
jnz roundandround

pop word [grad] ;restore!

sub bx,9 ;bx = color ; 7 = to the right / 9 = to the left

dec word [grad]
jnz main
mov word [grad],360


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :) ;or don't ;)
         int 10h
         ret


rotation:
;                     0              1             2             3             4         5         6         7
;                     x (in1)        y (in2)       z (in3)

;                     0              1             2             3             4         5         6         7
;                     x              y             z
;fldpi                ;pi             x             y             z
fild word [grad]
fidiv word [for_rad]  ;=180/pi
fst dword [gs:0000h] ;)

                     ;g              x             y             z
fsincos              ;cos           sin            x             y             z
fmul st0,st3         ;cos*y         sin            x             y             z
fxch st1             ;sin         cos*y            x             y             z
fmul st0,st4         ;sin*z       cos*y            x             y             z
fsubp st1,st0        ;cos*y-sin*z    x             y             z
                     ; y'            x             y             z
                     ;c*in2-s*in3    x             y             z

fld  dword [gs:0000h] ; =D

fsincos              ;cos           sin            y'            x             y         z
fmulp st5,st0        ;sin            y'            x             y           cos*z
fmulp st3,st0        ;y'             x           sin*y         cos*z
fxch st2             ;sin*y          x             y'          cos*z
faddp st3,st0        ;x              y'         sin*y+cos*z
                     ;x              y'            z'
                     ;x              y'         s*in2+cos*in3
ret

grad dw 1
for_rad dw 57 ;(180/pi)

;x dw 0
;z dw 0
y dw 50 ;size of circle

x2 dw ? ;points after 1st rotation
y2 dw ?
z2 dw ?

x3 dw ? ;points after 2nd rotation
y3 dw ?
z3 dw ?

;x2d dw ? ;2d for screen
;y2d dw ?