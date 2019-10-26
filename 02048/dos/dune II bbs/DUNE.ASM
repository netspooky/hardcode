.286

; Source of da DUNE ][ intro (1994 bytes compressed with our compresser)
; Coded by TSC of Phantom Dezign in about 2 hours of hurry... :-)
; Bye. BTW this souce is rotten.

                code     segment
                assume   cs:code, ds:code, es:code
                org     100h
start:
                mov     ax,0eh    ; 640x200x16
                int     10h
                mov     dx,3d4h
                mov     al,9
                mov     ah,0
                out     dx,ax     ; now 640x400x16
                lea     dx,[cs:reglist]
                mov     ax,1002h
                int     10h

                lea     si,[cs:pal]
                call    Pal16

                mov     cx,0
                call    plane
                lea     si,[cs:logo]
                push    0a000h
                pop     es
                mov     cx,62*80/2
                mov     di,6
                repnz   movsw

                call    typer
                lea     si,[cs:szam]
                mov     di,(220*80)-2
                mov     cx,36*80/2
                rep     movsw

                mov     ax,0
                int     16h
                call    Betukle
                mov     ax,3
                int     10h
                int     20h

typer:          mov     cx,1
                call    plane
                lea     si,[cs:szoveg]
nextchar:
                lodsb
                cmp     al,253
                je      UjLap
                cmp     al,254
                je      Ujsor
                ja      vege_typer
                jmp     nemujsor
UJSOR:          mov     [cs:aktoszlop],0
                add     [cs:aktsor],1
                jmp     nextchar
NemUjSor:       push    si
                call    Betukirak
                pop     si
                push    cx
                mov     cx,70
Loopka:         call    RasterWait
                loop    loopka
                pop     cx
                inc     [cs:aktoszlop]
                jmp     Nextchar
Vege_typer:     ret
UjLap:          mov     [cs:aktoszlop],0
                mov     [cs:aktsor],4
                call    Betukle
                pusha
                push    0a000h
                pop     es
                mov     di,20*4*80
                mov     cx,(32000-(20*4*80))/2
                mov     ax,0
                rep     stosw
                popa
                call    Betukfel
                jmp     NextChar

BetuKirak:      cmp     al,65
                jb      Space
                sub     al,65
                lea     si,[cs:nagybetuk]
                shl     al,1
                mov     ah,0
                add     si,ax
                push    0a000h
                pop     es
                mov     ax,80*20
                mul     [cs:aktsor]
                mov     bx,[cs:aktoszlop]
                shl     bx,1
                add     ax,bx
                mov     di,ax
                mov     cx,18
Betu1:
                movsw
                add     si,78
                add     di,78
                loop    Betu1
                jmp     vegeabetunek
Space:          mov     ax,80*20
                mul     [cs:aktsor]
                mov     bx,[cs:aktoszlop]
                shl     bx,1
                add     ax,bx
                mov     di,ax
                mov     cx,18
                mov     ax,0
Betu2:
                stosw
                add     di,78
                loop    Betu2

Vegeabetunek:   ret

Betukle:        pusha
                mov     cx,30
BetukLe1:
                cmp     byte ptr cs:[pal+12],30
                je      Okl1
                dec     byte ptr cs:[pal+12]
Okl1:           cmp     byte ptr cs:[pal+13],30
                je      Okl2
                dec     byte ptr cs:[pal+13]
Okl2:           cmp     byte ptr cs:[pal+14],35
                je      Okl3
                dec     byte ptr cs:[pal+14]
Okl3:           call    RasterWait
                lea     si,[cs:pal]
                call    Pal16
                loop    BetukLe1
                popa
                ret
BetukFel:       pusha
                mov     byte ptr cs:[pal+12],50
                mov     byte ptr cs:[pal+13],50
                mov     byte ptr cs:[pal+14],55
                lea     si,[cs:pal]
                call    Pal16
                popa
                ret

Pal16:          pusha
                mov     dx,3c8h
                mov     ax,0
                out     dx,al
                inc     dx
                mov     cx,15
                rep     outsb
                popa
                ret
RasterWait:     pusha
                mov     dx,03dah
Rast1:          in      al,dx
                test    al,8
                jz      Rast1
                popa
                ret

Plane:          pusha
                mov     dx,3c4h
                mov     al,2
                out     dx,al
                inc     dx
                mov     al,1
                shl     al,cl
                out     dx,al             ; plane select ?
                popa
                ret
                szoveg  db '        THIS FILE PASSED DUNE II',254
                        db 254
                        db ' WHQ FOR PHANTOM DEZIGN AND INFOMANIAX',254
                        db 'HHQ FOR IMPHOBIA CASCADA AND ABSOLUTE PC',254
                        db '              ABADDON SITE',254
                        db '           BRAIN BROWSE SITE',254
                        db '          CRIMINAL GANG SITE',254
                        db '           FUTURE CREW SITE',254
                        db '            GRIF TEAM SITE',254
                        db '              IGUANA SITE',254
                        db '           MAJIC TWELVE SITE',254
                        db '               ONYX SITE',254
                        db '             PENTAGON SITE',254
                        db '           PSYCHOSQUAD SITE',254
                        db '      THE DIGITAL MANEUVER SITE',254
                        db '        TWIN SECTORS INC SITE',254
                        db 253
                        db '        SYSOPS ARE TSC AND CAT',254
                        db '        THE COSYSOP IS ADMIRAL',254
                        db 254
                        db '          FOR TOONZ OF DEMOS',254
                        db 254
                        db '           DIAL THIS NUMBER',254
                        db 255
                aktsor    dw 4
                aktoszlop dw 0
                rulez   dw      0
                reglist db  0,2,4,6,8,10,12,14,1,3,5,7,9,11,13,15,0
                pal     db  30,30,35   ;hatter 0
                        db  40,40,45
                        db  40,40,45   ;plane 0
                        db  40,40,45
                        db  50,50,55   ;plane 1
include         dune.inc
include         nagy.inc
include         tsc.inc
ends code
end start
