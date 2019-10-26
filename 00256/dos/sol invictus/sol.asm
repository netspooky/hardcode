;sol invictus // the innermost sun
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: fritz kalkbrenner - wes (original mix)

;running under xp is recommended
;running under dosbox will need some runs to look correct
;(7 times on my machine) [and i don't know why]
;NO FPU

;ASSUMING: bx = 0

;used vars:
;bp         = scaling factor
;bp+30..255 = pos (for square of buffer#2)

org 100h
use16

start:   push 0a000h
         pop fs
         push 09000h
         pop es
         push 08000h
         pop ds
         mov al,13h
         int 10h

;smaller than code below but the fucker won't work correct under DOSBox
;        mov dx,0x3C9
;        mov si,65535-255
;pal:    shrd ax,si,18
;        out dx,al
;        out dx,al
;        xor ax,ax
;        out dx,al
;        add word[bp+si],si
;        inc si
;        jnz pal

        mov dx,0x3C9
        xor cx,cx    ;make sure ch = 0 because of mov si,cx!
pal:    mov si,cx
        shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        shr ax,1 ;xor ax,ax ;and al,cl
        out dx,al ;b
        add word[bp+si],si ;pos + speed 0...255 for dosbox compatibility
        inc cl
        jnz pal

mov word[bp],55 ;scaling; former data "multie"
                ;saves some bytes at calculation

;cx = 0 here
;bx = assumed to be 0
;squares on buffer#2
main2:
mov si,52   ;number of squares*2
buffloop:
mov bl,26   ;y
cubey2:
mov cl,23   ;x
cubex2:

imul di,bx,320        ;y
add di,cx             ;x
add di,word[bp+30+si] ;pos

stosb ;in most cases al <> 0

loop cubex2;x
dec bx     ;y
jnz cubey2

;movement of current square
mov ax,321*4 ;*? speeds up
cmp word[bp+100+si],65535/2 ;create direction
jb oneway
neg ax                      ;change direction
oneway:
add word[bp+30+si],ax  ;move

dec si
dec si
jnz buffloop
;squares on buffer#2 end

;cx = 0 here
;bx = 0 here
main:
mov bl,32          ;z
mov si,170         ;y
cubey:
dec cl ;cl=255     ;x
cubex:

;make 2d out of 3d

mov ax,si          ;y
sub ax,85          ;make -84 ... 85 out of 0..170
imul word[bp]

idiv bx    ;z
add ax,97 ;centerize

imul di,ax,320 ;2d y

mov ax,cx      ;x
sub ax,127     ;make -127 ... 128 out of 0..255
imul word[bp]

idiv bx    ;z
add ax,160 ;centerize

add di,ax  ;add calculated 2d value x
;make 2d out of 3d end

;rayworks
cmp bl,32          ;only test for square if first step!
jne ok
cmp byte[es:di],0  ;square is origin of ray
je error2          ;no square so break ray

ok:
cmp byte[ds:di],bl
jae error          ;don't draw higher colors on lower ones

mov byte[ds:di],bl     ;draw sun

error:
add bl,4   ;z = ray 1 or 2 = slow and 8 aweful
jnz cubex  ;256
error2:
mov bl,32 ;z
;rayworks end

;every point
loop cubex;x
dec si    ;y
jnz cubey

;make borders for design because there are many bytes left
dec cx ; = 0ffffh
mov si,320*201
lines:             ;vertical
mov byte[ds:si],cl
inc si
jnz lines

mov si,320*199
lines2:
mov word[ds:si],cx ;horizontal
mov word[ds:si+319],cx
sub si,320
jnz lines2

mov si,20
lines3:            ;edgeworks
mov byte[ds:si+320*5-10],cl
mov byte[ds:si+320*195-10],cl
dec si
jnz lines3

;drop a FAT BLUR on it
;si = 0 here
mov cx,12  ;ch <> 0 here so make it 0
blur:
mov al,byte[ds:si-320]
adc al,byte[ds:si+1]
adc ah,0
adc al,byte[ds:si+320]
adc ah,0
adc al,byte[ds:si-1]
adc ah,0
shr ax,2          ;div 4
jz firep
dec ax
firep:
mov byte[ds:si],al
inc si
jnz blur
loop blur

;flip
;si = 0 here
;cl = 0 here
flip:
mov byte[es:si],cl;al  ;clean buffer#2
mov al,byte[ds:si]
mov byte[fs:si],al
inc si
jnz flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main2            ;no, so go on

         mov ax,03h           ;keep it clean :)
         int 10h
         ret

;multie dw -65   ;scaling