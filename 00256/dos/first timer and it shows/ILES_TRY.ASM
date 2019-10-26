; This thing was coded (?) by ILE       (iljas@htsa.hva.nl)

            .ASSUME is anagram for USE ASM :-)

Teller2:
Start:               mov       al, 13h
Teller1:             int       10h
Adder:               push      0a000h
Random:              pop       es
                     
Data1:               sub       sp, 28

Waitretrace:         
                     mov       dx, 3dah    
            @l1:     in        al, dx
                     and       al, 8
                     jnz       @l1
            @l2:     in        al, dx
                     and       al, 8
                     jz        @l2

                     dec       byte ptr [teller1]   ; -1
                     add       byte ptr [teller2],22    ; + 2

                                  
;----=-=-=====--=-=-==-==-- Starz =-===---=--=-=-=-=-=
                     mov       si, offset postab
                     
                     mov       di, si
                     mov       cx, 14   ; aantalSterren

Starsweg:            pop       di
                     xor       al, al
                     stosb
                     loop      starsweg
                     
                     mov       cx, 14
                     
SterLus:             lodsw         ; X     
                     mov       bx, ax
                     xor       ah, ah
                     lodsb         ; Y
                     add       bx, cx   ; x + speed
                     cmp       bx, 319
                     jng       BinnenGrens 
                     
                     mov       al, byte ptr [random]
                     
                     mov       byte ptr ds:[si-1], al
                     add       byte ptr [random], 136
                     
                     xor       bx, bx       ; X=0

BinnenGrens:         mov       di, 320
                     mul       di
                     mov       di, ax
                     add       di, bx   ; di = pos (???)
                     push      di
                     
                     mov       word ptr [si-3], bx

                     mov       al, 15
                     stosb

                     loop      sterlus
                                 
;----=-=-=====--=-=-==-==-- NUMMER 1 =-===---=--=-=-=-=-=

                     mov       byte ptr [adder], 120 ; 187,21
                     xor       di, di
                     
                     mov       dx, 070Eh  ; dh AND-Value , dl hoogte
                                           ; DH == Patroon!!!
                     mov       al, [teller2]
                     mov       [data1], al
                     
                     call      drawit
;----=-=-=====--=-=-==-==-- NUMMER 2 =-===---=--=-=-=-=-=
                     mov       byte ptr [adder], 16  ; 16
                     mov       di, 60480    ;52900
                                  ;01720h
                                  ;01A0Fh
                     mov       dx, 1F0Bh  ;1F0Ch

                     push      [teller1]
                     pop       [data1]
                     neg       byte ptr [data1]
                     call      drawit
                     
Checkkey:            in        al, 60h
                     cmp       al, 1
                     je        backtodos
                     jmp       waitretrace ; goddamn jump > -127 :(

BackToDos:           mov       ax, 03h 
                     int       10h
                     
ToonMSG:             mov       dx, offset MSG    ; 'Merry Xmas!' or
                     mov       ah, 9             ; 'Happy 1998!' ???
                     int       21h
                     
                     mov       ah, 4ch ; CRAP! why doesn't RET work here???
                     int       21h
                     
;----=-=-=====--=-=-==-==-- Da Plasma Proc =-===---=--=-=-=-=-=
drawit PROC NEAR
                     mov       bx, offset stab
Vertlus:             mov       cl, 160   ; kopieer elke pixel

HorLus:              mov       al, cl
                     add       al, [teller1]
                     not       al
                     and       al, dh
                     xlat
                     mov       ah, al
                     
                     mov       al, dl
                     xlat
                     add       al, cl
                     add       al, [data1]
                     and       al, dh
                     xlat
                     add       al, ah

                     and       al, dh
                     add       al, [ADDER] 
                     stosb
                     stosb
                     loop      horlus
                     dec       dl
                     jnz       vertlus
                     ret
ENDP

MSG  db 'Merry Xmas!$'
Stab    db 0,1,1,2,2,3,4,4,5,6,7,9,11,12,13 
        db 13,12,11,9,7,6,5,4,4,3,2,2,1,1
        db 0,0,0   

Postab:
       ; There are some places where you could scrape off some bytes,
       ; but who cares now anyway?
