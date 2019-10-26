;KHAV home page
;http://khav.w.interia.pl

;Gra - UFO INVASION

assume cs:kod, ds:dane
dane segment
  ile_gwiazd equ 150
  licznik1 dw 100   ;czas pokazywania "BOOM" po zniszczeniu ufo
  licznik2 dw 100
  licznik3 dw 100
  czy_alt dw 0      ;jaki klawisz nacisniety Alt/Ctrl
  czy_ctrl dw 0
  ufo1_sila db 40   ;ile razy trzeba trafic w ufo
  ufo2_sila db 30
  ufo3_sila db 20
  liczba_ufo db 3
  szybkosc_pocisk dw 5    ;szybkosc pocisku
  szybkosc_pocisk1 dw 2   ;szybkosc rakiety
  ufo1_liczba dw 2      ;szybkosc i kierunek ufo
  ufo2_liczba dw 2
  ufo3_liczba dw -2
  boom1_pozycja_x dw 100   ;wspolrzedne "BOOM"
  boom1_pozycja_y dw 100
  boom2_pozycja_x dw 100
  boom2_pozycja_y dw 100
  boom3_pozycja_x dw 100
  boom3_pozycja_y dw 100
  czy_boom1 dw 0        ;sprawdza czy zniszczono ufo
  czy_boom2 dw 0
  czy_boom3 dw 0
  czy_pocisk dw 0      ;sprawdza czy byl wcisniety Alt/Ctrl
  czy_ufo1 dw 0      ;sprawdza czy zniszczono ufo
  czy_ufo2 dw 0
  czy_ufo3 dw 0
  samolot_pozycja_x dw 150     ;wspolrzedne samolotu
  samolot_pozycja_y dw 180
  ufo1_pozycja_x dw 150
  ufo1_pozycja_y dw 0       ;wspolrzedne ufo
  ufo2_pozycja_x dw 0
  ufo2_pozycja_y dw 30
  ufo3_pozycja_x dw 250
  ufo3_pozycja_y dw 60
  pocisk_pozycja_x dw ?
  pocisk_pozycja_y dw ?    ;wspolrzedne pocisku
  pocisk1_pozycja_x dw ?
  pocisk1_pozycja_y dw ?
  napis_powitalny db 5 dup(13,10),12 dup(' '),218,196,196,196,196,196,196,196,196,196,196,196,196,191
                  db 13,10,12 dup(' '),179,'UFO INVASION',179
                  db 13,10,12 dup(' '),192,196,196,196,196,196,196,196,196,196,196,196,196,217,'$'
  napis_info db 13,14 dup(' '),'Sterowanie:'
             db 13,10,14 dup(' '),196,196,196,196,196,196,196,196,196,196,196
             db 3 dup(13,10),10 dup(' '),'w lewo   = lewy Shift'
             db 2 dup(13,10),10 dup(' '),'w prawo  = prawy Shift'
             db 2 dup(13,10),11 dup(' '),'strzal  = Ctrl'
             db 2 dup(13,10),10 dup(' '),'rakieta  = Alt$'
  napis_koniec db 13,14 dup(' '),218,196,196,196,196,196,196,196,196,196,196,191
                  db 13,10,14 dup(' '),179,'PRZEGRALES',179
                  db 13,10,14 dup(' '),192,196,196,196,196,196,196,196,196,196,196,217,'$'
  napis_wygrana db 13,14 dup(' '),218,196,196,196,196,196,196,196,196,196,196,191
                  db 13,10,14 dup(' '),179,'ZWYCIESTWO',179
                  db 13,10,14 dup(' '),192,196,196,196,196,196,196,196,196,196,196,217,'$'
  pocisk  db 0,10,0
          db 0,10,0
          db 0,10,0    ;pocisk
          db 0,10,0
          db 0,10,0
          db 0,0,0
          db 0,0,0
          db 0,0,0
          db 0,0,0
          db 0,0,0
  pocisk1 db 0,7,0
          db 0,7,0
          db 7,7,7
          db 0,7,0
          db 0,7,0
          db 0,7,0    ;rakieta
          db 7,7,7
          db 7,7,7
          db 0,4,0
          db 0,4,0
     boom db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 4,4,4,0,0,0,4,4,0,0,0,4,4,0,0,4,0,0,0,4
          db 4,0,0,4,0,4,0,0,4,0,4,0,0,4,0,4,4,0,4,4
          db 4,4,4,0,0,4,0,0,4,0,4,0,0,4,0,4,0,4,0,4
          db 4,0,0,4,0,4,0,0,4,0,4,0,0,4,0,4,0,0,0,4
          db 4,0,0,4,0,4,0,0,4,0,4,0,0,4,0,4,0,0,0,4  ;po zniszczeniu ufo
          db 4,4,4,0,0,0,4,4,0,0,0,4,4,0,0,4,0,0,0,4  ;to sie pojawia
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

  samolot db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,1,7,7,1,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,1,7,7,1,0,0,0,0,0,0,0,0
          db 0,0,0,0,7,0,0,1,1,7,7,1,1,0,0,7,0,0,0,0
          db 0,0,0,0,7,0,1,1,1,1,1,1,1,1,0,7,0,0,0,0
          db 0,0,0,0,7,1,1,1,1,1,1,1,1,1,1,7,0,0,0,0
          db 0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
          db 0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
          db 0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0
          db 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0
          db 0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0


     ufo1 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,4,4,4,4,4,4,4,4,4,4,0,0,0,0,0
          db 0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0
          db 0,0,0,4,4,0,0,0,0,0,0,0,0,0,0,4,4,0,0,0
          db 0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0,0
          db 7,4,7,4,7,4,7,4,7,4,7,4,7,4,7,4,7,4,7,4
          db 4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4
          db 0,0,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,0,0
          db 0,0,0,0,4,4,4,4,4,4,4,4,4,4,4,4,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,7,0,0,7,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,7,0,0,0,0,7,0,0,0,0,0,0,0
          db 0,0,0,0,0,7,7,0,0,0,0,0,0,7,7,0,0,0,0,0

     ufo2 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,3,3,3,3,3,3,3,3,3,3,0,0,0,0,0
          db 0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0
          db 0,0,0,3,3,0,0,0,0,0,0,0,0,0,0,3,3,0,0,0
          db 0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0
          db 0,3,0,3,0,3,0,3,0,3,0,3,0,3,0,3,0,3,0,3
          db 3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3
          db 0,0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0
          db 0,0,0,0,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,7,0,0,7,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,7,0,0,0,0,7,0,0,0,0,0,0,0
          db 0,0,0,0,0,7,7,0,0,0,0,0,0,7,7,0,0,0,0,0

     ufo3 db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,8,8,8,8,8,8,8,8,8,8,0,0,0,0,0
          db 0,0,0,0,8,0,0,0,0,0,0,0,0,0,0,8,0,0,0,0
          db 0,0,0,8,8,0,0,0,0,0,0,0,0,0,0,8,8,0,0,0
          db 0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0
          db 7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8,7,8
          db 8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8
          db 0,0,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,0,0
          db 0,0,0,0,8,8,8,8,8,8,8,8,8,8,8,8,0,0,0,0
          db 0,0,0,0,0,0,0,0,0,7,7,0,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,0,7,0,0,7,0,0,0,0,0,0,0,0
          db 0,0,0,0,0,0,0,7,0,0,0,0,7,0,0,0,0,0,0,0
          db 0,0,0,0,0,7,7,0,0,0,0,0,0,7,7,0,0,0,0,0


