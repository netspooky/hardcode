;into the wild // crashing rainbow
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: nahko & medicine for the people - make a change

org 100h
use16

start:   push 09000h
         pop ds
         push 0a000h
         pop es
         mov al,13h
         int 10h

finit ;play the savety card

;mov word[bp+8],270 ;can be skipped because it is 270 after 1st frame
main:
;cl = 0
mov ch,53
mov ah,byte[bp+10] ;rainbow color

;bar top + bottom
mov bx,320*35-1
bars:
mov byte[ds:bx],cl
dec bx
cmp bx,320*164-1
jne bars

mov word[bp+2],57
mov al,ah;byte[bp+10]
path:
mov bx,word[bp]
fild word[bp] ;degree
fidiv word[bp+2]
fsin
fimul word[bp+2]
fistp word[bp+4]

imul di,word[bp+4],320 ;y
mov si,di
sub di,bx              ;x


add di,320*153+47+1
draw2:
mov bx,word[bp+8]
shr bx,3 ;fatness of the rainbow
draw:
;inc dl
;cmp dl,88
;jna nicer
;mov dl,59
;nicer:
cmp word[bp],211
ja fine
cmp bx,27
jb fine
cmp byte[ds:bx+di],ch
je skipz
fine:
mov byte[ds:bx+di],al


skipz:
dec bx
jnz draw

inc ah      ;create rainbow colors (kinda)
mov al,ah
sar al,4
add al,74

inc word[bp+8]
inc word[bp]
cmp word[bp],370
jnae path
mov word[bp+8],250 ;size
mov word[bp],120   ;start degree of rainbaw
okay:

inc byte[bp+10] ;color change


;jmp skipz2
mov bx,200*320
weiter:
mov di,20
weiter2:
mov byte[ds:di+bx+68],cl
cmp byte[ds:di+bx+163],ch ;don't draw on rainbow ;+180
jne neyney
mov byte[ds:di+bx+163],cl
cmp byte[ds:di+bx+183-320*41],cl
je neyney
mov byte[ds:di+bx+183-320*41],ch
neyney:
dec di
jnz weiter2
sub bx,320
jnz weiter

skipz2:
inc cx;;ch = 53; cl = 0;mov cl,1
mov di,100
nextor:
mov bx,di
shr bx,5
inc bx
imul ax,bx,321
nextor2:
sbb word[bp+di],ax
jnc okok
in al,40h
;xor ah,ah
jmp nextor2
okok:
mov si,word[bp+di]
mov dx,0f0fh

cmp cl,1
jne okokok
mov dx,04242h
cmp word[ds:si],3535h;53
jne nopey
okokok:
mov word[ds:si],dx
mov word[ds:si+320],dx
nopey:
neg cl ;change star in fore/background
dec di
dec di
cmp di,20 ;don't kill rainbow values
ja nextor

;slow it down
mov dx, 3dah
;vsync1:     ;not needed for this one
;in al,dx
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;xor di,di ;who gives a fuck?
xor cx,cx
flip:
mov al,53
xchg al,byte[ds:di]  ;drop to screen
stosb;mov byte[es:di],al  ;drop to screen
loop flip

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on
breaker:
         mov ax,03h            ;keep it clean :)
         int 10h
         ret