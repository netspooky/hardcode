;of mysteries & fireflies // the great jungle cave
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: explosions in the sky - dear madison

;meditating in the cave of mysteries & fireflies listening to the
;falling drops of water somewhere in the twilight of the jungle.
;this is where it will end. in peace.

;_____________________________________________________________________________
;again this intro took its time because of finding the right decisions in
;design. but finally i can say that i'm very happy with the result.

;first there was the palette. since i knew the intro should have some
;jungle feeling the colors had to be green. i went with fading from black
;to green to yellow to green and back to black. but using that whole range
;made the cave nice and bright but destroyed the sparkling effect of the
;fireflies. so i skipped that yellow part and reduced the number of used
;colors for the rays from above which creates a nice mystic scene while the
;fireflies use the whole range of colors and stand out.

;second problem were the fireflies. in the first version they simply reacted
;to the color of the rays they were in front of (simply shl 3). it made the
;scene sparkle and also created a very nice fading into the scene since the
;screen starts off completely black. then i changed the color of the fireflies
;every frame and was quite happy with that result even if it costs the fading
;in.

;the falling pixel is not supposed to be a dying firefly but a drop of water
;from the top of the cave illuminated by the light of the fireflies. but
;having fireflies dying makes the scene more complex ;)

;_____________________________________________________________________________


;assuming: bx = 0

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;background
         pop fs
         push 08000h ;background + lights + bottom/top of cave
         pop ds
         mov al,13h
         int 10h

        mov dx,0x3C9
        xor cx,cx       ;no inc cx because of loop pal2

pal:    xor al,al       ;black ---> green ---> black
        out dx,al ;r
        shrd ax,cx,17
        out dx,al ;g
        xor al,al
        out dx,al ;b
        inc cx
        cmp cl,127
        jne pal

pal2:   ;xor al,al     ;color #127 out of reach for being displayed
        out dx,al ;r   ;so skip that xor al,al and save 2b
        shrd ax,cx,17
        out dx,al ;g
        xor al,al
        out dx,al ;b
        loop pal2

cls:
mov byte[fs:bx],cl ;clean screen
inc bx
jnz cls

main:

xor di,di
mov cl,27    ;for different thickness of rays
rayworks:
in al,40h
mul bp       ;randomizer
shr ax,14
mov si,ax
movzx ax,byte[cs:fading+si] ;get way of changing of color

xor bx,bx             ;for making the ray thick
do_the_ray2:
mov si,di             ;start value where ray will be
do_the_ray:
add byte[fs:si+bx],al ;add changing value to color

mov ah,byte[fs:si+bx] ;get new screen data

cmp ah,31;26             ;check of colors are within boundaries
jne nothing              ;to keep the mysterious spirit alive
sub byte[fs:si+bx],60;50
nothing:
cmp ah,226;231
jne nothing2
add byte[fs:si+bx],60;50

nothing2:
mov byte[ds:si+bx],ah    ;copy colors to second screen
add si,321
;cmp si,64000
;jnae do_the_ray
jnc do_the_ray
inc bx
cmp bx,cx ;10;28;39
jna do_the_ray2

dec cx                   ;change thickness of ray

add di,bx
cmp di,319
jnae rayworks            ;all rays done?

;inc di                 ;odd ---> even
;di div 2 = number of lights/fireflies
lights:
in al,40h
mov si,word[cs:light+di]  ;get pos of light
mov dx,bp              ;randomizer changes color since it increases by 1 each frame
add dx,di              ;add di as index to make every light unique (at least #0-255)
shl dl,2               ;speed up the sparkling
mov byte[ds:si],dl     ;firefly me beautiful :)
mul bp                 ;randomizer
cmp si,64000           ;light outside of visible area?
jna nice               ;nope
mov word[cs:light+di],ax  ;because of sparkles new light can appear out of nowhere
                       ;without looking strange a.k.a. randomize values
nice:
shr ax,15              ;create movement 0 or 1
imul bx,ax,319         ;320 creates more movement but it looks "rough"
                       ;moving them also sidewards via 319 adds nice flow
                       ;318 makes parallax scolling BUT THIS IS NO STARFIELD
dec ax                 ;1 --> 0 / 0 --> -1
;cmp dl,128            ;for testing
;jb allrite            ;makes the whole crew of fireflies swarm like
;neg ax                ;by changing direction but again this destroys the flow
;allrite:
add bx,ax              ;value of movement
sub word[cs:light+di],bx  ;move
dec di                 ;work with all lights
dec di
jnz lights

inc bp                 ;randomizer
imul bx,bp,320         ;use randomizer for falling drop
mov byte[ds:bx],bh     ;of awesomeness

;create same speed everywhere using vsync
mov dx, 3dah
vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
mov cl,255 ;slow it down the cheap/easy way ;)
vsync2:
in al,dx
test al,8
jz vsync2
loop vsync2

;create top and bottom of cave
dec cx;mov cx,0ffffh          ;saving bytes below by using cx as word for black color
xor ax,ax              ;needs to be same every run to make same result
mov di,322
frame:
add ax,di              ;change height of stone
;jz frame              ;needed to be cut because of vsyncs bytes
cmp ax,55
ja frame               ;too high ---> so again

imul bx,ax,320         ;ah = 0
cave:
mov si,di
add si,bx                   ;height of stalactites/stalagmites
mov word[ds:si-2],cx        ;top of cave with stalactite
                            ;-2 because of left upper corner (ds:0000 and ds:0001)
neg si
mov word[ds:si-320*5+64],cx ;ground of cave with stalagmite
sub bx,320
jnc cave

dec di
dec di
jnz frame

;flip
;cx = 0ffffh
;di = 0
flip:
mov al,byte[ds:di] ;grab screen with background + fireflies
stosb              ;drop it including inc di
loop flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
breaker: ret

nop ;256

fading db -1,0,1,0             ;for the behaviour of the advanced lightning simulation
light dw 2000 dup ?            ;pos of lights as always fucked up by using dosbox
                               ;because of the "empty" memory