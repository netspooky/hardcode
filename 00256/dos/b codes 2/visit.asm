;7e1 // revision 2017 invitro (old version)
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening:

;shameless reuse of my intro "kaneda"

;dosbox: core=dynamic cycles=max
;runs nice on my old xp and a lot faster on
;the faster machine (freedos, vmware with xp).
;in the end: if it is a slide show your
; machine is slow as the code :D

;assuming: cx = 255 bx = ax = 0
org 100h
use16

maxie equ 140


start:   push 0a000h ;vga
         pop es
         push 08000h ;vsceen
         pop gs
         push 07000h ;copied text
         pop fs
         mov al,13h
         int 10h

         mov ah,09h      ;print string
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;so change afterwards

;grab printed text and save it
;only text is visible, rest of memory is 0
copy:
mov al,byte[es:bx] ;get
mov byte[fs:bx],al ;save
inc bx
jnz copy

        mov dx,0x3C9
;        inc cx

pal:    shrd ax,cx,18
        out dx,al ;r
        out dx,al ;g
        mov al,63
        out dx,al ;b

        mov si,cx           ;cheat a bit
        mov byte[s_z+si],cl ;to avoid having crashing values for x and y
                            ;cl never 0 here
        loop pal

main:

mov si,maxie  ;number of visible elements/2

malen:
dec byte[s_z+si]      ;move towards viewer

jnz okee                      ;not reached farest point

sternz:;-------create z-values--------
mov word[s_z+si],200;leave order
sternx:;-------create x-values--------
in al,40h
xor ah,ah ;ah = ? here
sub ax,127
mov word[s_x+si],ax ;save
sterny:;-------create y-values--------
in al,40h
xor ah,ah
sub ax,127
mov word[s_y+si],ax ;save

okee:

mov cx,word[s_z+si]
mov ax,100;word viewx ;nx:=(viewx*x div (z+cnz)) + cnx;
imul word[s_x+si]

idiv cx
add ax,120 ;center
mov bx,ax ;save calculated 2d value

mov ax,70;word viewy ;ny:=(viewy*y div (z+cnz)) + cny;
imul word[s_y+si]

idiv cx
add ax,99 ;center
mov dx,ax ;save calculated 2d value

;set 2d pixel at x,y
imul di,dx,321 ;321 instead of 320 makes bright crack
add di,bx

cmp bx,319  ;no error on display!
ja nix      ;includes < 0
cmp dx,199
ja nix

inc byte[gs:di] ;well well

nix:

dec si
dec si
jnz malen

;create ze chaos
;this also slows things down since it processes cl*0ffffh bytes
mov cl,80 ;ch = 0
boom1:
;xor di,di
boom:
inc ax         ;very very sensible
dec dh         ;configuration
mul dx         ;of doom
shr al,6       ;6=256/64 = 4
movzx bx,al
shl bx,1      ;word
mov bx,word[ways+bx]
;mov al,byte[gs:di] ;changing al for effect
;cmp al,ch ;get original pixel
cmp byte[gs:di],ch ;changing ah needed for effect
je nopey
inc byte[gs:bx+di]
xchg ah,dl ;gives nice glitchie
nopey:
dec di
jnz boom ;whole screen
loop boom1

;make bars
mov bx,320*15-1
bar:
;add byte[gs:bx+320*122-33],10
adc byte[gs:bx+320*140],40 ;middle
mov byte[gs:bx],cl         ;top bottom
dec bx
cmp bx,320*183-1
jne bar

;si = di = 0 here
;dec cx ;speed up by killing dec/inc si/checks
flip:
xor ax,ax
add al,byte[fs:di]
jz noe                        ;no font pixel found
mov byte[gs:di+54+320*114],bl ;copy text to pos
noe:
xchg al,byte[gs:di]  ;drop to screen
stosb;mov byte[es:di],al  ;drop to screen
     ;changes di
dec si
jnz flip

         in al,60h ;read keyboard
         dec ax    ;check it, dammit!
                   ;ah = 0 here (in most cases, so save 1b)
         jnz main               ;nothing so go on
breaker:
;         mov ax,03h            ;keep it clean :)
;         int 10h
         ret


;data segment
ways dw 1,-1,320,-320
;text db 31,'i5',179,194,' R',240,'v!s',173,254,0efh,' ',253,002,'17$'
text db 221,'visit REVISION 7e1$' ;2017 = 7E1h

;-------- data ------------
s_x dw 2048 dup ? ;x
s_y dw 2048 dup ? ;y
s_z dw 2048 dup ? ;z