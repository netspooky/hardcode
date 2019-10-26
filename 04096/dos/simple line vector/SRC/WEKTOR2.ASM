;COPROCESSOR 3D LINE VEKTORS
;CODE BY MOMAT

.MODEL small
.486
.STACK 100h
.DATA

include bryla.inc
TablicaPunktow3d dw Vertices dup (0,0,0)
TablicaPunktow2d dw Vertices dup (0,0)
katX    dd 0.0
katY    dd 0.0
katZ    dd 0.0
radian  dd 0.0174532925
radian2 dd 6.283185307

X       dw 0            ;wspolrzedne
Y       dw 0            ;    3D
Z       dw 0            ;  obiektu

xo      dw 0            ;wspolrzedne
yo      dw 0            ; polozenia
zo      dw -90*16       ;obserwatora

Xp      dw 0            ;wspolrzedne
Yp      dw 0            ;    dla
Xk      dw 0            ; procedury
Yk      dw 0            ;   Linia
KOLOR   db 0            ;kolor linii

kx      equ 150         ;korekcja x
ky      equ 100         ;korekcja y

.CODE

include proc\linia.inc
include proc\obroty.inc
include proc\perspekt.inc

Start:  mov ax,seg TablicaPunktow3d
        mov ds,ax
        mov ax,13h
        int 10h                 ;tryb graficzny
        call PrzeliczPolaczenia
        call CzyscEkran
        fninit

Main:   mov KOLOR,0
        call Raster
        call Rysowanie          ;zmazywanie ekranu
        call Bufor              ;kopiowanie punktow do tablicy 3d przed obrotem
        call Obroty             ;przeliczenie obrotow w tablicy 3d
        call Perspektywka       ;przeliczenie tablicy 3d na 2d
        mov KOLOR,63h
        call Rysowanie


        fld radian      ;radian do ST(0)
        fadd KatX       ;dodaj do ST(0)
        fcom radian2    ;porownaj z 2*pi rad
        fnstsw ax       ;flagi koprocka do ax
        sahf            ;ah na flagi procka
        jb Dalej
        fld radian
        ffree st(1)
Dalej:  fst KatX
        fst KatY
        fstp KatZ       ;zdjecie ze stosu


        jmp Klawisz


PrzeliczPolaczenia:             ;zmniejsza ilosc obliczen w trakcie animacji
        push ds
        pop es
        lea di,Lacz
        mov cx,Lines*2          ;ilosc linii * 2
Loop1:  mov ax,es:[di]          ;wczytanie liczby z tablicy polaczen
        shl ax,2
        stosw                   ;zapis do tablicy
        loop Loop1
        ret

CzyscEkran:
        mov ax,0a000h
        mov es,ax
        xor ax,ax
        xor di,di
        mov cx,320*200/4
        rep stosd
        ret

Rysowanie:
        lea di,Lacz
        lea si,TablicaPunktow2d
        mov cx,Lines            ;ilosc linii
RysowaniePetla:
        mov bx,ds:[di]          ;punkt z tablicy polaczen
        mov ax,ds:[si][bx]      ;Xp z tablicy punktow 2d
        mov Xp,ax
        mov ax,ds:[si][bx][2]   ;Yp      -   ||   -
        mov Yp,ax
        mov bx,ds:[di][2]
        mov ax,ds:[si][bx]      ;Xk z tablicy punktow 2d
        mov Xk,ax
        mov ax,ds:[si][bx][2]   ;Yk      -   ||   -
        mov Yk,ax
        push di
        push cx
        pushf
        call Line13P
        popf
        pop cx
        pop di
        add di,4                ;operujemy na DWORD'ach
        loop RysowaniePetla
        ret

Bufor:
        push ds
        pop es
        lea si,Obiekt
        lea di,TablicaPunktow3d
        mov cx,Vertices*3
        rep movsw
        ret

Obroty:
        lea di,TablicaPunktow3d
        mov cx,Vertices

ObrotyPetla:
        mov ax,ds:[di]          ;wspolrzedna X
        shl ax,4                ;mnozenie dla zwiekszenia dokladnosci
        mov X,ax
        mov ax,ds:[di][2]       ;wspolrzedna Y
        shl ax,4
        mov Y,ax
        mov ax,ds:[di][4]       ;wspolrzedna Z
        shl ax,4
        mov Z,ax

        call RotacjaX           ;obroty X, Y, Z

        mov ax,X
        mov ds:[di],ax
        mov ax,Y
        mov ds:[di][2],ax
        mov ax,Z
        mov ds:[di][4],ax

        add di,6
        loop ObrotyPetla
        ret

Perspektywka:
        lea si,TablicaPunktow3d
        lea di,TablicaPunktow2d
        mov cx,Vertices

PerspektywaPetla:
        lodsw           ;wspolrzedna X
        mov X,ax
        lodsw           ;wspolrzedna Y
        mov Y,ax
        lodsw           ;wspolrzedna Z
        mov Z,ax

        call Perspektywa

        mov ax,X
        sar ax,4        ;dzielenie w zwiazku z poprzednim mnozeniem
        add ax,kx
        stosw
        mov ax,Y
        sar ax,4
        add ax,ky
        stosw

        loop PerspektywaPetla
        ret

Raster: mov dx,3dah
RasterPetla:
        in al,dx
        test al,8
        je RasterPetla
        ret

Klawisz:
        mov ah,01h
        int 16h
        jz Main
ByeBye: mov ax,3h               ;tryb tekstowy i do domu
        int 10h
        mov ax,4c01h
        int 21h

END Start
