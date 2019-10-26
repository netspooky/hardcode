comment $

ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛßÛÛÛÛ ÛÛÛÛÛßÛÛÛÛ ÛÛÛÛÛßÛÛÛÛ ÛÛÛÛßÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛßÛÛÛÛ ÛÛÛÛÛßÛÛÛÛ
ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛ ÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ
ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÜÜÜÜ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÜÜÜÜ      ÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ
ÛÛÛÛÛßÛÛÛÛ ÛÛÛÛÛßÛÛÛÛ ÛÛÛÛÛßÛßßß ÛÛÛÛÛßÛÛÛÛ      ÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ ÛÛÛÛ ÛÛÛÛÛ
ÛÛÛÛÛ ÛÛÛ² ÛÛÛÛÛ ÜÜÜÜ ÛÛÛÛÛ ÛÛÛ² ÛÛÛÛÛ ÜÜÜÜ      ÛÛÛ² ÛÛÛ² ÛÛÛÛÛ ÜÜÜÜ ÛÛÛÛÛÛÛÛÛ²
ÛÛÛÛÛ ÛÛ²± ÛÛÛÛÛ ÛÛ²± ÛÛÛÛÛ ÛÛ²± ÛÛÛÛÛ ÛÛ²±      ÛÛ²± ÛÛ²± ÛÛÛÛÛ ÛÛ²± ÜÜÜÜÜ ÛÛ²±
ÛÛÛÛÛ Û²±° ÛÛÛÛÛÜÛ²±° ÛÛÛÛÛ Û²±° ÛÛÛÛÛÜÛ²±°      Û²±° Û²±° ÛÛÛÛÛÜÛ²±° ÛÛÛÛÛÜÛ²±°
                                                                             -cb

                         ùş  H E R E T I C S  ' 9 4  şù

                                    present:

                      Liquid Metal BBS Advertisement v1.10

                             coded by Black Artist

                            a long, long time ago...

                        v1.10 updated 5th September 1994

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

        erm..... make of this what you will - this was coded quite a while
        ago and was left uncommented, when I went to update it I thought I
        would release the source, but I can't be bothered to go through it
        and comment it decently.  Some of the code is shocking, but for an
        effect that is inherently so fast, even the sloppiest of code will
        run at full frame rate.

        I hope this helps somebody LEARN.  However do not be so lame as to
        try and simply RIP this code - if you are stupid enough to do so
        and try and release something using even portions of this code and
        call it your own, I will personally come and ram bugs down your
        throat.  Actually, I wouldn't bother, because it's such a unique
        effect (I haven't seen anything like it) and also so simple, that
        everyone will laugh at you. (And the sky will turn green, the devil
        will rise up and drag you down into the eternal pits of ..er...well
        bad things will happen.) :)

        Well I'm sick of writing this so i will stop.

        btw for all you ppl in the USA, the 5/9/94 does NOT mean 9th May :)


                  Yoong-Chert Foo
                  Black Artist / Heretics
                  5th September 1994

±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

        this requires a 386 as it uses a couple of 386 instructions, but it
        could very easily be converted for 286 or even 8088 instructions if
        you were very, very bored and poor :)

        a VGA is mandatory, and if you want to hear some music you need
        something capable of producing Adlib FM sounds - btw SBOS works but
        some bits sound out of tune

        everything is done by me apart from the music system [chicken] and
        the music [?? - came with HSC tracker]

        quick greetings to the cool ppl on IRC - you know who you are :-)

        for smallest size, link with microsoft link and use /e

$

display "DO NOT ASSEMBLE WITH TASM 4.0!!!!!! (will crash)"

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


.386
model compact

extrn _hscplayer:far

assume cs:only,ds:nothing,es:nothing,fs:nothing,gs:nothing

screenwidth     equ     144
screenstart     equ     129*screenwidth

stack 128

;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
p1              segment para use16
p1buf           label   byte
                include back1.db
                db      screenwidth*152 dup (?)
p1              ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
p2              segment para use16
p2buf           label   byte
                include back2.db
                db      screenwidth*152 dup (?)
p2              ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
p3              segment para use16
p3buf           label   byte
                include back3.db
                db      screenwidth*152 dup (?)
p3              ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
p4              segment para use16
p4buf           label   byte
                include back4.db
                db      (screenwidth*152-768-24) dup (?)
