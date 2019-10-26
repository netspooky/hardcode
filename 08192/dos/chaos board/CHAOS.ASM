;Chaos Board intro - source code
;coded by Mrock/Hellcore
;Adlib player (and tracker) - RAD by Reality
;InSourceGreetings goes to all SourceReleasing groups
;
;The Main
;sorry for strange label names and maybe non-English comments
;---------------------------------------
Ideal
P386
;---------------------------------------
;Keya: If Esc is pressed it jumps immediately to the end of program
MACRO           keya
                in      al,60h
                dec     al
                jz      kuniec
ENDM
;--------------------------------------
;VSync: Waiting for vertical retrace (for synchronization)
MACRO           vsync
LOCAL           vs1, vs2
                keya
                mov     dx,3dah
vs1:            in      al,dx
                and     al,8
                jnz     vs1
vs2:            in      al,dx
                and     al,8
                jz      vs2
ENDM
;--------------------------------------
SEGMENT         code    use16
                assume  cs:code
start:
                in     al,21h           ;disable keyboard
                or     al,02h
                out    21h,al

                call    set320x400      ;set 320x400 256 colors, X-mode
                call    makeM4tun       ;make mask for effect
                call    make256_3       ;make pattern
                call    unpackfonts     ;unpack fonts

                mov     ax,seg module   ;player initialization stuff
                mov     es,ax
                call    initplayer
                call    setint

                mov     ax,0a000h
                mov     es,ax
main:
;+++++++++++++++++ 1 ++++++++++++++++++
                mov    di,offset text1          ;text numba 1
                call   write                    ;write it
                mov    [cs:typ],offset type1    ;set effect type
                call   route                    ;call routine
;+++++++++++++++++ 2 ++++++++++++++++++
                mov    di,offset text2          ;text numba 2
                call   write                    ;and so long...
                mov    [cs:typ],offset type2
                call   route
;+++++++++++++++++ 3 ++++++++++++++++++
                mov    di,offset text3
                call   write
                mov    [cs:typ],offset type3
                call   route
;+++++++++++++++++ 4 ++++++++++++++++++
                mov    di,offset text4
                call   write
                mov    [cs:typ],offset type4
                call   route
;++++++++++++++++++++++++++++++++++++++
                jmp  main               ;neverending process

;--code jumps here through macro Keya (in macro Vsync)--
kuniec:
                call    resetint        ;player stuff
                call    endplayer

                mov     ax,3            ;textmode
                int     10h

                in     al,21h           ;enable keyboard
                and    al,0fdh
                out    21h,al

                mov     ax,4c00h        ;what is this doin' ???
                int     21h             ;d'ya know?
;--------------------------------------
PROC            route
                xor     bx,bx           ;fade palette from black
into1:          push    bx
                call    fadepalette
                call    justfun         ;call main effect routine
                vsync                   ;wait for vertical retrace
                pop     bx
                inc     bx              ;increase intensity
                cmp     bx,63           ;63 = normal palette
                jbe     into1
                mov     cx,250          ;wait 250 cycles
ff1:            push    cx
                call    justfun
                vsync
                pop     cx
                loop    ff1
                mov     bx,63           ;fade palette to black
outo1:          push    bx
                call    fadepalette
                call    justfun
                vsync
                pop     bx
                dec     bx              ;decrease intensity
                jnz     outo1
                ret
ENDP
;--------------------------------------
;Message texts are desribed here, only capital letters, 20 cols, 11 rows,
;255=LineDown, 0=EndOfText
text1           db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      'C H A O S  B O A R D',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',0

text2           db      'NICE ROUTINES',255
                db      'NOT TOO FAST',255
                db      '',255
                db      'LOOK AT THE SOURCE',255
                db      '',255
                db      '',255
                db      'AND REMEMBER',255
                db      'H E L L C O R E',255
                db      '   R U L E S',255
                db      '',255
                db      '',0

text3           db      'AZZEMBLA RULEZ',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      ' NICE TUNNEL IS IT',0

text4           db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      '',255
                db      'CODED BY',255
                db      'MROCK/HELLCORE',255
                db      '',255
                db      'ADLIB PLAYER',255
                db      'RAD BY REALITY',0