dane ends
kod segment
.386


;============================
gwiazdy:
        mov dx, 0a000h
        mov es, dx
        mov dx, seg ofst
        mov ds, dx
        lea si, ofst
        xor eax, eax
        mov cx, ile_gwiazd
czystar:
        lodsw
        mov es:[eax], byte ptr 0
loop czystar
        mov dx, seg random
        mov ds, dx
        lea si, random
        mov cx, ile_gwiazd/3
ruszaj_gwiazdy:
        add ds:[si],word ptr 960
        add si, 2
        add ds:[si],word ptr 640
        add si, 2
        add ds:[si],word ptr 320
        add si, 2
loop ruszaj_gwiazdy
        mov dx, seg ofst
        mov fs, dx
        lea bp, ofst
        mov dx, seg random
        mov ds, dx
        lea si, random
        xor eax, eax
        mov cx, ile_gwiazd/3
rysuj_gwiazdy:
        lodsw
        mov es:[eax], byte ptr 31
        mov fs:[bp], ax
        add bp, 2
        lodsw
        mov es:[eax], byte ptr 25
        mov fs:[bp], ax
        add bp,2
        lodsw
        mov es:[eax], byte ptr 20
        mov fs:[bp], ax
        add bp, 2
loop rysuj_gwiazdy
ret



