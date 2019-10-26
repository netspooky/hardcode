;breed // growing in the dark
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: the end of the ocean - to be buried and discovered again

;aiming for the clouds
;evolving thingies instead
;great to see them grow


;########

;some words about that intro:

;there is no grabbing of the timer to prevent very ugly shapes (like only a staight line)
;at least a lot of test runs did not show them with the current code
;so the evolving is restricted/loops because of that decision.

;for those who are curious how it works but don't want to look at the code:

;basically for each thingie x lines are drawn beginning at [pos] with length/pixels [sze].
;[shp] is used as initial value to create the direction (1,-1,320,-320) of the next pixel of that line.
;the calculation is bound to the # of the thingie, so every thingie is unique (in theory).
;[sze] also is the drawing color changing from 1 to 255 (fade in) and back again to 1 (fade out).
;when [sze] reaches 0 [shp] and [pos] are changed to create a new thingie to appear. the movement of e.g.
;a tentacle is caused by the values playing all together with [sze] changing every frame.
;that's all folks :D

;assuming: cx = 255

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx        ;cl = 0 / ch = 1
pal:    xor ax,ax     ;don't make the eye hurt
        out dx,al ;r
        shrd ax,cx,18
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal

xor bx,bx ;boom! safety
init:
sbb dx,bx
adc ax,bx
mul dx
adc word[pos+bx],ax ;position
sbb word[shp+bx],dx ;shape
sbb byte[sze+bx],al ;size / fading
shr ah,7 ;div 128 ---> 0 or 1
shl ah,1 ;0 or 2
dec ah   ;-1 or 1
mov byte[how+bx],ah ;1 or -1
inc bl
jnz init

main:

mov si,50           ;24 thingies (si = 0 is not drawn)

loop1:

mov dx,word[sze+si] ;movement based on size
shr dx,14
inc dx
imul ax,dx,320

cmp bp,32222        ;movement on/off
jb nextone
sub word[pos+si],ax ;move

nextone:
mov ch,byte[how+si] ;1 or -1
add byte[sze+si],ch ;change size
jnz okay            ;size 0?
neg ch              ;make 1 to -1 or -1 to 1
mov byte[how+si],ch ;save it
add byte[sze+si],ch ;make size <> 0

cmp byte[how+si],-1 ;only change values when faded to black
je okay
sub word[shp+si],bp ;change shape
adc word[pos+si],bp ;change pos

okay:

mov cx,si ;cl = loops / ch will be step length every loop
shr cx,2  ;max 50/4 +1
inc cx    ;restrict loops because too much look ugly

mov dx,word[shp+si];make sure ax and dx are ALWAYS during 1 frame
                   ;ax comes from above
draw:
mov ch,byte[sze+si] ;step lenght every loop
oki:
mov di,word[pos+si] ;start/center of thingie
loop0:
add ax,si           ;change for creating thingies look
sub dx,si           ;bound to the # of the thingie
mul dx              ;to make them unique

mov bx,ax           ;copy to keep ax for next run
xor bh,bh           ;shr bx,14 /shl bx,1 would save 2b but the look :)
shr bl,6            ;/64 = 0 ... 3
shl bl,1            ;double because of word
add di,word[way+bx] ;get way of movement

cmp byte[fs:di],ch  ;give it
jae nope            ;shading
mov byte[fs:di],ch
nope:

dec ch
jnz loop0           ;all steps/full length done?

loop draw           ;next loop

mov ax,word[way+bx] ;floating around according to last movement of thingie
add word[pos+si],ax ;move

dec si
dec si
jnz loop1           ;work with all thingies

adc bp,123          ;change seed for thingies + change counter for movement on/off

;si = 0
mov cx,90           ;size of triangle for design
corner1:
mov bx,cx
;si=0
corner:
shr byte[fs:si+bx-257],1
dec bx
jnz corner
sub si,320
loop corner1

;slow it down
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;flip to screen
mov di,320*20
flip:
mov ax,18           ;add some lines for the eyes
xchg ax,word[fs:di] ;grab vscreen
stosw
cmp di,320*180
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

way dw 1,-1,320,-320
how dw 800 dup ? ;way of fading 1 or -1
pos dw 400 dup ? ;position
sze dw 400 dup ? ;size/fading
shp dw 400 dup ? ;shape