.model tiny
.code
.386
org 100h

;ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
;³ This is Yehar's entry for the #coders 256b fire compo.        Date: 5/1996 ³
;³ (gaffer: a fun idea!) Boy, it looks HOT! Ok, now I'll tell you what        ³
;³ strange things I have coded in here... The flame itself is 160 x 67, but   ³
;³ when drawed, it is stretched to 320 x 134 pixels and interpolated to       ³
;³ improve the quality of the picture. Nothing else... Oh, I just added some  ³
;³ comments for you - Have fun! NOTE: The program reaches 70Hz on my 486/80.  ³
;³                                                                            ³
;³ Greetings: Faust, Absu, Gaze, Dope^Dood, Buckra, Carnifex, #coders, #mesta ³
;ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
; E-mail me (comments or anything): ollinie@hauki.haukipudas.fi

linelen         = 160                   ;How many pixels per line
donotdrawlines  = 0                     ;These won't be shown
lines           = 67+donotdrawlines     ;How many lines
linesperpix     = 3                     ;Height of graphics pixels (try 1!)
c0      = 62          ;Do not worry!
c1      = 32          ;These are just values for palet creating
c11     = 0           ;
c2      = 59          ;
c22     = 5           ;

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

start:
                mov     ax, 13h         ;mode 13h
                int     10h             ;
                mov     dx,3D4h                         ;320 x 133.33 pixels
                mov     ax,(linesperpix-1)*100h+09h     ;
                out     dx,ax                           ;

                cld                     ;Never forget!

                xor     ax, ax                                  ;Fill memory
                mov     di, offset zerostart                    ;with zeroes
                mov     cx, offset zeroend - offset zerostart   ;
                rep     stosb                                   ; hehe.. =)

                mov     di, offset palet+c0*3   ;Colors from black to red
                mov     cl, c1*2                ;
paletloop1:     mov     bl, (c1+c11)*2          ;
                sub     bl, cl                  ;
                mov     ds:[di], bl             ;
                inc     di                      ;
                stosw                           ;
                dec     cx                      ;
                loop    paletloop1              ;

                mov     cl, c2-c22      ;Colors from red to yellow
paletloop2:     mov     ax, c2+c22      ;
                sub     ax, cx          ;
                mov     ds:[di], bl     ;
                inc     di              ;
                stosw                   ;
                loop    paletloop2      ;

                mov     cx, (256-(c2-c22)-c1-c0+2)*3    ;The rest are white
                mov     al, 3fh                         ;This looks much better
                rep     stosb                           ;than shading, U know!

                mov     ax, 1012h        ;Set colors
                inc     ch               ;-> 256  hey, this is tricky ;)
                xor     bx, bx           ;
                mov     dx, offset palet ;
                int     10h              ;

                push    0a000h          ;Set ES
                pop     es              ;

mainloop:       mov     si, offset fire
                push    si
                mov     cx, linelen*lines

                xor     ax, ax
fire_xloop:     mov     al, ds:[si+linelen]     ;Smooth and shift up flames
                mov     bl, ds:[si+linelen-1]   ;
                add     ax, bx                  ;
                mov     bl, ds:[si+linelen*2]   ;
                add     ax, bx                  ;
                mov     bl, ds:[si+linelen+1]   ;
                add     ax, bx                  ;
                shr     ax, 2                   ;
                dec     ax              ;Tummennus
                jns     xxx             ;"Fade to black?"
                inc     ax              ;
                xxx:                    ;
                mov     ds:[si], al             ;
                inc     si
                loop    fire_xloop

                mov     cx, linelen

random_loop:    imul    ax, randomroot, 221     ;Random
                inc     ax                      ;
                mov     randomroot, ax          ;
                mov     ds:[si], ah                     ;This is what is
                mov     ds:[si+linelen], ah             ;burning down there
                inc     si
                loop    random_loop

                mov     dx,3dah                 ;Wait for vertical retrace
novrx:          in      al,dx                   ;
                test    al,00001000b            ;
                jz      novrx                   ;
novrx2:         in      al,dx                   ;
                test    al,00001000b            ;
                jnz     novrx2                  ;

                xor     di, di
                pop     si
                mov     cx, lines - donotdrawlines

                xor     dx, dx
drawloopy:      push    cx                      ;Draw the flames now!
                mov     cx, linelen

drawloopx:      movzx   ax, ds:[si]             ;Interpolation
                inc     si                      ;
                mov     bl, ds:[si]             ;
                mov     dl, ds:[si-1+linelen]   ;
                movzx   bp, ds:[si-1+linelen+1] ;
                                                ;
                add     bx, ax                  ;whoa! This is how you get
                shl     bx, 7                   ;4 pixels out of 1...
                mov     bl, al                  ;
                mov     es:[di], bx     ;Draw upper 2 pixels
                add     ax, dx                  ;
                mov     dx, ax                  ;
                shr     dx, 1                   ;
                add     ax, bp                  ;
                movzx   bx, ds:[si]             ;
                add     ax, bx                  ;
                shl     ax, 6                   ;
                mov     al, dl                  ;
                mov     es:[di+320], ax ;Draw lower 2 pixels

                inc     di
                inc     di
                loop    drawloopx
                add     di, 320         ;Y = Y + 1
                pop     cx              ;
                loop    drawloopy

                mov ah, 1       ;If someone wants to quit
                int 16h         ;
                jz  mainloop
                mov ax, 3               ;Back to co80
                int 10h                 ;
                ret     ;Bye bye!

ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

zerostart label

palet   db 256*3 dup (?)                ;Colors are here!
fire    db linelen*(lines+2) dup (?)    ;Flames are here!

zeroend label

randomroot      dw ?

end start