;========================================
boom1_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, boom1_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, boom1_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;pozycja na ekranie
ret


;=======================================
rysuj_boom1:
        call boom1_pozycja
        lea si, boom
        mov cx, 17
petla_boom1_2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_boom1_2
ret



;========================================
boom2_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, boom2_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, boom2_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;pozycja na ekranie
ret


;=======================================
rysuj_boom2:
        call boom2_pozycja
        lea si, boom
        mov cx, 17
petla_boom2_2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_boom2_2
ret


;========================================
boom3_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, boom3_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, boom3_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;pozycja na ekranie
ret


;=======================================
rysuj_boom3:
        call boom3_pozycja
        lea si, boom
        mov cx, 17
petla_boom3_2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_boom3_2
ret





;=======================================
pocisk_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, pocisk_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, pocisk_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;pozycja na ekranie
ret


;=======================================
czysc_pocisk:
        call pocisk_pozycja
        mov cx, 10
        ;w zaleznosci od wielkosci objektu
        ;dobieramy licznik cx
petla_pocisk_1:
        push cx
        push di
        ;cx razy wykonamy stosb =
        ;wysylanie bajtu do pamieci
        mov cx, 3
        ;wybieramy czarny kolor
        ;do zamazania
        mov ax, 0
        rep stosb
        pop di
        pop cx
        add di, 320
loop petla_pocisk_1
ret


;=======================================
rysuj_pocisk:
        call pocisk_pozycja
        lea si, pocisk
        mov cx, 10
petla_pocisk_2:
        push cx
        push di
        mov cx, 3
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_pocisk_2
ret


;=======================================
poruszaj_pocisk:
        push bx
        mov bx, szybkosc_pocisk
        sub pocisk_pozycja_y, bx
        pop bx
ret



;=======================================
pocisk1_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, pocisk_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, pocisk_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;pozycja na ekranie
ret


;=======================================
czysc_pocisk1:
        call pocisk1_pozycja
        mov cx, 10
        ;w zaleznosci od wielkosci objektu
        ;dobieramy licznik cx
petla_pocisk1_1:
        push cx
        push di
        ;cx razy wykonamy stosb =
        ;wysylanie bajtu do pamieci
        mov cx, 3
        ;wybieramy czarny kolor
        ;do zamazania
        mov ax, 0
        rep stosb
        pop di
        pop cx
        add di, 320
loop petla_pocisk1_1
ret


;=======================================
rysuj_pocisk1:
        call pocisk1_pozycja
        lea si, pocisk1
        mov cx, 10
petla_pocisk1_2:
        push cx
        push di
        mov cx, 3
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_pocisk1_2
ret


;=======================================
poruszaj_pocisk1:
        push bx
        mov bx, szybkosc_pocisk1
        sub pocisk_pozycja_y, bx
        pop bx
ret



;========================================
ufo1_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, ufo1_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, ufo1_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;pozycja na ekranie
ret


