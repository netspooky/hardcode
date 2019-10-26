;***************************************************************************;
;* 'SCORING .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - scoring class (used mostly to handle main_game loop behaviour)        *;
;***************************************************************************;

SCORINGGAMEF   EQU     0       ; BYTE game flag 0 = game is on
                               ;      other value = game is over
SCORINGGAMECNT EQU     1       ; BYTE game cnt -> minimal pause to next game
SIZEOFSCORING  EQU     4

; constants

; static constants (allocated only once)

; functions
SCO_constructor_macro MACRO    ; set bx before this
       MOV     WORD PTR [bx+SCORINGGAMEF],0+(RESTARTDELAY*256) ; game is on
                               ; and after and wait minimaly RESTARTDELAY
ENDM

SCO_refresh_macro MACRO        ; doesn't need anything
       XOR     ax,ax
       CMP     BYTE PTR Player1[AIRPLANESCORE],POINTSTOWIN
       RCL     al,1            ; carry flag will be before XOR at "0x02" position
       CMP     BYTE PTR Player2[AIRPLANESCORE],POINTSTOWIN
       RCL     al,1            ; carry flag will be before XOR at "0x01" position
       XOR     al,3            ; al = 0, if both players are under POINTSTOWIN
       MOV     BYTE PTR ScoringObj[SCORINGGAMEF],al ; otherwise al = some nonzero value
ENDM

COMMENT ~
SCO_refresh:                   ; doesn't need anything (non-macro version)
       SCO_refresh_macro
       RET
~
