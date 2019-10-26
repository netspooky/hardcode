;road [to peace of mind]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: dj okawari - flower dance

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

;assuming: bx = 0 / dx = 0

;make col # 0 to some nice blue
;dh = r
;ch = g
;cl = b

;xor bx,bx
mov cx,283fh ;cl=63=3fh / ch=40=28h
;mov dh,37
mov ax,1010h
int 10h

;setup 50 points ----> 50*2b ---> 100 + 50*2b for color/speed ---> 200
mov si,200 ;200/4
setup:
add ax,si
mov byte [bp+8+si],al ;save pos/color/speed
dec si
jnz setup ;the one at si=0 moves by random numbers in memory


main:
;square
mov word [bp],-18   ;original x
mov word [bp+2],-18 ;original y

;[bp+4] = rotated x
;[bp+6] = rotated y
;[bp+8..58]=position center of square
;[bp+60..110]=speed of square + color
;[bp+120..170]=angle


loop1:


;around z axis | x=cos*x-sin*y | y=sin*x-cos*y        [X]
;around x axis | y=cos*y-sin*z | z=sin*y-cos*z        [ ]
;around y axis | x=cos*x-sin*z | z=sin*x-cos*z        [ ]

fninit ;init fpu WITHOUT fwait

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
add ax,word [bp+8+si] ;pos of square

mov di,ax ;set pos
shr di,1 ;clean squares from black dots --> screen/2
mov ax, word [bp+60+si] ;color
stosb;mov byte [es:di],al ;vscreen
shr di,1 ;shrink --> screen/4
stosb;mov byte [es:di],al ;vscreen
mov byte [es:di+320*51-17],al ;vscreen


;movement trough all points of the square
inc word [bp] ;x
cmp word [bp],19 ;x
jne loop1
mov word [bp],-18 ;x
inc word [bp+2] ;y
cmp word [bp+2],19;y
jne loop1

mov ax,word [bp+60+si] ;grab color/speed
shr ax,14 ;create speed
inc ax    ;never 0
mov dx,320 ;up up ^^
mul dx
dec ax ;do some move sidewards
sub word [bp+8+si],ax ;move

;rotate
mov al,byte [cs:0005h] ;)
add byte [bp+120+si],al ;change al if too fast/slow
neg byte [cs:0005h] ;next time other direction

;change palette
mov bx,word [bp+60+si] ;color# !
;xor bh,bh   ;hm ...
mov ax,1015h ;bios set palette color / 1015h=read palette color
int 10h
;dh = r
;ch = g
;cl = b

mov ah,dh
call rgb
mov dh,ah

mov ah,ch
call rgb
mov ch,ah

mov ah,cl
call rgb
mov cl,ah

mov ax,1010h
int 10h
;change palette end

inc si
inc si
cmp si,50
jna main ;next square


;all squares now on screen

mov si,32000
;put to screen
flip:
xor ax,ax
xchg al,byte [es:si];grab + clear
mov byte [fs:si+320*48-1],al ;put to a nice place
dec si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

;in ---> ah=r/g/b
rgb:
mov dl,1 ;add 1
in al,40h
cmp al,128 ;random?
ja oki
cmp ah,21 ;r/g/b <= ?  < --- f.e. 50 makes bright squares
jnbe oki3 ;;sub 1 because r/g/b <= ?
oki:
cmp ah,63 ;r/g/b = 63?
jne oki2  ;nope, so add
oki3:
mov dl,255    ;63 so add -1
oki2:
add ah,dl
ret