palette         label   word
                db      0,0,0
                i=0
                rept    15
                db      i*3+18,i*2+18,0
                i=i+1
                endm
                i=0
                rept    64
                db      0,0,i
                i=i+1
                endm
                i=0
                rept    32
                db      i,0,63
                i=i+2
                endm
                i=0
                rept    64
                db      63,i,63-i
                i=i+1
                endm
                i=0
                rept    64
                db      63,63,i+16
                i=i+1
                endm
                db      16 dup (63,63,63)
xdata           db      5fh,4fh,50h,82h,54h,80h,0dh,3eh,00h,01h,00h,00h
                db      73h,0ffh,00h,00h,0eah,8ch,0dfh,48h,00h,0e7h,06h,0e3h
p4              ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
music           segment use16
muzak           label   byte
include         music.db
music           ends
;ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

only            segment use16

planesegs       label   word
p1bufseg        dw      seg     p1buf
p2bufseg        dw      seg     p2buf
p3bufseg        dw      seg     p3buf
p4bufseg        dw      seg     p4buf

chardata        dw      ?,?

                include lisa.db

; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄGeneralÄInitialisationÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
bobinit         proc

                mov     ax,13h
                int     10h

                mov     dx,03c8h
                xor     al,al
                out     dx,al
                mov     cx,768
                inc     dx
wipepal:        out     dx,al
                loop    wipepal

                mov     dx,03c4h
                mov     ax,00604h
                out     dx,ax
                mov     ax,00100h
                out     dx,ax
                mov     dx,03c2h
                mov     al,0e3h
                out     dx,al
                mov     dx,03c4h
                mov     ax,00300h
                out     dx,ax

                mov     dx,03d4h
                mov     al,11h
                out     dx,al
                inc     dx
                in      al,dx
                and     al,7fh
                out     dx,al

                mov     dx,03d4h
                xor     al,al
                mov     ds,p4bufseg
                mov     si,offset xdata
                mov     cx,24
xloop:          mov     ah,ds:[si]
                out     dx,ax
                inc     al
                inc     si
                loop    xloop

                mov     dx,03c0h
                mov     al,10h
                out     dx,al
                mov     al,61h
                out     dx,al
                mov     al,013h
                out     dx,al
                mov     al,6
                out     dx,al

                mov     ds,p4bufseg
                mov     si,offset palette
                mov     dx,03c8h
                xor     al,al
                out     dx,al
                mov     cx,768
                inc     dx
                rep     outsb

                xor     bx,bx
fillplane:      mov     ax,planesegs[bx]
                mov     ds,ax
                mov     es,ax
                mov     di,18
                mov     dh,7
fillbuf:        xor     si,si
                mov     cx,56
fillline:       movsd
                movsd
                movsd
                movsd
                movsw
                add     si,screenwidth-18
                add     di,screenwidth-18
                loop    fillline
                sub     di,56*screenwidth-18
                dec     dh
                jnz     fillbuf
                xor     si,si
                mov     di,56*screenwidth
                mov     cx,5472
                rep     movsd
                inc     bx
                inc     bx
                cmp     bx,8
                jb      fillplane

                mov     ax,1102h
                mov     dx,3c4h
                out     dx,ax
                mov     bx,1104h
                mov     ax,0a000h
                mov     es,ax
                xor     bp,bp
copyplane:      mov     ds,planesegs[bp]
                mov     dl,7
                mov     di,16*screenwidth
copyrow:        xor     si,si
                mov     cx,2016
                rep     movsd
                dec     dl
                jnz     copyrow
                xor     si,si
                mov     cx,1440
                rep     movsd

                dec     bl
                jz      copied
                rol     bh,1
                mov     al,bh
                mov     dx,03c5h
                out     dx,al
                inc     bp
                inc     bp
                jmp     copyplane
copied:


                mov     ax,1130h
                mov     bh,6
                int     10h
                mov     chardata,bp
                mov     chardata+2,es

                ret

bobinit         endp


; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄWriteÄ8*16ÄCharÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ³ writechar wants : es:di -> offset
; ³                   ds:si -> chardata
; ³                   bx -> character

planesel        db      ?
counter         db      ?

writechar       proc

                shl     bx,4

                mov     ax,1102h
                mov     dx,03c4h
                out     dx,ax
                mov     word ptr planesel,0411h
                xor     bp,bp
                mov     dx,8008h

