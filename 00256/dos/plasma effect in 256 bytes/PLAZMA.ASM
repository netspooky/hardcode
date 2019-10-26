; ²²²²²²²²²²²²²²²²²²²²²²  Plasma Effect in 256 bytes  ²²²²²²²²²²²²²²²²²²²²²²
;
;                                 code: TrIx
;                                   (C)1998
; contact: trix@polbox.com

Code SEGMENT
Assume Cs:Code
.386
.387
org 100h


Start:
 jmp Main

;°°°°°°°°°°°°°°°° Stale i dane °°°°°°°°°°°°°°°°
 Sin equ 100h+500                  ; adres tablicy Sinusow
 Cos equ 100h+500+256*2            ; adres tablicy Cosinusow
 Pal equ 100h+500+256*4            ; adres palety kolorow
 Pal_ equ 100h+500+256*4+3*128     ; adres palety kolorow od srodka

 p255 dw 255                   ; mnoznik dla generatora Sinusow
 p128 dw 128                   ; mnoznik dla generatora Cosinusow
 radius dd 0.024639942         ; stala dla gen. Sin/Cos : 0.2463..=2*PI/255


;²²²²²²²²²²²²²²²² Poczatek programu ²²²²²²²²²²²²²²²²
Main:


;°°°°°°°°°°°°°°°° Generator Sin/Cos °°°°°°°°°°°°°°°°
 mov si,Sin
 mov di,Cos

 fldz     ; zero na stos koprocesora

 mov cx,256
next_SinCos:
 fld radius            ; radius {0.2463..} na stos koprocesora
 fmul st,st(1)         ; mnozenie st i st(1), wynik na stos
 fsincos               ; Sin i Cos, dla kata otrzymanego wyzej, na stos kopr.
 fimul p128            ; mnozenie wartosci Cos przez stala p128 {128}
 frndint               ; zaokraglenie wyniku powyzszego mnozenia
 fistp word ptr [di]   ; zapamietanie wyniku w tablicy
 fimul p255             ; mnozenie wartosci Sin przez stala p255 {255}
 frndint                ; zaokraglenie wyniku powyzszego mnozenia
 fistp word ptr [si]    ; zapamietanie wyniku w tablicy
 fld1                 ; zwiekszenie wartosci
 fadd                 ; przechowywanej na stosie kopr. o 1

 inc si
 inc si
 inc di
 inc di
loop next_SinCos


;°°°°°°°°°°°°°°°° Generator palety kolorow °°°°°°°°°°°°°°°°
 mov ax,13h
 int 10h

 mov si,Pal
 mov di,Pal_

 mov bx,127   ; bl=127, bh=0
next_color:

;°°° Red °°°
 mov ax,bx
 shr al,2
 mov [si],al
 inc si
 shr ah,2      ;---
 mov [di],ah
 inc di

;°°° Green °°°
 shr al,1
 mov [si],al
 inc si
 shr ah,1      ;---
 mov [di],ah
 inc di

;°°° Blue °°°
; shr ah,1
 mov [si],ah
 inc si
; shr al,1      ;---
 mov [di],al
 inc di

 inc bh
 dec bl
 jns next_color    ; skok wtedy gdy bl > 0

;°°° inicjalizacja nowej palety °°°
 mov dx,3C8h
 out dx,al   ; al=zero
 mov si,Pal
 mov cx,768
 inc dx
 rep outsb


;°°°°°°°°°°°°°°°° GLOWNA PETLA PROGRAMU °°°°°°°°°°°°°°°°
 push 0a000h
 pop es


MAIN_LOOP:

  mov di,0   ; zerowanie offsetu ekranowego

 ;°°° wspolrzedna Y °°°
  mov bx,0
  next_Y:

   ;°°° wspolrzedna X °°°
    mov cx,0
    next_X:

      mov al,dl
      add ax,cx
      and ax,0FFh

      mov si,Cos
      add si,ax
      add si,ax
      mov bp,[si]


      mov ah,0
      mov al,dh
      add ax,bx
      and ax,0FFh

      mov si,Sin
      add si,ax
      add si,ax
      mov ax,[si]

      add ax,bp
      shl cx,2
      add ax,cx
      shr cx,2


      mov es:[di],al   ; wyswietlanie punktu na ekranie
      inc di

    inc cx
    cmp cx,320
    jne next_X

  inc bx
  cmp bx,200
  jne next_Y

  sub dl,3
  add dh,3

 mov ah,11h    ; sprawdzanie czy nie zostal nacisniety jakis klawisz ...
 int 16h
 je MAIN_LOOP  ; ... jesli nie to glowna petla powtarza sie


;°°°°°°°°°°°°°°°° Koniec °°°°°°°°°°°°°°°°
 mov ax,03h
 int 10h

 mov ah,09h
 mov dx,offset Info
 int 21h

 mov ah,4ch
 int 21h

Info DB 'TrIx$'

ends
end Start