;=======================================
czysc_ufo1:
        call ufo1_pozycja
        mov cx, 17
        ;w zaleznosci od wielkosci objektu
        ;dobieramy licznik cx
petla_ufo1_1:
        push cx
        push di
        ;cx razy wykonamy stosb =
        ;wysylanie bajtu do pamieci
        mov cx, 20
        ;wybieramy czarny kolor
        ;do zamazania
        mov ax, 0
        rep stosb
        pop di
        pop cx
        add di, 320
loop petla_ufo1_1
ret


;=======================================
rysuj_ufo1:
        call ufo1_pozycja
        lea si, ufo1
        mov cx, 17
petla_ufo1_2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_ufo1_2
ret



;=======================================
ufo2_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, ufo2_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, ufo2_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;ufo1_pozycja na ekranie
ret


;=======================================
czysc_ufo2:
        call ufo2_pozycja
        mov cx, 17
        ;w zaleznosci od wielkosci objektu
        ;dobieramy licznik cx
petla_ufo2_1:
        push cx
        push di
        ;cx razy wykonamy stosb =
        ;wysylanie bajtu do pamieci
        mov cx, 20
        ;wybieramy czarny kolor
        ;do zamazania
        mov ax, 0
        rep stosb
        pop di
        pop cx
        add di, 320
loop petla_ufo2_1
ret



;=======================================
rysuj_ufo2:
        call ufo2_pozycja
        lea si, ufo2
        mov cx, 17
petla_ufo2_2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_ufo2_2
ret



;=======================================
ufo3_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, ufo3_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, ufo3_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;ufo1_pozycja na ekranie
ret


;=======================================
czysc_ufo3:
        call ufo3_pozycja
        mov cx, 17
        ;w zaleznosci od wielkosci objektu
        ;dobieramy licznik cx
petla_ufo3_1:
        push cx
        push di
        ;cx razy wykonamy stosb =
        ;wysylanie bajtu do pamieci
        mov cx, 20
        ;wybieramy czarny kolor
        ;do zamazania
        mov ax, 0
        rep stosb
        pop di
        pop cx
        add di, 320
loop petla_ufo3_1
ret



;=======================================
rysuj_ufo3:
        call ufo3_pozycja
        lea si, ufo3
        mov cx, 17
petla_ufo3_2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla_ufo3_2
ret





;=======================================
samolot_pozycja:
        ;mnozenie przez 320
        ;320=2^8+2^6
        ;ustala polozenie
        mov ax, samolot_pozycja_y
        mov bx, ax
        shl ax, 8
        shl bx, 6
        add ax, bx
        add ax, samolot_pozycja_x
        mov di, ax
        ;do di zapisana zostaje
        ;samolot_pozycja na ekranie
ret


;=======================================
czysc_samolot:
        call samolot_pozycja
        mov cx, 20
        ;w zaleznosci od wielkosci objektu
        ;dobieramy licznik cx
petla1:
        push cx
        push di
        ;cx razy wykonamy stosb =
        ;wysylanie bajtu do pamieci
        mov cx, 20
        ;wybieramy czarny kolor
        ;do zamazania
        mov ax, 0
        rep stosb
        pop di
        pop cx
        add di, 320
loop petla1
ret




;=======================================
rysuj_samolot:
        call samolot_pozycja
        lea si, samolot
        mov cx, 20
petla2:
        push cx
        push di
        mov cx, 20
        rep movsb
        pop di
        pop cx
        add di, 320
loop petla2
ret



;=======================================
samolot_w_lewo:
        push bx
        mov bx,3
        cmp samolot_pozycja_x, 4
        jb nic1
        sub samolot_pozycja_x, bx
        nic1:
        pop bx
ret


;=======================================
samolot_w_prawo:
        push bx
        mov bx,3
        cmp samolot_pozycja_x, 296
        ja nic2
        add samolot_pozycja_x, bx
        nic2:
        pop bx
