;how to skin the rainbow serpent // the holy skin of a giant
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: blue forest - spiral dance

;based losely on my intro "upup" in terms of the core idea
;to use a nice pattern (with hexagons). having them rotated
;by 90 degrees reminded me on the skin of a snake - and that
;is where a part of the name of the intro came from. the idea
;with the rainbow serpent is based on the colors.

org 100h
use16

start:   push 0a000h     ;vga
         pop es
         push 08000h     ;vscreen
         pop ds
         mov al,13h
         int 10h

;make palette (43b)
;        mov dx,0x3C9

;        xor cx,cx ;no inc cx because of loop pal2
;pal:    mov al,bl ;first half
;        out dx,al ;r
;        shrd ax,cx,17
;        out dx,al ;g
;        xor al,al;shr al,1; it is the rainbow serpent ffs
;        out dx,al ;b
;        cmp cl,64
;        jb allright
;        inc bx
;        allright:

;        mov si,cx
;        mov byte[bp+si+10],cl ;compatibility

;        inc cx
;        cmp cl,127
;        jne pal

;pal2:   mov al,bl
;        out dx,al ;r
;        shrd ax,cx,17
;        out dx,al ;g
;        xor al,al;shr al,1;
;        out dx,al ;b
;        cmp cl,63
;        ja allright2
;        dec bx
;        allright2:
;        loop pal2


;xor al,al = 30c0h as code
;shr al,1  = d038h as code

;d038h - 30c0 = 9f78

;5b less than code above
        mov dx,0x3C9

        xor cx,cx ;no inc cx because of loop pal2
pal:
        mov al,bl     ;black, green, yellow, orange, black (original set)
        out dx,al ;r  ;no red in here but it looks more polished than
        shrd ax,cx,17 ;the other sets. and since i had to decide on one
        out dx,al ;g  ;set i went with the best. and it has a warm feel:)
        xor al,al;shr al,1;
        out dx,al ;b

;        shrd ax,cx,17 ;black, green, yellow, orange, red, black
;        out dx,al ;r  ;nice transitions but colors look a bit
;        mov al,bl     ;i don't know ... gut feeling. not good.
;        out dx,al ;g
;        xor al,al;shr al,1; retina? what? :D
;        out dx,al ;b

;        mov al,bl     ;black, purple, pink, blue, black
;        out dx,al ;r  ;demoish
;        xor al,al;shr al,1;
;        out dx,al ;g
;        shrd ax,cx,17
;        out dx,al ;b

;        shrd ax,cx,17 ;black, purple, pink, red, black
;        out dx,al ;r  ;even more demoish
;        xor al,al;shr al,1;
;        out dx,al ;g
;        mov al,bl
;        out dx,al ;b

        cmp bh,ch;0
        jne pal2

        cmp cl,64
        jb allright
        inc bx
        allright:

        mov si,cx
;        mov byte[bp+si+10],cl ;dosbox compatibility
        mov byte[bp+si],cl ;dosbox compatibility

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

;bp+10 = for changing of the scenes + generate pattern
        ;word it is set above to 0001h and not changed
        ;by the rays below
        ;so every start the same without spending extra
        ;bytes
main:

mov word[bp],32*7 ;columns
shape5:
mov dx,3 ;rows (*2) ;dx = 3dah after jump back to main
shape4:
mov cl,16      ;x ;ch = 0 here
shape3:
mov di,320*16  ;y1
shape2:
mov bx,321*16  ;y2
shape:
imul si,cx,319 ;basic pos
imul ax,dx,320*48+320*16 ;rows
;sub ax,320*71+49+16-32;base from below but -1b since ax is used
                       ;using at pixel set saves 1b (values have been fixed/changed!)
add si,ax
add si,di
add si,word[bp] ;columns
;sub si,320*55+49;base

mov ax,word[bp+12]       ;color management
;add al,127
add al,cl                ;give it bump'ishness
sub al,bh                ;give it bump'ishness
;cmp word[bp+100],0ffffh/2 ;helper wastes bytes but
                          ;reusing angles takes way too long time
                          ;since only -1/frame
