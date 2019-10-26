;the iron dragonfly/ad
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: anilah - medicine chant

;the logo is from the cover of my novel
;"die eiserne libelle" (the iron dragonfly)
;which is only availiable in german at the
;moment but will be translated and being
;published in english in 2o17.

;the german edition is availiable as ebook
;wherever you want. the printed (limited run of 200,
;hand numbered) is availiable by dropping me an email
;at kontakt@sensenstahl.com

;you can get an extract (.pdf) of it for free
;at www.sensenstahl.com (also german only)

;this prod is no ... cracktro ^^

;please support a poor scener :D

org 100h
use16

basic equ 160*3 ;basic pos
                ;makes it a bit easier to move things around :)

start:   push 0b800h ;textmooooooode
         pop es
         push 08000h ;mem with logo a.k.a. vscreen2
         pop ds
         push 07000h ;vscreen
         pop gs

         mov ax,1112h  ;80x50 so 8000b buffer needed
                       ;1byte char and 1byte attributes
         int 10h

         mov ax,1003h  ;disable blink (128) ---> full 16 bg colors
                       ;so syntax = color (0..15) + 16*background color (0..15 = 16 colors)
         int 10h


;############### draw the dragonfly into memory once
;                and not every time by jumping to main:
mov cl,160 ;use below; ch = 0 here

;draw the dragonfly
;draw the body
mov si,29*80*2 ;height
fine2:
mov bl,6       ;thickness
fine:

mov ax,0c0deh   ;placeholder value
               ;it is later scanned for exactly this value
mov word[ds:si+bx+78+5*160+basic],ax

dec bx
dec bx
jnz fine
sub si,cx;80*2
jnz fine2

;draw the 4 wings
;mov bx,80*2*2
one2:
mov di,18*2
one1:
mov word[ds:di+bx+6*160+38+basic],ax ;upper left
mov word[ds:di+bx+6*160+88+basic],ax ;upper right
cmp di,12*2
ja nono
mov word[ds:di+bx+10*160+50+basic],ax ;lower left
mov word[ds:di+bx+10*160+88+basic],ax ;lower right
nono:
dec di
dec di
jnz one1
add bx,cx;80*2
cmp bx,80*2*2
jne one2

;draw the head + tail
;mov bx,80*2*3
one6:
mov di,3*2
one5:
mov word[ds:di+bx+1*160+78+basic],ax
mov word[ds:di+bx+37*160+78+basic],ax
dec di
dec di
jnz one5
sub bx,cx;80*2
jnc one6
;############### drawing done

;cx is free to use so it is used for rotation
main:

;create bars by changing the middle part of the screen
mov di,160*3+1
bars:
mov byte[gs:di],16*8
inc di
inc di
cmp di,160*47+1
jne bars

;make a little flying thingie to fill up bytes i gained by optimizing
;it will be in the background
imul bx,cx,-160
mov word[gs:bx],0efdch

;grab symbol out of memory, center it and rotate and drop on vscreen
mov bx,45*80*2 ;y
grabb2:
mov si,48*2 ;x
grabb:
mov ax,word[ds:si+bx+34]
cmp ax,0c0deh ;how big is the possibility to have this combination in the memory?
              ;so assuming it will happen almost never i can save the cls
jne nonono
mov word[bp],si   ;x
sub word[bp],24*2 ;center
mov word[bp+2],cx
fild word[bp+2];degrees
nop ;sneaky nop is sneaky
fidiv word[cs:103];fine enough instead of 57/2
fsin
fimul word[bp]
fistp word[bp]

mov di,word[bp]
test di,1 ;test if even or odd
jz ok     ;even
inc di    ;odd so make even
ok:

mov byte[gs:di+bx+34+44+1],7       ;final pos + adjust, highlight
                                ;only change colors of bg to draw
mov byte[gs:di+bx+34+44+160+2+1],8 ;final pos + adjust, shape

nonono:

dec si
dec si
jnz grabb
sub bx,80*2
jnz grabb2

;additional design as always
;give it color to set it more into the foreground
;si = di = bx = 0
line:
mov bl,15*2
line2:
mov word[gs:bx+si+56*2],9304h  ;advanced combination #1
mov word[gs:bx+si+56*2-4],912fh;advanced combination #2

dec bx
dec bx
jnz line2

add si,160+2
;cmp di,50*160
;jna line
jno line ;stops at 32k, jnc not work correct

inc cx ;change rotation

mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2


;di = 0 here
flip:
in al,40h          ;rnd
mul cx             ;rnd
xor ax,di          ;rnd
mov ah,7+16*8      ;color + random bg color
xchg ax,word[gs:di]
stosw
cmp di,80*50*2
jna flip


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;nothing so go on
         ret
