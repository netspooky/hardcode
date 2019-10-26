;***************************************************************************;
;* 'GFXBALL .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - graphics generator for balloon, balloon tower, sandbag                *;
;* - this class does not need to have an instance (fake class ;))          *;
;* - screen object must be initialized before graphics generation          *;
;***************************************************************************;

SIZEOFGFXBALL  EQU     0

; constants
IFDEF __SANDBAG
GFXBAG_SIZE    EQU     0202h           ; 2x2 pixels for shot (WORD format)
GFXBAG_SIZEIB  EQU     4
GFXBAG_COLOR   EQU     2A2B2B2Ch       ; (DWORD format)
ENDIF
GFXBAL_SIZEX   EQU     12
GFXBAL_SIZEY   EQU     18
GFXBAL_SIZEIB  EQU     GFXBAL_SIZEX*GFXBAL_SIZEY
GFXBALT_SIZEX  EQU     12
GFXBALT_SIZEY  EQU     20
GFXBALT_SIZEIB EQU     GFXBALT_SIZEX*GFXBALT_SIZEY

; static constants (allocated only once)
GFXBALL_balloon LABEL BYTE
INCLUDE GFXBAL.INC
GFXBALL_balltow LABEL BYTE
INCLUDE GFXBALT.INC

; functions
; no constructor ... for what ?

GFXBAL_gen:                            ; bx = ScreenObj !!!
       ; 0 = balloon, 1 = sandbag, 2 = baltower
       MOV     cx,GFXBAL_SIZEIB        ; cx = number of bytes for gfx (<256!)
       MOV     dx,(GFXBAL_SIZEY*256)+GFXBAL_SIZEX  ; dx = (8:8) SizeY:SizeX
       CALL    SCR_AddNewGfx   ; return cx = 0, es:di = gfxptr, ax = 0
       MOV     cx,GFXBAL_SIZEIB
       MOV     si,OFFSET GFXBALL_balloon
       REP MOVSB
IFDEF __SANDBAG
       MOV     cx,GFXBAG_SIZEIB        ; cx = number of bytes for gfx (<256!)
       MOV     dx,GFXBAG_SIZE          ; dx = (8:8) SizeY:SizeX
       CALL    SCR_AddNewGfx   ; return cx = 0, es:di = gfxptr, ax = 0
       MOV     DWORD PTR es:[di],GFXBAG_COLOR
ENDIF
       MOV     cx,GFXBALT_SIZEIB       ; cx = number of bytes for gfx (<256!)
       MOV     dx,(GFXBALT_SIZEY*256)+GFXBALT_SIZEX  ; dx = (8:8) SizeY:SizeX
       CALL    SCR_AddNewGfx   ; return cx = 0, es:di = gfxptr, ax = 0
       MOV     cx,GFXBALT_SIZEIB
       MOV     si,OFFSET GFXBALL_balltow
       REP MOVSB
       RET
