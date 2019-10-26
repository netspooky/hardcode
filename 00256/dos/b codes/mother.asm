;mother // breed 2
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: electric youth - faces

;A few weeks ago they found those little creatures in a sample of water
;taken from that unknown planet they had to observe while searching for
;iron, gold and other minerals. But what they found in the depth of one
;of the oceans made they shiver. They captured the huge creature and put
;it into a cryo chamber on board of their space ship. There it sleeps
;while the crew waits for scientist to arrive. Everyone who has seen it
;only calls it "mother". They are sure that something will happen when
;the sleep ends. So everyone puts all energy into keeping the machines
;running to prevent the cryo chamber to fail ...

;###
;changed to "cloudius"

;

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx        ;cl = 0 / ch = 1
pal:    xor ax,ax     ;don't make the eye hurt
        out dx,al ;r
        cmp cl,ch     ;ch = 1
        jb skip       ;keep black as black
        shrd ax,cx,18
        skip:
        out dx,al ;g
        shr al,2
        out dx,al ;b
        inc cl
        jnz pal

;finit ;safety what?

;vars used:
;bp+2  = degrees for rotation
;bp+4  = x
;bp+6  = y
;bp+8  = z

;bp+10 = x after rotation
;bp+12 = y after rotation
;bp+14 = z after rotation

main:
;background
mov bx,320*17-1
;xor di,di
bar:
add byte[es:di],bh        ;si at 1st frame 0100h
add di,321
mov word[es:bx+320*75-1],si        ;si at 1st frame 0100h
mov word[es:bx+320*109-1],si ;then always 0 here
dec bx
jnz bar

mov cl,36 ;segments ;ch = 1 at 1st frame
thingie1:
;xor ax,ax ;always the same at every run
           ;always the same after 1st frame (from flip)
           ;si = 0100h at 1st frame, then always 0 here
mov word[bp+4],si;ax;x ;start values (center of object)
mov word[bp+6],si;ax;y
mov word[bp+8],si;ax;z
mov si,6000 ;steps ;4400 and si only +1 below
thingie2:
add ax,cx
mul si

mov di,6 ;for access x,y,z
adding:
add ax,si
mul di
mov bx,ax
shr bx,15
shl bx,1 ;word
mov bx,word[way+bx] ;1 / -1
add word[bp+2+di],bx ;move
fild word[bp+2+di] ;load on fpu stack
dec di
dec di
jnz adding

;################################## R O T A T E ##################################

;fild word[bp+8] ;z ;load on fpu stack
;fild word[bp+6] ;y
;fild word[bp+4] ;x

;[on] around y axis | x=cos*x-sin*z | z=sin*x+cos*z | y=y
;[on] around x axis | y=cos*y-sin*z | z=sin*y+cos*z | x=x
;[on] around z axis | x=cos*x-sin*y | y=sin*x-cos*y | z=z

;at his point thanks to lord kelvin for his intro "only a cube" where i
;first saw 2 rotation calls together, so no loop-stuff needed. here it
;rotates around all 3 axis
call rotate  ;y axis in x y z out y' x z'
call rotate  ;x axis in y' x z' out x' y' z''
fxch st2     ;z'' y' x'
call rotate  ;z axis in z'' y' x' out y'' z'' x''

;fmul dword[correct];correct value (= (would make false stuff if done inside rotate-routine)
fistp word[bp+12]  ;grab new value y
shr word[bp+12],1  ;does its job and saves a byte

;fmul dword[correct]
fistp word[bp+14]   ;grab new value z (color)
;shr word[bp+14],1   ;does its job and saves a byte

fmul dword[correct]
fistp word[bp+10]   ;grab new value x

;calculate pos on screen
imul di,word[bp+12],320 ;di=word[y2]*320 = x
add di,word[bp+10]

add di,110+320*98;word[bp] ;add pos of cube
mov bx,word[bp+14] ;get current z (= color)
shr bx,1            ;
add bl,160          ;make negative z positive

cmp byte[es:di],bl ;check if pixel is in background or behind an existing pixel
ja nope             ;to far in background or behind something


;cmp bl,byte[bp+2]
;jne ok
;mov bl,255
;ok:

mov byte[es:di],bl
cmp byte[es:di+20],127
ja nope
mov byte[es:di+20],ch ;shadow
nope:

dec si
dec si
jnz thingie2

loop thingie1

;rotate
inc word[bp+2]         ;just change degrees

;flip
;si = 0 here
flip:
mov ax,si
shr ax,10
inc ax ;no ugly missing 1/2 line at top
xchg al,byte[es:si] ;grab + clear  // byte is slower but -1b (- inc si)
mov byte[fs:si],al  ;set
inc si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ;ret                 ;safe that byte by using the ret at the end of rotate


rotate:
;                     0              1             2             3             4         5         6         7
;                     x              y             z
fild word [bp+2]     ;g              x             y             z
fidiv word[for_rad]
fsincos              ;cos           sin            x             y             z
fmul st0,st3         ;cos*y         sin            x             y             z
fxch st1             ;sin         cos*y            x             y             z
fmul st0,st4         ;sin*z       cos*y            x             y             z
fsubp st1,st0        ;cos*y-sin*z    x             y             z
                     ; y'            x             y             z
fild word [bp+2]     ;g              y'            x             y             z
fidiv word[for_rad]
fsincos              ;cos           sin            y'            x             y         z
fmulp st5,st0        ;sin            y'            x             y           cos*z
fmulp st3,st0        ;y'             x           sin*y         cos*z
fxch st2             ;sin*y          x             y'          cos*z
faddp st3,st0        ;x              y'         sin*y+cos*z
                     ;x              y'            z'
fxch st1             ;y'             x             z'
ret

for_rad dw 57/2    ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
way dw -1,1
correct dd 0.5