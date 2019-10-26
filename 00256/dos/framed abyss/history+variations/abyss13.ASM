;for fasm
;framed abyss
;code: sensenstahl
;www.sensenstahl.com

;assuming: di = bl = 0

org 100h
use16

start:   push 09000h
         pop fs
         push 08000h
         pop es

         mov ax,1112h  ; Set up 80x50 text mode
         ;xor bl,bl
         int 10h

;only enable when shader <> deep ocean (II)
;check shader-routine for correct division
;         mov ax,1003h  ;disable blink (128) ---> full 16 bg colors (=
;         int 10h

main:    ;xor di,di
f_loop:  mov al,[fs:di]
         adc al,[fs:di+160+2]
         adc ah,0
         adc al,[fs:di+160+160+4]
         adc ah,0
         adc al,[fs:di-160-2] ;uh, please grab the not-so-random-line
         adc ah,0
         shr ax,2
         cmp ax,9 ;must be same value as-----------------|
         jnae f01                                       ;|
                                                        ;|
         sub al,9 ;change for higher/lower flames  <-----|
f01:     cmp di,160*51 ;reached bottom? BOTTOMLINE AT 51 so outside of screen!
         jnae noline   ;nope
         in al,40h     ;reached, so new char
         noline:
         mov [fs:di-160],al ;draw new pixel above the current one
         inc di
         inc di
         cmp di,160*52 ;bottomline + 1 --> so bottomline can be drawn completely!
         jnae  f_loop
         ;no more fire

         ;not useful here, so saving some bytes
         ;wait for vsync because of speed
         ;mov dx, 3dah  ;port on vga to check retrace
         ;vsync1:
         ;in al,dx
         ;test al,8
         ;jz vsync1     ;0 = not in retrace; loop until 1

         ;--- get some + shaderwork-------
         mov di,160*25 ;only copy 1/2 of screen
         ;shr di,1 ;who cares, so 160*52/2
         flip:
         mov al,byte [fs:di+160*25] ;grab correct byte from bottom of vscreen (line 50)
         ;mov bh,al ;-----> to see chars not blocks ;)
         ;<shader> 25*10=250 --> :) [deep ocean ---> 21 (21*12=252)]
         mov bl,21
         div bl    ;-->ah=rest of division
         xor ah,ah
         mov si,ax
         shl si,1 ;mul 2 to get right shadervalues
         mov cx,word [shader_c17+si] ;chr + col+bg
         ;</shader>
         mov word [es:di+160*25-2],cx
         ;mov cl,bh ;-----> to see chars not blocks ;)
         neg di  ;)
         mov word [es:di+160*25],cx ;right pos to get a 1:1 mirrored copy
         neg di
         dec di
         dec di
         jnz flip

         ;left and right
         ;xor di,di ;di = 0 here
         ;xor si,si ;si should be 0 here anytime because it's on top of flame
         xor bx,bx
         testing:
         mov cx,word [es:si] ;grab word
         cmp bl, 25
         ja funk_you ;if above y = 25 then always draw something!
         cmp byte [es:di+1],0 ;emptyness to draw anything into?
         jne nein             ;nope, so don't draw anything
         funk_you:
         cmp ch,0 ;is col+bg of grabbed char = 0 ?
         je nein  ;it is ---> don't draw emptyness!
         mov word [es:di],cx ;draw on left side
         neg di                         ;running out of si and di again
         mov word [es:di+2*160*25-2],cx ;mirror on the right side
         neg di
         nein:
         add di,160 ;line down
         inc bl
         inc si
         inc si
         cmp bl,51    ;bottom?
         jnae testing ;y=51 ---> gtfo
         sub di,160*51
         inc di
         inc di
         sub si,51*2
         add si,160
         xor bl,bl
         inc bh
         cmp bh,25
         jne testing

         ;flip to screen
         push 0B800h
         pop fs
         xor di,di
         flip2:
         mov al,[es:di]
         mov [fs:di],al
         inc di
         jnz flip2
         push 09000h
         pop fs

         ;make it move
         mov di,160*53
         flip3:
         mov al,byte [fs:di]
         xchg byte [fs:di-2],al
         mov byte [fs:di],al
         dec di
         jnz flip3

         ;-----------------------------------------------------------

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main               ;nothing so go on

         mov ax,03h            ;keep it clean :)
         int 10h
         ret