writeplane:     xor     ax,ax
                test    byte ptr ds:[si+bx],dl
                jz      clear1
                mov     ah,bl
clear1:         test    byte ptr ds:[si+bx],dh
                jz      clear2
                mov     al,bl
clear2:         and     ax,0f0fh
                mov     word ptr es:[di+bp],ax
                inc     bx
                add     bp,screenwidth
                cmp     bp,16*screenwidth
                jb      writeplane

                dec     counter
                jz      allwritten
                shr     dx,1
                mov     bp,dx
                sub     bx,16
                rol     planesel,1
                mov     dx,03c5h
                mov     al,planesel
                out     dx,al
                mov     dx,bp
                xor     bp,bp
                jmp     writeplane

allwritten:     ret

writechar       endp


; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDrawÄBobÄRoutineÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ³ Bob wants : dx -> x value
; ³             bx -> y value * screenwidth
; ³            eax -> add value

drawbob         proc

                mov     cx,dx
                shr     dx,1
                jc      @1or3
                shr     dx,1
                jc      @2
                mov     ds,p1bufseg
                mov     es,p2bufseg
                mov     fs,p3bufseg
                mov     gs,p4bufseg
                xor     si,si
                xor     di,di
                jmp     @shadein
                
@2:             mov     ds,p3bufseg
                mov     es,p4bufseg
                mov     fs,p1bufseg
                mov     gs,p2bufseg
                mov     si,1
                mov     di,1    
                jmp     @shadein

@1or3:          shr     dx,1
                jc      @3
                mov     ds,p2bufseg
                mov     es,p3bufseg
                mov     fs,p4bufseg
                mov     gs,p1bufseg
                xor     si,si
                mov     di,1
                jmp     @shadein
                
@3:             mov     ds,p1bufseg
                mov     es,p2bufseg
                mov     fs,p3bufseg
                mov     gs,p4bufseg
                xor     si,si
                mov     di,-1
                inc     dl
                                
@shadein:       add     bx,dx

                add     dword ptr ds:[bx],eax
                add     dword ptr es:[bx],eax
                add     dword ptr fs:[bx+si],eax
                add     dword ptr gs:[bx+di],eax

                add     dword ptr ds:[bx+screenwidth],eax
                add     dword ptr es:[bx+screenwidth],eax
                add     dword ptr fs:[bx+si+screenwidth],eax
                add     dword ptr gs:[bx+di+screenwidth],eax

                add     dword ptr ds:[bx+screenwidth*2],eax
                add     dword ptr es:[bx+screenwidth*2],eax
                add     dword ptr fs:[bx+si+screenwidth*2],eax
                add     dword ptr gs:[bx+di+screenwidth*2],eax

                add     dword ptr ds:[bx+screenwidth*3],eax
                add     dword ptr es:[bx+screenwidth*3],eax
                add     dword ptr fs:[bx+si+screenwidth*3],eax
                add     dword ptr gs:[bx+di+screenwidth*3],eax

                add     dword ptr ds:[bx+screenwidth*4],eax
                add     dword ptr es:[bx+screenwidth*4],eax
                add     dword ptr fs:[bx+si+screenwidth*4],eax
                add     dword ptr gs:[bx+di+screenwidth*4],eax

                add     dword ptr ds:[bx+screenwidth*5],eax
                add     dword ptr es:[bx+screenwidth*5],eax
                add     dword ptr fs:[bx+si+screenwidth*5],eax
                add     dword ptr gs:[bx+di+screenwidth*5],eax

                add     dword ptr ds:[bx+screenwidth*6],eax
                add     dword ptr es:[bx+screenwidth*6],eax
                add     dword ptr fs:[bx+si+screenwidth*6],eax
                add     dword ptr gs:[bx+di+screenwidth*6],eax

                add     dword ptr ds:[bx+screenwidth*7],eax
                add     dword ptr es:[bx+screenwidth*7],eax
                add     dword ptr fs:[bx+si+screenwidth*7],eax
                add     dword ptr gs:[bx+di+screenwidth*7],eax

                add     dword ptr ds:[bx+screenwidth*8],eax
                add     dword ptr es:[bx+screenwidth*8],eax
                add     dword ptr fs:[bx+si+screenwidth*8],eax
                add     dword ptr gs:[bx+di+screenwidth*8],eax

                add     dword ptr ds:[bx+screenwidth*9],eax
                add     dword ptr es:[bx+screenwidth*9],eax
                add     dword ptr fs:[bx+si+screenwidth*9],eax
                add     dword ptr gs:[bx+di+screenwidth*9],eax

                add     dword ptr ds:[bx+screenwidth*10],eax
                add     dword ptr es:[bx+screenwidth*10],eax
                add     dword ptr fs:[bx+si+screenwidth*10],eax
                add     dword ptr gs:[bx+di+screenwidth*10],eax

                add     dword ptr ds:[bx+screenwidth*11],eax
                add     dword ptr es:[bx+screenwidth*11],eax
                add     dword ptr fs:[bx+si+screenwidth*11],eax
                add     dword ptr gs:[bx+di+screenwidth*11],eax

                add     dword ptr ds:[bx+screenwidth*12],eax
                add     dword ptr es:[bx+screenwidth*12],eax
                add     dword ptr fs:[bx+si+screenwidth*12],eax
                add     dword ptr gs:[bx+di+screenwidth*12],eax

                add     dword ptr ds:[bx+screenwidth*13],eax
                add     dword ptr es:[bx+screenwidth*13],eax
                add     dword ptr fs:[bx+si+screenwidth*13],eax
                add     dword ptr gs:[bx+di+screenwidth*13],eax

                add     dword ptr ds:[bx+screenwidth*14],eax
                add     dword ptr es:[bx+screenwidth*14],eax
                add     dword ptr fs:[bx+si+screenwidth*14],eax
                add     dword ptr gs:[bx+di+screenwidth*14],eax

                add     dword ptr ds:[bx+screenwidth*15],eax
                add     dword ptr es:[bx+screenwidth*15],eax
                add     dword ptr fs:[bx+si+screenwidth*15],eax
                add     dword ptr gs:[bx+di+screenwidth*15],eax

                cmp     di,-1
                jne     @drawin
                dec     bx

