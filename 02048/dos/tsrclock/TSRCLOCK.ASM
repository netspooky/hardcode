comment |

 Asemblery - laboratorium
 II rok informatyki

 Marcin Rociek (grupa poniedzialkowa, godz. 8:00)
 "Program rezydentny: wygaszacz ekranu (zegar)"

   Program ten instaluje sie w pamieci i po ustalonym czasie nieaktywnosci
 uzytkownika na ekranie pojawia sie duzy cyfrowy zegar (w trybie tekstowym).
 Monitorowanie aktywnosci sprowadza sie do sprawdzenia stanu klawiatury oraz
 myszy (jesli jest zainstalowana). Czas wyswietlany na ekranie pobierany
 jest bezposrednio z pamieci CMOS.
   Opcje:
      -sXXX ustalenie czasu zwloki na XXX sekund
      -mXXX ustalenie czasu zwloki na XXX minut
      -u    odinstalowanie programu
   Aby program zainstalowac, trzeba podac parametr -s lub -m. Jesli
 program zostanie uruchomiony z jednym z tych parametrow, a byl juz
 wczesniej zainstalowany, czas zwloki zostanie ustawiony zgodnie z nowymi
 parametrami.
   Przykladowo:
     tsrclock -s10
   spowoduje ustawienie czasu zwloki na 10 sekund.
 Do kompilacji uzylem kompilatora tasm 4.0:
   tasm tsrclock /z /m2 /zi
   tlink /t /x tsrclock.obj
 Program *koniecznie* musi byc linkowany jako .COM! (opcja /t)
 (gdyz po prostu dla jego uproszczenia korzystalem z cech plikow .COM,
 tzn cs=ds=es i PSP pod offsetem 0)

|

;Stale zdefiniowane dla zwiekszenia czytelnosci:

;numery uzywanych przerwan
TIMER_INT       = 08h
VIDEO_INT       = 10h
DOS_INT         = 21h
TSR_INT         = 27h
MOUSE_INT       = 33h

;funkcje przerwania 21h (DOS)
DISPLAY_STRING  = 09h
SET_VECTOR      = 25h
GET_VECTOR      = 35h
MEM_ALLOC       = 48h
MEM_FREE        = 49h
EXIT            = 4ch

;funkcje przerwania 33h (mysz)
QUERY_DRIVER    = 00h
DISPLAY_POINTER = 01h
HIDE_POINTER    = 02h
QUERY_POS       = 03h

;kolor zegara
CLOCK_COLOR     = 3

writeln         macro   string
local           mend,mess
                push    ax dx ds
                mov     ah,DISPLAY_STRING
                mov     dx,offset mess
                int     DOS_INT
                jmp     mend
mess            db      string,13,10,'$'
mend:
                pop     ds dx ax
endm

.model tiny
.code
.486
org 100h

start:
                jmp     start_here

;----------------------------------------------------------------------------
;dane czesci rezydentnej

digits          db      ' ÜÜÜÜÜÜÜ '
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      'ÛÛÛÛ ÛÛÛÛ'
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      ' ßßßßßßß '

                db      '   ÜÜÜÜ  '
                db      ' ÜÛÛÛÛÛ  '
                db      '   ÛÛÛÛ  '
                db      '   ÛÛÛÛ  '
                db      '   ßßßß  '

                db      ' ÜÜÜÜÜÜÜ '
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      ' ÜÜÜÜÛÛÛß'
                db      'ÞÛÛÛ     '
                db      'ßßßßßßßßß'

                db      ' ÜÜÜÜÜÜÜ '
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      '    ÛÛÛÛÛ'
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      ' ßßßßßßß '

                db      'ÜÜÜÜ ÜÜÜÜ'
                db      'ÛÛÛÛ ÛÛÛÛ'
                db      'ÞÛÛÛ ÛÛÛÛ'
                db      ' ßßßßÛÛÛÛ'
                db      '     ßßßß'

                db      ' ÜÜÜÜÜÜÜ '
                db      ' ÛÛÛÜÜÜÜ '
                db      '     ÛÛÛÝ'
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      ' ßßßßßßß '

                db      ' ÜÜÜÜÜÜÜ '
                db      'ÞÛÛÛÜÜÜÜ '
                db      'ÛÛÛÛ ÛÛÛÝ'
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      ' ßßßßßßß '

                db      'ÜÜÜÜÜÜÜÜ '
                db      '     ÛÛÛÝ'
                db      '     ÛÛÛÛ'
                db      '     ÛÛÛÛ'
                db      '     ßßßß'

                db      ' ÜÜÜÜÜÜÜ '
                db      'ßÛÛÛÜÛÛÛß'
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      ' ßßßßßßß '

                db      ' ÜÜÜÜÜÜÜ '
                db      'ÞÛÛÛ ÛÛÛÝ'
                db      'ÞÛÛÛ ÛÛÛÛ'
                db      ' ßßßßÛÛÛÝ'
                db      ' ßßßßßßß '

                db      '         '
                db      '   ÞÛÝ   '
                db      '         '
                db      '   ÞÛÝ   '
                db      '         '

