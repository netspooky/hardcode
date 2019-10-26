; +----------------------------------+
; |  gal.anonim's 2nd trial in 256B  |
; +----------------------------------+
; |  copyleft to Llama&Llama prods.  |
; +----------------------------------+

; revision 1.1 - bledy moga jeszcze byc :)

IDEAL
p386
MODEL TINY

MACRO salc                      ; male makro robiace salc
    db 0D6h
EndM

DATASEG

; particles - jest ich 12, kazdy ma pozycje y (top-) i czas
; z tym, ze najpierw idzie 12 czasow, a potem 12 ypos :)

 particles dw 12*2 dup (?)

; virtual screen - zmiescil sie w segmencie kodu - to dobrze :)
; dzieki temu nie korzystamy z dodatkowego segmentu i unikamy wymiany
; ds z es przy kopiowaniu

 screen db 320*202 dup (?)

; rozne dodatkowe pierdoly - w tym wypadku adress generatora znakow

 add_data db ?

CODESEG
org 100h

Start:

    mov al,13h                  ; najpierw tryb 13h (ah=0 z zalozenia)
    int 10h

    mov dx,3C8h                 ; teraz paleta
    salc
    out dx,al
    inc dx
    mov si,offset palette
    mov cl,6*3
    rep outsb

    mov di,offset particles

    mov cl,12                   ; random init 
ParLoop:
    xor ax,dx                   ; prosty generator randomowy (szybko sie
    ror ax,3                    ; wyczerpuje :)
    stosw
    loop ParLoop


    mov ax,1130h                ; pobieramy addy matrycy znakow 8x8
    mov bh,03h
    int 10h                     ; zwraca w es:bp

    mov [word ptr add_data],bp
    push es
    pop gs                      ; gs = segment generatora znakow (?)


MainLoop:
    push ds
    pop es                      ; i juz w es mamy segment virtscreen :)

    mov di,offset screen
    push di                     ; zostawiamy sobie te wartosc na pozniej 1bajt
    mov ch,7Dh
    xor ax,ax
    rep stosb

;    mov ch,7Dh
;    mov al,3
;    rep stosb

; jak tu do cholery wcisnac te szachownice?
; 
; to jest raczej mala (i kiepska) imitacja tego co tu mialo byc :)
; a miala byc szachownica w perspektywie.
    
    mov cl,64h
@TerraGen1:
    mov bx,140h
@TerraGen2:
    mov dx,cx
    and dx,16
    add dx,cx
    add dx,bx
    mov al,3
    test dl,16
    jz @TerraGen3
    add al,2
@TerraGen3:
    stosb
    dec bx
    jnz @TerraGen2
    loop @TerraGen1


    mov al,12                   ; ilosc powtorzen
    mov di,offset screen+48040  ; offset poczatkowy
    mov si,offset particles
@TextLoop:

    fild [word ptr si]
    fidiv [word ptr Palette+8]  ; size hack - odpowiednia wartosc :)
    fsin
    fabs
    fimul [word ptr DrawZnak+5] ; tu jeszcze jeden
    fistp [word ptr si+24]
    inc [word ptr si]
; !!! UWAGA: wszelkie zmiany w kodzie, prowadzace do zmiany offsetow
; wartosci uzywanych w powyzszej sekwencji powoduje niezamierzone
; efekty (do powieszenia sie kompa wlacznie)

; =================

DrawZnak:                       ; w bx = nr znaku di = offset poczatkowy
    push si
    push bx
    mov bp,[word ptr si+24]     ; odczytujemy pozycje
    sar bp,2                    ; i dzielimy /4
    mov dx,bp
    imul bp,bp,320              ; offset znaku  (y/4)*320
    mov si,di
    add si,8
    sar dx,2
    imul dx,dx,319              ; offset cienia (y/16)*319
    add si,dx
    mov bl,[byte ptr tekst+bx]  ; znak do narysowania
    shl bx,3
    add bx,[word ptr add_data]  ; i mamy bx = gen_znakow + tekst[bx] :)
    mov dx,8
@LoopY:
    mov cl,8
@LoopX:
    rol [byte ptr gs:bx],1      ; fajny hack ;), przynajmniej mnie sie podoba
    jnc @Skip
    dec [byte ptr si]
    mov [byte ptr es:di+bp],1
@Skip:
    inc bp
    inc si                     
    loop @LoopX
    inc bx
    add bp,312
    add si,311
    dec dx
    jnz @LoopY
    pop bx
    pop si

; =================

    inc bx
    inc si                      ; 2x inc si = 2 bajty, 1x add si,2 = 3 bajty
    inc si
    add di,20
    dec ax
    jnz @TextLoop



    push 0A000h
    pop es

    mov dx,3dah
@2: in al,dx
    test al,8
    jz @2

;    mov si,offset screen       ; tu bylyby 3 bajty
    pop si                      ; a jest 1 :) [+tamten push di], zysk: 3-2=1
    xor di,di
    mov ch,7Dh
    rep movsw


    in al,60h                   ; to jest hack, ktory powoduje, ze trzeba
    das                         ; umiejetnie program uruchomic ;)
    jc MainLoop

    mov al,03h
    int 10h


    ret                         ; That's all folks!
 
 palette db 0,2,37,     \       ;0 tlo                          000
            63,63,0,    \       ;1 zolty = znak                 001
            0,16,44,    \       ;2 niebieski - 1 = cien         010
            0,22,63,    \       ;3 niebieski                    011
            33,33,33,   \       ;4 szary - 1 = cien             100
            52,52,52            ;5 szary                        101

 tekst db 'ABSTRACT2002'

; _c dw -512                    ; tu widzimy skamieliny po stalych ;)

END Start
