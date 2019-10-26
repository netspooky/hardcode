;timelapse
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: source direct - stars

;after some changes this intro became "timelines"

org 100h
use16

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h

xor si,si
main:

mov bx,320
scriptie:

mov dx, 3dah ;wait for vsync for constant speed
vsync1:
in al,dx
test al,8
jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

xor ax,ax               ;delete ah for correct calc
mov al,byte[dta00+si]   ;get pos
imul di,ax,320
mov al,byte[dta00+si+2] ;adjust pos
sub di,ax
mov al,byte[dta00+si+1] ;get color
mov byte[es:di+bx],al
mov al,byte[dta00+si+3] ;get steps
sub bx,ax               ;move
jnz scriptie

add si,4                ;next set of data

cmp si,4*41             ;got last data?
ja stoppie              ;yes so exit

         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

stoppie:
         mov ax,03h           ;keep it clean :)
         int 10h
         ret

              ;pos   ;color;  ;adjust;steps
dta00 db      80,    30,      1,     1 ;upper bar
dta01 db      114,   30,      1,     1 ;lower bar

dta02 db      93,    78,      1,     1 ;sky
dta03 db      94,    78,      1,     1 ;sky
dta04 db      95,    78,      1,     1 ;sky
dta05 db      96,    78,      1,     1 ;sky
dta06 db      97,    78,      1,     1 ;sky
dta07 db      98,    54,      1,     1 ;water
dta08 db      99,    54,      1,     1 ;water
dta09 db      100,   54,      1,     1 ;water

dta10 db      94,    15,      1,     1 ;clouds
dta11 db      98,    71,      1,     1 ;plants + animals

dta12 db      98,    25,      2,     4 ;humans
dta13 db      98,    25,      3,     4 ;humans
dta14 db      97,    25,      2,     4 ;humans
dta15 db      96,    25,      2,     4 ;humans

dta16 db      94,    30,      1,     1 ;darker clouds

dta17 db      98,    25,      4,     4 ;humans step 2 killing plants + animals

dta18 db      97,    25,      3,     4 ;humans step 3 building more

dta19 db      99,    28,      1,     1 ;dirty water
dta20 db      100,   28,      1,     1 ;dirty water

dta21 db      98,    25,      1,     2 ;humans step 3 killing more plants + animals


dta22 db      94,    28,      1,     1 ;dark clouds

dta23 db      93,    27,      1,     1 ;dirty sky
dta24 db      95,    27,      1,     1 ;dirty sky
dta25 db      96,    27,      1,     1 ;dirty sky hiding humans
dta26 db      97,    27,      1,     1 ;dirty sky hiding humans
dta27 db      98,    27,      1,     1 ;dirty sky hiding humans
dta28 db      94,    27,      1,     1 ;dirty sky hiding clouds
dta29 db      99,    27,      1,     1 ;dirty sky hiding water
dta30 db      100,   27,      1,     1 ;dirty sky hiding water

dta31 db      93,    0,       1,     1 ;outro
dta32 db      94,    0,       1,     1 ;outro
dta33 db      95,    0,       1,     1 ;outro
dta34 db      96,    0,       1,     1 ;outro
dta35 db      97,    0,       1,     1 ;outro
dta36 db      98,    0,       1,     1 ;outro
dta37 db      99,    0,       1,     1 ;outro
dta38 db      100,   0,       1,     1 ;outro

dta39 db      114,   0,       1,     1 ;delete lower bar
dta40 db      80,    0,       1,     1 ;delete upper bar

dta41 db      100,   0,       1,     2 ;make delay to
                                       ;think about the intro
                                       ;before exit