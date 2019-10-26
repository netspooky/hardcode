;Worm v0.1 by Quark(particle)      1/26/97
.model tiny
.data
red     db      'Red Wins!','$'      ;hehehe
blue    db      'Blue Wins!','$'
keys    db      '8e6f2c4s7w9r3v1x'        ;players keys defines
addval  dw      -320,1,320,-1,-321,-319,321,319     ;movement 
pinc    dw      -320,-320         ;initial motion is up ^
.code
.startup
        mov     di,32214       ;initial player offsets.
        mov     si,32107
        mov     ax,0A000h      ;set es pointing to start of video mem
        mov     es,ax
        mov     ax,0013h       ;set video mode; mode 13h
        int     10h
Again:  mov     ah,01h
        int     16h             ;find out if there is a key pressed...
        jz      nokey
        xor     ah,ah           ;if a key is pressed, what is it?
        int     16h             
        cmp     al,'q'          ;check for 'q', (exit condition)
        jnz     NoQ
        mov     ax,0003h    ;set DOS video mode,and ...
        int     10h
        int     20h         ;exit
NoQ:    xor     bx,bx
        xor     bp,bp
AgainP: cmp     al,byte ptr ds:[keys+bp]
        jnz     short Nopkey
        push    bp
        shr     bp,1   ;has the effect of evening out the number
        shl     bp,1     
        mov     dx,word ptr ds:[addval+bp]    ;number
        mov     word ptr [pinc+bx],dx
        pop     bp
Nopkey: xor     bx,2          ;flip
        inc     bp
        cmp     bp,10h
        jl      AgainP
nokey:  add     di,pinc
        cmp     byte ptr es:[di],0           ;check for hit
        jz      NoRWin
        mov     dx,offset blue
        jmp     short EndG
NoRWin: mov     byte ptr es:[di],4           ;draw red worm
        add     si,word ptr [pinc+2]
        cmp     byte ptr es:[si],0            ;check for hit
        jz      NoBWin
        mov     dx,offset red
        jmp     short EndG
NoBWin: mov     byte ptr es:[si],1          ;draw blue worm
        xor     cx,cx
        mov     dx,0F000h       ;number of microseconds to delay
        mov     ah,86h          ;bios function
        int     15h             ;call bios
        jmp     short Again
EndG:   mov     ax,0003h          ;restore DOS video mode
        int     10h
        mov     ah,09h             ;print winner info (Blue or Red?)
        int     21h
        int     20h               ;exit
end


