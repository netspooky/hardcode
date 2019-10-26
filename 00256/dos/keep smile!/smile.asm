;============================================================================
; Keep smile! by luks
;----------------------------------------------------------------------------
; This is my first 256b intro. It was be done for Demobit XP. Compile it only
; under Netwide Assembler (NASM). Write me to luks@host.sk
;============================================================================

[segment .text]
[org 100h]

RANGLE  equ     720             ; toto sa da pouzit na zmenu rychlosti

BEGIN   fninit                  ; inicializacia koprocesoru

        mov     al,0x13         ; graficky mod
        int     0x10

        push    word 0A000h     ; FS = Video RAM
        pop     fs
                                ; nastavi paletu v odtienoch modrej
PALETTE mov     dx,03C8h        ; ale pouzitelna je len 0..31
        mov     al,cl
        out     dx,al
        inc     dx
        shl     al,1
        out     dx,al
        out     dx,al
        shl     al,1
        cmp     al,63
        jbe     OUTBLUE
        mov     al,63
OUTBLUE out     dx,al
        loop    PALETTE

MAIN    push    ds
        pop     es

        mov     ax,1300h        ; napiseme smajlika do rohu obrazovky
        mov     cl,3
        xor     dx,dx
        mov     bx,1
        mov     bp,SMILE
        int     0x10

        push    word 0x8000     ; es = segment, ktory bude dufam volny ;)
        pop     es

        xor     di,di
        mov     cl,8
SMALLY  mov     ch,24
SMALLX  mov     al,[fs:di]      ; zoberie pixel z maleho smajlika
        or      al,al           ; ak je nulovy, ...
        jz      ESMALLX         ; ... tak ho nebudeme kreslit

        movzx   dx,cl           ; vypocita suradnicu Y
        shl     dx,byte 3
        sub     dx,byte 32

        movzx   ax,ch           ; vypocita suradnincu X
        imul    ax,byte 6
        sub     ax,byte 72

        push    cx              ; odlozime CX
        mov     cl,8
BIGY    mov     ch,6
BIGX    mov     bx,Z            ; BX = Z
        mov     [bx],word 0     ; nastavi Z na spravnu hodnotu = 0
        lea     bp,[bx-2]       ; BP = Y
        mov     [bp],dx         ; nastavi Y na spravnu hodnotu
        mov     [bp+6],word RANGLE
        call    ROTATE
        sub     bx,byte 4       ; BX = X
        mov     [bx],ax         ; nastavi X na spravnu hodnotu
        add     bp,byte 2       ; BP = Z
        shr     word [bp+4],1
        call    ROTATE
        sub     bp,byte 2       ; BP = Y
        shr     word [bp+6],1
        call    ROTATE
        mov     si,[bp]         ; vypocita offset pixelu
        imul    si,320          ; offset = Y * 320 + X
        add     si,[bx]
        add     si,68*320+88+32*320+72  ; a este treba normalizovat suradnice
        mov     [es:si],byte 31 ; vlozime pixel do bitmapy

        inc     ax              ; zvysime X
        dec     ch
        jnz     BIGX
        sub     ax,byte 6       ; nastavime X na povodnu hodnotu
        inc     dx              ; a zvysime Y
        loop    BIGY
        pop     cx              ; obnovime CX

ESMALLX inc     di              ; nastavime sa na dalsi pixel v predlohe
        dec     ch
        jnz     SMALLX
        add     di,320-24       ; nastavime sa na dalsi riadok v predlohe
        loop    SMALLY

        inc     word [bp+4]     ; zvysime uhol rotovania

EFFECTS mov     [fs:di],al
        stosb
        mov     al,[es:di]
        add     al,[es:di+1]
        add     al,[es:di-32]
        add     al,[es:di+32]
        shr     al,2
        loop    EFFECTS

        mov     ah,0x11         ; zistime ci je stlacena klavesa
        int     0x16
        jz      near MAIN       ; ak nie dalej loopujeme

ROTATE  fldpi                   ; ã
        fimul   word [ANGLE]    ; ã.uhol
        fidiv   word [DEG]      ; à
        fsincos                 ; sin ; cos
        fld     st1             ; cos ; sin ; cos
        fld     st1             ; sin ; cos ; sin ; cos
        fimul   word [bp]       ; y.sin ; cos ; sin ; cos
        fild    word [bx]       ; x ; y.sin ; cos ; sin ; cos
        fmulp   st2             ; y.sin ; x.cos ; sin ; cos
        fsubp   st1             ; x.cos-y.sin ; sin ; cos
        fild    word [bx]       ; x ; x.cos-y.sin ; sin ; cos
        fxch                    ; x.cos-y.sin ; x ; sin ; cos
        fistp   word [bx]       ; x ; sin ; cos
        fmulp   st1             ; x.sin ; cos
        fild    word [bp]       ; y ; x.sin ; cos
        fmulp   st2             ; x.sin ; y.cos
        faddp   st1             ; x.sin+y.cos
        fistp   word [bp]       ; nic
        ret

SMILE   db      "(-:"           ; ten smajlik tu musi byt naopak, aby bol potom spravne

DATA
X       equ     DATA
Y       equ     DATA + 2
Z       equ     DATA + 4
ANGLE   equ     DATA + 6
DEG     equ     DATA + 8



