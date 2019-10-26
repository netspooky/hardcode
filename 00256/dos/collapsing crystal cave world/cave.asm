;collapsing crystal cave world // the glassic intro
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: xyce ft. malmen - sourire

;well this might be the most fun intro i worked on so far.
;having something different in mind (procedural gfx ^^ ) one
;thing led to another and i ended up with a cave, lights and
;falling blocks everyone should know where they are from :D

;since i got a weakness for "random" stuff i used the famous
;and simple timer port to create the background. so some
;results might not look that great but what do you expect
;from a collapsing crystal cave. mario won't give a fuck too :)
;just restart the intro :)

org 100h
use16

start:   push 0a000h ;vga
         pop fs
         push 09000h ;screen with the cave drawn once
         pop es
         push 08000h ;vscreen
         pop ds
         mov al,13h
         int 10h

;make palette
;again grabbed from "blue fusion"
;takes a lot of bytes but it is for the looks

;assuming: ax = bx = 0 / cx = 255

        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2

pal:    mov al,bl ;first half
        out dx,al ;r
        out dx,al ;g
        shrd ax,cx,17
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
        mov al,bl
        out dx,al ;g
        shrd ax,cx,17
        out dx,al ;b
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal2

;draw the cave in one run into memory
;only change will be the cycling of the colors below at updating the screens (flip)
;to make the reflections effect and that in only 3b ^______________^

;make colors of lines + pos/speed of falling mario blocks
;cx = bx = 0 here
xor di,di              ;i could assume it but safety first ;)
mov cl,80              ;80 x 4 = 320
line:
in al,40h              ;adc ax,dx; for fixed background that looks good
mul cx
shr al,1               ;less is sometimes more appealing to the eye :)
mov ah,al              ;word
stosw                  ;di + 2
mov word[es:di-320],ax ;to avoid a single pixel line by grabbing
                       ;nothing out of memory at di(320) - 321 at rays
stosw                  ;di + 2
mov si,cx              ;get correct pos for data saving
adc word[bp+si],ax     ;save pos of the blocks
adc word[bp+si+200],ax ;save speed of the blocks
                       ;both is kinda "random" depending on values already in memory
loop line

;make diagonal light rays
;di = 320 here / cx = 0 here
;rays:
;mov al,byte[es:di-321]
;mov byte[es:di],al
;inc di
;jnz rays

; -1b
sub cx,di ;)
rays:
mov al,byte[es:di-321]
stosb
loop rays

;make ground
mov di,320*138
ground:
add byte[es:di],13 ;is enough contrast to see the floor
inc di
jnz ground

;make crystals with moving reflections and some nice fading into the environment
;cx = bx = 0 here
mov cl,150 ;height
crystals:
imul di,cx,320
mov bl,82 ;width
lines:
sub byte[es:di+bx+320*50+24],bl  ;left
neg di                           ;)
sub byte[es:di+bx+215-320*28],cl ;middle
add byte[es:di+bx-19+320*10],cl  ;right
neg di                           ;)
add byte[es:di+bx+320*90+267],bl ;left/right/top to fill the cave with last bytes
add byte[es:di+bx+320*90+267],cl ;chopped off vsync
dec bx
jnz lines
loop crystals

main:

;draw super mario world blocks
;cx = bx = 0 here
mov si,32             ;number of floating blocks*2 / blocks at si=0 not used
blocks:               ;i think 15 blocks are a good number
mov cl,12             ;height
square1:
imul di,cx,320        ;make height
add di,word[bp+si]    ;add pos
mov bl,15             ;width
square2:
add byte[ds:di+bx],cl ;shade
add byte[ds:di+bx],bl ;might be too weak for the eye in motion :)
                      ;but only adding a fixed value is too "flat"
dec bx                ;move to draw a line
jnz square2
loop square1

mov di,word[bp+si];save origin for "eyes"

;draw eyes to the block
;writing bytes instead of words to avoid overflow crash
;when writing at ds:65565 (will happen because start position is random)
mov cl,5     ;size of the eyes
add di,320*3+4 ;top of the eyes
eyes:                          ;##############  simple       ##############
mov byte[ds:di],cl ;why ch?    ;##############  block        ### ###### ###
mov byte[ds:di+1],cl           ;############## <-----        ### ###### ###
mov byte[ds:di+7],cl           ;##############  neat  block  ### ###### ###
mov byte[ds:di+8],cl           ;##############     with      ##############
add di,320                     ;##############  personality  ##############
loop eyes                      ;##############      ------>  ##############

;make the blocks drop
mov dx,word[bp+si+200] ;get speed value
shr dx,15              ;make it good
inc dx                 ;make it not 0
imul ax,dx,320         ;make it possible
add word[bp+si],ax     ;make it move

dec si                 ;next set of data
dec si
jnz blocks             ;work all sets

mov dx, 3dah           ;wait for vsync for constant speed
;vsync1:                ;to make things smoother and not
;in al,dx               ;rushed
;test al,8              ;vsync1 not needed for result
;jnz vsync1             ;so 5b for another crystal in the scene :)
vsync2:
in al,dx
test al,8
jz vsync2

;flip and stuff
;si = 0
flip:
mov al,byte[es:si]  ;get saved screen
xchg byte[ds:si],al ;get vscreen + overwrite it with saved background
mov byte[fs:si],al  ;drop data to vga
inc byte[es:si]     ;calvin rotate likes! rotate saved screen colors for reflections (3b)
inc si
jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

nop                    ;255
nop                    ;256
