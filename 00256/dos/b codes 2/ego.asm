;vague // into the abyss [ego version]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;in this version the frame moves like the viewer has been hit by
;an explosion himself. no distortion on the submarine here.

;dosbox: 80.000 cycles are fine enough

;assuming: cx = 255

;vars used: cx and bp for shaking effect


org 100h
use16

start:   push 09000h
         pop ds      ;vscreen with background
         push 0a000h
         pop es      ;vga
         push 08000h
         pop gs      ;vscreen with background + submarine
         mov al,13h
         int 10h

        mov dx,0x3C9
pal:    xor ax,ax   ;blue ---> black
        out dx,al ;r
        shrd ax,cx,19
        out dx,al ;g
        shl al,1
        out dx,al ;b
        loop pal

;cls not needed;screen will fix itself after first frames;)
;cls:
;mov byte[ds:bx],140
;inc bx
;jnz cls

main:

;xor bx,bx ;bx = 0 here after 1st frame
;in al,40h ;randomized after 1st frame
boom:
cmp byte[ds:bx],140 ;bg color
ja nope
inc ax;sbb ax,dx  ;don't stay 0
dec dx;add dx,bx  ;don't stay 0
mul dx
shr al,6      ;6=256/64 = 4
movzx si,al
shl si,1      ;word
mov si,word[cs:dirs+si]
shld cx,si,16+1 ;shaker*4 = movement of explosion
mov al,byte[ds:bx] ;get original pixel
inc ax ;change color up to 140 (bg)
mov byte[ds:bx+si],al ;set pixel to new pos to make explosion
nope:
mov al,byte[ds:bx] ;grab screen
mov byte[gs:bx],al ;drop screen
inc bx
jnz boom ;whole screen

xor bp,bp ;no shaker

xor si,si
submarine:
mov bx,320*130+60 ;base
;sub bx,bp ;distort but keep some parts at position :)
add bx,word[cs:datasets2+si] ;pos
mov di,word[cs:datasets1+si] ;length
liney:
;neg bp ;make (almost) whole ship glitchy for the cost of 2b
mov ax,di
sub al,100;95 ;color based on length to have some shading
cmp byte[gs:di+bx],100 ;got hit?
jae ok
mov bp,cx ;activate shaking
ok:
mov byte[gs:di+bx],al
dec di
jnz liney
inc si
inc si ;word
cmp si,2*9
jne submarine


mov si,320*60-1
bars:
mov byte[gs:si+bp],255
dec si
cmp si,320*140-1
jne bars

;make a nice frame to make the shaking looking better
mov di,32
frame2:
mov bx,200*320
frame1:
add bx,bp
mov byte[gs:di+bx-16],255
mov si,di ;make the colored bar stay fixed while shaking the rest
;sub si,bp
mov byte[gs:si+bx-80],bh
mov byte[gs:si+bx-120],255
sub bx,bp
sub bx,320
jnz frame1
dec di
jnz frame2


;di = 0 here
;bp = shaker
flip:
mov al,byte[gs:di]    ;grab
mov byte[es:di],al ;shake it but don't break it
inc di
jnz flip

;set a new bomb
in al,40h ;randomize
mul dx    ;= ? here
cmp dx,60 ;avoid toooo much explosions
jb fine
mov si,ax
mov word[ds:si],di ;dropper
fine:

;scroll the background + add distortion
scroll:
inc ax
mul ax
mov dl,byte[ds:di]     ;grab pixel
cmp ah,100             ;adjust so not too much stuff
ja noey
dec dx                 ;change color
noey:
mov byte[ds:di-321],dl ;make it scrollolololo
inc di
jnz scroll

         in al,60h ;read keyboard
         dec al    ;check it, dammit!
         jnz main  ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h               ;or not ;)
         ret

;data of the submarine
datasets1 dw 50, 53,  53,  10,       4,         3,        3,1,1 ;length
datasets2 dw 0 ,-319,-640,-320*3+12,-320*4+16,-320*5+17,-320*6+17,-320*7+19,-320*8+19 ;pos

;data for explosion/shaking
dirs dw 1,-1,320,-320;,319,-319,322,-322