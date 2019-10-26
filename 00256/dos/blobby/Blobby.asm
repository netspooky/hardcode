; Blobby
; by Quick
; Use Tasm & Tlink


.MODEL TINY
.486
.CODE

ORG 100h
BEGINNING:
;========================================
;               CONDITIONS
;========================================

BINVARS     EQU   1        ; Yes: 1, No:0 (-2 bytes)
SMALLCLIP   EQU   1        ; Yes: 1, No:0 (ONLY WHEN BINVARS = 1) (-2 bytes))


;========================================
;                CONSTANTS
;========================================

NUMMASS     EQU   4        ; Number of Masses (max: 4)
ANGLSTP     EQU   80       ; Angle Step Divisor
VMODE13     EQU   13h      ; 320x200x256
VMODE03     EQU   03h      ; TEXT MODE

OFFSRAD     EQU   14h

IF (SMALLCLIP EQ 1)
OFFSANG     EQU   08h      ; 08h value=0068h=104
ELSE
OFFSANG     EQU   138      ;(8Bh)
ENDIF


;========================================
;                 MACROS
;========================================

; Wait For Retrace
WaitRetrace    MACRO 
local @@l
        mov    dx,3DAh
@@l:
        in     al,dx
        test   al,8
        jz     short @@l
ENDM


; Set Video Mode
SetVideoMode   MACRO vmode
      mov   ax,vmode
      int   10h
ENDM


;========================================
;                 MAIN
;========================================

main:

SetVideoMode   VMODE13

; Set Palette 
   mov   dx,03C9h

; goto VideoMem
   push  0A000h
   pop   es

LoopPalette:
   mov   ax,bx
   shr   al,2
   out   dx,al
   out   dx,al
   out   dx,al
   dec   bx
   jnz   LoopPalette


@kbnhit:    
   WaitRetrace

   mov   ax,NUMMASS*2+2    ; num of masses x2+2
   mov   di,ax             ; angle diff
   
@@ChPosition:
   inc   bp
   inc   bp

   fldpi
IF (BINVARS EQ 1)
   fidiv word ptr [BEGINNING + OFFSANG]
ELSE
   fidiv SICO
ENDIF
   shl   di,cl
   mov   dx,fs             ; fs contains AngleCounter
   add   dx,di

   push  dx
   fimul word ptr [esp]
   pop   dx

   fsin
IF (BINVARS EQ 1)
   fimul word ptr [BEGINNING + OFFSANG]
ELSE
   fimul SICO
ENDIF
   fistp [Xf + 2 + bp]

   inc   cx
   dec   ax
   jnz   @@ChPosition

   inc   dx
   mov   fs,dx

   mov   dx,200
@loopY:
   mov   cx,320
@loopX:
   mov   ax,NUMMASS
   fldz
@@looppixel:
   mov   bp,4              ; select X OR Y
   mov   si,ax
   shl   si,2

   mov   bx,dx
@@@square:
   sub   bx,[Xf - 2 + bp + si]
   sub   bx,100
   push  bx
   fild  word ptr [esp]
   fmul  st(0),st(0)
   pop   bx
   mov   bx,cx
   dec   bp
   dec   bp
   jnz   @@@square

   faddp  st(1),st(0)

IF (BINVARS EQ 1)
   fidivr   word ptr [BEGINNING + OFFSRAD]
ELSE
   fidivr   RAD
ENDIF

   faddp st(1),st(0)

   dec   ax
   jnz   @@looppixel

   fistp X
   mov   ax,X

; Reduces by 2 bytes
IF (SMALLCLIP EQ 1)
   neg   ah
   sbb   ah,ah
   or    al,ah
ELSE
   cmp   ax,0FFh
   jbe   @nocut
   mov   ax,0FFh
@nocut:
ENDIF
   not   al
   inc   al
   stosb

   loop  @loopX
   dec   dx
   jnz   @loopY


;@kbnhit:
   in    al,60h
   cmp   al,1
   jnz   @kbnhit

   
SetVideoMode   VMODE03

   ret

IF (BINVARS EQ 0)
   RAD   dw    32000       ; Replaced with from bin
   SICO  dw    ANGLSTP     ; Replaced with from bin
ENDIF
   Xf    dw    ?
   Yf    dw    ?
   Xf1   dw    ?
   Yf1   dw    ?
   Xf2   dw    ?
   Yf2   dw    ?
   Xf3   dw    ?
   Yf3   dw    ?
   Xnn   dw    10 dup(?)
   Ynn   dw    10 dup(?)
   X     dw    ?

END main