buffer          db      4000 dup(?)     ;bufor na zapamietanie ekranu
insaving        db      0               ;czy w trybie wygaszania
original_vector dd      0               ;oryginalny wektor przerwania
licznik         dd      0               ;licznik czasu
limit           dd      0               ;czas po ktorym nastepuje wygaszanie
mouse           db      0               ;czy mysz zainstalowana
mousex          dw      0               ;x myszy
mousey          dw      0               ;y myszy
id              dd      'scrs'          ;identyfikator (musi byc tutaj)

;----------------------------------------------------------------------------
;czesc rezydentna programu:

resident_part:
                pushf
                pusha

                inc     dword ptr cs:[licznik] ;zwiekszenie licznika sekund

                ;czy jakis klawisz jest wcisniety?
                in      al,60h          ;port klawiatury
                and     al,128          ;bit 7 = 0 -> jakis klawisz wcisniety
                jz      reset_counter

                ;sprawdzenie czy ruszono mysza
                cmp     cs:[mouse],0
                jz      no_mouse
                cli
                mov     ax,QUERY_POS
                int     MOUSE_INT
                sti

                mov     ax,cs:[mousex]
                mov     si,cs:[mousey]
                mov     cs:[mousex],cx
                mov     cs:[mousey],dx
                cmp     cx,ax
                jne     reset_counter

                cmp     dx,si
                jne     reset_counter

                cmp     bx,0
                jz      no_activity

reset_counter:
                mov     cs:[licznik],0  ;zeruje licznik
no_activity:
no_mouse:
                ;czy przekroczony zostal limit?
                mov     eax,cs:[limit]
                cmp     cs:[licznik],eax
                jb      time_below_limit

                ;czy aktualnie jestesmy w trybie wygaszania?
                cmp     cs:[insaving],0
                jz      not_in_saving

        ;tryb wygaszania--------------------

                mov     al,4             ;\
                out     70h,al           ; \
                jmp     $+2              ; odczyt godziny z zegara CMOS
                in      al,71h           ;/
                mov     bl,al            ;\
                and     al,15            ; \
                mov     di,(10+80*10)*2  ;
                call    draw_digit       ;  narysowanie godziny
                mov     al,bl            ;
                shr     al,4             ;
                mov     di,(0+80*10)*2   ; /
                call    draw_digit       ;/

                mov     al,10            ;\
                mov     di,(20+80*10)*2  ; narysowanie dwukropka
                call    draw_digit       ;/

                mov     al,2             ;\
                out     70h,al           ; \
                jmp     $+2              ; odczyt minuty z zegara CMOS
                in      al,71h           ;/
                mov     bl,al            ;\
                and     al,15            ; \
                mov     di,(40+80*10)*2  ;
                call    draw_digit       ;  narysowanie minuty
                mov     al,bl            ;
                shr     al,4             ;
                mov     di,(30+80*10)*2  ; /
                call    draw_digit       ;/

                mov     al,10            ;\
                mov     di,(50+80*10)*2  ; narysowanie drugiego dwukropka
                call    draw_digit       ;/

                mov     al,0             ;\
                out     70h,al           ; \
                jmp     $+2              ; odczyt sekundy z zegara CMOS
                in      al,71h           ;/
                mov     bl,al            ;\
                and     al,15            ; \
                mov     di,(70+80*10)*2  ;
                call    draw_digit       ;  narysowanie sekundy
                mov     al,bl            ;
                shr     al,4             ;
                mov     di,(60+80*10)*2  ; /
                call    draw_digit       ;/

                jmp     after_all
not_in_saving:
        ;wejscie w tryb wygaszania-----------

                cmp     cs:[mouse],0
                jz      no_pointer_to_hide
                cli
                mov     ax,HIDE_POINTER
                int     MOUSE_INT
                sti
