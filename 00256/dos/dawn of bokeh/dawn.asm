;dawn of bokeh // the journey of the electric clouds
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: solar fields - station 5

;dosbox has problems at setup: so i included a solution
;for the cost of a clean exit.

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         mov al,13h
         int 10h

;assuming cx=0 / bx=0

;used vars
;bp             = y
;bp + 2         = x
;bp + 10..74    = pos (64 = 32 squares)
;bp + 80..144   = speed
;bp + 300..364  = layers
;bp + 380..444  = for change of layer
;bp + 500       = for change of palette
;bp + 501       = delay for change of palette

;bl = blue value
;bh = displayed layer

        inc cx;mov cx,256
setup:  mov si,cx
;        sar word[bp+10+si],1  ;include for dosbox (= [and exclude clean exit!]
        add word[bp+10+si],cx ;pos + speed up to 265
        mov byte[bp+300+si],1 ;layer + layerchanger up to 555 (=
        loop setup

;xor si,si ;gets 0 soon enough so don't care

main:
cmp byte[bp+300+si],bh ;correct layer?
jne drop               ;no so do nothing

mov word[bp],22;27 ;y
looper2:
mov word[bp+2],25;30 ;x
looper1:

imul di,word[bp],320  ;y
add di,word[bp+2]     ;x
add di,word[bp+10+si] ;pos
mov ax,0ffffh
stosb
shl di,1
stosw

dec byte[bp+2] ;x
jnz looper1
dec byte[bp]   ;y
jnz looper2

;movement
mov dx,word[bp+80+si] ;get speed
sub dx,word[bp+10+si] ;add some changer (=
sub dx,si             ;change even if some objects are on the same spot
shr dx,14
sub dx,321;318..323
add word[bp+10+si],dx

;change layer on random object
in al,40h
mul al
shr al,2;3 ;256/8=32 // 256/4=64
xor ah,ah
mov di,ax
;shl di,1 ;*2=64
;mov di,si ;test to see that flickering of some parts comes from different stages of blur

;layers / layer = number of blurs
mov al,byte[bp+380+di] ;grab counter
add byte[bp+300+di],al ;change layer
jnz donothing          ;reached first layer?
neg byte[bp+380+di]    ;reverse
donothing:
cmp byte[bp+300+di],40 ;reached last layer? 80 = complete vanish but slow
jne donothing2
neg byte[bp+380+di]    ;reverse
donothing2:

drop:
inc si
inc si
cmp si,64 ;/2 = number of squares (32)
jna main

xor si,si

;blurry times
blur:
mov al,byte[es:si+320]
adc al,byte[es:si+1]
adc ah,0
adc al,byte[es:si-1]
adc ah,0
adc al,byte[es:si-320]
adc ah,0
shr ax,2
jz ney
dec al
ney:
mov byte[es:si],al
inc si
jnz blur

;change displayed layer
inc bh
cmp bh,40;80; reached last layer? 80 = complete vanish but slow
jna main
xor bh,bh ;set to first layer

;oh wait!
dec byte[bp+501]   ;on first run create pal [bp+501]=1
jnz flip
mov byte[bp+501],8 ;no premature ejaculation

;change palette
add bl,byte[bp+500]
jnz donothing3     ;0
neg byte[bp+500]
donothing3:
cmp bl,62          ;63
jna donothing4
neg byte[bp+500]
donothing4:

;set palette from dusk till dawn without night ^^
         mov dx,0x3C9
pal:     mov al,bh ;bh=0 here
         shr al,2
         out dx,al ;r
         shr al,1
         out dx,al ;g
         mov al,bl
         out dx,al ;b
         inc bh
         jnz pal

;bars + copy
;si=0 here
flip:
mov al,byte [es:si]
mov byte [fs:si],al
inc si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h              ;but exclude for dosbox to stay below 257b ^^
         ret