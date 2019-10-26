;
; Assembly Hex Codes
;
; Some constant hex values for assembly commands that I have had to use over
; the years.  I suppose this is one of the few things that I have done that
; other people might actually find useful; or handy.  Wow.
;

; -----> Segment Overrides
             
SEG_DS = 03eh


; -----> Increment/Decrement Commands

INC_BP = 045h
DEC_BP = 04dh
INC_SI = 046h
DEC_SI = 04eh

INCBP_BP = 046feh           ; Inc [Byte Bp + Byte Immidiate]
INCSI_BP = 004feh           ; Inc [Byte Si]
DECBP_BP = 04efeh           ; Dec [Byte Bp + Byte Immidiate]
DECSI_BP = 00cfeh           ; Dec [Byte Si]

INCBP_WP = 046ffh           ; Inc [Word Bp + Byte Immidiate]
INCSI_WP = 004ffh           ; Inc [Word Si]
DECBP_WP = 04effh           ; Dec [Word Bp + Byte Immidiate]
DECSI_WP = 00cffh           ; Dec [Word Si]


; -----> Move Commands
 
MOVAL_BI  = 0b0h            ; Mov Al,Byte Immidiate

MOVAX_WI  = 0b8h            ; Mov Ax,Word Immidiate
MOVCX_WI  = 0b9h            ; Mov Cx,Word Immidiate
MOVBP_WI  = 0bdh            ; Mov Bp,Word Immidiate
MOVSI_WI  = 0beh            ; Mov Si,Word Immidiate                                                   
                                               

; -----> Addition commands

ADDAL_BI  = 004h            ; Add Al,Byte Immidiate

ADDBX_BI  = 0c383h          ; Add Bx,Byte Immidiate
ADDDX_BI  = 0c283h          ; Add Dx,Byte Immidiate
ADDDI_BI  = 0c783h          ; Add Di,Byte Immidiate

ADDBX_WI  = 0c381h          ; Add Bx,Word Immidiate
ADDDX_WI  = 0c281h          ; Add Dx,Word Immidiate
ADDDI_WI  = 0c781h          ; Add Di,Word Immidiate


; -----> Subtraction commands

SUBAL_BI  = 02ch            ; Sub Al,Byte Immidiate

SUBAX_WI  = 02dh            ; Sub Ax,Word Immidiate
SUBPTR_WI = 02e81h          ; Sub [Word ptr],Word Immidiate
