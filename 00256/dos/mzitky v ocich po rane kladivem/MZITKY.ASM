;Black DS / DDT
			;NASM-IDE ASM Assistant Assembler Project File
[BITS 16]		;Set code generation to 16 bit mode
[ORG 0x0100]		;Set code start address to 0100h


[SEGMENT .text]		;Main code segment
START:
    finit               ;Nastartujeme kopra'k
    mov  ax,0013h
    int  10h            ;Nahodi'me grafa'rnu

    xchg ah,al
    mov  bx,224
    mov  cl,12
    xor  dx,dx
    mov  bp,textik
    int  10h
;    call DELEJSIN       ;Napra'skame siny do tabulky
;    call paleta         ;Nmalujeme si paletu
    xor ah,ah
paleta:	
;    xor  bl,bl		;nastaveni palety
    inc  ah             ;zaciname registrem 1 (kvuli bh, taky startuje na 1)
    mov  dx,03c8h	;adresovy registr pro zapis
    mov  al,ah
    out  dx,al
    mov  dx,03c9h	;datovy registr
    mov  cx,3      	;opakujeme 3x : R,G,B
    test ah,40h         ;testuj zda zesvetlujeme, nebo ztmavujeme
    jz   barvi
    xor  al,111111b     ;zesvetlujeme (cili inverznime)
barvi:                  ;v pripade ze ztmavujeme, nechame to byt
    out  dx,al
    loop barvi
    cmp  ah,255
    jnz  paleta

    mov  cl,255         ;citac pozice tabulky
    mov  di,sintab      ;kam se budou ukladat vysledky
SKOCTU:
    mov  [kopr],cl	;CISLO=80*(SIN(CL*PI/64))     tiku
    Fild word [kopr]    ;ST0=cl                       16
    Fldpi               ;ST0=ST1;ST0=PI               08
    Fmulp st1           ;ST0=pi*cl=st1*st0            27
    Fild word [c64]     ;ST0=ST1;ST0=64               16
    Fdivp st1           ;ST0=ST1/ST0=(pi*cl)/c64      73
    Fsin                ;ST0=sin(ST0)                 57
    Fild word [c80]     ;ST0=ST1;ST0=80               16
    Fmulp st1           ;ST0=80*sinus((cl*pi)/64)     27
    Fistp word [kopr]   ;kopr=vysledek ze ST0         34
    mov  ax,[kopr]      ;                             ==
    stosb               ;uloz do tabulky sinusu      274 tiku
    loop SKOCTU




    push  word 0a000h      ;Nastavi'me segment videopameti
    pop   es
MAIN:                   ;hlavni smycka plazmy

	mov	dx,3DAh
FRAM:	in	al,dx
	and	al,8
	jz	FRAM


    mov  al,byte[sy2]        ;py2:=sy2
    mov  byte[py2],al
    mov  al,byte[sy1]        ;py1:=sy1
    mov  byte[py1],al
    mov  di,3200
    mov  cx,94               ;Citac Y
FORY:
    mov  al,byte[sx1]
    mov  byte[px1],al        ;px1:=sx1
    mov  al,byte[sx2]
    mov  byte[px2],al        ;px2:=sx2
    mov  dx,0                ;Citac X
FORX:

    xor  bh,bh
    mov  si,sintab
    mov  bl,byte[py1]
    mov  al,[bx+si]
    mov  bl,byte[py2]
    add  al,[si+bx]
    mov  bl,byte[px1]
    add  al,[bx+si]
    mov  bl,byte[px2]
    add  al,[bx+si]

    stosb
    inc  di                 ;v pripade hrubsiho rastru
    inc  dx

    dec  byte[px1]
    add  byte[px2],2

    cmp  dx,319              ;Test na maxima'lni X-ovou souradnici
    jbe  FORX                ;jnbe

ZVYSY:
    inc  byte[py1]          ;Mozno smazat
    inc  byte[py1]
    inc  byte[py2]
    loop FORY

    inc  byte [sx1]     ;    |
    add  byte[sx2],2    ;    |
    add  byte[sy1],2    ;Zvysujeme promenne o jedna a dva
    inc  byte [sy2]     ;    |

    in   al,60h	        ;Testujeme port
    dec  al             ; zda-li sme stiskli ESC
    jnz  MAIN           ;Skaceme mazurku

    ret                 ;konec vseho
;**************************************************************
[SEGMENT .data]		;Initialised data segment
kopr     dw   0
c64      dw   128
c80      dw   180
px1      db   0
px2      db   0
py1      db   0
py2      db   0
sx1      db   0
sx2      db   0
sy1      db   0
sy2      db   0
textik   db   'Mzitky v ...';ocich'; po rane kladivem'
[SEGMENT .bss]		;Uninitialised data segment
sintab   resb 255       ;pole sinusu  :melo by to byt integer