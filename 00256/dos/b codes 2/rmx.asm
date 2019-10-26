;rmx
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: yuzo koshiro - moon beach

;a little recreation of the shader cupe coded in the semi final
;of the shader showdown at revision 2o17. i was quite impressed
;and a bit jealous tbh since that thingie was so simple and yet
;rocking :) i thought it would look nice in 256b.  so i changed
;some elements and here you go :)


org 100h
use16

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h
         push 07000h
         pop fs

        mov dx,0x3C9

        xor cx,cx ;no inc cx because of loop pal2
pal:
        shrd ax,cx,17 ;black, green, yellow, orange, red, black
        out dx,al ;r
        mov al,bl
        out dx,al ;g
        xor al,al
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
pal2:
        cmp cl,63
        ja allright2
        dec bx
        allright2:
        loop pal



main:

xor bx,bx                ;number of elements
                         ;to access data
mov word[bp+60],5*320*40 ;column

loop4:
mov word[bp+62],8*40     ;row

loop3:
mov word[bp+64],cx ;size of circle to be drawn
loop2:
imul ax,word[bp+64],6;make a spiral

add ax,word[adder+bx]    ;add the individual rotation
mov word[bp],ax          ;save for use

mov cl,200;360 ;angle to draw to
               ;200 makes a nice spiral

mov dx,ax;word[adder+bx] ;color
xor dx,word[main+bx]  ;make it a bit more rnd
shr dx,4              ;don't flicker like fuck

loop1:

fild word[bp]      ;load degrees
fidiv word[for_rad]
fsincos             ;cos sin
fimul word[bp+64]   ;size of circle
fistp word[bp+6]    ;new x pop
fimul word[bp+64]   ;sin*x/y
fistp word[bp+8]    ;new y pop

;set 2d pixel
imul di,word[bp+6],320 ;normal approach

test byte[adder+2+1],8 ;add a little variation
jnz no1
imul di,word[bp+6],319;iso approach
inc dx                ;color is sweeeeeetieful
no1:

add di,word[bp+8] ;y*320+x = pos pixel
add di,word[bp+66] ;global movement
add di,word[bp+62] ;row
add di,word[bp+60] ;column


mov byte[fs:di],dl ;drop to vscreen

dont_draw:
inc word[bp] ;next degree
loop loop1   ;do whole degrees


add word[bp+64],4;3;:D
cmp word[bp+64],19 ;max size of circle per element?
jna loop2

mov ax,word[bp+64]
mul di
shr ax,12             ;speed of rotation
;inc ax
sub word[adder+bx],ax ;rotate

inc bx ;change number of element
inc bx ;word!

sub word[bp+62],40 ;x8 ;row
jnz loop3

sub word[bp+60],320*40 ;x5 ;column
jnz loop4

sub word[bp+66],321 ;global movement

;simply reuse bx :)
bar:
mov di,88
bar2:
mov al,byte[fs:bx+di-6]
add al,12
mov byte[fs:bx+di],al

mov word[fs:bx],cx   ;borders of bar
mov word[fs:bx+88],cx
dec di
jnz bar2
add bx,319
jnc bar


mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

mov di,320*30
;mov cx,320*68;=5500h
mov ch,55h
flip:
mov ax,0fbf9h       ;bg pattern
xchg ax,word[fs:di] ;get vscreen
stosw
loop flip

         in al,60h            ;read keyboard buffer
         dec al               ;esc needs to be pressed several times
         jnz main             ;nothing so go on
breaker: ret                  ;return to sender
         nop                  ;guess what
         nop

for_rad dw 57 ;180°
adder dw 200 dup ? ;better start that with 0 ;for rotation