;inside [a sea of soylent green]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: EUS - Albora

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

        mov dx,0x3C9
        mov cx,256
pal:    mov ax,cx
        shr al,1 ;2 V1=1 V2=2
        out dx,al ;r
        shr al,1;1 V1=1 V2=2
        out dx,al;g
        shr al,2;1 V1=2 V2=1
        out dx,al;b
        loop pal

;setup 50 points ----> 50*2b ---> 100 + 50*2b for color/speed ---> 200
mov si,200
setup:
add ax,si
xchg al,ah
mov byte [bp+8+si],al ;save pos/color/speed
dec si
jnz setup

main:
mov word [bp],-16   ;original x
mov word [bp+2],-16 ;original y

;[bp+4] = rotated x
;[bp+6] = rotated y
;[bp+8..58]=position center of square
;[bp+60..110]=speed of square
;[bp+120..170]=angle


loop1:
;around z axis | x=cos*x-sin*y | y=sin*x-cos*y        [X]
;around x axis | y=cos*y-sin*z | z=sin*y-cos*z        [ ]
;around y axis | x=cos*x-sin*z | z=sin*x-cos*z        [ ]

fninit ;del everything on fpu stack to prevent error

fild word [bp+120+si] ;word [grad]hmhmmmmmmm o_O
;                        0             1          2           3
fsincos                ;cos           sin

fld st1           ;     sin           cos         sin
fimul word [bp+2]   ;   sin*y         cos         sin
fld st1           ;     cos           sin*y       cos         sin
fimul word [bp]   ;     cos*x         sin*y       cos         sin
fsub st0,st1    ;       cos*x-sin*y   sin*y       cos         sin
fist word [bp+4];rx

fxch st2    ;st0<-->st1 cos           sin*y      cos*x-sin*y  sin
fimul word [bp+2]   ;   cos*y         sin*y      cos*x-sin*y  sin
fld st3           ;     sin           cos*y      sin*y        cos*x-sin*y        sin
fimul word [bp]   ;     sin*x         cos*y      sin*y        cos*x-sin*y        sin
fadd st0,st1    ;       sin*x+cos*y   cos*y      sin*y        cos*x-sin*y        sin
fist word [bp+6];ry


;set 2d pixel
mov ax,320
mul word [bp+6]
add ax,word [bp+4] ;y*320+x = pixel pos
add ax,word [bp+8+si] ;pos of center of square
mov di,ax ;set pos
shr di,1 ;screen/2
mov byte [es:di],100 ;V1
;add byte [es:di],150 ;V2 change stuff at blur routine! comic style?
;ror word [es:di],1 ;V2.2
;neg byte [es:di] ;V2.3

;movement trough all points of the square
inc word [bp] ;x
cmp word [bp],17 ;x
jne loop1
mov word [bp],-16 ;x
inc word [bp+2] ;y
cmp word [bp+2],17;y
jne loop1

;move
mov ax,word [bp+60+si] ;grab color/speed
shr ax,14 ;create speed
add ax,321 ;up! (-1 insurance)
sub word [bp+8+si],ax

;rotate
mov al,byte [cs:0005h] ;)
add byte [bp+120+si],al ;change al if too fast/slow (dosbox = very slow!)
neg byte [cs:0005h] ;next time other direction

;do the blur
inc bx
cmp bx,5 ;V1=5 V2=1
jna noblur
dec bx ;mov bx,4 ;V1=4 V2=1
again:
xor di,di
blur:
mov al,[es:di+320]
adc al,[es:di+1]
adc ah,0
adc al,[es:di-1]
adc ah,0
adc al,[es:di-320]
adc ah,0
shr ax,2
jnz ney
dec al ;add some nice fake lightningflickering from above
ney:
mov [es:di],al
inc di
jnz blur
dec bx
jnz again

noblur:

inc si
inc si
cmp si,50
jna main ;next square

xor bx,bx ;no blur on next run starting! V1=on V2=off

;flip+cut edges (320*15/320*9)
mov si,32000-320*15
flip:
xor ax,ax
xchg al,byte [es:si+320*15]
mov byte [fs:si+320*48-1+320*9],al
dec si
jnz flip

in al,60h
cmp al,1
jne main

mov ax,03h
int 10h
ret