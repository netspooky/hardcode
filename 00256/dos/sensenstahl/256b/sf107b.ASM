;starfield 111b
;code: www.sensenstahl.com
;written for the A86

;history:
;113b 10.sep 09
;112b 10.sep 09
;111b 10.nov 09
;107b 11.nov 09

data segment
;-------- data ------------
position dw 255 dup ? ;256 stars
speed db 255 dup ?    ;speed for every star
;--------------------------

code segment
org 100h

push 0a000h    ;segment vga ;start+5 = 00h @ code to get initialization value for blue
pop es

;----- set 13h 320x200x256 vga ----
mov al,13h
int 10h

;setup stars
mov di,512 ; ;-)
setup:
in al,40h ;grab some value
add ax,dx
mul ax
mov byte [position+di],al ;save position
dec di
jnz setup

mov di,255 ;set a speed value for every star
mov dl,1
setup2:
mov byte [speed+di],dl
inc dl
cmp dl,6
jb label1
mov dl,1
label1:
dec di
jnz setup2


main:
mov cl,255 ;was mov cx,255 saved 1 byte
xor bx,bx
draw:
mov di,cx
mov bl,byte [offset speed+di] ;grab speed
shl di,1 ;mul 2
mov ax,word [offset position+di] ;grab position ---> ax
xchg di,ax ;set pos in memory
mov byte es:[di],00h ;erase old star
sub di,bx ;move!
add bl,26 ;correct classic color (=
mov byte es:[di],bl ;draw new star
xchg di,ax ;restore
mov word [offset position+di],ax ;save new position <--- ax

dec cx
jnz draw

;wait for vsync (looks better =)
mov dx, 3dah ;port on vga to check retrace
vsync1:
in al,dx    ;get byte
test al,8   ;test bit 8 (and); bit 1 for horizontal retrace
jnz vsync1      ;1 = in retrace; loop until 0
vsync2:
in al,dx
test al,8
jz vsync2       ;0 = not in retrace; loop until 1

mov ah,01h     ;00 readkey; 01 keypressed
int 16h        ;bios int
jz main        ;nix, also weiter / zeroflag = 1

mov ax, 0003h
int 10h ; set 03h = textmode 80x25

ret