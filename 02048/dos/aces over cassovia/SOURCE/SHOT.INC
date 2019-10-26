;***************************************************************************;
;* 'SHOT    .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - shot class (inherits basic object class)                              *;
;* - collision detection is handled by special class                       *;
;* - init of shot is handled by shooting airplane                          *;
;***************************************************************************;

SIZEOFSHOT     EQU     SIZEOFOBJECT    ; no new variable needed

; constants
SHT_SPD        EQU     3BBE0DEDh       ; 0.0058 (about 3.7 pix.)

; functions (for all functions bx = pointer to object)
; just partial constructor is here, airplane object is handling rest
SHT_constructor:
       MOV     WORD PTR [bx+OBJECTREFRESH],OFFSET SHT_refresh
       MOV     DWORD PTR [bx+OBJECTGFXFLAG],eax
       MOV     DWORD PTR [bx+OBJECTSPD],SHT_SPD
       MOV     BYTE PTR [bx+OBJECTHOLD],1      ; hold = 1
       RET

SHT_refresh:
; modifies eax
       CMP     BYTE PTR [bx+OBJECTCNT],0
       JZ      SHT_die         ; if (cnt == 0) killme();
       DEC     BYTE PTR [bx+OBJECTCNT]
       CALL    OBJ_updatePos   ; pos += spd*dir;
       CMP     BYTE PTR [bx+OBJECTY+3],0
       JL      SHT_die         ; if (pos.y < 0) killme();
       CMP     DWORD PTR [bx+OBJECTY],OBJ_FLOAT1
       JGE     SHT_die         ; if (pos.y >= 1.0) killme();
       RET
SHT_die:
       MOV     BYTE PTR [bx+OBJECTHOLD],1      ; hold = 1 (dead shot ;))
       RET