;--------------------------------------
ofsa            dw      0,80*400        ;starting offsets in video memory
cjk             db      ?
cjm             db      ?
mx              dw      ?
my              dw      ?
mc              db      ?
PROC            justfun

                ;change page
                ror     [dword cs:ofsa],16
                mov     eax,[dword cs:ofsa]
                mov     [cs:voffs],ax   ;visual page (will be set after draw)
                mov     [word cs:propage+3],ax;active page (CHANGING CODE!!!)

                mov     ax,0a000h       ;video memory
                mov     es,ax
                mov     ax,seg buffer   ;mask segment
                mov     fs,ax
                mov     ax,seg buffer2  ;pattern segment
                mov     ds,ax

                dec     [cs:cjk]        ;advance variables
                sub     [cs:cjm],2

                mov     ax,0302h        ;set plane 1 and 2
                mov     dx,3c4h
                out     dx,ax
                mov     si,640          ;offset in mask
                mov     di,80           ;offset on screen
                call    mj

                mov     ax,0c02h        ;set plane 3 and 4
                mov     dx,3c4h
                out     dx,ax
                mov     si,642
                mov     di,80
                call    mj

                call    setvoffs        ;set visual page
                ret
;--------------------------------------
mj:
                mov     dx,[word cs:cjk]
                mov     cx,80           ;80=width of screen
jiji:           push    cx
                mov     bx,[fs:si]      ;get word from mask
                mov     cl,bl           ;save 'depth' for color fading
                ror     ecx,8
                jmp     [cs:typ]        ;calculate shifts in bitmap
powrot:         and     bx,0fffeh       ;crashes without this, when emm386 (?)
                mov     al,[ds:bx]      ;get color from bitmap pattern
                rol     ecx,8
                neg     cl
                mul     cl              ;fade it with 'depth'
                shr     ah,1            ;128 colors only
                add     ah,16           ;first 16 colors are used by fonts
propage:        mov     [es:di+0bacah],ah ;CODE MODIFIES THIS VALUE
                add     si,4            ;next offset in mask
                add     di,1            ;next offset on screen
                pop     cx
                loop    jiji            ;do it for whole line
                add     di,80           ;when finished, skip line down
                cmp     di,80*395       ;end of screen?
                jbe     mj
                ret
ENDP

