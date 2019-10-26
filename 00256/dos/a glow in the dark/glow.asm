;a glow in the dark
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: nujabes - rainyway back home

org 100h
use16

start:   push 0a000h
         pop fs ;screen
         push 09000h
         pop es ;vscreen
         push 08000h
         pop gs ;texture
         mov al,13h
         int 10h

;bp=x
;bp+2=new x
;bp+4=grabbed texture/shape
;bp+6=for saving ax

;at this point there are many ways to choose from.
;even though i adore black/white i picked another decent one (in my opinion).

        mov dx,0x3C9
        mov cx,256  ;cl=0 ch=1
pal:    mov ax,cx
        shr al,1
        out dx,al ;r
        out dx,al ;g
        shr al,2 ;shl al,2 texturize me :D
        out dx,al ;b
        loop pal

;draw baseline where the texture/shape will be grabbed/calculated from
;2 x 180° ---> no ugly break in the shape / shape it but don't break it
;mov ax,0B400h ;ah=180 / al=0
;xor di,di
;init:
;mov [gs:di],al     ;one half 0..179
;mov [gs:di+180],ah ;another half 180..359
;inc al
;dec ah
;inc di
;cmp di,359-180
;jna init

mov ax,0B400h ;ah=180 / al=0
mov di,360-180
init:
mov [gs:di-1],al     ;one half 179..0
mov [gs:di+179],ah  ;another half 359..180
inc al
dec ah
dec di
jnz init

main:

mov si,word[grad] ;grab texture // 0-359
mov bh,byte[gs:si]
mov byte[bp+4],bh

;draw from 200 down to 1
mov cx,200
xor si,si ;clear for calc texture
xor ax,ax ;clear for calc texture

doit:
;create texture out of original = shape
add si,cx;\
rol si,cl;-\
mov bx,si;--- delete to get clean shapes, but clean shapes are so artificial
sar bx,13;-/  without anything special
add al,bl;/
add al,byte[bp+4] ;grab (original on first run) texture
add al,byte[variation] ;add al,4 ;[original] ;SHAPES! CHANGE IT HERRE!
shr ax,1;div 2

mov byte[bp+4],al ;safe new byte of texture/shape

mov word[bp+6],ax ;safe for further texture usage (otherwise it will be erased below)
                  ;push/pop would fuck up bp/sp and correcting is just extra code

;xor ah,ah       ;al = color = radius/shape /// ah always 0 here
shr ax,1        ;SHAPES! CHANGE IT HERRE!
mov word[bp],ax ;don't care about starting radius (it would reveal the magic too fast ^^)

;create new x
;fninit                  ;clear fpu-stack
fild word [grad]        ;load degrees
fidiv word [for_rad]    ;pi*grad/180 = grad/57
;                        0             1          2           3
fsin                    ;sin
fmul [correct]    ;     correct to avoid missing pixels (=
fimul word [bp]   ;     sin*x
fistp word [bp+2]  ;    new x + pop = clear fpu stack so no fninit needed = speed up

;calculate position
imul ax,cx,320 ;calc correct hight
mov di,word[pos];115 ;because centerizing sucks
                     ;320*0.625 golden ratio = 200 // reverse 120 // sucks too // 115 is just fine
add di,word [bp+2] ;new x
add di,ax          ;di = pos

mov ax,word[bp+6] ;restore for further texture usage above + color (al) below

;                180°
;          270°        90°
;                0°
;
;              screen
;
;               0_o
;
cmp word[grad],180
ja ok              ;181° - 360° = draw no matter what (=
cmp byte [es:di],0 ;0-180°
jne notnew         ;there is already something drawn so behave

ok:
stosb ;set pixel ;mov [es:di],al

notnew:
;dec cx
;jnz doit ;draw all lines
loop doit

;go on
inc word[grad]
cmp word[grad],359
jna main ;360=0
mov word[grad],0

;flip texture 359...0  :D
mov di,359
mov dl,byte [gs:di];359
flip_tex:
mov al,byte[gs:di-1]
mov byte[gs:di],al
dec di
jnz flip_tex
mov byte[gs:di],dl ;di=0

;auto changer
;below 0 mushroom // above 0 flower aroideae
inc byte[counter]
jnz flip
neg word[pos] ;jumping to a position
dec byte[variation]
cmp byte[variation],-5 ;-4 .. 5 is just fine as amount of variation
jne flip
mov byte[variation],5

;di=0 here
;flip to screen + clear vscreen
flip:
xor ax,ax
xchg al,byte [es:di]
mov byte [fs:di],al
dec di
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret

for_rad dw 57 ;pi*grad/180 = grad/57 (180/3.14... = 57,...)

variation db 5
correct dd 0.68  ; (= (= (=
pos dw 115
counter db ?
grad dw ?    ;who gives a fuck where it starts?