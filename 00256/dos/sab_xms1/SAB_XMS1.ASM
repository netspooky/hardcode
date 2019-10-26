.MODEL TINY
.CODE
.STARTUP
.386

;
; ..TRICKY CODING..
; Hmm... omdat we geen datasegment hebben, kunnen we lekker DS gebruiken
; Omdat we ook geen stack hebben, kunnen we ook BP gebruiken
;


    mov al,13h
    int 10h

;
;   ff het palette goed zetten (blauw)
;   groen kost 2 bytes minder, maar dan is het veel te duidelijk te zien
;   dat het effect niet helemaal klopt
;

    mov cl,128
    mov dx,3c8h
@setpal2:
    mov al,cl
    out dx,al   ;schrijf index
    inc dx
    out dx,al
    out dx,al
    mov al,63
    out dx,al
    dec dx
    dec cx
    cmp cx,63
    ja @setpal2

@setpal:
    mov al,cl
    out dx,ax   ;schrijf index+rood (altijd 0)
    inc dx
    mov al,0
    out dx,al
    mov al,cl
    out dx,al
    dec dx
    loop @setpal

;
; gebruik een buffer dat begint 1000h nadat de code begint (de code kan dus
; zat 4k worden, iets wat het toch niet wordt in een 256-byte-je
; een 2e buffer begint 2000h na de eerste
;

    mov bx,cs
    add bx,1000h
    mov es,bx

    dec cx          ; gelijk de buffer ff schoonmaken
    rep stosb       ; cx is nog 0, en -1 = 0ffffh
                    ; het maakt niet uit waar di op staat, omdat
                    ; hij toch het hele segment pakt (en di wrapt wel rond)

    mov ds,bx
    add bx,2000h
    mov es,bx

    xor bp,bp        ; bp = y van het "balletje"

;
; hier begint de hoofdlus
;

@loop:
        ;
        ; ff de onderste lijn(en) gaan randomizen (in de bron-buffer)
        ;

        mov cx,0ffh

    @randfire:
        xor ah,ah
        in  al,40h
        mov bx,ax
        in  al,40h
        add bx,ax
        mov [bx+64000-320-((320-512)/2)],cl
        loop @randfire
        xor bh,bh
        add bx,32
        mov fs,bx               ;bewaar random waarde

        ;
        ; ff de bron naar de doelbuffer kopieren met het vuur effect
        ; we gebruiken hier alleen AL, omdat er pas een overflow komt
        ; na vier keer optellen. De maximale kleur is 63, en 63*4=252
        ; (daarna zit je over de 255, en dus is er kans op een overflow).
        ; We hoeven dus pas na de 4e keer optellen(4 waardes opgeteld in AL)
        ; te controleren of al buiten het bereik valt.
        ; Hiervoor is een handige instructie, namelijk optellen met carry.
        ; Die carry moeten we wel bij AH optellen, en niet AL, anders konden
        ; we meteen met een carry gaan optellen.
        ; Daarna delen we door 8 (shr 3) en maskeren we alle waardes boven
        ; de 63 uit (vandaar die maximale kleur van 63 =).
        ; we gooien de nieuwe kleur in de doelbuffer en we gaan verder
        ;

        mov bx,200*320
        mov si,200              ; si = y
        @lusje2:
            mov di,320          ; di = x
            @xlusje:
                mov ax,di
                mov dx,fs
                sub ax,dx
                jns @noaxS
                    neg ax
                @noaxS:
                mul eax
                mov cx,si
                sub cx,bp
                jns short @nocxS
                    neg cx
                @nocxS:
                xchg eax,ecx
                mul eax
                add ecx,eax
                jnz short @nocxZ
                    inc cx
                @nocxZ:
                mov ax,03ffh
                xor edx,edx
                div ecx
                cmp ax,127
                jb short @bla
                    mov al,127
                @bla:
                mov es:[bx],al

                dec bx
                dec di
                jnz @xlusje
            dec si
            jnz @lusje2

        inc bp              ; is eigenlijk de y waarde van de "bal"
        and bp,0ffh

        xor bx,bx
        mov cx,64000

        @lusje:
            xor ah,ah
            mov al,ds:[bx+1]
            add al,ds:[bx-1]
            add al,ds:[bx+318]
            add al,ds:[bx+319]
            adc ah,0
            add al,ds:[bx+321]
            adc ah,0
            add al,ds:[bx+322]
            adc ah,0
            add al,ds:[bx+639]
            adc ah,0
            add al,ds:[bx+641]
            adc ah,0
            shr ax,3
            cmp al,es:[bx]
            jb short @noswap
              mov es:[bx],al
            @noswap:
            inc bx
            loop @lusje

        ;
        ; Nu gaan we ES en DS ff omkeren, zodat de volgende keer
        ; het doelbuffer het bronbuffer is en andersom
        ; we moeten zowieso even ES gebruiken, dus we wachten ff met
        ; het poppen van ES totdat we ES niet meer nodig hebben in de
        ; onderstaande lus
        ;

        push ds
        push es
        pop ds
    
        mov cx,64000-320*6      ; we willen de onderste 4 lijnen niet zien
                                ; die zien er niet uit =)
        mov ax,0a000h
        mov es,ax
        mov si,320
                                ; XOR DI,DI hoeft niet, DI is nog steeds 0
                                ; XOS SI,SI hoeft ook niet, zelfde
        rep movsb               ; ff het buffer op het beeldscherm gooien
        pop es                  ; zooo, nu kunnen we dat ding weer poppen
    
        in  al,60h              ; is er op een toets gedrukt?
        cmp al,80h
        ja  @loop               ; zoja, stoppen

    mov ax,3
    int 10h

    ret                         ; ret ipv .EXIT, dat scheelt 3 bytes
END
