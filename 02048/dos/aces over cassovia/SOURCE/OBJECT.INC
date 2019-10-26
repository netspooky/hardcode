;***************************************************************************;
;* 'OBJECT  .INC' ASMINC Ped / 7 Gods (C)2000          #ASM compo 2kB game *;
;* - basic object class                                                    *;
;* - a global variable DWORD Temp0 must exists outside                     *;
;* - no constructor and destructor                                         *;
;***************************************************************************;

OBJECTREFRESH  EQU     0       ; ptr to refresh function
OBJECTGFXFLAG  EQU     4       ; byte gfx flag
OBJECTGFXNUM   EQU     5       ; byte number of frame to draw
;OBJECTBGNUM    EQU     6       ; junk (not used anymore)
OBJECTINITDIR  EQU     7       ; byte init direction (only used by airplane)
OBJECTCNT      EQU     8       ; byte cnt (counter "to_death")
OBJECTDIR      EQU     9       ; byte dir (0..31, 0 is RIGHT, clockwise)
OBJECTHOLD     EQU     10      ; byte hold flag
OBJECTSHOTDOWN EQU     11      ; byte shotdown flag (dead animation running)
OBJECTX        EQU     12      ; float x
OBJECTY        EQU     16      ; float y
OBJECTSPD      EQU     20      ; float spd
OBJECTLASTDX   EQU     24      ; float lastDeltaX
OBJECTLASTDY   EQU     28      ; float lastDeltaY
OBJECTSCRX1    EQU     32      ; word last screen x1    ; for coll. detection
OBJECTSCRX2    EQU     34      ; word last screen x2
OBJECTSCRY1    EQU     36      ; word last screen y1
OBJECTSCRY2    EQU     38      ; word last screen y2
OBJECTSCRGFX   EQU     40      ; word last graphics offset + align
SIZEOFOBJECT   EQU     44

; constants
OBJ_FLOAT1     EQU     3F800000h
;OBJ_FLOAT1     EQU     3F700000h
; some common constants for object::dir
DIR_RIGHT      EQU     0
DIR_DOWN       EQU     8
DIR_LEFT       EQU     16
DIR_UP         EQU     24
; constants for object::gfxflag
OBJ_GFXF_32DIR EQU     1       ; got 32 frames (for each direction)
OBJ_GFXF_DONTDRAWHOLD  EQU     2       ; if (hold==1) don't draw this object
OBJ_GFXF_DONTDRAW      EQU     4       ; don't draw this object

; static constants (allocated only once)
OBJ_dirtorad   DD      0.196349540849362077    ; 1.0/16.0*3.14159265358979324

; functions (for all functions bx = pointer to object)
; no constructor, function spawning new object must init it
; no destructor ... not needed

OBJ_updatePos:                 ; no parameters, will pos += spd*dir_vect;
; ax modified, automaticaly wraps x coordinate (in 0.0 .. 1.0)
       MOVZX   ax,BYTE PTR [bx+OBJECTDIR]
       MOV     WORD PTR [Temp0],ax
       FILD    WORD PTR [Temp0]
       FMUL    DWORD PTR [OBJ_dirtorad]
       FSINCOS
       FMUL    DWORD PTR [bx+OBJECTSPD]
       FST     DWORD PTR [bx+OBJECTLASTDX]
       FADD    DWORD PTR [bx+OBJECTX]
       FSTP    DWORD PTR [bx+OBJECTX]
       FMUL    DWORD PTR [bx+OBJECTSPD]
       FST     DWORD PTR [bx+OBJECTLASTDY]
       FADD    DWORD PTR [bx+OBJECTY]
       FSTP    DWORD PTR [bx+OBJECTY]
OBJ_wrap:                      ; no parameters, will wrap X coordinate
; eax modified
       CMP     BYTE PTR [bx+OBJECTX+3],0
       FLD1
       JGE     OBJ_wrap_test1ok
       FADD    DWORD PTR [bx+OBJECTX]  ; x < 0 =>  x += 1.0;
OBJ_wrap_updateXCoor:
       FSTP    DWORD PTR [bx+OBJECTX]
       RET
OBJ_wrap_test1ok:
       MOV     eax,DWORD PTR [bx+OBJECTX]
       FSUBR   DWORD PTR [bx+OBJECTX]  ; x - 1.0
       CMP     eax,OBJ_FLOAT1
       JGE     OBJ_wrap_updateXCoor    ; (x >= 1.0) -> update it
       FSTP    ST                      ; empty stack
OBJ_refresh:                   ; empty function stub
OBJ_draw_ret:
       RET

OBJ_draw:
; modifies ax, bx, cx, dx, si, di, bp, es
       TEST    BYTE PTR [bx+OBJECTGFXFLAG],OBJ_GFXF_DONTDRAW
       JNZ     OBJ_draw_ret    ; as you wish ...
       TEST    BYTE PTR [bx+OBJECTGFXFLAG],OBJ_GFXF_DONTDRAWHOLD
       JZ      OBJ_draw_donotcheckHold
       CMP     BYTE PTR [bx+OBJECTHOLD],0
       JNZ     OBJ_draw_ret    ; as you wish ...
OBJ_draw_donotcheckHold:
       MOVZX   ax,BYTE PTR [bx+OBJECTGFXNUM]   ; ax = gfnum
       TEST    BYTE PTR [bx+OBJECTGFXFLAG],OBJ_GFXF_32DIR
       JZ      OBJ_draw_not32dirgfx
       ADD     al,BYTE PTR [bx+OBJECTDIR]
OBJ_draw_not32dirgfx:
       MOV     bp,bx
       MOV     bx,OFFSET ScreenObj
       JMP     SCR_drawobject  ; draw & RET
