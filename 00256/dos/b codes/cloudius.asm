;cloudius on tape // creature in the sky
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: vhs dreams - vice point

;###
;this became "nautilus dreaming", released at revision 2o16 :)

org 100h
use16

;assuming: cx = 255 bx = 0 ax = 0 di = fffeh si = 0100h
;vars used:
;bp    = size of cloudius (skipped)
;bp+2  = degrees for rotation/speed of movements
;bp+4  = x
;bp+6  = y
;bp+8  = z

;bp+10 = x after rotation
;bp+12 = y after rotation
;bp+14 = z after rotation

start:   push 0a000h
         pop es
         push 09000h
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx
pal:    shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        shr al,1
        out dx,al ;b
        inc cl
        jnz pal

fninit ;safety what? runs on my xp machine, under DosBox and VMWare
       ;so it might run on other systems too. but hey, it's revision!

main:

mov cl,32         ;segments ;ch = 1 at 1st frame
                  ;[bp] = length of each segment
thingie1:
;xor ax,ax ;always the same at every run
           ;always the same after 1st frame (from flip)
           ;di = fffeh at 1st frame, then always 0 here
mov word[bp+4],di;ax;x ;start values (center of object)
mov word[bp+6],di;ax;y
mov word[bp+8],di;ax;z
mov di,3800

thingie2:
add ax,cx
mul di

mov si,6 ;for access x,y,z
adding:
add ax,di
mul si
mov bx,ax
shr bx,15 ;0 or 1
;shl bx,1 ;word
;mov bx,word[way+bx] ;1 / -1
jnz neat ;bx = 1
dec bx   ;bx = 0 so make it -1
neat:
add word[bp+2+si],bx ;move
fild word[bp+2+si] ;load on fpu stack
dec si
dec si
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
;fxch st2     ;z'' y' x'
;call rotate  ;z axis in z'' y' x' out y'' z'' x''

;fmul dword[correct];correct value (= (would make false stuff if done inside rotate-routine)
fistp word[bp+12]  ;grab new value y
shr word[bp+12],1  ;does its job and saves a byte

;fmul dword[correct]
fistp word[bp+14]   ;grab new value z (color)
;shr word[bp+14],1   ;does its job and saves a byte

fmul dword[cs:correct]
fistp word[bp+10]   ;grab new value x

;calculate pos on screen
imul si,word[bp+12],320
add si,word[bp+10]

imul bx,word[bp+2],321
;add si,bx          ;movement

mov dx,word[bp+14] ;get current z (= color)
shr dx,1            ;
add dl,160;160          ;make negative z positive
                    ;and brighten things up

cmp byte[ds:si+bx],dl ;check if pixel is in background or behind an existing pixel
jae nope             ;to far in background or behind something

mov byte[ds:si+bx],dl
;cmp byte[es:di+20],127
;ja nope
;mov byte[es:di+20],ch ;shadow
nope:

dec di
jnz thingie2
loop thingie1

;ax always the same here
;create starting point of bars on top
;using degrees for movement
sub ax,word[bp+2] ;add/mov/sub changes direction of movement
mov bx,320
xor dx,dx         ;no zeroing makes it wrong
div bx
mov bx,dx         ;dx = 0 .. 319
                  ;ax = 0 .. 20x

;make the bars
;one will be in the foreground :)
mov al,200            ;height of screen to avoid too much shit
bar:
mov cl,60;ch = 0
barr:
imul si,dx,2          ;parallax me beautiful
add si,ax
cmp byte[ds:si+bx],70 ;check if cloudius is there
ja neyney             ;if so then don't draw!
mov byte[ds:si+bx],cl
neyney:
mov byte[ds:bx],bh    ;bar in the foreground
shr byte[ds:bx-128],1 ;shadow of bar in foreground
inc bx
loop barr
adc bx,318-60         ;-60 because of cl/size
                      ;remember: using the carry flag makes
                      ;things more advanced without doing
                      ;anything. it's true!
dec ax
jnz bar

;bars on top and bottom
mov bx,320*24-64 ;57*320-64 = 4700h bl = ?
barrr:
mov byte[ds:bx+320*191-1],190 ;wise color choice
dec bx
jnz barrr

sub word[bp+2],2        ;change degrees/speed

;flip
;di = cx = 0 here
flip:
mov ax,di;make light shine from below
shr ax,10
xchg ax,word[ds:di] ;grab + clear  // byte is slower but -1b (- inc si)
stosw;mov word[es:si],ax  ;set
cmp di,cx
jne flip

         in al,60h            ;read keyboard buffer
         dec al               ;ESC?
         jnz main             ;no, so go on
breaker:
         mov ax,03h           ;keep it clean :)
         int 10h
         ;ret                 ;safe that byte by using the ret at the end of rotate

rotate:
;                     0              1             2             3             4         5         6         7
;                     x              y             z
fild word[bp+2]     ;g              x             y             z
fidiv word[cs:for_rad]
fsincos              ;cos           sin            x             y             z
fmul st0,st3         ;cos*y         sin            x             y             z
fxch st1             ;sin         cos*y            x             y             z
fmul st0,st4         ;sin*z       cos*y            x             y             z
fsubp st1,st0        ;cos*y-sin*z    x             y             z
                     ; y'            x             y             z
fild word[bp+2]     ;g              y'            x             y             z
fidiv word[cs:for_rad]
fsincos              ;cos           sin            y'            x             y         z
fmulp st5,st0        ;sin            y'            x             y           cos*z
fmulp st3,st0        ;y'             x           sin*y         cos*z
fxch st2             ;sin*y          x             y'          cos*z
faddp st3,st0        ;x              y'         sin*y+cos*z
                     ;x              y'            z'
fxch st1             ;y'             x             z'
ret

for_rad db 57/2    ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
                   ;byte + additional byte at doubleword below work fine
correct dd 0.5