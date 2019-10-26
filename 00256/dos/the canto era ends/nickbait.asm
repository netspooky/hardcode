;The Canto Era Ends (or, "A Gift For Nick")
;Partyplace compofiller by Trixter/Hornet 1/10/2016
;Written in 2 hours, don't judge me.  Can be further optimized.
;Based on Nick Montfort's The Era Canto (except, as the title
;suggests, this one ends, and is meant to sound comprehensible.)
;Can generate infinite poetry if you replace the random number generator
;but I didn't want to torture the audience.

        org     100h
        jmp     start

pwords  DB      'cantoothemeterasextonended'
                ;0123456789abcdef0123456789
                ;000111222333444555666777xx
ppunc   DB      ',;:??!..'
nstanza DB      4

rand25: ;return random number in range 2-5
        lodsb                           ;pull random character
        and     al,3
        add     al,2
        ret
start:
        mov     si,offset pwords        ;seed with chosen random numbers
        mov     ah,02                   ;for printing chars with dos

stanzaloop:
        mov     dl,10
        int     21h
        mov     di,0008h

lineloop:
        call    rand25
        mov     cl,al
        mov     bp,cx                   ;bp=numwords

wordsloop:
        lodsb                           ;grab random data
        and     al,7                    ;al=0-7
        mov     bl,al                   ;bl=0-7
        shl     bl,1                    ;bl=bl*2
        add     bl,al                   ;bl=bl*3; bx=start of word
        call    rand25
        mov     cl,al                   ;num of chars in word
letloop:
        mov     dl,[bx+pwords]
        int     21h
        inc     bx
        loop    letloop
        mov     dl,' '
        int     21h                     ;space after word
        dec     bp
        jnz     wordsloop

        mov     dl,8
        int     21h                     ;erase space after last word
        lodsb
        and     al,7
        xor     bx,bx
        mov     bl,al
        mov     dl,[bx+ppunc]
        int     21h
        mov     dl,' '
        int     21h                     ;space after last punc

        dec     di
        test    di,0001                 ;odd number?
        jnz     lineloop                ;not time for line end yet
        mov     dl,13
        int     21h
        mov     dl,10
        int     21h
        cmp     di,0
        jne     lineloop

        and     si,13fh                 ;to keep rands coming from our code
        dec     nstanza
        jnz     stanzaloop

        ret                             ;end program