;ohhh... I will try to desribe how this routines works, but I think I will
;be a bit non understandable...
type1:          mov     cx,bx   ;Let's say that:
                                ;BL and BH contains X and Y in 256x256 bitmap
                                ;DL and DH contains changing variables
                                ;(let's call them CJM and CJK)
                add     bl,dl   ;so this is X+CJM
                xor     bh,bh   ;sine table has only 256 values, so we don't
                                ;need BH stuff
                mov     bl,[cs:sin+bx] ;sin(X+CJM)
                add     bl,ch   ;sin(X+CJM)+Y
                add     bl,dl   ;sin(X+CJM)+Y+CJM
                mov     bl,[cs:sin+bx] ;sin(sin(X+CJM)+Y+CJM)
                shr     bl,2    ;sin(sin(X+CJM)+Y+CJM)/4
                add     bl,cl   ;sin(sin(X+CJM)+Y+CJM)/4+X
                mov     al,bl   ;store this value to AL
                mov     bl,dh   ;CJK
                mov     bl,[cs:sin+bx] ;sin(CJK)
                add     bl,cl   ;sin(CJK)+X
                add     bl,dl   ;sin(CJK)+X+CJM
                mov     bl,[cs:sin+bx] ;sin(sin(CJK)+X+CJM)
                shr     bl,2    ;sin(sin(CJK)+X+CJM)/4
                add     bl,ch   ;sin(sin(CJK)+X+CJM)/4+Y
                mov     bh,bl   ;finally: Y=sin(sin(CJK)+X+CJM)/4+Y
                mov     bl,al   ;and X=sin(sin(X+CJM)+Y+CJM)/4+X
                jmp     powrot  ;so BX contains offset in 256x256 bitmap...
                                ;it is clear I think...

type2:          mov     cx,bx   ;and here are the same manners...
                shr     bx,8
                add     bl,dh
                mov     bl,[cs:sin+bx]
                add     bl,cl
                xchg    cl,bl
                add     bl,dl
                add     ch,[cs:sin+bx]
                mov     bx,cx
                jmp     powrot

type3:          mov     cx,bx
                add     bl,dl
                xor     bh,bh
                mov     bl,[cs:sin+bx]
                shr     bl,2
                add     cl,bl
                sub     cl,dh
                mov     bl,dl
                add     bl,ch
                mov     bl,[cs:sin+bx]
                shr     bl,2
                add     ch,bl
                mov     bx,cx
                jmp     powrot

type4:          mov     cx,bx
                xor     bx,bx
                mov     bl,dh
                add     ch,[cs:sin+bx]
                mov     bx,cx
                jmp     powrot

typ             dw      0    ;points to proper part of code (type1, type2 etc)
;--------------------------------------
voffs           dw      ?
PROC            setvoffs                ;set start offset of the screen
                mov     bx,[word ptr cs:voffs]
                mov     dx,3d4h         ;crt
                mov     al,0ch          ;0ch,0dh - start address
                mov     ah,bh
                out     dx,ax
                inc     al
                mov     ah,bl
                out     dx,ax
                ret
ENDP
;--------------------------------------
PROC            make256_3               ;make bitmap pattern
                mov     ax,seg buffer2
                mov     es,ax

                ;first draw some plasma
                xor     di,di
yrlp:           xor     si,si
xrlp:           mov     bx,si
                xor     bh,bh
                mov     bl,[cs:sin+bx]
                add     bx,di
                xor     bh,bh
                mov     al,[cs:sin+bx]
                mov     bx,di
                xor     bh,bh
                mov     bl,[cs:sin+bx]
                add     bx,si
                xor     bh,bh
                mov     bl,[cs:sin+bx]
                add     bl,al
                mov     al,[cs:sin+bx]
                mov     bx,si
                mov     dx,di
                mov     bh,dl
                mov     [es:bx],al
                inc     si
                cmp     si,255
                jbe     xrlp
                inc     di
                cmp     di,255
                jbe     yrlp

                ;then put randomly 55000 dots on this plasma
                mov     cx,55000
rrr:            call    random
                add     [es:bx],al
                loop    rrr

                ;and finally average each 2x2 squares (5 passes)
                mov     cx,5
smoot:          mov     di,65535
sm234:          mov     al,[es:di]
                mov     bx,ax
                mov     al,[es:di-1]
                add     bx,ax
                mov     al,[es:di-256]
                add     bx,ax
                mov     al,[es:di-257]
                add     bx,ax
                shr     bx,2
                mov     [es:di],bl
                dec     di
                jnz     sm234
                loop    smoot
ret
ENDP
;--------------------------------------
RandSeed        dw      ?
RandSeed2       dw      ?
PROC            random                  ;returns random value
                mov     bx,[cs:randseed2]
                mov     ax,[cs:randseed]
                add     bx,63f7h
                add     ax,0a137h
                rol     ax,2
                mov     [cs:randseed],ax
                add     bx,ax
                ror     bx,1
                mov     [cs:randseed2],bx
                add     ax,bx
                ret
ENDP
;---------------------------------------
PROC            FadePalette             ;sets palette intensity by BL
                mov     si,offset pal
                mov     cx,(128+16)*3
                mov     dx,03C8h
                xor     al,al
                out     dx,al
                inc     dx
@@loop:         mov     al,[cs:si]
                inc     si
                mul     bl
                shr     ax,6
                out     dx,al
                dec     cx
                jnz     @@loop
                ret
ENDP
;---------------------------------------
;hmmm.. not too much comments in this routine...
;believe me, it sets 320 x 400, 256 colors x-mode with 480 scan lines
PROC            set320x400
                mov     ax,13h
                int     10h
                xor     bl,bl
                call    fadepalette     ;clear palette
                mov     dx,3c4h
                mov     ax,604h
                out     dx,ax
                mov     ax,100h
                out     dx,ax
                mov     dx,3c2h
                mov     al,11100011b    ;bit d7=1 and d6=1, 480 scan lines
                out     dx,al
                mov     dx,3c4h
                mov     ax,300h
                out     dx,ax
                mov     dx,3d4h
                mov     al,11h
                out     dx,al
                inc     dx
                in      al,dx
                and     al,7fh
                out     dx,al
                dec     dx
                mov     ax,4009h
                out     dx,ax
                mov     ax,14h
                out     dx,ax
                mov     ax,0e317h
                out     dx,ax
                mov     dx,3c4h
                mov     ax,0f02h
                out     dx,ax

                mov     ax,0a000h
                mov     es,ax
                xor     di,di
                mov     cx,16000
                xor     eax,eax
                rep     stosd           ;clear video memory
                ret
ENDP
;---------------------------------------
;this procedure writes one char.
;input: AX-x, BX-y, CL-ascii code of char
;not too fast...
PROC            writechar
                mov     [word ptr cs:mx],ax
                mov     [word ptr cs:my],bx
                sub     cl,'-'          ;first char
                xor     ch,ch
                shl     cx,4
                mov     ax,cx
                mov     si,offset fontmap;offset of font bitmap
                add     si,ax           ;plus offset in font bitmap
                mov     ax,seg fontmap  ;segment etc.
                mov     ds,ax
                mov     cx,16           ;height of char
wr1:            push    si
                push    di
                mov     dx,16           ;width of char
wr2:            mov     al,[byte ptr ds:si] ;get byte from bitmap
                mov     [byte ptr cs:mc],al
                pusha
                mov     dx,3c4h
                mov     al,2
                mov     ah,1
                mov     cx,[cs:mx]
                and     cx,3
                shl     ah,cl
                out     dx,ax
                mov     bx,[cs:mx]
                mov     cx,[cs:my]
                shr     bx,2
                shl     cx,4
                add     bx,cx
                shl     cx,2
                add     bx,cx
                mov     al,[cs:mc]
                mov     [es:bx+12*80],al
                mov     [es:bx+12*80+32000],al;draw to both 'pages'
                popa
eowr2:          inc     di              ;next byte on screen
                inc     [word ptr cs:mx]
                inc     si              ;next byte in bitmap
                dec     dx              ;decrement width counter
                jnz     wr2
                pop     di
                pop     si
                sub     [word ptr cs:mx],16
                add     [word ptr cs:my],2 ;two lines down
                add     si,736          ;next line in bitmap
                dec     cx              ;decrement our height counter
                jnz     wr1
                ret
endp
;---------------------------------------
;this procedure writes texts by using writechar proc
;INPUT: CS:DI -textoffset (last char in text must be 0)
textx           dw      0
texty           dw      0

PROC            write
                push    di
                mov     ax,0f02h
                mov     dx,3c4h
                out     dx,ax
                xor     eax,eax
                mov     di,0
                mov     cx,16000
                rep     stosd           ;clear screen
                pop     di
writetext:      mov     cl,[cs:di]      ;get byte from string
                or      cl,cl           ;is it zero? (end of text)
                jz      eowriting
                cmp     cl,32           ;is it 32? (space)
                je      nothingg
                cmp     cl,255          ;is it 255? (next line)
                je      movedown
                mov     ax,[cs:textx]   ;get x,y on screen
                mov     bx,[cs:texty]
                push    di
                call    writechar       ;write char
                pop     di
nothingg:       add     [cs:textx],16   ;next will be 16 points right
moved:          inc     di
                jmp     writetext
eowriting:      mov     [cs:textx],0
                mov     [cs:texty],0
                ret
movedown:       mov     [cs:textx],0
                add     [cs:texty],34
                jmp     moved
ENDP

;---------------------------------------
PROC            unpackfonts             ;unpack fonts bitmap
                mov     ax,seg pacfont  ;from pacfont
                mov     ds,ax
                mov     si,offset pacfont
                mov     ax,seg fontmap  ;to fontmap
                mov     es,ax
                xor     di,di
                call    unpack2
                ret
ENDP
;---------------------------------------
;this routine unpacks raw PCX data.
;INPUT: DS:SI packed data
;       ES:DI output buffer
PROC            unpack2
petla2:         mov     al,[ds:si]
                cmp     [dword ptr ds:si],'lleH' ;EndOfData index
                je      definitkoniec
                mov     ah,al
                and     ah,11000000b
                cmp     ah,11000000b
                jne     niekod
                and     al,00111111b
                xor     ch,ch
                mov     cl,al
                mov     al,[ds:si+1]
                add     si,2
                jmp     draw2
niekod:         mov     cx,1
                inc     si
draw2:          rep     stosb
                jmp     petla2
definitkoniec:  ret
ENDP
;---------------------------------------
;This routine makes This Magic Mask
;I don't remember how it exactly works, but if you want take a look
;at this mask, copy it to screen memory, in 13h mode with grayscale palette
;(or better make it in video mem in 13h, you will see making process)
x               dw      ?
y               dw      ?
xe              dw      ?
ye              dw      ?
PROC            makeM4tun
                mov     ax,seg buffer
                mov     es,ax
;Part I
;(This is conversion from Pascal, so it is not understable even for me now)
                mov     si,400
mmt2:           mov     di,1
mmt1:
                mov     cx,si
                shr     cx,1
                add     cx,160
                mov     ax,si
                mov     bx,di
                mov     bl,[sin+bx]
                xor     bh,bh
                mul     bx
                shr     ax,8
                mov     ah,dl
                sub     cx,ax
                mov     [x],cx
                ;y
                mov     cx,si
                shr     cx,1
                add     cx,100
                mov     ax,si
                mov     bx,di
                add     bx,64
                xor     bh,bh
                mov     bl,[sin+bx]
                xor     bh,bh
                mul     bx
                shr     ax,8
                mov     ah,dl
                sub     cx,ax
                mov     [y],cx

                mov     ax,si
                shr     ax,6
                inc     ax
                inc     ax
                mov     bx,[x]
                add     bx,ax
                mov     [xe],bx
                mov     bx,[y]
                add     bx,ax
                mov     [ye],bx

                mov     bp,[x]
mmt3:           mov     dx,[y]

mmt4:           mov     bx,bp
                mov     cx,dx
                cmp     bx,1
                jb      nott
                cmp     bx,319
                ja      nott
                cmp     cx,1
                jb      nott
                cmp     cx,199
                ja      nott
                shl     cx,8
                add     bx,cx
                shr     cx,2
                add     bx,cx
                mov     ax,di
                mov     [es:bx],al
nott:
                inc     dx
                cmp     dx,[ye]
                jb      mmt4
                inc     bp
                cmp     bp,[xe]
                jb      mmt3
                inc     di
                cmp     di,256
                jl      mmt1
                dec     si
                jnz     mmt2
                call    makesqrtable
;Part ][
;this part is clear, I think...  And some useful comments...
                mov     ax,seg buffer2
                mov     ds,ax
                mov     ax,seg buffer
                mov     es,ax
                mov     di,199          ;end y
mtl1:           mov     si,0            ;start x
mtl2:           mov     ax,160
                sub     ax,si           ;srx-x
                mov     bx,ax
                imul    bx              ;(srx-x)ý
                mov     bx,ax
                mov     ax,100          ;sry
                sub     ax,di           ;sry-y
                mov     cx,ax
                imul    cx              ;(sry-y)ý
                add     bx,ax           ;(srx-x)ý+(sry-y)ý  =dr
                mov     al,[ds:bx]      ;sqrt(dr) (=radius)
                xor     ah,ah
                shl     ax,7
                mov     bx,ax
                mov     al,[ds:bx]      ;sqrt(128*sqrt(dr))
                mov     bx,si
                mov     cx,di
                shl     cx,8
                add     bx,cx
                shr     cx,2
                add     bx,cx
                mov     [es:bx],al
                add     si,2
                cmp     si,319
                jl      mtl2
                dec     di
                jnz     mtl1
                ret
ENDP
;---------------------------------------
PROC            makesqrtable    ;making table of SQRT function in buffer2
                mov      ax,seg buffer2
                mov      es,ax
                xor      bx,bx
                xor      ax,ax
lsqrt0:         mov      cx,ax
                shl      cx,1
                inc      cx
lsqrt1:         mov      [byte ptr es:bx],al
                inc      bx
                cmp      bx,0ffffh
                je       lsqrt2
                dec      cx
                jnz      lsqrt1
                inc      al
                jmp      lsqrt0
lsqrt2:         ret
ENDP
;---------------------------------------
;Table of PseudoPseudoSine
LABEL Sin BYTE
 db 127,130,133,136,139,143,146,149,152,155,158,161,164,167,170,173,176,178,181,184
 db 187,190,192,195,198,200,203,205,208,210,212,215,217,219,221,223,225,227,229,231
 db 233,234,236,238,239,240,242,243,244,245,247,248,249,249,250,251,252,252,253,253
 db 253,254,254,254,254,254,254,254,253,253,253,252,252,251,250,249,249,248,247,245
 db 244,243,242,240,239,238,236,234,233,231,229,227,225,223,221,219,217,215,212,210
 db 208,205,203,200,198,195,192,190,187,184,181,178,176,173,170,167,164,161,158,155
 db 152,149,146,143,139,136,133,130,127,124,121,118,115,111,108,105,102,99,96,93
 db 90,87,84,81,78,76,73,70,67,64,62,59,56,54,51,49,46,44,42,39
 db 37,35,33,31,29,27,25,23,21,20,18,16,15,14,12,11,10,9,7,6
 db 5,5,4,3,2,2,1,1,1,0,0,0,0,0,0,0,1,1,1,2
 db 2,3,4,5,5,6,7,9,10,11,12,14,15,16,18,20,21,23,25,27
 db 29,31,33,35,37,39,42,44,46,49,51,54,56,59,62,64,67,70,73,76
 db 78,81,84,87,90,93,96,99,102,105,108,111,115,118,121,124
;--------------------------------------
;rest of routines was done by Shayde/Reality

Masm
                include player.inc      ;player stuff
                ips=50
;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Enables and starts the player interrupt.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetInt:         push    ax es

                cli
                xor     ax,ax
                mov     es,ax
                mov     ax,es:[8*4]
                mov     word ptr OldInt,ax
                mov     ax,es:2[8*4]
                mov     word ptr OldInt+2,ax
                mov     word ptr es:[8*4], offset PlayerInt
                mov     es:2[8*4],cs

                mov     ax,IPS
                call    SetTimer

                sti
                pop     es ax
                ret


;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Disables the player interrupt.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResetInt:       push    ax es

                cli
                xor     ax,ax
                mov     es,ax
                mov     ax,word ptr OldInt
                mov     es:[8*4],ax
                mov     ax,word ptr OldInt+2
                mov     es:2[8*4],ax

                call    ResetTimer

                sti
                pop     es ax
                ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; The player interrupt.  Called 50 times a second.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
PlayerInt:      push    ax

                call    PlayMusic

        ; see if we have passed 18.2/s mark
        @@lx:   mov     ax,TimerSteps           ; this no. of steps per int.
                add     TimerCnt,ax
                jnc     @@ly                    ; don't call timer interrupt
                pop     ax
                jmp     cs:OldInt               ; call old interrupt handlers

        ; standard exit
        @@ly:   mov     al,20h
                out     20h,al
                pop     ax
                iret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Sets the interrupt timer duty cycle.
; IN:
;       AX      - number of times per second for INT08.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
SetTimer:       push    ax bx dx

                mov     bx,ax
                mov     ax,13532   ; 1193180 mod 65536 (TASM craps out)
                mov     dx,18      ; 1193180/65536 (TASM can't calculate this)
                div     bx
                mov     bx,ax

                mov     al,36h
                out     43h,al
                mov     al,bl
                out     40h,al
                mov     al,bh
                out     40h,al

                mov     TimerSteps,bx   ; for keeping 18.2 timer correct
                mov     TimerCnt,0      ; counter

                pop     dx bx ax
                ret

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²
; Resets the interrupt timer back to 18.2/sec duty cycle.
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
ResetTimer:     push    ax

                mov     al,36h
                out     43h,al
                xor     al,al
                out     40h,al
                out     40h,al

                pop     ax
                ret

OldInt          dd      ?
TimerCnt        dw      ?
TimerSteps      dw      ?

Ideal

;²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²²

LABEL           pacFont byte
                include "736.rx"        ;fonts (PCXed bitmap)
LABEL           pal     byte
                include "736.bxp"       ;palette for intro
ENDS

;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
SEGMENT         modo                    ;adlib track (RAD)
LABEL           module  byte
                include "module.inc"
ENDS
;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
SEGMENT         dlafontow               ;buffer for unpacked fonts
LABEL           FontMap byte
                db      320*35 dup(?)
ENDS
;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
SEGMENT         dat                     ;buffer for mask
LABEL           buffer  byte
                db      0ffffh dup(?)
ENDS
;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
SEGMENT         dat2
LABEL           buffer2 byte            ;buffer for pattern
                db      0ffffh dup(?)
ENDS
;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
SEGMENT         dstack  stack 'STACK'   ;stack for stack...
                db      4096 dup(?)
ENDS
;þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ
end
