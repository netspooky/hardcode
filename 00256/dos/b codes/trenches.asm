;in the trenches // where it waits
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: new risen throne - dead, scourged sun

;You are on guard. But there is no one left. No one left in this war.
;Only the cold rain and the illusive fog. Or are those shades the
;lost souls of the fallen ones?

;Is the wind the playing an haunting song? Are the barbed wires
;coming to life?

;You lie here. Feeling the cold crawling into your body.

;You are on guard hoping for a bird calling out the sun.

org 100h
use16

start:   push 0a000h ;vga
         pop es
         push 09000h ;vscreen
         pop fs
         mov al,13h
         int 10h

        mov dx,0x3C9
        inc cx
pal:    shrd ax,cx,17 ;grayscale
        out dx,al ;r
        out dx,al ;g
        out dx,al ;b
        inc cl
        jnz pal

mov bx,16000*2 ;fill data with data ;)
makedata:
inc ax         ;no 0
mul bx
adc word[pos+bx],ax
dec bx
jnz makedata

main:
mov di,5000 ;number of "fog elements"
mov bp,320  ;for add/div ... saves bytes
draw:
mov si,word[pos+di] ;get pos for movement calculation
mul si              ;give it some variation
sar ax,13           ;sloooow it down
add ax,bp;inc ax    ;add extra movement upwards
sub word[pos+di],ax ;new pos

mov ax,si           ;pos
xor dx,dx
div bp              ;div 320
shr ax,2            ;/4
inc ax              ;not 0!

mov cx,ax ;make square side lenght = ax
loop2:
inc si              ;move right
imul bx,ax,320
loop1:
inc byte[fs:si+bx]
sub bx,bp           ;move up
jnz loop1
loop loop2

dec di              ;next set of data
dec di
jnz draw            ;okay

;create same game speed everywhere using vsync
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;bars
mov bx,320*53
bars:
mov byte[fs:bx],dh ;not full black
dec bx
cmp bx,320*145-1
jne bars

;mov word[var1],60 ;amplitude
mov word[var2],di ;x to draw at
mov word[var3],54 ;start degree
fninit ;not necessarily needed but well ...
wire:
fild word[var3]      ;degree
fidiv word[for_rad]  ;pi*grad (changed; normally 57.14...)
fsin
fimul word [for_rad] ;amplitude
fistp word [var4]    ;new y

mov cx,1218h         ;save 3b
imul si,word[var4],320   ;create pos of pixel on the screen
add si,word[var2]        ;add x pos
mov word[fs:si+320*98+3],cx ;set

;make spikes
mov ax,word[var1] ;for movement
add ax,word[var2] ;x pos
xor dx,dx
mov bx,16
div bx
cmp dx,di;0      ;spikes every 14 steps
jne nospike
mov bx,-321*3+320*98+3 ;left up to right down
mov bp,-319*3+320*98+3 ;right up to left down
spike:
mov word[fs:si+bx],cx   ;set spike
mov word[fs:si+bp],cx   ;set spike
add bp,319              ;move to next bit of spike
add bx,321              ;move to next bit of spike
cmp bx,321*4+320*98+3  ;full spike drawn?
jne spike
nospike:
inc word[var2]     ;x to draw at
inc word[var3]     ;change degrees
cmp word[var3],327 ;end degree
jne wire

dec word[var1] ;move spikes

;flip
;di = 0 here
flip:
xor ax,ax
xchg ax,word[fs:di] ;grab vscreen
stosw;mov byte [es:di],al ;drop to screen
cmp di,0;inc di
jne flip;jnz flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         nop
         nop
         nop
         nop ;256
         ret

for_rad dw 60
pos dw 16000 dup ?
var1 dw ?
var2 dw ?
var3 dw ?
var4 dw ?