@drawin:        mov     ax,1102h
                and     cx,3
                shl     ah,cl
                mov     bp,cx
                shl     bp,1
                mov     dx,03c4h
                out     dx,ax

                mov     ch,ah
                mov     cl,4
                mov     ax,0a000h
                mov     es,ax
                mov     di,bx

@copyplane:     mov     ds,planesegs[bp]
                mov     eax,dword ptr ds:[di]
                mov     dword ptr es:[di+screenstart],eax
                mov     eax,dword ptr ds:[di+screenwidth]
                mov     dword ptr es:[di+screenstart+screenwidth],eax
                mov     eax,dword ptr ds:[di+screenwidth*2]
                mov     dword ptr es:[di+screenstart+screenwidth*2],eax
                mov     eax,dword ptr ds:[di+screenwidth*3]
                mov     dword ptr es:[di+screenstart+screenwidth*3],eax
                mov     eax,dword ptr ds:[di+screenwidth*4]
                mov     dword ptr es:[di+screenstart+screenwidth*4],eax
                mov     eax,dword ptr ds:[di+screenwidth*5]
                mov     dword ptr es:[di+screenstart+screenwidth*5],eax
                mov     eax,dword ptr ds:[di+screenwidth*6]
                mov     dword ptr es:[di+screenstart+screenwidth*6],eax
                mov     eax,dword ptr ds:[di+screenwidth*7]
                mov     dword ptr es:[di+screenstart+screenwidth*7],eax
                mov     eax,dword ptr ds:[di+screenwidth*8]
                mov     dword ptr es:[di+screenstart+screenwidth*8],eax
                mov     eax,dword ptr ds:[di+screenwidth*9]
                mov     dword ptr es:[di+screenstart+screenwidth*9],eax
                mov     eax,dword ptr ds:[di+screenwidth*10]
                mov     dword ptr es:[di+screenstart+screenwidth*10],eax
                mov     eax,dword ptr ds:[di+screenwidth*11]
                mov     dword ptr es:[di+screenstart+screenwidth*11],eax
                mov     eax,dword ptr ds:[di+screenwidth*12]
                mov     dword ptr es:[di+screenstart+screenwidth*12],eax
                mov     eax,dword ptr ds:[di+screenwidth*13]
                mov     dword ptr es:[di+screenstart+screenwidth*13],eax
                mov     eax,dword ptr ds:[di+screenwidth*14]
                mov     dword ptr es:[di+screenstart+screenwidth*14],eax
                mov     eax,dword ptr ds:[di+screenwidth*15]
                mov     dword ptr es:[di+screenstart+screenwidth*15],eax

                dec     cl
                jz      @alldone
                rol     ch,1
                mov     dx,03c5h
                mov     al,ch
                out     dx,al
                cmp     al,12h
                inc     bp
                inc     bp
                jnc     @copyplane
                inc     di
                xor     bp,bp
                jmp     @copyplane