ret



;=======================================
ufo1_zmien_kierunek:
        neg cx
        add ufo1_pozycja_y, 10
        jmp dalej1_ufo


;=======================================
ufo2_zmien_kierunek:
        neg cx
        add ufo2_pozycja_y, 10
        jmp dalej2_ufo


;=======================================
ufo3_zmien_kierunek:
        neg cx
        add ufo3_pozycja_y, 10
        jmp dalej3_ufo


;=======================================
poruszaj_ufo1:
        push cx
        mov cx, ufo1_liczba
        add ufo1_pozycja_x, cx
        cmp ufo1_pozycja_x, 0
        jz ufo1_zmien_kierunek
        cmp ufo1_pozycja_x, 300
        jz ufo1_zmien_kierunek
        dalej1_ufo:
        mov ufo1_liczba, cx
        pop cx
ret

;=======================================
poruszaj_ufo2:
        push cx
        mov cx, ufo2_liczba
        add ufo2_pozycja_x, cx
        cmp ufo2_pozycja_x, 0
        jz ufo2_zmien_kierunek
        cmp ufo2_pozycja_x, 300
        jz ufo2_zmien_kierunek
        dalej2_ufo:
        mov ufo2_liczba, cx
        pop cx
ret

;=======================================
poruszaj_ufo3:
        push cx
        mov cx, ufo3_liczba
        add ufo3_pozycja_x, cx
        cmp ufo3_pozycja_x, 0
        jz ufo3_zmien_kierunek
        cmp ufo3_pozycja_x, 300
        jz ufo3_zmien_kierunek
        dalej3_ufo:
        mov ufo3_liczba, cx
        pop cx
ret




;=======================================
poruszaj_samolot:
        mov ah, 2
        int 16h
;w rej. al mamy bajt, ktorego poszczegolne
;bity ukazuja stan odpowiednich klawiszy
        push ax
        push ax
        push ax
        push ax
        ;ALT
        pop ax
        and al,8
        jnz takk
        jmp dalejk
        takk:
        push dx
        mov dx, 1
        mov czy_alt, dx
        pop dx
        call strzal
        dalejk:
        ;CTRL
        pop ax
        and al,4
        jnz tak1
        jmp dalej1
        tak1:
        push dx
        mov dx, 1
        mov czy_ctrl, dx
        pop dx
        call strzal
        dalej1:
        ;lewy SHIFT
        pop ax
        and al,2
        jnz tak2
        jmp dalej2
        tak2: call samolot_w_lewo
        dalej2:
        ;prawy SHIFT
        pop ax
        and al,1
        jnz tak3
        jmp dalej3
        tak3: call samolot_w_prawo
        dalej3:
ret


;========================================
czysc_alt_ctrl:
        push dx
        mov dx, 0
        mov czy_alt, dx
        mov czy_ctrl, dx
        pop dx
ret



;=======================================
czy_esc:
        in al,60H
        cmp al,1
        jne petla
        jmp koniec
ret


;=======================================
delay:
        mov ah, 86H
        mov dx, 6000
        mov cx, 0
        int 15h
ret


;=======================================
poczekaj_na_dowolny_klawisz:
        mov ah,08h
        int 21h
ret


;=======================================
tryb_graficzny:
        mov al,13h
        mov ah,00h
        int 10h
ret

;=======================================
tryb_tekstowy:
        mov al,03h
        mov ah,00h
        int 10h
ret

;=======================================
tytul:
        mov dx,offset napis_powitalny
        mov ah,9h
        int 21h
ret

;=======================================
info:
        mov dx, offset napis_info
        mov ah,9
        int 21h
ret


;=======================================
czysc_ekran:
        push es
        mov ax,0a000h
        mov es,ax
        mov bx,0000h
wpisuj_zera:
        mov byte ptr es:[bx],00h
        inc bx
        cmp bx,64000
        jnz wpisuj_zera
        pop es
