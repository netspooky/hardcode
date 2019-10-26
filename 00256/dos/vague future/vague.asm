;vague future // into the abyss
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;for this one i grabbed some older code which displayed the submarine. i had no idea
;what to do with it but then i rewatched some of my old intros and thought that the
;effect of "when the clouds" might provide some nice looking explosion. so i did that
;and included some nice shaking to the scene, added some "noise" to the background
;and a nice frame around it.

;also: design > realism ^_^ that's why things are shaking/standing still that should
;not shake/stand still.

;uses vsync

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
;make explosions
boom:
cmp byte[ds:bx],140 ;bg color
ja nope
inc ax;don't stay 0
dec dx;don't stay 0
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

;grab data + draw submarine
mov si,2*9
submarine:
mov di,320*126+60      ;basic position
sub di,bp              ;distort (some parts)
add di,word[cs:datasets2+si-2] ;pos ;-2 because si=0 is not grabbed without
shrd bx,si,16+1
mov bl,byte[cs:datasets1+bx-1] ;length ;-1 ... same as si-2 above
                             ;bh = here (because si shr 1 < 256
                             ;so no movzx needed = -1b
liney:
neg bp                 ;make (almost) whole ship glitchy for the cost of 2b
mov ax,bx
sub al,102;95          ;color based on length to have some shading
cmp byte[gs:di+bx],60  ;got hit?
jae ok
mov bp,cx              ;activate shaking
ok:
mov byte[gs:di+bx],al
dec bx
jnz liney

;slow it down
;a bit extra because of the loop
mov dx,3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

dec si
dec si ;word
jnz submarine

mov cl,255 ;save 1b below

;bars top and bottom to make windows
mov si,320*65-1
bars:
mov byte[gs:si],cl
dec si
cmp si,320*135-1
jne bars

;make a nice frame to make the shaking looking better
mov di,29
frame2:
mov bh,0fah;mov bx,200*320;fa00h
frame1:
mov byte[gs:di+bx-14],cl ;left + right
sub di,bp                ;make the colored bar stay fixed while shaking the rest
mov byte[gs:di+bx-80],bh ;only here+fixed for design
add di,bp
mov byte[gs:di+bx-127],cl;middle
sub bx,320
jnz frame1
dec di
jnz frame2


;scroll the background + add small explosions (too clean visuals without)
scroll:
inc ax
mul ax
mov dl,byte[ds:di]     ;grab pixel
cmp ah,150             ;adjust so not too much stuff
ja noey
dec dx                 ;change color
noey:
mov byte[ds:di-321],dl ;make it scrollolololo
inc di
jnz scroll

;set a new bomb
in al,40h ;randomize
cmp al,8
ja fine
mul dx
mov si,ax
mov word[ds:si],di ;dropper = 0
fine:

;di = 0 here
;bp = shaker
flip:
mov al,byte[gs:di]    ;grab
mov byte[es:di+bp],al ;shake it but don't break it
inc di
jnz flip

         in al,60h ;read keyboard
         dec al    ;check it, dammit!
         jnz main  ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h               ;or not ;)
         ret

;data of the submarine
datasets1 db 50, 53,  53,  10,       4,         3,        3,1,1 ;length
datasets2 dw 0 ,-319,-640,-320*3+12,-320*4+16,-320*5+17,-320*6+17,-320*7+19,-320*8+19 ;pos

;data for explosion/shaking
dirs dw 1,-1,320,-320;,319,-319,322,-322