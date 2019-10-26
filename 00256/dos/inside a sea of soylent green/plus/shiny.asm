;shining in sequence
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: hammock - an empty field

org 100h
use16

start:   push 0a000h
         pop es
         push 09000h
         pop fs
         mov al,13h
         int 10h

;assuming: cx = 0 / bx = 0

;dh = r
;ch = g
;cl = b
;bl = #

inc bx ; bl = 1 ;only to be sure
mov ax,1010h

;pal: ;v1 ;base colors
;add ch,2
;mov dh,bl
;;mov ax,1010h
;int 10h
;inc bl
;jnz pal

;mov bl,56  ;reflection
;pal2:
;mov ch,50
;;mov cl,63
;mov dh,40
;;mov ax,1010h
;int 10h
;add bl,96
;jo pal2

pal3: ;colors + some polishing (=
add ch,2
add cl,9 ;9 / 60
mov dh,bl
;mov ax,1010h
int 10h
inc bl
jnz pal3


;setup 20 x pos/speed [20x2b pos + 20x2b speed = 80]
mov si,80
setup:
add ax,si
mov byte [bp+si],al ;save pos/speed
dec si
jnz setup

main:

;shows bar with colors 0-255
;xor ax,ax
;xor di,di
;tester:
;mov [fs:di],al
;mov [fs:di+320],al
;mov [fs:di+320*2],al
;inc al
;inc di
;cmp di,256
;jb tester

;setup start of cubepoints
mov word [x],-6
mov word [y],-6
mov word [z], 6
add word [grad],3 ;rotation ... 3 works fine (at least on my xp machine ...)


cube:


fild word [z] ;load
fild word [y] ;load
fild word [x] ;load

;around y axis | x=cos*x-sin*z | z=sin*x+cos*z | y=y
;around x axis | y=cos*y-sin*z | z=sin*y+cos*z | x=x

call rotate
call rotate

fistp [x2] ;grab new value
fistp [y2] ;grab new value
fistp [z2] ;grab new value


;calculate pos on screen
mov ax,320
mul word [y2]
add ax,word [x2]
mov di,ax
add di,[bp+si] ;add pos of every cube
mov ax,word [z2] ;get current z (= color)
add al,50        ;adding for color (=    0 - cube + 255
cmp byte [fs:di],al ;check if pixel is in background or behind an existing pixel
ja nope             ;to far in background or behind something
mov byte [fs:di],al ;set pixel
neg di
add al,93;93 / 94 / 98
mov byte [fs:di+60],al ;make symmetry
nope:


;move through all points of a cube
inc word [x]
cmp word [x],7
jne cube
mov word [x],-6
inc word [y]
cmp word [y],7
jne cube
mov word [y],-6
dec word [z]
cmp word [z],-7
jne cube

;move cubes
mov ax,word [bp+42+si] ;grab speed
shr ax,13              ;create speed by slowing down
inc ax                 ;never 0, never stop
mov dx,320             ;up up ^^
mul dx
dec ax                 ;do some move sidewards
sub word [bp+si],ax    ;move

;next cube
inc si
inc si
cmp si,40
jna main



;put to screen
;xor si,si ;who recognizes those missing 42b at the left upper corner ?
flip:
xor ax,ax
xchg al,byte [fs:si] ;grab + clear  // byte is slower but -1b (- inc si)
mov byte [es:si],al  ;set
inc si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret

rotate:
;finit not needed because there is no coming crash/overflow
;                     0              1             2             3             4         5         6         7
;                     x              y             z
fild word [grad]     ;g              x             y             z
fsincos              ;cos           sin            x             y             z
fmul st0,st3         ;cos*y         sin            x             y             z
fxch st1             ;sin         cos*y            x             y             z
fmul st0,st4         ;sin*z       cos*y            x             y             z
fsubp st1,st0        ;cos*y-sin*z    x             y             z
                     ; y'            x             y             z
fild word [grad]     ;g              y'            x             y             z
fsincos              ;cos           sin            y'            x             y         z
fmulp st5,st0        ;sin            y'            x             y           cos*z
fmulp st3,st0        ;y'             x           sin*y         cos*z
fxch st2             ;sin*y          x             y'          cos*z
faddp st3,st0        ;x              y'         sin*y+cos*z
                     ;x              y'            z'
fxch st1             ;y'             x             z'
ret

x dw ?  ;points of cube
y dw ?
z dw ?

x2 dw ? ;points of cube after rotation
y2 dw ?
z2 dw ?

grad dw ?