ret

;=======================================
czy_opadly:
        cmp ufo1_pozycja_y, 170
        je koniec_gry
        cmp ufo2_pozycja_y, 170
        je koniec_gry
        cmp ufo3_pozycja_y, 170
        je koniec_gry
ret


;=======================================
koniec_gry:
        call rysuj_samolot
        call czy_rysuj1_ufo1
        call czy_rysuj1_ufo2
        call czy_rysuj1_ufo3
        call poczekaj_na_dowolny_klawisz
        call czysc_ekran
        mov dx,offset napis_koniec
        mov ah,9h
        int 21h
        call poczekaj_na_dowolny_klawisz
        jmp koniec
ret


;=======================================
koniec_wygrana:
        call rysuj_samolot
        call poczekaj_na_dowolny_klawisz
        call czysc_ekran
        mov dx,offset napis_wygrana
        mov ah,9h
        int 21h
        call poczekaj_na_dowolny_klawisz
        jmp koniec
ret


;=======================================
czy_strzal:
        cmp czy_pocisk, 1
        je pocisk_leci
ret


;=======================================
strzal:
        cmp czy_pocisk, 1
        je nic1_strzal
        push bx
        push bx
        mov pocisk_pozycja_y, 180
        mov bx, samolot_pozycja_x
        add bx,9
        mov pocisk_pozycja_x, bx
        pop bx
        mov bx, 1
        mov czy_pocisk, bx
        pop bx
        nic1_strzal:
ret


;=======================================
pocisk_leci:
        cmp czy_alt, 1
        je alt_tak
        cmp czy_ctrl, 1
        je ctrl_tak
        alt_tak:
        call poruszaj_pocisk1
        call rysuj_pocisk1
        jmp potem
        ctrl_tak:
        call poruszaj_pocisk
        call rysuj_pocisk
        jmp potem
ret


;=======================================
czy_pudlo:
        cmp pocisk_pozycja_y, 0
        je brak_pocisku
ret


;=======================================
brak_pocisku:
        push bx
        call czysc_alt_ctrl
        mov bx, 0
        mov czy_pocisk, bx
        pop bx
ret



;=======================================
czy_trafione_ufo1:
        cmp czy_pocisk, 0
        je czy_trafione_ufo1_koniec
        cmp czy_ufo1, 1
        je czy_trafione_ufo1_koniec
        push bx
        mov bx, ufo1_pozycja_y
        add bx, 10
        cmp pocisk_pozycja_y, bx
        je czy_ufo1_trafione_2
        potem_ufo1:
        pop bx
        czy_trafione_ufo1_koniec:
ret


;=======================================
czy_ufo1_trafione_2:
        push bx
        push cx
        mov bx, ufo1_pozycja_x
        sub bx, 5
        mov cx, 30
czy_ufo1_trafione_petla:
        cmp pocisk_pozycja_x, bx
        je ufo1_trafione
        add bx,1
loop czy_ufo1_trafione_petla
        pop cx
        pop bx
        jmp potem_ufo1
ret


;=======================================
ufo1_trafione:
        cmp czy_alt, 1
        je odejm1_4
        jmp odejm1_1
        odejm1_4:
        sub ufo1_sila, 8
        jmp odejm1_4_koniec
        odejm1_1:
        sub ufo1_sila, 1
        odejm1_4_koniec:
        call brak_pocisku
        cmp ufo1_sila,9
        ja potem
        sub liczba_ufo, 1
        push bx
        call dane_dla_boom1
        mov bx, 1
        mov czy_ufo1, bx
        pop bx
        jmp potem
ret



;=======================================
czy_trafione_ufo2:
        cmp czy_pocisk, 0
        je czy_trafione_ufo2_koniec
        cmp czy_ufo2, 1
        je czy_trafione_ufo2_koniec
        push bx
        mov bx, ufo2_pozycja_y
        add bx, 10
        cmp pocisk_pozycja_y, bx
        je czy_ufo2_trafione_2
        potem_ufo2:
        pop bx
        czy_trafione_ufo2_koniec:
