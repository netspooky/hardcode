;***************************************************************************;
;* 'TEXTOUT .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - displays current score (due to size restrictions a "bar" type used)   *;
;***************************************************************************;

; TextOut class
TXTOUTREFRESH  EQU     0       ; refresh function pointer
                               ; word alignment
SIZEOFTEXTOUT  EQU     4

; constants

; static constants (allocated only once)

; functions (for all functions bx = pointer to object)
TXTOUT_constructor_macro MACRO
       MOV     WORD PTR [bx+TXTOUTREFRESH],OFFSET TXTOUT_refresh
ENDM

TXTOUT_refresh:                ; draws scoring bars
; modifies: who cares ? the screen object modifies all, so I may too...
       PUSH    0a000h
       POP     es
       XOR     di,di
       MOV     dx,TXTOUTSIZEY
TXTOUT_refresh_lineloop:
       MOV     ax,152+(TXTOUTPL1COL*256) ; 152 = background color!
       MOV     bh,BYTE PTR Player1[AIRPLANESCORE]
       SUB     bh,17           ; -17 .. -1 (for scores 0..16)
       CALL    TXTOUT_refresh_OneBar
       MOV     ax,TXTOUTPL2COL+(152*256)
       MOV     bh,15           ; 15 .. -1 (for scores 0..16)
       SUB     bh,BYTE PTR Player2[AIRPLANESCORE]
       CALL    TXTOUT_refresh_OneBar
       DEC     dx
       JNZ     TXTOUT_refresh_lineloop
       RET

TXTOUT_refresh_OneBar:
       MOV     bl,16           ; number of points in bar
TXTOUT_refresh_SinglePoint:
       INC     bh
       JNZ     TXTOUT_refresh_SinglePoint_Test1Ok
       XCHG    al,ah           ; change colors
TXTOUT_refresh_SinglePoint_Test1Ok:
       CMP     bh,16
       JNZ     TXTOUT_refresh_SinglePoint_Test2Ok
       XCHG    al,ah           ; change colors
TXTOUT_refresh_SinglePoint_Test2Ok:
       MOV     cx,TXTOUTSIZEX
       REP STOSB
       DEC     bl
       JNZ     TXTOUT_refresh_SinglePoint
       RET
