;scrollingham palace fat version
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;fast made version with big letters

org 100h
use16

maxement equ 40 ;max number of letters

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h

         mov ah,09h      ;print string to vga
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

         push 09000h     ;vscreen
         pop ds

;assuming: bx = 0 ch = 0 cl = 255

cls:
cmp byte[es:bx],ch
je noblacken
mov byte[es:bx],cl ;blacken letters so no one sees them :>
noblacken:
inc bx
jnz cls

;letters 8 pixels high, 7 pixels wide + 1 pixel space in between = 8x8

main:
;xor cx,cx ;cx = number(s) of letter(s)
mov cx,maxement;xor cx,cx
grabbement1:
xor bx,bx ;height
grabbement3:
xor dx,dx ;width
grabbement2:
;shld si,cx,16+3 ;1b bigger than following imul
imul si,cx,8    ;basic index on the screen
                ;based on number of letter
imul di,bx,320  ;row on screen
add di,dx       ;add column on screen
add di,si       ;add basic index on screen
cmp byte[es:di],ch;16 ;normal 7 under xp, 15 under dosbox
je skip
;mov byte[es:di],10

xor ax,ax ;z
deep:
;fninit ;what?
mov word[bp],ax ;z
;sub word[bp],3 ;center
fild word[bp]
mov word[bp],bx
;sub word[bp],4 ;center
fild word[bp]
mov word[bp],dx
;sub word[bp],4 ;center
fild word[bp]

call rotate  ;y axis in x y z out y' x z'
call rotate  ;x axis in y' x z' out x' y' z''
;fxch st2     ;z'' y' x'
;call rotate  ;z axis in z'' y' x' out y'' z'' x''

;following values grabbed in order of rotating behaviour
fistp word[bp+16]  ;grab new value y from fpu stack
fistp word[bp+12]  ;grab new value z from fpu stack
fistp word[bp+14]  ;grab new value x from fpu stack

;calculate pos on screen
imul di,word[bp+12],320*1
add di,word[bp+16] ;x
add di,si ;base
sub di,word[bp+2] ;scroll

mov ch,al;byte[bp+14] ;color management
add ch,16+6        ;gray scale bitch
;cmp ch,16
;jb nextie
;shr ch,1
;cmp byte[ds:di+320*82+16+8],ch
;ja nextie
mov byte[ds:di+320*82+16+8],ch
shl di,1

mov byte[ds:di+320*112+16+8],ch
mov byte[ds:di+320*112+16+9],ch
mov byte[ds:di+320*113+16+8],ch
mov byte[ds:di+320*113+16+9],ch
nextie:
xor ch,ch ;has to be 0 to avoid error
inc ax
cmp al,8 ;saves 1b over ax ... maybe because of the jump (?)
jne deep

skip:

inc dx
cmp dx,8 ;0..7
jne grabbement2 ;width

inc bx
cmp bx,8 ;0..7
jne grabbement3 ;height


again:
in al,40h
;add ax,cx
aas
shr ax,15 ;0..1
inc ax
;jz again
adc word[bp+20+si],ax ;rotation for every letter

dec cx
jnz grabbement1

;scroll?
inc word[bp+2]
cmp word[bp+2],320+8
jnae nice
mov word[bp+2],bx
nice:

;flip
;di = cx = bx = 0 here
mov di,320*62
;mov cx,320*80 ; =6400h
mov ch,64h
flip:
mov al,09h
xchg al,byte[ds:di] ;grab vscreen
stosb              ;drop + inc di
loop flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
;         ret                  ;use the ret at rotate

rotate:
;                     0              1             2             3             4         5         6         7
;                     x              y             z
fild word[bp+20+si]     ;g              x             y             z
fidiv word[cs:103]   ;fine enough instead of 57/2
fsincos              ;cos           sin            x             y             z
fmul st0,st3         ;cos*y         sin            x             y             z
fxch st1             ;sin         cos*y            x             y             z
fmul st0,st4         ;sin*z       cos*y            x             y             z
fsubp st1,st0        ;cos*y-sin*z    x             y             z
                     ; y'            x             y             z
fild word[bp+20+si]     ;g              y'            x             y             z
fidiv word[cs:103]
fsincos              ;cos           sin            y'            x             y         z
fmulp st5,st0        ;sin            y'            x             y           cos*z
fmulp st3,st0        ;y'             x           sin*y         cos*z
fxch st2             ;sin*y          x             y'          cos*z
faddp st3,st0        ;x              y'         sin*y+cos*z
                     ;x              y'            z'
fxch st1             ;y'             x             z'
ret

;for_rad dw 57/2    ;pi*grad/180 = grad/57 (180/3.14... = 57,...)
                   ;byte + additional byte at doubleword below works fine

;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
text db ' HI 2 ALL SIZEC',2,'DERS$' ;empty space at beginning to avoid broken H
                                    ;saves 3 bytes above at grabbement via cx