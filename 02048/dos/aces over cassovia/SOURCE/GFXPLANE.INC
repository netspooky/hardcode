;***************************************************************************;
;* 'GFXPLANE.INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - graphics generator for airplanes and shots                            *;
;* - this class does not need to have an instance (fake class ;))          *;
;* - screen object must be initialized before graphics generation          *;
;* - global temporary variables Temp0 and Temp1 needed                     *;
;***************************************************************************;

SIZEOFGFXPLANE EQU     0

; constants
GFXSHT_SIZE    EQU     0202h           ; 2x2 pixels for shot (WORD format)
GFXSHT_SIZEIB  EQU     4
GFXSHT_COLOR   EQU     0F0F0F0Fh       ; pure white (DWORD format)
GFXPLN_SIZEX   EQU     12
GFXPLN_SIZEY   EQU     12
GFXPLN_SIZEIB  EQU     GFXPLN_SIZEX*GFXPLN_SIZEY

; static constants (allocated only once)
GFXPLN_MinusX  DD      -5.5
GFXPLN_AngAdd  DD      0.196349540849362077    ; 2*Pi / 32
GFXPLN_plane1 LABEL BYTE
INCLUDE GFXPL1.INC
GFXPLN_plane2 LABEL BYTE
INCLUDE GFXPL2.INC

; functions
; no constructor ... for what ?

GFXPLN_gen:                            ; bx = ScreenObj !!!
       ; 3..34 = Pl1, 35 = Shot1, 36..67 = Pl2, 68 = Shot2
       MOV     DWORD PTR [Temp1],0     ; zero angle
       MOV     cx,32                   ; create 32 directions
       MOV     si,OFFSET GFXPLN_plane1
       CALL    GFXPLN_gen_32directions
       MOV     DWORD PTR [Temp1],0     ; zero angle
       MOV     cx,32
       MOV     si,OFFSET GFXPLN_plane2
GFXPLN_gen_32directions:
       PUSH    cx
       MOV     cx,GFXPLN_SIZEIB      ; cx = number of bytes for gfx (<256!)
       MOV     dx,(GFXPLN_SIZEY*256)+GFXPLN_SIZEX  ; dx = (8:8) SizeY:SizeX
       CALL    SCR_AddNewGfx   ; return cx = 0, es:di = gfxptr, ax = 0
       ; rotate gfx !          ; si = where to get plane gfx
       FLD     DWORD PTR [GFXPLN_MinusX]       ; [-5.5,-5.5] upper left corner
GFXPLN_gen_32dir_lines:
       FLD     DWORD PTR [GFXPLN_MinusX]
       MOV     dl,GFXPLN_SIZEX
GFXPLN_gen_32dir_pixels:
       PUSH    si
       ; y coord.
       FLD     DWORD PTR [Temp1]
       FSINCOS
       FMUL    ST,ST(3)                        ; y*cos
       FXCH
       FMUL    ST,ST(2)                        ; x*sin
       FSUBP                   ; y*cos - x*sin
       CALL    GFXPLN_gen_32dir_GetCoordinate
       MOV     ah,GFXPLN_SIZEX
       MUL     ah
       ADD     si,ax                           ; si += SizeX*y
       ; x coord.
       FLD     DWORD PTR [Temp1]
       FSINCOS
       FMUL    ST,ST(2)                        ; x*cos
       FXCH
       FMUL    ST,ST(3)                        ; y*sin
       FADDP
       CALL    GFXPLN_gen_32dir_GetCoordinate
       ADD     si,ax                           ; si += x
       MOVSB                   ; render pixel :)
       POP     si
       FLD1
       FADDP                   ; x += 1.0
       DEC     dl
       JNZ     GFXPLN_gen_32dir_pixels
       FSTP    ST(0)
       FLD1
       FADDP                   ; y += 1.0
       DEC     dh
       JNZ     GFXPLN_gen_32dir_lines
       FLD     DWORD PTR [Temp1]
       FADD    DWORD PTR [GFXPLN_AngAdd]       ; add angle of rotation
       FSTP    DWORD PTR [Temp1]
       FNINIT
       POP     cx
       LOOP    GFXPLN_gen_32directions
       ; shot gfx
       MOV     cx,GFXSHT_SIZEIB        ; cx = number of bytes for gfx (<256!)
       MOV     dx,GFXSHT_SIZE          ; dx = (8:8) SizeY:SizeX
       CALL    SCR_AddNewGfx   ; return cx = 0, es:di = gfxptr, ax = 0
       MOV     DWORD PTR es:[di],GFXSHT_COLOR
       RET

GFXPLN_gen_32dir_GetCoordinate:        ; v al vrati cislo
       FSUB    DWORD PTR [GFXPLN_MinusX]       ; 0..11
       FISTP   WORD PTR [Temp0]
       ; osekanie na max. SIZEX/Y
       MOV     al,GFXPLN_SIZEX
       CMP     BYTE PTR [Temp0],al
       SALC                    ; if ([Temp0] < 12) al = 0FFh else al = 00h
       AND     al,BYTE PTR [Temp0]
       RET
