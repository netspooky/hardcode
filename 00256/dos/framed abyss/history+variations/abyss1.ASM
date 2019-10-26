;for fasm
;code: sensenstahl
;www.sensenstahl.com

org 100h
use16

start:   push 09000h
         pop fs
         push 0B800h
         pop es

         mov ax,1112h  ; Set up 80x50 text mode
         xor bl,bl
         int 10h

         mov ax,1003h  ;disable blink (128) ---> full 16 bg colors (instead of 7)
         int 10h

main:    mov di,160
lines:   in al,40h ;80x per frame
         xor al,ah
         mov [fs:di+51*160], al
         dec di
         dec di
         jnz lines

         ;xor di,di
f_loop:  mov al,[fs:di]
         adc al,[fs:di+2]
         adc ah,0
         adc al,[fs:di+160]
         adc ah,0
         adc al,[fs:di-2]
         adc ah,0
         shr ax,2          ;div 4
         cmp ax,3 ;must be same value as-----------------|
         jna f01                                        ;|
                                                        ;|
         sub al,3 ;change for higher/lower flames  <-----|
f01:     mov [fs:di-160],al;draw new pixel above the current one
         inc di
         inc di
         cmp di,160*52
         jb  f_loop
         ;no more fire

         ;wait for vsync because of speed
         mov dx, 3dah  ;port on vga to check retrace
         vsync1:
         in al,dx
         test al,8
         jz vsync1     ;0 = not in retrace; loop until 1

         ;--- get some + shaderwork-------
         xor di,di
         flip:
         mov al,byte [fs:di] ;grab byte from vscreen (0 - 255)

         ;shader 17*14=255 --> :)
         mov bl,15
         div bl ;-->ah=rest of division
         xor ah,ah
         mov si,ax
         shl si,1 ;mul 2 to get right shadervalues
         mov al,byte [shader17+si]    ;chr
         mov bl,byte [shader17+si+1]  ;col+bg
         ;add bl,7*16 ;play around :)
         ;/shader

         mov byte [es:di],al
         mov [es:di+1],bl
         inc di
         inc di
         cmp di,160*50
         jna flip
         ;-----------------------------------------------------------

         mov ah,01h            ;read keyboard
         int 16h               ;read, dammit!
         jz main                ;nothing so go on

         mov ax,03h             ;keep it clean
         int 10h
         ret

;shadevalue   =   co+bg*16
;            chr  co bg
shader17 db 219,00+00*16 ;{black}
shader16 db 176,04+00*16
shader15 db 177,04+00*16
shader14 db 178,04+00*16
shader13 db 219,04+04*16 ;{dark red}
shader12 db 176,12+04*16
shader11 db 177,12+04*16
shader10 db 178,12+04*16
shader09 db 219,12+12*16 ;{bright red}
shader08 db 176,14+12*16
shader07 db 177,14+12*16
shader06 db 178,14+12*16
shader05 db 219,14+14*16 ;{yellow}
shader04 db 176,15+14*16
shader03 db 177,15+14*16
shader02 db 178,15+14*16
shader01 db 219,15+14*16 ;{white}