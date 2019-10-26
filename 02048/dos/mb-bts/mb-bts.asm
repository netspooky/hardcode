;****************************************************************************
;*                                                                          *
;*  Designed and written by Tomasz Weglarski                                *
;*  Copyright (C) DevBit 2002                                               *
;*  homepage: www.devbit.prv.pl                                             *
;*  e-mail: tommyw@o2.pl                                                    *
;*                                                                          *
;****************************************************************************

;Kompilacja:
; tasm.exe !.asm /z /zi /n
; tlink.exe /3 !.obj

;Uzycie:
; !.exe

;Opis:
; Program demonstruje plynna animacje tla poprzez odpowiednia zmiane palety
; kolorow RGB. Dziala w trybie 320x200x256.

assume cs:program,ds:dane,ss:sts

;≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤  kod  ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤

program segment

.386p

 wpaleta      dw      0,seg paleta

 _1           dw      0           ;poczatek dla paska RED
 p1           dw      1           ;przyrost dla paska RED
 _2           dw      90*3  ;0    ;poczatek dla paska GREEN
 p2           dw      2           ;przyrost dla paska GREEN
 _3           dw      180*3 ;0    ;poczatek dla paska BLUE
 p3           dw      3           ;przyrost dla paska BLUE

start:
              call    test_386p
              call    set_graph
              call    make_dark
              call    fill        ;przygotowanie ekranu

 petla_1:     call    clr_pal     ;wyzerowanie palety
              call    paski
              call    slow
              call    slow_video
              call    set_pal

              mov     ah,1
              int     16h
              jz      petla_1

              call    set_txt
              mov     ah,4ch
              int     21h

;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€  procedury  €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€
;Procedura przeksztalca palete.

 paski        proc

;============================================

              lds     si,dword ptr wpaleta
              add     si,3
              add     si,_1
              call    pasek

              cmp     _1,0
              ja      d1

              mov     p1,1

 d1:          cmp     _1,(200-20)*3
              jb      d2

              mov     p1,-1

 d2:          mov     ax,p1
              mov     cx,3
              imul    ax,cx
              add     ax,_1
              mov     _1,ax

;============================================

              lds     si,dword ptr wpaleta
              add     si,3
              add     si,_2
              add     si,1
              call    pasek

              cmp     _2,0
              ja      d3

              mov     p2,2

 d3:          cmp     _2,(200-20)*3
              jb      d4

              mov     p2,-2

 d4:          mov     ax,p2
              mov     cx,3
              imul    ax,cx
              add     ax,_2
              mov     _2,ax

;============================================

              lds     si,dword ptr wpaleta
              add     si,3
              add     si,_3
              add     si,2
              call    pasek

              cmp     _3,0
              ja      d5

              mov     p3,3

 d5:          cmp     _3,(200-20)*3
              jb      d6

              mov     p3,-3

 d6:          mov     ax,p3
              mov     cx,3
              imul    ax,cx
              add     ax,_3
              mov     _3,ax

;============================================

              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;Pod ds:[si] musi byc podany pierwszy kolor.

 pasek        proc
              mov     byte ptr ds:[si],10
              add     si,3
              mov     byte ptr ds:[si],15
              add     si,3
              mov     byte ptr ds:[si],20
              add     si,3
              mov     byte ptr ds:[si],25
              add     si,3
              mov     byte ptr ds:[si],30
              add     si,3
              mov     byte ptr ds:[si],35
              add     si,3
              mov     byte ptr ds:[si],40
              add     si,3
              mov     byte ptr ds:[si],45
              add     si,3
              mov     byte ptr ds:[si],50
              add     si,3
              mov     byte ptr ds:[si],55
              add     si,3
              mov     byte ptr ds:[si],55
              add     si,3
              mov     byte ptr ds:[si],50
              add     si,3
              mov     byte ptr ds:[si],45
              add     si,3
              mov     byte ptr ds:[si],40
              add     si,3
              mov     byte ptr ds:[si],35
              add     si,3
              mov     byte ptr ds:[si],30
              add     si,3
              mov     byte ptr ds:[si],25
              add     si,3
              mov     byte ptr ds:[si],20
              add     si,3
              mov     byte ptr ds:[si],15
              add     si,3
              mov     byte ptr ds:[si],10
              add     si,3
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 make_dark    proc
              mov     dx,3C8h
              xor     al,al
              out     dx,al
              inc     dx
              mov     cx,256*3

 mp:          out   dx,al
              loop  mp
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 set_pal      proc
              lds     si,dword ptr wpaleta
              mov     dx,3C8h
              xor     al,al
              out     dx,al
              inc     dx
              mov     cx,256*3
              rep     outsb
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 fill         proc
              mov     ax,0A000h
              mov     es,ax
              xor     di,di
              xor     al,al
              mov     bx,200

 petla_2:     mov     cx,320
              inc     al
              rep     stosb
              dec     bx
              jns     petla_2
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 clr_pal      proc
              les     di,dword ptr wpaleta
              mov     cx,256*3/4
              xor     eax,eax
              cld
              rep     stosd
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 slow         proc
              mov     ah,86h
              mov     dx,20000
              xor     cx,cx
              int     15h
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 slow_video   proc
              mov     dx,3dah

 sloc_1:      in      al,dx
              test    al,8
              je      sloc_1
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 pause        proc
              sub     ax,ax
              int     16h
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 set_graph    proc
              mov     ax,13h
              int     10h
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 set_txt      proc
              mov     ax,03h
              int     10h
              ret
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

 test_386p    proc
              cld
              pushf
              pop     bx
              mov     ax,bx
              xor     ah,40h
              push    ax
              popf
              pushf
              pop     ax
              cmp     ah,bh
              je      nie_386p
              ret

 nie_386p:    mov     ax,seg error_1
              mov     ds,ax
              lea     dx,error_1
              mov     ah,09h
              int     21h

              mov     ax,4C01h
              int     21h

 error_1      db      'Konieczny 386 lub lepszy!',13,10,'$'
              endp

;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±


;€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€€  koniec kodu  €€€€€€€€€€€€€€€€€€€€€€€€€€€€€€

program ends

;≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤  dane  ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤

dane segment
 paleta       db      256*3 dup(?)
dane ends

;≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤  stos  ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤

sts segment stack 'stos'
              db      1024     dup(?)
sts ends

;≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤ koniec ≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤≤

end start
