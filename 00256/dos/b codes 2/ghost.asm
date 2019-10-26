;ghost party
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;the core of this one is based on the idea cupe coded during
;the shader showdown semi finals at revision 2o17.

org 100h
use16

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h
         push 07000h
         pop fs
         push 08000h
         pop gs

        mov dx,0x3C9

        xor cx,cx ;no inc cx because of loop pal2
pal:
        mov al,bl     ;black, green, yellow, orange, black (original set)
        out dx,al ;r  ;no red in here but it looks more polished than
        shrd ax,cx,17 ;the other sets. and since i had to decide on one
        out dx,al ;g  ;set i went with the best. and it has a warm feel:)
        shr al,1;xor al,al;
        out dx,al ;b

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
;        jmp pal
pal2:
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal

main:

mov bx,52 ;number of elements*2
loop3:
mov word[bp],cx ;size of circle to be drawn; cx = 0
loop2:
imul ax,word[bp],6       ;make a spiral
add ax,word[adder+bx]      ;add the individual rotation
mov word[bp+2],ax          ;save degrees for use

mov cx,200;360 ;angle to draw to

mov ax,word[adder+bx] ;color
shr ax,3

test bx,4
jz no2
neg word[bp+2] ;change rotation
no2:

loop1:

fild word[bp+2]      ;load degrees
fidiv word[for_rad]

fsincos             ;cos sin

fimul word[bp]   ;cos*x/y sin
fistp word[bp+6] ;new x pop

fimul word[bp]   ;sin*x/y
fistp word[bp+8];new y pop

;set 2d pixel
imul di,word[bp+6],320
add di,word[bp+8] ;y*320+x = pos pixel
add di,word[start+bx]

mov byte[fs:di],al
mov byte[fs:di+1],al ;fake accuracy +4b


dont_draw:

inc word[bp+2] ;next degree

loop loop1   ;do whole degrees


inc word[bp]
cmp word[bp],bx
jna loop2

mov ax,word[bp]
mul di
shr ax,11
inc ax
sub word[adder+bx],ax ;rotate

mov ax,bx
shr ax,4
inc ax
imul ax,ax,319
sub word[start+bx],ax

dec bx
dec bx
jnz loop3



imul bx,word[start+10],-1
mov di,320*60
col1:
mov al,byte[fs:di+bx]

xor byte[fs:di+bx+320*5+8],al
dec di
jnz col1


mov bx,320*30-1
bar:
mov byte[fs:bx],cl ;0
dec bx
cmp bx,320*169-1
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


;di = 0
mov cx,0ffffh/2

flip:
mov ax,0faf8h
xchg ax,word[fs:di] ;get vscreen
stosw
loop flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         ret

for_rad dw 57 ;180°

adder dw 200 dup ? ;better start that with 0 ;for rotation