@alldone:       ret

drawbob         endp

; ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄSetÄWindowÄLocationÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
; ³ SetWindow needs   cx-->x
; ³                   dx-->y * screenwidth

setwindow       proc
                mov     bx,cx
                shr     cx,2
                add     cx,dx

                mov     dx,03dah
@setwindowsync: in      al,dx
                and     al,08h
                jnz     @setwindowsync

                mov     dx,03d4h
                mov     al,00dh
                mov     ah,cl
                out     dx,ax

                dec     al
                ;mov     al,00ch
                mov     ah,ch
                out     dx,ax

                mov     dx,03dah
@ksyncagain:    in      al,dx
                and     al,08h
                jz      @ksyncagain

                mov     dx,03c0h
                mov     al,033h
                out     dx,al

                mov     al,bl
                and     al,3
                shl     al,1
                out     dx,al

                ret

setwindow       endp


; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄMainÄVariablesÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
anglex          dw      0
angley          dw      0
backx           dw      0
backy           dw      0
viewx           dw      0
viewy           dw      0
coeffxdir       dw      1
coeffydir       dw      -1
coeffx          dw      2      ;starting rate of change in x
coeffy          dw      3      ;starting rate of change in y
bobcounter      dw      0
jerkbits        equ     7
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄParametersÄforÄBobÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
coeffxmax       equ     4      ;max rate of change of x
coeffymax       equ     5      ;max rate of change of y
boblength       equ     450    ;length of Bob in squares
viewdelay       equ     32     ;how many squares behind Bob's head camera views
fastjerkbits    equ     7      ;how many squares drawn per scroll (70Hz)-fast
slowjerkbits    equ     3      ;how many squares drawn per scroll (70Hz)-slow
patternlength   equ     2800   ;5secs*8jerks*70fps
;  40characters wide -   0123456789012345678901234567890123456789
message         db      'Liquid Metal  +61ù7ù201ù5242  28k824hrs'
                db      ' ş Heretics WHQ ş Sysop: Chuck Biscuits '
                db      'Australia''s best demoboard - Aust HQ for'
                db      'KLF  EMF  Iguana/VangeliSTeam  Admire'
                db      'Psychic Monks  Mental Design  sYmptom '
                db      'Surprise! Prod.  VLA  Digital Infinity'
                db      '  distro site for Inertia Player  DMP  '
                db      'iCE member board  DiE ANSi member board'
                db      'This Adv 100% ASM by Black Artist 5ù9ù94'
                db      '& uses HSC-Tracker by Chicken (<-greetz)'
messagelength   equ     $-message
signoff         db      'Call Liquid Metal: +61ù7ù201ù5242  28k8 All Hours - Australia''s finest demoboard',0ah,0dh
                db      '  ş Heretics WHQ ş   Sysop: Chuck Biscuits [Heretics/iCE/Dissonance Co-Editor]',0ah,0dh,0ah,0dh
                db      'this BBS Advertisement v1.10 coded by Black Artist/Heretics,  5th September 1994',0ah,0dh
                db      '$'


messagecount    dw      0
; ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄMainÄProcedureÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
main            proc
                
                call    bobinit
                
                mov     ah,4
                xor     bx,bx
                call    _hscplayer
                mov     ax,seg muzak
                mov     es,ax
                mov     si,offset muzak
                xor     ah,ah
                mov     bx,0101h
                call    _hscplayer

                lds     si,dword ptr chardata
                mov     ax,0a000h
                mov     es,ax
                mov     cx,40
                xor     di,di
wipeline:       mov     bx,'Û'
                call    writechar
                inc     di
                inc     di
                loop    wipeline

keepgoing:      cmp     bobcounter,64
                ja      dontslideon
                mov     bx,bobcounter
                shr     bx,1
                mov     ax,0e418h
                sub     ah,bl
                mov     dx,03d4h
                out     dx,ax