;shadevalue   =   co+bg*16
;           chr co bg
;deep ocean
shader_c17 db 032,00+00*16
shader_c16 db 176,02+00*16
shader_c15 db 177,02+00*16
shader_c14 db 178,02+00*16
shader_c12 db 176,03+02*16
shader_c11 db 177,03+02*16
shader_c10 db 178,03+02*16
shader_c08 db 176,02+03*16
shader_c07 db 177,02+03*16
shader_c06 db 178,02+03*16
shader_c05 db 176,10+03*16 ;these 2 and the next 2 bytes are used in theory
shader_c04 db 177,10+03*16

;blue.ish
;shader_a17 db 032,00+00*16
;shader_a16 db 176,01+00*16
;shader_a15 db 177,01+00*16
;shader_a14 db 178,01+00*16
;shader_a12 db 176,09+01*16
;shader_a11 db 177,09+01*16
;shader_a10 db 178,09+01*16
;shader_a08 db 176,11+09*16
;shader_a07 db 177,11+09*16
;shader_a06 db 178,11+09*16

;meadow
;shader_b17 db 032,00+00*16
;shader_b16 db 176,02+00*16
;shader_b15 db 177,02+00*16
;shader_b14 db 178,02+00*16
;shader_b12 db 176,10+02*16
;shader_b11 db 177,10+02*16
;shader_b10 db 178,10+02*16
;shader_b08 db 176,12+10*16
;shader_b07 db 177,12+10*16
;shader_b06 db 178,12+10*16

;guess what?
;shader_d17 db 032,00+00*16
;shader_d16 db 176,04+00*16
;shader_d15 db 177,04+00*16
;shader_d14 db 178,04+00*16
;shader_d12 db 176,12+04*16
;shader_d11 db 177,12+04*16
;shader_d10 db 178,12+04*16
;shader_d08 db 176,14+12*16
;shader_d07 db 177,14+12*16
;shader_d06 db 178,14+12*16

;deep ocean II
;shader_e17 db 032,00+00*16
;shader_e16 db 176,03+00*16
;shader_e15 db 177,03+00*16
;shader_e14 db 178,03+00*16
;shader_e12 db 176,01+03*16
;shader_e11 db 177,01+03*16
;shader_e10 db 178,01+03*16
;shader_e08 db 176,02+01*16
;shader_e07 db 177,02+01*16
;shader_e06 db 178,02+01*16
;shader_e05 db 176,10+02*16
;shader_e04 db 177,10+02*16



;test
;shader_f17 db 032,00+00*16
;shader_f16 db 176,09+00*16
;shader_f15 db 177,09+00*16
;shader_f14 db 178,09+00*16
;shader_f12 db 176,07+01*16
;shader_f11 db 177,07+01*16
;shader_f10 db 178,07+01*16
;shader_f08 db 176,14+03*16
;shader_f07 db 177,14+03*16
;shader_f06 db 178,14+03*16
;shader_f05 db 176,15+01*16
;shader_f04 db 177,15+01*16

;test 2
;shader_g17 db 032,00+00*16
;shader_g16 db 176,09+00*16
;shader_g15 db 177,09+00*16
;shader_g14 db 178,09+00*16
;shader_g12 db 176,10+01*16
;shader_g11 db 177,10+01*16
;shader_g10 db 178,10+01*16
;shader_g08 db 176,12+03*16
;shader_g07 db 177,12+03*16
;shader_g06 db 178,12+03*16
;shader_g05 db 177,15+01*16
;shader_g04 db 178,15+01*16