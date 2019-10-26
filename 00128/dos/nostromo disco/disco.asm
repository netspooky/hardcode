;nostromo disco // molecularized vinyl
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: phelios - lv-426

;----------------------------------------------
;for this intro i had to skip the clean exit to
;dos since that gave me 5 bytes i was not  able
;to cut off.  but  better a  dirty exit than no
;esc support at all ;)

;the sound was chosen after fiddling around for
;some time. i used lord kelvins intro  "half of
;of a melody" to get started. the rest was luck
;finding that nice sound that fits  quite  well
;and led to the title of the prod.
;----------------------------------------------
;DosBox:  About  20.000  cycles are fine enough
;because the intro uses vsync.
;----------------------------------------------

;assuming:
;bx = 0

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h

        mov dx,0x3C9

pal:    shrd ax,bx,18 ;gray scale
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        inc bl
        jnz pal

;create random positions of the thingies
mov si,dx ;969
initer:
inc ax
mul si
adc word[pos+si],ax
dec si
jnz initer

main:

mov di,256 ;128 thingies

thingies:
mov ax,word[pos+di] ;get pos of thingie
mov cl,13           ;cl is for shr and also for width of thingies
shr ax,cl
add ax,315          ;add some movement

sub word[pos+di],ax ;move thingie

thing2:
mov si,word[pos+di] ;get pos
add si,cx           ;add width
mov bx,321*35       ;create final height
xor ax,ax           ;for the color
thing:
add byte[fs:si+bx],al ;draw
inc ax                ;rise color
sub bx,321            ;change height
jnz thing
loop thing2           ;draw whole thingie

dec di
dec di
jnz thingies          ;all thingies drawn?

;midi part
mov dx,331h           ;init
mov al,3fh
out dx,al
dec dx

mov al,155            ;go!
out dx,al

mov ax,bp
and al,147
out dx,al

or al,35
out dx,al

inc bp                ;change data for sound

;create same speed everywhere using vsync
mov dx, 3dah
vsync2:
in al,dx
test al,8
jz vsync2

;flip
;di = cx = 0 here
flip:
xor ax,ax
xchg ax,word[fs:di] ;grab vscreen
stosw               ;drop it including inc di
cmp di,cx
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

;         mov ax,03h           ;had to cut it because of the 5 bytes worth
;         int 10h
         ret

pos dw 1000 dup ?