dontslideon:    cmp     bobcounter,patternlength-512
                jb      dontslideoff
                mov     bx,bobcounter
                sub     bx,patternlength-512
                shr     bx,4
                mov     ax,0c418h
                add     ah,bl
                mov     dx,03d4h
                out     dx,ax

dontslideoff:   cmp     bobcounter,patternlength-boblength
                jae     dontdraw
                mov     si,cs:[anglex]
                movzx   dx,lisax[si]
                add     dx,153
                mov     si,cs:[angley]
                mov     al,screenwidth
                mul     lisay[si]
                mov     bx,ax
                mov     eax,02020202h
                call    drawbob

                mov     ax,cs:[anglex]
                add     ax,coeffx
                cmp     ax,1256
                jb      @nomodx
                sub     ax,1256
@nomodx:        mov     cs:[anglex],ax
                mov     ax,cs:[angley]
                add     ax,coeffy
                cmp     ax,1256
                jb      @nomody
                sub     ax,1256
@nomody:        mov     cs:[angley],ax

dontdraw:       mov     ax,jerkbits
                test    bobcounter,ax
                jnz     noview

                mov     ah,1
                call    _hscplayer

                mov     si,cs:[viewx]
                movzx   cx,lisax[si]
                mov     si,cs:[viewy]
                mov     al,screenwidth
                mul     lisay[si]
                mov     dx,16*screenwidth
                add     dx,ax
                call    setwindow

noview:         cmp     bobcounter,viewdelay
                jb      dontmove
                cmp     bobcounter,patternlength-boblength+viewdelay
                jae     dontmove
                mov     ax,cs:[viewx]
                add     ax,coeffx
                cmp     ax,1256
                jb      @nomodvx
                sub     ax,1256
@nomodvx:       mov     cs:[viewx],ax
                mov     ax,cs:[viewy]
                add     ax,coeffy
                cmp     ax,1256
                jb      @nomodvy
                sub     ax,1256
@nomodvy:       mov     cs:[viewy],ax

dontmove:       cmp     bobcounter,boblength
                jb      notyet
                mov     si,cs:[backx]
                movzx   dx,lisax[si]
                add     dx,153
                mov     si,cs:[backy]
                mov     al,screenwidth
                mul     lisay[si]
                mov     bx,ax
                mov     eax,-02020202h
                call    drawbob

                mov     ax,cs:[backx]
                add     ax,coeffx
                cmp     ax,1256
                jb      @nomodbx
                sub     ax,1256
@nomodbx:       mov     cs:[backx],ax
                mov     ax,cs:[backy]
                add     ax,coeffy
                cmp     ax,1256
                jb      @nomodby
                sub     ax,1256
@nomodby:       mov     cs:[backy],ax

notyet:         inc     bobcounter
                cmp     bobcounter,patternlength
                jb      dontchange

                mov     bobcounter,0

                mov     ax,coeffx
                add     ax,coeffxdir
                jz      changexdir
                cmp     ax,coeffxmax
                jbe     dontchangexdir
changexdir:     neg     coeffxdir
                add     ax,coeffxdir
                add     ax,coeffxdir
dontchangexdir: mov     coeffx,ax
                mov     bx,ax

                mov     ax,coeffy
                add     ax,coeffydir
                jz      changeydir
                cmp     ax,coeffymax
                jbe     dontchangeydir
changeydir:     neg     coeffydir
                add     ax,coeffydir
                add     ax,coeffydir
dontchangeydir: mov     coeffy,ax

                lds     si,dword ptr chardata
                mov     ax,0a000h
                mov     es,ax
                mov     di,-screenwidth
                cmp     messagecount,messagelength
                jb      dontwrap
                mov     messagecount,0
dontwrap:       mov     cx,40

nextchar:       mov     bp,messagecount
                movzx   bx,message[bp]
                call    writechar
                inc     di
                inc     di
                inc     messagecount
                loop    nextchar

dontchange:     in      al,60h
                cmp     al,1
                jne     keepgoing

outtahere:      mov     ax,3
                int     10h

                mov     ah,2
                call    _hscplayer

                mov     ax,cs
                mov     ds,ax
                mov     ah,9
                mov     dx,offset signoff
                int     21h
                mov     ax,4c00h
                int     21h
                
main            endp               

only            ends
          
end             main
