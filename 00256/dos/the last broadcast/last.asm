;the last broadcast // into the unknown
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: blood box - ghost procession

;################################## == ###################################
;
;They left for an expedition into the unknown depths of this new continent
;that had risen out of nowhere.  Its name:  Darwinia II.  After a few days
;the live transmission suddenly stopped and the team disappeared without a
;trace.  What you are about to see is the last digital signal right before
;the event. This is the last broadcast.
;
;################################## == ###################################

org 100h
use16

start:   push 0a000h ;screen
         pop es
         push 09000h ;buffer1
         pop ds
         push 08000h ;buffer2
         pop fs      ;using stack segment saves 1b if really needed (no stack operations!)
         mov al,13h
         int 10h

;make palette // cx = 255 here
        mov dx,0x3C9
        inc cx
pal:    shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        xor al,al
        out dx,al ;b
        loop pal

;used vars:
;bl = for moving elements
;bh = for color of power lights
;di = position for drawing

;mov bl,6 ;init not needed
main:
in al,40h   ;random seed every whole run so now slow down
mov cx,37951;27953;65535/2

;move the drawing pixel
bringer:
neg dx    ;won't stay 0 + nifty cineastic stripes
add ax,cx ;won't stay 0
mul dx
shr al,6  ;256/64 [which way do you prefer, sire?]
jnz gate1
add di,320 ;move down
gate1:
cmp al,1   ;dec al
jne gate2  ;jnz gate2
dec di     ;move left
gate2:
cmp al,2
jne gate3
inc di     ;move right
gate3:
cmp al,3
jne gate4
sub di,320 ;move up
gate4:
mov byte[ds:di],255  ;set new pixel
loop bringer

;do the blur // si = 0 here after first run
blur:
mov al,byte[ds:si+320]
adc al,byte[ds:si+1]
adc ah,0
adc al,byte[ds:si-1]
adc ah,0
adc al,byte[ds:si-320]
adc ah,0
shr ax,2
;jz ney ;not necessary since average lowest color somewhere above 5; so save 2b
dec al
ney:
mov byte[ds:si],al ;buffer   work with
mov byte[fs:si],al ;buffer2  backup for adding bars before dropping to screen
dec si
jnz blur

;dot for "disortion" but i don't know ... 6b
;mov si,dx
;mov word[ds:si],di
;xor si,si

;makes blur/movement a bit smoother
mov dx, 3dah ;wait for vsync
;vsync1:     ;wait for v retrace end
;in al,dx
;test al,8    ;9=h/vsync
;jnz vsync1
vsync2:      ;wait for v retrace start
in al,dx     ;only this part is needed (-5b to use somewhere else)
test al,8    ;9=h/vsync
jz vsync2

;power lights // si = cx = 0 here
b1:
mov cl,6;9 ;width
b2:
neg bh
mov byte[fs:si+293+320*160],bh ;left   5b each *sigh         5b
mov byte[ds:si+293+320*160],bh ;drop it on buffer1 for flare 4b
neg bh
mov byte[fs:si+283+320*160],bh ;left-1                       5b
;              280+320*160
mov byte[fs:si+270+320*160],bl ;left-2 slighty flickering    5b
;mov byte[ds:si+270+320*160],bl ;drop it on buffer1 for flare 4b

mov byte[fs:si+254+320*160],ch ;left-3 broken                5b

;mov byte[fs:si+246+320*160],ch ;left-4 broken                5b
inc si       ;change width
loop b2
add si,320-6 ;change height + move back
cmp si,320*6 ;max size?
jna b1
inc bh ;charge!

;black bars on buffer2 // cx = 0 here
mov si,320*54+256
flip2:
mov byte[fs:si-320*31+63],cl ;cl instead of 0 ---> -1b
mov byte[ds:si-320*31+63],179;dl ;make blur + "highlight" on edges (buffer1)
dec si
jnz flip2

;moving elements on buffer2 // si = cx = 0 here
sub si,bx ;movement
sar si,12 ;movement
two:
mov cl,18 ;width
one:      ;draw line left to right
cmp bl,9  ;do we draw a cell?
ja four   ;no ---> empty height!
dec byte[fs:si+10]   ;right thing
shl byte[fs:si+10],1
neg si
mov byte[fs:si-248-320*5],ch ;left/right edge thing
mov byte[ds:si-203-320*13],247;ch ;left/right edge thing
neg si
four:
inc si        ;width+
loop one      ;make complete width
dec bl        ;height
jnz three     ;reached complete hight of 1 cell + 1 empty space
mov bl,18     ;reset value
three:
add si,320-18 ;change height and move back to the left
cmp si,64000  ;end of screen?
jb two        ;no
;dec bl ;speed up

;flip to screen // si >= 64000 here
flip:
mov al,byte[fs:si]
mov byte[es:si],al
dec si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main            ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret