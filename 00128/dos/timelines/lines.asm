;timelines
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: phonat - never

;you have to hit ESC like nuts while hoping that
;it will exit. if not - the intro stops at the end
;so no need to get crazy :)

;this prod is the result of a concept including
;some decisions and resulting changes.

;i wanted to tell something like a story. to cut it
;short: in the end i wanted to do something very
;minimalistic but understandable. so i hope i reached
;that goal ;)

;the first version of this concept included something
;like buildings to show the influence on the planet.
;but the more i worked on it the more it felt like
;those buildings are destroying the flow. so i tried
;to work completely with staight lines. because of
;this i could cut off a lot of bytes. so i made the
;almost not existing visuals even more simple and got
;it down to 128b.

;#######################################################################

;this is the place for the very important
;fucking mad props for inspiration + influence:

;skrju & triebkraft - a true story from the life of a lonely cell (2o1o)
;fsqrt - paleozoa (2o12)
;Gem / Nagz / Rufus - pure 1d demo (2oo5)
;rustbloom - scanline (2o11)

;#######################################################################


org 100h
use16

start:   push 0a000h ;vga
         pop es
         mov al,13h
         int 10h

xor si,si
main:

mov bx,320 ;draw a line from right to left

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
mov al,byte[dta00+si+1] ;get color
mov byte[es:di+bx-1],al ;adjust pos and draw
dec bx                  ;move
jnz scriptie

inc si
inc si                ;next set of data

cmp si,2*30             ;got last set of data?
ja stoppie              ;yes so exit


         in al,60h            ;read keyboard buffer
         cmp al,1             ;ESC?
         jne main             ;no, so go on

stoppie: mov ax,03h           ;keep it clean :)
         int 10h
         ret

              ;pos   ;color;
dta00 db      81,    30      ;upper bar
dta01 db      114,   30      ;lower bar

dta02 db      94,    78      ;sky
dta03 db      95,    78      ;sky ;becomes clouds
dta04 db      96,    78      ;sky
dta05 db      97,    78      ;sky
dta06 db      98,    54      ;water ;becomes land
dta07 db      99,    54      ;water

dta08 db      95,    15      ;clouds
dta09 db      98,    2      ;plants + animals

dta10 db      98,    48      ;humans

dta11 db      95,    30      ;darker clouds

dta12 db      98,    70      ;humans step 2 killing plants + animals

dta13 db      99,    28      ;dirty water

dta14 db      98,    25      ;humans step 3 killing more plants + animals


dta15 db      95,    28      ;dark clouds

dta16 db      94,    27      ;dirty sky
dta17 db      96,    27      ;dirty sky hiding humans
dta18 db      97,    27      ;dirty sky hiding humans
dta19 db      98,    27      ;dirty sky hiding humans
dta20 db      95,    27      ;dirty sky hiding clouds
dta21 db      99,    27      ;dirty sky hiding water

dta22 db      94,    0       ;outro
dta23 db      95,    0       ;outro
dta24 db      96,    0       ;outro
dta25 db      97,    0       ;outro
dta26 db      98,    0       ;outro
dta27 db      99,    0       ;outro

dta28 db      114,   0       ;delete lower bar
dta29 db      81,    0       ;delete upper bar

dta30 db      100,   0       ;make delay to
                             ;think about the intro
                             ;before exit