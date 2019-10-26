;something lingers in the fog // arising out of nowhere
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: insomnius dei - the aftermath

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,256
pal:    mov ax,cx
        shr al,2
        out dx,al ;r
        shl al,1
        out dx,al ;g
        out dx,al ;b
        dec cx
        jnz pal

;vars used:

;bp    = position of cube
;bp+2  = degrees for rotation
mov word[bp+2],270 ;hide in the fog >:)
;bp+4  = x
;bp+6  = y
;bp+8  = z

;bp+10 = x after rotation
;bp+12 = y after rotation
;bp+14 = z after rotation

;bp+16 = changer (BYTE!)
;mov word[bp+16],0

main:
;set size of the cube
;enlarge it in grayscale (=
mov word[bp+8],121 ;z
cubez:
mov word[bp+6],121 ;y ;cube will be drawn from 121 down to 1
cubey:
mov word[bp+4],121 ;x ;size = 120 x 120 x 120 (work 121 downto 1)
cubex:

mov ax,word[bp+4] ;init

;do the magic xor stuff :D
xor al,byte[bp+16]
xor al,byte[bp+6]
xor al,byte[bp+8]
jnz nope

;2 tooks eternity to calc/show
;mov bx,word[bp+16]
;and ax,bx
;and cx,ax
;and dx,cx
;jz nope

;static object / xor thingie / slooooow
;xor cx,ax
;and ax,dx
;and dx,cx
;jnz nope

;################################## C U B E ##################################
;erase stuff above up to "cubex:" and see some 120x120x120 pixel cube moving
;around --> only skin is drawn
;imul ax,word[bp+4],-1 ;invert / see below
;imul cx,word[bp+6],-1
;imul dx,word[bp+8],-1

;inc ax ;-1 ---> 0 / effect see below
;inc cx ;
;inc dx ;

;only draw if NO point (x/y/z) is inside of the cube (inside is between -119 and -1)
;x/y/z:  121 and 0:  skin of cube to work with
;x/y/z: -120 and 0 : skin of cube after invert and inc ax/cx/dx
;0 is NOT ABOVE ;)
;xor bx,bx
;cmp al,-120 ;x
;ja no1     ;not on skin level
;inc bx
;no1:
;cmp cl,-120 ;y
;ja no2
;inc bx
;no2:
;cmp dl,-120 ;z
;ja no3
;inc bx
;no3:
;cmp bx,0 ;nowhere on skin level so skip calc
;je nope
;################################## C U B E ##################################

fild word[bp+8] ;z ;load on fpu stack
fild word[bp+6] ;y
fild word[bp+4] ;x

;[on] around y axis | x=cos*x-sin*z | z=sin*x+cos*z | y=y
;[on] around x axis | y=cos*y-sin*z | z=sin*y+cos*z | x=x
;[on] around z axis | x=cos*x-sin*y | y=sin*x-cos*y | z=z

;at his point thanks to lord kelvin for his intro "only a cube" where i
;first saw 2 rotation calls together, so no loop-stuff needed. here it
;rotates around all 3 axis for more dynamic behavior (even in the fog)
call rotate  ;y axis in x y z out y' x z'
call rotate  ;x axis in y' x z' out x' y' z''
fxch st2     ;z'' y' x'
call rotate  ;z axis in z'' y' x' out y'' z'' x''

fmul dword[correct];correct value (= (would make false stuff if done inside rotate-routine)
fistp word[bp+12]  ;grab new value y

fmul dword[correct]
fistp word[bp+14]   ;grab new value z

fmul dword[correct]
fistp word[bp+10]   ;grab new value x

;calculate pos on screen
imul di,word[bp+12],320 ;di=word[y2]*320 = x
add di,word [bp+10]
add di,word[bp] ;add pos of cube

mov ax,word [bp+14] ;get current z (= color)

sub ax,25 ;use only if changing palette

cmp ax,255 ;if too far don't draw to prevent color-error (=
ja nope
cmp byte [es:di],al ;check if pixel is in background or behind an existing pixel
ja nope             ;to far in background or behind something

stosb
nope:

;   _____
;  /___ /|
; y|   | |
;  |___|z
;    x

;move through all points of a cube
dec word[bp+4];x  ;size downto 0
jnz cubex    ;size not 0 so go on / 0 will be drawn at first run!

dec word[bp+6];y
jnz cubey

dec word[bp+8];z
jnz cubez

;movement
add word[bp],319

;rotate
inc word[bp+2]         ;just change degrees
cmp word[bp+2],270+360 ;arise and hide
jb weiter
mov word[bp+2],270     ;still hide to arise
;add byte[bp+16],3      ;change changer
inc byte[bp+16]
cmp byte[bp+16],25*5   ;last step, there is nothing directly beyond
jna weiter
mov byte[bp+16],0

weiter:
;flip
xor si,si ;safety first
flip:
xor ax,ax
xchg al,byte [es:si] ;grab + clear  // byte is slower but -1b (- inc si)
mov byte [fs:si],al  ;set
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

for_rad dw 57    ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
correct dd 0.73  ; (= (= (=