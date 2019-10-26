;[really] meh
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: rummelsnuff - seemann

;this hilarious thing ranked 7th out of 7 at the [living room] bremen demo scene party III
;held on 15th December 2012. contributed as remote entry to spread eye cancer :D

org 100h
use16

start:   push 0a000h
         pop es
         ;les bp,[bx] ;not needed ^_^
         mov al,13h
         int 10h

main:
shrd si,di,cl
shr byte[es:si],cl

add cl,byte[es:si]
mov si,cx ;di
inc byte[es:si]

inc cx
xchg di,cx

neg si
inc byte[es:si]


jmp main ; 30b
;         in al,60h            ;read keyboard buffer
;         cmp al,1             ;ESC?
;         jne main             ;no, so go on

;         mov ax,03h           ;keep it clean :)
;         int 10h
;Dddd         ret