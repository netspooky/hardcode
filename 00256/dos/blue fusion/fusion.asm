;blue fusion // beyond dark matter
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: tholen - as all hope was dying

;the universe. elements were born inside the stars and
;given to the cosmos.  this is were we came from.  and
;this is were we will be going one day.

;okay, this is not the main idea behind this prod.  it
;is a bit more simple:

;since there are some intros showing different effects
;i wanted to try to show more than 2 on one screen. so
;i made it to 3. or 3.5 if you consider the shining of
;the stars as effect ;) while trying different sets of
;colors i decided the finally used one as the best and
;most fitting to connect the 3 effects.  the idea with
;the universe was just a consequence. and the  armadas
;of spaceships are just a happy accident :D

;about  50.000  cycles under DosBox will to their job.

;HINT:
;after about 1 minute a spaceship armada will appear
;followed by a second one far away.

org 100h
use16

;assuming:
;ax = 0
;bx = 0
;cx = 255

start: push 09000h    ;vscreen (16b)
       pop ds
       push 08000h    ;variables for stars
       pop fs
       push 0a000h    ;vga
       pop es

       mov al,13h
       int 10h


;make palette (43b)
        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

pal:    mov al,bl ;first half
        out dx,al ;r
        shrd ax,cx,17
        out dx,al ;g
        out dx,al ;b
        cmp cl,64
        jb allright
        inc bx
        allright:
        inc cx
        cmp cl,127
        jne pal

pal2:   shrd ax,cx,17 ;second half
        out dx,al ;r
        out dx,al ;g
        mov al,bl
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

;create stars 2 - max (21b)
;flood full memory to save 1b
;only needed stars will be grabbed below
;since dec bx all values get in right order
;bx = 0 here
initstars:
aaa;in al,40h            ;same "random" values on every run and -1b
                         ;there will appear spaceships in the distance. so beware!
                         ;das for tiny armada
                         ;daa for small armada
                         ;aaa/aas will make 2 spaceship armadas, a small one and a big one. impossibru! ;)
mul bx                   ;make new "random" ax
mov word[fs:bx],ax       ;save pos
shr al,6                 ;make speed (256/64 = 4 layers) ;aaa ~ shr al,5 and saves 2b but too fast
inc ax;al                ;never 0
mov word[fs:bx+8000],ax ;save speed[al] + color[ah]
mov word[ds:bx],cx       ;clean vscreen; cx = 0
dec bx
dec bx
jnz initstars

main:

;use stars 2 - max (41b)
mov si,1426             ;why not 1424 stars? at least in theory
top:
mov di,word[fs:si]      ;get pos of star to show
;xor ax,ax               ;no wrong moving
;mov bx,32000-1          ;saving bytes below
;mov byte[ds:di],al      ;del old one
;mov al,byte[fs:si+bx+1] ;get speed si+32000
;mov dl,byte[fs:si+bx]   ;get color si+32000-1

xor dx,dx               ;for correct movement and to save 1b compared to code above
mov bx,8002             ;somehow all color data fucked up using 8000
mov byte[ds:di],dl      ;del old one
mov ax,word[fs:si+bx]   ;get speed[al] + color[ah]
xchg dl,ah              ;grab color and delete ah for correct movement
again:
add di,ax               ;move
cmp di,320*68           ;in visible area?
ja again                ;no so move again until it is!
inc byte[fs:si+bx+1]   ;change saved color so it will change on display next time
mov word[fs:si],di      ;save new pos
mov byte[ds:di],dl      ;set new star
dec si
dec si
jnz top

mov di,320*68 ;start of middle area

mov bx,320 ;make smooth colors and stuff (22b)
middle:
mov ax,di
xor dx,dx
div bx
mul dx
add ax,cx
mov byte[ds:di],ah

inc di
cmp di,320*131
jb middle

add cx,46 ;movement slow and smooth. not fast and crinkly like your mama

;fire (35b)
bottom: mov al,byte[ds:di]     ;do the fading
        adc al,byte[ds:di-319]
        adc al,byte[ds:di+bx+1];+321
        adc al,byte[ds:di+1]
        shr ax,2
        jz fire
        dec ax
fire:   cmp di,64000 ;outside of screen?
        jb go        ;nope, so no random color
        in al,40h    ;aaa would do it's "randomizing" job again like at initstars
                     ;but is too fast; reading timer slows things down at least on my slow machine
                     ;otherwise vsync would be needed but no bytes for that
        mul di       ;make random color; das/daa will work but fire will lose randomness
go:     mov byte[ds:di-320*2+1],al
        inc di
        jnz bottom

;this eats a lot of bytes (35b) but also adds some design
;might be enough to make a 4th effect on the screen
;but i did not think about going for that because
;i think the lines are important for the eye :D
;bx = 320 here
mov al,127 ;neg at flip makes it to 128 so the eye won't see the difference
lines:
mov byte[ds:bx+320*8-1],al
mov byte[ds:bx+320*9-1],al
mov byte[ds:bx+320*68-1],al
neg byte[ds:bx+320*85-1] ;very fake lensflare like line
mov byte[ds:bx+320*129-1],al;also hiding something? ;)
mov byte[es:bx+320*190-1],al;NOT on vscreen because it would fuck up the flames
mov byte[es:bx+320*191-1],al;NOT on vscreen because it would fuck up the flames
dec bx
jnz lines

;copy vscreen to vga (23b)
;and "create" bars for design
mov di,320*8 ;start visible area
flip:
mov ax,word[ds:di]
neg ax   ;pimpin' (color of fire + dithering at middle part)
cmp di,320*131
jb dont
shl ax,2 ;pimpin'
dont:
stosw
cmp di,320*190 ;end visible area
jne flip

         mov ah,01h            ;read keyboard (14b)
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;textmode 80*25
         int 10h
         ret

nop ;256