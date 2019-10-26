;nostromo disco // molecularized vinyl [old]
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;assuming:
;cx = 255

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx        ;cl = 0

pal:    shrd ax,cx,18 ;gray scale
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal

;create random positions of the thingies
mov si,900*2
initer:
in al,40h
mul si
adc word[pos+si],ax
dec si
jnz initer

main:

mov si,256 ;128 thingies

thingies:
mov ax,word[pos+si] ;get pos of thingie
mov cl,13           ;cl is for shr and also for width of thingies
shr ax,cl
add ax,315          ;add some movement

sub word[pos+si],ax ;move thingie

thing2:
mov di,word[pos+si] ;get pos
add di,cx           ;add width
mov bx,321*35       ;create final height
xor ax,ax           ;for the color
thing:
add byte[fs:di+bx],al ;draw
inc ax                ;rise color
sub bx,321            ;change height
jnz thing
loop thing2           ;draw whole thingie

dec si
dec si
jnz thingies          ;all thingies drawn?

;midi part
mov dx,331h           ;init
mov al,3fh
out dx,al
dec dx

mov al,155          ;go!
out dx,al

mov ax,bp
and al,147
out dx,al

or al,35
out dx,al

inc bp     ;change data for sound

;flip
mov di,320*40       ;bar area above
flip:
mov al,cl
xchg al,byte[fs:di] ;grab vscreen
stosb               ;drop it including inc di
cmp di,320*159      ;bar area below
jne flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

;         mov ax,03h            ;had to cut it because of the 5 bytes worth
;         int 10h
         ret

pos dw 1000 dup ?