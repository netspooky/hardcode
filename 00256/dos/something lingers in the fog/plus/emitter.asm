;emitter
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: felix marc - parallel world

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

        mov dx,0x3C9
        mov cx,256 ;heat inside
pal2:    mov ax,cx
        shr al,2
        out dx,al ;r
;        shr al,2
        out dx,al ;g
        shr al,2
        out dx,al ;b
        loop pal2

;        xor cx,cx ;heat outside
;pal3:   mov ax,cx
;        shr al,2
;        out dx,al ;r
;        shr al,1
;        out dx,al ;g
;        shr al,2
;        out dx,al ;b
;        inc cl
;        jnz pal3

;create fire as texture
ohohfire:
mov di,640
fire:
in al,40h
mul al
add byte[gs:di+64000], al
dec di
jnz fire

fireloop:
mov al,byte[gs:di]
adc al,byte[gs:di+1]
adc ah,0
adc al,byte[gs:di+320]
adc ah,0
adc al,byte[gs:di-1]
adc ah,0
shr ax,2          ;div 4
;jz firep
inc ax ;)
firep:
mov byte[gs:di-960+6],al;higher + swirl!
inc di
jnz  fireloop

;magical optical secret not-so-secret pixels used during coding
;in al,40h
;mov byte[gs:160+320*150],al
;mov byte[gs:158+320*150],al
;mov byte[gs:162+320*150],al

main:

;draw from 200 down to 1
mov cx,200

doit:
;create texture out of original = shape
imul ax,cx,320
mov di,ax
add di,word[grad]

mov si,160 ;right half 0..180° starting from middle of texture

cmp word[grad],180 ;left half?
jb allright        ;nope

mov si,121-320   ;set correct start position

allright:
add di,si
xor ah,ah
mov al,byte[gs:di] ;get+save texture/color

mov word[bp+6],ax ;safe for further texture usage (otherwise it will be erased below)
                  ;push/pop would fuck up bp/sp and correcting is just extra code

;add ax,100      ;add radius
sub ax,380      ;add radius
mov word[bp],ax ;save x/radius

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
mov ax,320
mul cx     ;calc correct hight
mov di,210 ;because centerizing sucks

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

ok: ;not needed if inc ax @ fire
;cmp al,0 ;don't draw blackness into foreground! (left side)
;je notnew

stosb

notnew:

loop doit;draw all lines

;go on
inc word[grad]
cmp word[grad],359
jne main ;360=0
mov word[grad],0

mov di,320*168
mov al,120
bars:
add si,320
stosb
cmp di,320*30
jne bars

nothing:
xor di,di
;flip to screen + clear vscreen
flip:
xor ax,ax
xchg al,byte [es:di]
mov byte [fs:di],al
dec di
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne ohohfire             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret

for_rad dw 57 ;pi*grad/180 = grad/57 (180/3.14... = 57,...)

correct dd 0.14

grad dw ? ;who gives a fuck where it starts?