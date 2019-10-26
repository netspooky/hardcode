;***************************************************************************;
;* 'SANDBAG .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - sandbag class (inherits basic object class)                           *;
;* - collision detection is handled by special class                       *;
;***************************************************************************;

SIZEOFSANDBAG  EQU     SIZEOFOBJECT    ; no new variable needed

; constants
BAG_SPD        EQU     3C14F209h       ; (1.0/(BAL_SANDBAGCNT-10))

; functions (for all functions bx = pointer to object)
BAG_constructor:
; ax = (8:8) = (gfxnum:gfxflag)
       MOV     WORD PTR [bx+OBJECTREFRESH],OFFSET BAG_refresh
       MOV     WORD PTR [bx+OBJECTGFXFLAG],ax
       MOV     DWORD PTR [bx+OBJECTSPD],BAG_SPD
       MOV     BYTE PTR [bx+OBJECTHOLD],01h    ; (hold=1, other not needed)
       MOV     BYTE PTR [bx+OBJECTDIR],DIR_DOWN
       ; x/y coord. don't have to be initialized ... (will be upon launch)
       RET

BAG_refresh:
; modifies eax
       CALL    OBJ_updatePos   ; pos += spd*dir;
       CMP     BYTE PTR [bx+OBJECTY+3],0
       JL      BAG_die
       CMP     DWORD PTR [bx+OBJECTY],OBJ_FLOAT1
       JL      BAG_live
BAG_die:
       MOV     BYTE PTR [bx+OBJECTHOLD],1      ; if (pos.y >= 1.0) killme();
BAG_live:
       RET