cmp byte[bp+3],07fh ;ffffh/2 = 7fffh so save 1b
ja differ
;add si,128      ;change base a bit and also use the carry flag to adjust
                ;because add 128 takes 1 byte more
                ;but there is a jump right of 1 pixel to the left right before
                ;switching to the 2nd part
;sub si,127
mov ax,word[bp+40] ;make some variations; +40 chosen because of behaviour at start
sub si,ax          ;spicing it up a little bit with movement on 1 scene

or al,byte[bp]          ;change the pattern based on global color value from above
differ:
mov byte[ds:si+bx-320*55-33],al           ;one cell (original 320*70-33 when +10 at pal
                                          ;          for dosbox compatibility)
mov byte[ds:si+bx+320*32+16-320*55-33],al ;below right of that cell is another one
sub bx,321
jnz shape
sub di,320
jnz shape2
loop shape3
;inc word[bp+10] ;global counter adds 2x6 each frame
                ;saved 1 b compared to add word[bp+10],32+8
                ;not used so speed things up

dec dx
jnz shape4
sub word[bp],32
jnc shape5 ;do all columns



mov di,80 ;number of rays*2

rays:
;imul dx,di,2

mov word[bp],di;dx ;x
fild word[bp+di];degrees (was bp+di+10 but save 1b)
fidiv word[cs:103];fine enough instead of 57/2
fsin
fimul word[bp]
fistp word[bp]

mov si,320+140+32+32 ;adjust rays to avoid missing ones because of
                  ;sin (underflow at 0 ---> jnc breaks without
                  ;showing the ray
add si,word[bp]   ;add sin

line:
shld bx,di,16+1;2   ;thickness
line2:
sbb byte[ds:si+bx],2

dec bx
jnz line2
add si,318
jnc line

dec word[bp+di] ;change angle for every ray
                ;(was bp+di+10 but save 1b)


inc word[bp+2] ;increases by 40 every frame
               ;so same change as code above vsync but saving 1b here
dec di
dec di
jnz rays           ;do all rays (except ray #0)


;add a brighter area in the middle to create/fake 2 more bars
;mov bx,1900h*4 ;6400h
mov bh,64h;+19h ;6400h
;mov bh,64h+19h+19h+1 ;v2
bars2:
;sub word[ds:bx+320*48-1],0305h
sub word[ds:bx+320*59-1],0306h ;make stripes
                               ;sub byte is not enough. looks like simply
                               ;drawn on top and not like some layer.
                               ;high level nagging.
;sub byte[ds:bx+320*59-1],4 ;byte is fine enough and -1b
                               ;having the stripes on top+bottom (v2)
                               ;was used in my intro "kaneda" and it
                               ;reminds me too much on it so make the
                               ;stripes in the middle

;sub word[ds:bx+320*140-2],0503h ;v2
dec bx
dec bx
jnz bars2

;set a black bar on top of it all
;to give it a little extra shape/depth
;di = bx = 0 here
bars:
mov bl,48+2
bars3:
;mov byte[ds:di+bx+73],cl
mov byte[ds:di+bx-60-32-16],cl
mov al,byte[ds:di+bx-8-22] ;put weight a bit more on the left side
mov byte[ds:di+bx-22],al   ;to make it look a bit better even if +1b
nop                        ;sneaky nop is sneaky :3
dec bx
jnz bars3
add di,321;319;321
jnc bars

;add word[bp+10],32+8 ;change the global counter for switching
                      ;between the 2 scenes
                      ;changed at rays to save 1b

mov dx, 3dah                 ;wait for vsync for constant speed
;vsync1:                     ;to make things smoother
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;cx = 0 here
mov di,320*30
;mov cx,320*136/2; =5500h
mov ch,55h*2
flip:
mov al,byte[bp+12]  ;grab basic color
;mov ah,al           ;make it equal
;inc ax              ;make stripes
;inc ax              ;make stripes
xchg al,byte[ds:di] ;grab vscreen
stosb               ;drop + inc di
;cmp di,320*168;cx;0
;jne flip
loop flip

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;nothing so go on
breaker: ret