no_pointer_to_hide:

                push    ds
                push    es
                mov     ax,cs            ;\
                mov     es,ax            ; \
                mov     di,offset buffer ;
                mov     ax,0b800h        ;  skopiowanie zawartosci
                mov     ds,ax            ;  ekranu do bufora
                mov     si,0             ;
                mov     cx,80*25*2       ; /
                rep     movsb            ;/

                mov     ax,ds            ;\
                mov     es,ax            ; \
                mov     di,0             ;  wyczyszczenie
                mov     cx,80*25*2       ;  zawartosci ekranu
                mov     al,0             ; /
                rep     stosb            ;/

                pop     es
                pop     ds

                mov     cs:[insaving],1  ;ustawienie zmiennej logicznej

                jmp     after_all

time_below_limit:
                cmp     cs:[insaving],0
                jz      after_all

        ;wyjscie z trybu wygaszania----------

                push    ds
                push    es
                mov     ax,cs            ;\
                mov     ds,ax            ; \
                mov     si,offset buffer ;
                mov     ax,0b800h        ;  skopiowanie zawartosci
                mov     es,ax            ;  bufora na ekran
                mov     di,0             ;
                mov     cx,80*25*2       ; /
                rep     movsb            ;/
                pop     es
                pop     ds

                cmp     cs:[mouse],0
                jz      no_pointer_to_display
                cli
                mov     ax,DISPLAY_POINTER
                int     MOUSE_INT
                sti
no_pointer_to_display:

                mov     cs:[insaving],0  ;wyzerowanie zmiennej logicznej

after_all:
                popa
                popf

                ;skok do oryginalnej procedury obslugi przerwania
                jmp     dword ptr cs:[original_vector]

;----------------------------------------------------------------------------
;procedura rysujaca cyfre
;wejscie: al - cyfra (0-9) (10=dwukropek)
;         di - docelowy offset na ekranie
draw_digit:
                push    es bx cx dx di
                mov     bl,5*9          ;tyle bajtow zajmuje jedna cyfra
                mul     bl
                mov     bx,ax
                mov     ax,0b800h       ;segment pamieci ekranu
                mov     es,ax
                mov     ah,CLOCK_COLOR  ;atrybut cyfry
                mov     dx,5            ;ilosc wierszy cyfry
yloop:          mov     cx,9            ;ilosc kolumn cyfry
xloop:          mov     al,cs:[digits+bx]
                stosw                   ;narysowanie fragmentu cyfry
                inc     bx
                loop    xloop
                add     di,(80-9)*2     ;przejscie do nastepnego wiersza
                dec     dx
                jnz     yloop
                pop     di dx cx bx es
                ret

; koniec czesci rezydentnej
;----------------------------------------------------------------------------

;----------------------------------------------------------------------------
;program glowny

start_here:

                writeln
                writeln 'Program rezydentny: wygaszacz ekranu (zegar)'
                writeln 'autor: Marcin Rociek, II rok informatyki'
                writeln

                mov     ax,QUERY_DRIVER
                int     MOUSE_INT
                cmp     ax,0
                jz      mouse_not_installed
                mov     [mouse],1
mouse_not_installed:

                mov     al,'u'
                call    scan_params
                jc      deinstalling

                mov     al,'m'
                call    scan_params
                jc      installing

                mov     al,'s'
                call    scan_params
                jc      installing

        ;nie podano zadnych opcji-----------

                call    is_installed
                jc      yes
                writeln 'aktualnie program nie jest zainstalowany'
                jmp     show_options
yes:
                writeln 'aktualnie program jest zainstalowany'
show_options:
                writeln
                writeln 'opcje: -mXXX czas zwloki w minutach'
                writeln '       -sXXX czas zwloki w sekundach'
                writeln '       -u    odinstalowanie'

                mov     al,1
                jmp     exiting

        ;deinstalacja programu--------------

deinstalling:
                call    is_installed
                jc      ok_deinstalling

                writeln 'program nie jest zainstalowany!'
                mov     al,2
                jmp     exiting

ok_deinstalling:
                call    deinstall

                writeln 'program zostal odinstalowany'
                mov     al,0
                jmp     exiting

        ;instalacja programu----------------

v18             dd      18.206497192e00 ;czestotliwosc zegara
v60             dd      60              ;ilosc sekund w minucie
temp            dd      0               ;pomocnicza zm. do komunikacji z FPU

installing:
                call    atoi
                jnc     proper_number
                writeln 'nieprawidlowo podany czas zwloki!'
                jmp     show_options
proper_number:
                mov     [temp],eax
                finit
                fild    [temp]
                fmul    [v18]
                cmp     byte ptr ds:[di-1],'m'
                jne     not_minutes
                fimul   [v60]
not_minutes:
                fistp   [temp]

                mov     eax,[temp]
                mov     [limit],eax

                call    is_installed
                jnc     ok_installing

                writeln 'program byl juz zainstalowany'

                call    deinstall
                call    install

                writeln 'czas zwloki zostal zmieniony'

                jmp     tsring
