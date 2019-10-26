; code by TrIx

Code SEGMENT
Assume Cs:Code
.386
.387

org 100h


Start:
 jmp Main

;같같같같같같같같 Stale i dane 같같같같같같같같
 a dd 0
 b dd 0
 sw1 db 0
 cx_ dd 0
 cy_ dd 0
 zx dd 0
 zy dd 0
 stx dd 0
 sty dd 0
 min dd -2.0
 max dd 2.0
 pow2 dd 2.0
 pow3 dd 3.5
 krok_X dd 0.0125
 krok_Y dd 0.02
 cx_krok dd 0.01
 cx_krok_min dd -0.01
 pow1_8 dd 1.8
 pow0_8_min dd -0.8
 pow0_7 dd 0.7

;께께께께께께께께 Poczatek programu 께께께께께께께께
Main:

 mov ax,13h   ; tryb graficzny
 int 10h

 mov dx,3c8h
 mov al,1
 out dx,al
 inc dx
 mov bl, 17

petlapal:
 mov al,bl
 out dx, al
 mov al,0
 out dx, al
 mov al,bl
 add al,5
 shl al,1
 out dx, al

 dec bl
 jne petlapal


;같같같같같같같같 GLOWNA PETLA PROGRAMU 같같같같같같같같
 push 0a000h
 pop es

 mov bp,32000
 mov dx,320

petla:   ; petla glowna

 mov di,0
 cld
 mov ax,0

 fld min
 fst sty  ; sty=-2.
 fstp stx ; stx=-2.

  ; petla przelatujaca po poszczegolnych punktach ekranu
 ScreenOffset:

  fld stx
  fstp zx
  fld sty
  fstp zy

  mov ch,0
  mov cl,16
  Iter_petla:   ; for (k=0;k<16;k++)

    fld zx
    fmul st(0),st(0)   ;  a=zx*zx
    fst a

    fld zy
    fmul st(0),st(0)   ; b=zy*zy
    fst b

    faddp st(1),st(0)  ; a*b
    fld pow3
    fcompp st(1),st  ; if (a+b>3) { PutPixel (bufor,i,g,k); goto NextPoint; }

    fstsw ax
    sahf
    jb NextPoint  ; jb

    fld a
    fld b
    fsubp st(1),st
    fld cx_
    faddp st(1),st   ;  NewZx=a-b+cx

    fld zx
    fld zy
    fmulp st(1),st  ; NewZy=2*zx*zy+cy
    fld pow2
    fmulp st(1),st
    fld cy_
    faddp st(1),st

    fstp zy     ; zx=NewZx
    fstp zx      ; zy=NewZy

   dec cl
   jne Iter_petla

   mov cl,7   ; PutPixel (bufor,i,g,20);

 NextPoint:
   mov al,cl   ; PutPixel (bufor,i,g,cl);
   stosb

 NextEnd:

 fld stx
 fld krok_x
 faddp st(1),st
 fstp stx

 dec dx
 jne NicNieRob    ; test konca wiersza

  mov dx,320
  fld min
  fstp stx

 fld sty
 fld krok_y
 faddp st(1),st
 fstp sty

NicNieRob:

 cmp di,bp
 jne ScreenOffset


;Kopiowanie polowy w odbiciu lustrzanym
 mov cx,320*100
 mov di,0
 mov si,64000
kop_X:
 mov al,es:[di]
 mov es:[si],al
 inc di
 dec si

 dec cx
 jne kop_X

 mov es:[si],al

 cmp sw1,0
 jne sw1_
 fld cx_
 fld cx_krok
 faddp st(1),st
 fst cx_
 fld pow1_8
 fcompp st(1),st
 fstsw ax
 sahf
 ja sw_end  ; jb
 mov al,1
 mov sw1,al
 jmp sw_end

sw1_:

 fld cx_
 fld cx_krok_min
 faddp st(1),st
 fst cx_
 fld pow0_8_min
 fcompp st(1),st
 fstsw ax
 sahf
 jb sw_end  ; jb
 mov al,0
 mov sw1,al

sw_end:

 fld cy_
 fld pow0_7
 fcompp st(1),st
 fstsw ax
 sahf
 jb cy_end  ; jb
 fld cy_
 fld cx_krok
 faddp st(1),st
 fstp cy_
 cy_end:

;  if (sw1==0) { cx+=0.01; if (cx>1.8) sw1=1; }
;  else if (sw1==1) { cx-=0.01;  if (cx<-0.8) sw1=0; }
;  if (cy<0.7) cy+=0.01;

 mov ah,1
 int 16h
 jz petla


;같같같같같같같같 Koniec 같같같같같같같같
; mov ax,03h
; int 10h

 mov ah,09h
 mov dx,offset Info
 int 21h

 mov ah,4ch
 int 21h

Info DB 'TrIx$'

ends
end Start
