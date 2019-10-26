;golden dawn anomaly // ley line turbulence
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: changes - icarus


;he stood at the shore and looked into the morning sky. and
;there it was: the optical turbulence they whispered about. ley
;lines in the sky, energetic fields creating shapes like fog,
;catching and reflecting the golden light of this beautiful dawn.
;he captured the phenomenon to proof its existence.

;back at home he uploaded the footage. two days later it got
;deleted - and he disappeared without a trace up to this date.

;rumours say that there is a file in the wild named "anomaly.com"
;which displays the footage. rumours also say that everyone who
;has the file on the hd has to be very careful.

;THEY might know.
;THEY might come.

;----------------------------------------------------------------

;based on - again - "breed" i wanted to do something rotating
;around all 3 axis. well it looked very boring so i stretched
;it, decided on the colors at voila! the anomaly will  change
;every time it appears.

;on your knees, bitch! hail the stretched cube! :D

;assuming:
;cx = 255
;bx = 0
;si = 0100h

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx        ;ch = 1
pal:    shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        mov al,30;25
        out dx,al ;b
        inc cl
        jnz pal

;finit ;safety what?

;vars used:
;bp    = size cloud/cube
;bp+2  = degrees for rotation
;bp+4  = x
;bp+6  = y
;bp+8  = z

;bp+10 = x after rotation
;bp+12 = y after rotation
;bp+14 = z after rotation

;bp+20 = center of abnomaly + randomiz0r

;ch is for size changing

mov word[bp],bx ;init
main:

;let size change from 0 to 255 and back to 0
add byte[bp],ch  ;ch = 1 at beginning
jnz smallie
neg ch
cmp ch,1           ;anomaly small/vanished?
jne main           ;don't use 0 otherwise it will skip a cloud a.k.a. 1 frame flicker
adc word[bp+20],ax ;change randomiz0r
                   ;this is fine enough
smallie:

mov cl,44         ;segments
;xor si,si         ;strangely compiling that xor si,si BELOW thingie adds 2b more (?????)
                  ;safety for 1st frame (si = 0100h at startup)
                  ;---> who cares + save 2b
thingie1:
;xor ax,ax        ;always the same at every run
                  ;ax will be 5558h after 1st frame (from flip)
mov word[bp+4],si;x
mov word[bp+6],si;y
mov word[bp+8],si;z
mov si,3000       ;steps 2800 x 50 x 3 = way too much to store values
thingie2:
add al,cl ;using ch causes jump to another shape then reaching size limit
          ;and ch jumps from 1 to -1 or back

mov di,6 ;for access x,y,z
adding:
add ax,word[bp+20]    ;random'ish
mul si
movzx bx,byte[bp]     ;check size
shl bx,1              ;double so 512 max! (in theory)
cmp word[bp+2+di],bx
je skippie ;jumping to "nope" makes cubish shape disappear :(
           ;plus it changes the framerate
neg bx
cmp word[bp+2+di],bx
je skippie
add bx,ax
shr bx,15
shl bx,1 ;word
mov bx,word[way+bx] ;1 / -1
add word[bp+2+di],bx ;move
skippie:
fild word[bp+2+di]; load on fpu stack
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

fistp word[bp+12]  ;grab new value y
;shl word[bp+12],1

fistp word[bp+14]   ;grab new value z

fmul dword[correct]
fistp word[bp+10]   ;grab new value x
;shl word[bp+10],1  ;does its job and saves a byte

;calculate pos on screen
imul di,word[bp+12],320*2 ;di=word[y2]*320 = x
add di,word[bp+10]

add di,word[bp+20];120+320*98;word[bp] ;add pos of center
mov bx,word[bp+14] ;get current z (= color)
add bx,255*2 ;size can be -512 max
                      ;so make it 0 (or positive)
shr bx,2     ;make it fit into colors 0 ... 255
             ;no extra color adding to make it not too bright (e.g. 64)

;cmp bl,255 ;if too far don't draw to prevent color-error (=
;ja nope
cmp byte[es:di],bl ;check if pixel is in background or behind an existing pixel
jae nope             ;to far in background or behind something

mov byte[es:di],bl
add byte[es:di+321],9 ;get some and add some
                      ;320+1 looks somehow smoother
nope:

dec si
jnz thingie2
dec cl
jnz thingie1

inc word[bp+2]      ;rotation

;flip
;si = 0 here
flip:
;mov ax,4548h
;shrd ax,si,16+9     ;bop till you drop
mov ax,si             ;^ somehow this does not work on my xp machine (?)
shr ax,10;9
mov ah,al
xchg ax,word[es:si] ;grab + clear  // byte is slower but -1b (- inc si)
mov word[fs:si],ax  ;set
inc si              ;word to speed up
inc si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ;ret                  ;skip that and use end of rotation routine if 1b is needed
                              ;it is

rotate:
;                     0              1             2             3             4         5         6         7
;                     x              y             z
fild word[bp+2]     ;g              x             y             z
fidiv word[for_rad]
fsincos              ;cos           sin            x             y             z
fmul st0,st3         ;cos*y         sin            x             y             z
fxch st1             ;sin         cos*y            x             y             z
fmul st0,st4         ;sin*z       cos*y            x             y             z
fsubp st1,st0        ;cos*y-sin*z    x             y             z
                     ; y'            x             y             z
fild word[bp+2]     ;g              y'            x             y             z
fidiv word[for_rad]
fsincos              ;cos           sin            y'            x             y         z
fmulp st5,st0        ;sin            y'            x             y           cos*z
fmulp st3,st0        ;y'             x           sin*y         cos*z
fxch st2             ;sin*y          x             y'          cos*z
faddp st3,st0        ;x              y'         sin*y+cos*z
                     ;x              y'            z'
fxch st1             ;y'             x             z'
ret

for_rad db 57/2    ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
                   ;/2 speed up
                   ;only reserve 1 byte and no word (following dword makes it possible)
correct dd 0.5
way dw -1,1