ret


;=======================================
czy_ufo2_trafione_2:
        push bx
        push cx
        mov bx, ufo2_pozycja_x
        sub bx, 5
        mov cx, 30
czy_ufo2_trafione_petla:
        cmp pocisk_pozycja_x, bx
        je ufo2_trafione
        add bx,1
loop czy_ufo2_trafione_petla
        pop cx
        pop bx
        jmp potem_ufo2
ret


;=======================================
ufo2_trafione:
        cmp czy_alt, 1
        je odejm2_4
        jmp odejm2_1
        odejm2_4:
        sub ufo2_sila, 8
        jmp odejm2_4_koniec
        odejm2_1:
        sub ufo2_sila, 1
        odejm2_4_koniec:
        call brak_pocisku
        cmp ufo2_sila,9
        ja potem
        sub liczba_ufo, 1
        push bx
        call dane_dla_boom2
        mov bx, 1
        mov czy_ufo2, bx
        pop bx
        jmp potem
ret



;=======================================
czy_trafione_ufo3:
        cmp czy_pocisk, 0
        je czy_trafione_ufo3_koniec
        cmp czy_ufo3, 1
        je czy_trafione_ufo3_koniec
        push bx
        mov bx, ufo3_pozycja_y
        add bx, 10
        cmp pocisk_pozycja_y, bx
        je czy_ufo3_trafione_2
        potem_ufo3:
        pop bx
        czy_trafione_ufo3_koniec:
ret


;=======================================
czy_ufo3_trafione_2:
        push bx
        push cx
        mov bx, ufo3_pozycja_x
        sub bx, 5
        mov cx, 30
czy_ufo3_trafione_petla:
        cmp pocisk_pozycja_x, bx
        je ufo3_trafione
        add bx,1
loop czy_ufo3_trafione_petla
        pop cx
        pop bx
        jmp potem_ufo3
ret


;=======================================
ufo3_trafione:
        cmp czy_alt, 1
        je odejm3_4
        jmp odejm3_1
        odejm3_4:
        sub ufo3_sila, 8
        jmp odejm3_4_koniec
        odejm3_1:
        sub ufo3_sila, 1
        odejm3_4_koniec:
        call brak_pocisku
        cmp ufo3_sila,9
        ja potem
        sub liczba_ufo, 1
        push bx
        call dane_dla_boom3
        mov bx, 1
        mov czy_ufo3, bx
        pop bx
        jmp potem
ret


;========================================
dane_dla_boom1:
        push bx
        mov bx, 1
        mov czy_boom1, bx
        pop bx
ret

;========================================
czy_boom1_leci:
        cmp czy_boom1, 0
        je czy_boom1_end
        cmp licznik1, 0
        je czy_boom1_end
        sub licznik1, 1
        push bx
        mov bx, ufo1_pozycja_y
        mov boom1_pozycja_y, bx
        mov bx, ufo1_pozycja_x
        mov boom1_pozycja_x, bx
        pop bx
        call rysuj_boom1
        czy_boom1_end:
ret

;========================================
dane_dla_boom2:
        push bx
        mov bx, 1
        mov czy_boom2, bx
        pop bx
ret

;========================================
czy_boom2_leci:
        cmp czy_boom2, 0
        je czy_boom2_end
        cmp licznik2, 0
        je czy_boom2_end
        sub licznik2, 1
        push bx
        mov bx, ufo2_pozycja_y
        mov boom2_pozycja_y, bx
        mov bx, ufo2_pozycja_x
        mov boom2_pozycja_x, bx
        pop bx
        call rysuj_boom2
        czy_boom2_end:
ret


;========================================
dane_dla_boom3:
        push bx
        mov bx, 1
        mov czy_boom3, bx
        pop bx
ret

