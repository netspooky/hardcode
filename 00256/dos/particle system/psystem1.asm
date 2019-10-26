; asmsyntax=nasm
;
; psystem1.asm
; 2003 tisnik (Pavel Tisnovsky)
;
; --- Syndeecate Apocalypse D e m o p a r t y ---- 2 0 0 3
;

bits 16

ParticleCount   equ     0x7f
FixedPointZero  equ     7
x0              equ     160 << FixedPointZero
y0              equ     160 << FixedPointZero
xmin            equ     20  << FixedPointZero
xmax            equ     300 << FixedPointZero
ymin            equ     20  << FixedPointZero
ymax            equ     190 << FixedPointZero
color           equ     63


;-----------------------------------------------------------------------------
section .data

title           db      "Tisnik 2003$"

;-----------------------------------------------------------------------------
section .bss

particles       resw    ParticleCount*8 ; x, y, vx, vy
paleta          resb    256*3



;-----------------------------------------------------------------------------
org     0x100
section .text

Start:

;------ Graficky rezim 320x200x256 -------
        mov     ax, 0x13
        int     0x10

;------ Inicializace palety -------
        xor     ax, ax
        mov     di, paleta
        mov     cx, 256
                6       14:30-15:30     mlátièka: dodìlány všechny funkce pro zpracování chyb
        push    di                      ; adresa pocatku palety
        push    cx                      ; pocet barev
SetPaletteLoop:
        stosb                           ; red component
        stosb                           ; green component
        stosb                           ; blue component
        inc     ax
        loop    SetPaletteLoop

;------ Nastaveni palety -------
        mov     ax, 0x1012
        pop     cx                      ; pocet barev
        pop     dx                      ; adresa pocatku palety
        xor     bx, bx
        int     0x10

        mov     bx, 6                   ; offset pri pristupu do pole
;------ Nastaveni castic -------
        mov     cx, ParticleCount
        mov     si, particles
SetParticlesLoop:
        call    SetOneParticle
        add     si, byte 8
        loop    SetParticlesLoop

;------ Nastaveni bufferu pro video RAM -------
        mov     ax, cs                  ; ziskat hodnotu code segmentu
        add     ah, 0x10                ; posun o 64kB na program
        mov     es, ax                  ; segment video bufferu

;------ Vymazani bufferu - odstraneni smeti ------
        xor     di, di
        mov     ax, di
        mov     cx, 32000
        rep     stosw

;------ Vykreslovaci smycka -------
MainLoop:
        mov     cx, ParticleCount
        mov     si, particles
DrawParticlesLoop:
        mov     ax, [si+2]              ; y-ova souradnice
        mov     di, [si+bx]
        sub     ax, di
        dec     di                      ; gravitace
        mov     [si+bx], di
        mov     [si+2], ax
        cmp     ax, ymax
        jnc     NewParticlePosition
        ;cmp     ax, ymin               ; castice nedoletnou az k hornimu okraji
        ;jc      NewParticlePosition
        shr     ax, FixedPointZero      ; na integer
        mov     di, ax
        shl     di, 6                   ; y*64
        shl     ax, 8                   ; y*256
        add     di, ax
        mov     ax, [si]                ; x-ova souradnice
        add     ax, [si+4]              ; +vx
        mov     [si], ax
        cmp     ax, xmin
        jc      NewParticlePosition
        cmp     ax, xmax
        jnc     NewParticlePosition
        shr     ax, FixedPointZero      ; na integer
        add     di, ax                  ; souradnice pixelu
        mov     al, 63
        stosb
next:   add     si, byte 8
        loop    DrawParticlesLoop

;------ Filtr -------
        push    ds
        push    word 0xa000
        pop     ds
        mov     di, 321
        mov     cx, 64000
        mov     dx, 5

FilterLoop:
        xor     ax, ax
        mov     al, [es:di+1-321]       ; ziskat hodnotu pixelu z bufferu
        add     al, [es:di+320-321]
        add     al, [es:di]
        add     al, [es:di+1]
        add     al, [es:di+641-321]
        adc     ah, dh
        div     dl
        mov     [di], al                ; ulozit do obrazove pameti
        stosb                           ; ulozit pixel zpet do bufferu
        loop    FilterLoop
        pop     ds

;------ Zjisteni, zda byla stisknuta klavesa -------
        mov     ah, 0x01                ; sluzba BIOSu-cteni stavu bufferu klavesnice
        int     0x16
        jz      near MainLoop           ; zadna klavesa v bufferu -> opakovat smycku

;------ Vyprazdnit buffer klavesnice -------
        xor     ax, ax
        int     0x16

;------ Textovy rezim 80x25 -------
        mov     ax, 0x03
        int     0x10

;------ Tisk retezce na obrazovku
        mov     dx, title
        mov     ah,9
        int     21h

;------ Vyprazdnit buffer klavesnice a cekat na klavesu -------
        xor     ax, ax
        int     0x16

;------ Ukonceni procesu -------
        retn

NewParticlePosition:
        call    SetOneParticle
        jmp     next

SetOneParticle:
        mov     [si], word x0           ; particle.x
        mov     [si+2], word y0         ; particle.y
        mov     ax, si
        and     ax, 0x007f
        sub     ax, 1 << FixedPointZero-1
        mov     [si+4], ax              ; particle.vx
        mov     ax, cx
        and     ax, 0x007f
        add     ax, 70
        mov     [si+bx], ax             ; particle.vy
        retn

