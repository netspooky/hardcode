;***************************************************************************;
;* 'BACKGRND.INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - background generator class                                            *;
;* - this class does not need to have an instance (fake class ;))          *;
;***************************************************************************;

SIZEOFBACKGRND EQU     0               ; seed in static, so no variables

; constants

; static constants (allocated only once)

; functions
; no constructor ... for what ?

BACKGRND_gen_macro MACRO
; very simple and not really pretty background, but no space for "real thing"
       PUSH    0a000h
       POP     es
       XOR     di,di
       MOV     al,152
       MOV     dx,200/8
Backgrnd_line:
       MOV     cx,320*8
       REP STOSB
       INC     ax
       DEC     dx
       JNZ     Backgrnd_line
ENDM