;========================================
czy_boom3_leci:
        cmp czy_boom3, 0
        je czy_boom3_end
        cmp licznik3, 0
        je czy_boom3_end
        sub licznik3, 1
        push bx
        mov bx, ufo3_pozycja_y
        mov boom3_pozycja_y, bx
        mov bx, ufo3_pozycja_x
        mov boom3_pozycja_x, bx
        pop bx
        call rysuj_boom3
        czy_boom3_end:
ret



;=======================================
czy_rysuj_ufo1:
        cmp czy_ufo1, 1
        je czy_rysuj_ufo1_koniec
        call poruszaj_ufo1
        call rysuj_ufo1
        czy_rysuj_ufo1_koniec:
ret

;=======================================
czy_rysuj_ufo2:
        cmp czy_ufo2, 1
        je czy_rysuj_ufo2_koniec
        call poruszaj_ufo2
        call rysuj_ufo2
        czy_rysuj_ufo2_koniec:
ret

;=======================================
czy_rysuj_ufo3:
        cmp czy_ufo3, 1
        je czy_rysuj_ufo3_koniec
        call poruszaj_ufo3
        call rysuj_ufo3
        czy_rysuj_ufo3_koniec:
ret


;=======================================
czy_rysuj1_ufo1:
        cmp czy_ufo1, 1
        je czy_rysuj1_ufo1_koniec
        call rysuj_ufo1
        czy_rysuj1_ufo1_koniec:
ret

;=======================================
czy_rysuj1_ufo2:
        cmp czy_ufo2, 1
        je czy_rysuj1_ufo2_koniec
        call rysuj_ufo2
        czy_rysuj1_ufo2_koniec:
ret

;=======================================
czy_rysuj1_ufo3:
        cmp czy_ufo3, 1
        je czy_rysuj1_ufo3_koniec
        call rysuj_ufo3
        czy_rysuj1_ufo3_koniec:
ret





;=======================================
czy_nie_ma_ufo:
        cmp liczba_ufo, 0
        je koniec_wygrana
ret


;=======================================
przerwanie_pionowe:
        push ax
        push dx
czekaj01:
        mov dx,03dah
        in al,dx
        test al,8
        jne czekaj01
czekaj02:
        in al,dx
        test al,8
        je czekaj02
pop dx
pop ax
ret



;------------------------------
;------------------------------
start:
        mov ax, seg dane
        mov ds, ax
        mov ax, 0A000H
        mov es, ax
        call tryb_graficzny
        call tytul
        call poczekaj_na_dowolny_klawisz
        call czysc_ekran
        call info
        call poczekaj_na_dowolny_klawisz
        call czysc_ekran
        call gwiazdy
        mov ax, seg dane
        mov ds, ax
        mov ax, 0A000H
        mov es, ax
        call rysuj_samolot
        call poczekaj_na_dowolny_klawisz
petla:
        mov ax, seg dane
        mov ds, ax
        mov ax, 0A000H
        mov es, ax
        call rysuj_samolot
        call czy_rysuj_ufo1
        call czy_rysuj_ufo2
        call czy_rysuj_ufo3
        call przerwanie_pionowe
        call czysc_pocisk
        call czysc_pocisk1
        call czysc_samolot
        call czysc_ufo1
        call czysc_ufo2
        call czysc_ufo3
        call poruszaj_samolot
        call czy_strzal
        potem:
        call czy_trafione_ufo1
        call czy_trafione_ufo2
        call czy_trafione_ufo3
        call czy_boom1_leci
        call czy_boom2_leci
        call czy_boom3_leci
        call czy_opadly
        call czy_nie_ma_ufo
        call czy_pudlo
        call gwiazdy
        call czy_esc
koniec:
        call tryb_tekstowy
        mov ah, 4CH
        int 21H

random:
        include stars.inc
        ofst dw ile_gwiazd dup(0)

kod ends

Stacks SEGMENT USE16 STACK 'STACK'
        db 512 dup(0)
STACKS ENDS

end start