ok_installing:
                call    install

                writeln 'program zostal zainstalowany'
tsring:
                mov     dx,offset start_here
                int     TSR_INT

        ;wyjscie z programu-----------------
exiting:
                mov     ah,EXIT
                int     DOS_INT

;----------------------------------------------------------------------------
;procedura skanujaca parametry programu
;wejscie: al - znak ktorego szukamy
;wyjscie: CF=0 nie znaleziono
;         CF=1 znaleziono
;              di - offset wskazujacy tuz za znaleziony znak
scan_params:
                push    cx bx
                mov     cl,ds:[80h]     ;dlugosc lancucha z parametrami
                cmp     cl,0
                jz      char_not_found
                mov     di,81h          ;poczatek lancucha z parametrami
scan_loop:      mov     bl,[di]         ;znak z parametrow
                inc     di
                cmp     bl,al
                je      char_found
                dec     cl
                jnz     scan_loop
char_not_found:
                clc
                jmp     get_out
char_found:
                stc
get_out:
                pop     bx cx
                ret

;----------------------------------------------------------------------------
;procedura zamieniajaca ciag ascii oznaczajacy liczbe na postac binarna
;wejscie: di - offset wskazujacy na ciag
;wyjscie: CF=1 blad
;         CF=0 ok
;              eax - liczba w postaci binarnej
atoi:
                push    bx ecx edx esi
                mov     bx,di           ;bx wskazuje na pierwsza cyfre
prepare_loop:
                mov     al,[bx]
                cmp     al,0
                je      end_of_number
                cmp     al,' '
                je      end_of_number
                cmp     al,13
                je      end_of_number
                inc     bx
                jmp     prepare_loop
end_of_number:  dec     bx              ;teraz bx wskazuje na ostatnia cyfre

                mov     esi,0           ;w esi bedzie suma
                mov     ecx,1           ;mnoznik
convert_loop:
                movzx   eax,byte ptr [bx]
                sub     al,'0'
                cmp     al,9
                jbe     ok_thats_digit
                stc
                jmp     exit_now
ok_thats_digit:
                mul     ecx
                add     esi,eax         ;dodaje do sumy
                imul    ecx,10
                dec     bx
                cmp     bx,di
                jae     convert_loop
                mov     eax,esi
                clc
exit_now:
                pop     esi edx ecx bx

                ret

;----------------------------------------------------------------------------
;procedura sprawdzajaca, czy ten program jest juz w pamieci
;wyjscie: CF=1 tak
;         CF=0 nie
is_installed:
                push    es bx

                ;odczytanie wektora przerwania zegarowego
                mov     ah,GET_VECTOR
                mov     al,TIMER_INT
                int     DOS_INT

                ;sprawdzenie ciagu charakterystyczego dla tego programu
                clc
                cmp     dword ptr es:[bx-4],'scrs'
                jne     not_installed
                stc
not_installed:
                pop     bx es
                ret

;----------------------------------------------------------------------------
;procedura instalujaca program (i zwalniajaca pamiec srodowiska)
install:
                push    es ax bx dx

                ;odczytanie wektora przerwania zegarowego
                mov     ah,GET_VECTOR
                mov     al,TIMER_INT
                int     DOS_INT

                ;zapisanie go w danych czesci rezydentnej
                mov     word ptr cs:[original_vector],bx
                mov     word ptr cs:[original_vector+2],es

                ;ustawienie naszego wektora przerwania zegarowego
                mov     ah,SET_VECTOR
                mov     al,TIMER_INT
                mov     dx,offset resident_part
                int     DOS_INT

                ;zwolnienie segmentu srodowiska (environment)
                mov     ax,word ptr ds:[2ch]  ;numer segmentu srodowiska
                mov     es,ax
                mov     ah,MEM_FREE
                int     DOS_INT

                pop     dx bx ax es
                ret

;----------------------------------------------------------------------------
;procedura deinstalujaca program
deinstall:
                push    ds es ax bx dx

                ;odczytanie wektora przerwania zegarowego
                mov     ah,GET_VECTOR
                mov     al,TIMER_INT
                int     DOS_INT

                ;odtworzenie oryginalnego wektora
                mov     dx,word ptr es:[original_vector]
                mov     ax,word ptr es:[original_vector+2]
                mov     ds,ax
                mov     ah,SET_VECTOR
                mov     al,TIMER_INT
                int     DOS_INT

                ;usuniecie z pamieci naszego programu obslugi przerwania
                mov     ah,MEM_FREE
                int     DOS_INT

                pop     dx bx ax es ds
                ret

;----------------------------------------------------------------------------

end start
