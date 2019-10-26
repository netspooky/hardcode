;all our little happy alien ghosts
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;the core of this one is based on the idea cupe coded during
;the shader showdown semi finals at revision 2o17. i think i
;would not have had the idea without it while recreating the
;effect (but simpler) in under 256 bytes. it does not look
;that good in 320*200 so i had to do something about it. so
;things evolved and became those little happy alien ghosts.

org 100h
use16

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h
         push 07000h
         pop fs

;pal gen from "how to skin the rainbow serpent"
        mov dx,0x3C9
        xor cx,cx ;no inc cx because of loop pal2
pal:
        mov al,bl
        out dx,al ;r
        shrd ax,cx,18
        out dx,al ;g
        shl al,1
        out dx,al ;b  ;no red in here but it looks more polished than

        cmp bh,ch;0
        jne pal2

        cmp cl,64
        jb allright
        inc bx
        allright:

        inc cx
        cmp cl,127
        jne pal
        inc bh
pal2:
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal

main:

mov bx,50            ;number of elements*2
loop3:
mov word[bp],cx      ;size of circle to be drawn; cx = 0
loop2:
imul ax,word[bp],6   ;make a spiral
add ax,word[adder+bx];add the individual rotation
mov word[bp+2],ax    ;save degrees for use

mov cx,200;360       ;angle to draw to

mov ax,word[adder+bx];color
shr ax,3             ;don't trip!

test bx,4            ;change rotation
jz no2               ;to anti clock
neg word[bp+2]       ;for some elements
no2:

loop1:


fild word[bp+2]      ;load degrees
fidiv word[for_rad]  ;right
fsincos              ;cos sin

fimul word[bp]       ;cos*x/y sin
fistp word[bp+6]     ;new x pop

fimul word[bp]       ;sin*x/y
fistp word[bp+8]     ;new y pop

imul di,word[bp+6],320
add di,word[bp+8]
add di,word[start+bx+1] ;data +1 has more variation

mov byte[fs:di],al
mov byte[fs:di+1],al ;fake accuracy +4b

inc word[bp+2] ;next degree

loop loop1     ;do whole degrees


inc word[bp]
cmp word[bp],bx
jna loop2      ;size

mov ax,word[bp]
shr ax,2
inc ax
sub word[adder+bx],ax ;rotate

mov ax,bx
shr ax,4
inc ax
imul ax,ax,321
sub word[start+bx+1],ax ;change pos

dec bx
dec bx
jnz loop3 ;all elements done?

;bars with scaling, right one x1, left one x2 :)
mov si,160
ok3:
mov bx,si
ok2:
xor di,di
ok1:
mov al,byte[fs:di+bx]
dec ax
dec ax
mov ah,al
mov word[fs:di+bx-320*5+6],ax
mov word[fs:di+bx-320*5+6+320],ax
add di,319*2 ;320 makes scaling a bit more obvious
jnc ok1      ;but it looks not that nice
cmp si,80
jne ok4
dec bx ;scale x2
ok4:
dec bx ;scale x1
jnz ok2
sub si,80
jnz ok3

;pal bars
;mov bx,320*40-1;=3200h
mov bh,32h ;don't care about that 1 black pixel in the left upper corner to save 1b
bar:
mov byte[fs:bx],cl ;0
dec bx
cmp bx,320*159-1
jne bar

mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;xor di,di
;di = 0
;cx = 0
flip:
mov al,0fh
xchg al,byte[fs:di] ;get vscreen
stosb
loop flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

         ret

for_rad dw 57       ;180°

adder dw 200 dup ? ;better start that with 0 ;for rotation