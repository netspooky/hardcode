;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
; 4K Intro 01                                               by Picard 1998 (c)
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

MAX_OBJ_VERTEX          equ     2560*2 ; Interpolar uses Buffer 128byte per Vertex
MAX_VERTEX              equ     10000h
MAX_FACE                equ     10000h
MAX_OBJECT              equ     97     ; must be below 100h
MAX_PROCESS             equ     100h   ; must be multiple of 256

SCREEN_SIZE             equ     10000h
SCREEN_X                equ     320
SCREEN_Y                equ     200

CALL_SIZE               equ     12
REAL_START_OFFSET       equ     1100h
ifdef __SCRDEBUG
PMODE_SIZE      equ     (80h+REAL_START_OFFSET/10h) ;in para
else
PMODE_SIZE	equ	(1Eh+REAL_START_OFFSET/10h) ;in para
endif

segcode

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Functions
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

global LANG ProtMain:near

global LANG _Read4Bit:near
global LANG _ReadS4Bit:near
global LANG _ReadS8Bit:near
global LANG _Random:near
global LANG _Text_Avg:near
global LANG _TF_Avg:near
global LANG _Text_Wood:near
global LANG _CN_SubVector:near
global LANG _Mirror:near
global LANG _DrawFace:near
global LANG _DrawTriangle:near
global LANG _CalcDelta:near
global LANG _CalcTo:near

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Constants
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

global LANG Const_CallData:word
global LANG Const_CalcMatrix:byte
global LANG Const_InterPolar3:byte
global LANG Const_InterPolar4:byte
global LANG Const_FontVertex:byte
global LANG Const_FontFace:byte
global LANG Const_PalData:byte
global LANG Const_Fract:byte
global LANG Const_CalcNormal:byte
global LANG Const_Model:byte
global LANG Const_Code:byte
global LANG Const_Object:byte
global LANG RandomSeed:dword
global LANG Fix16:dword
global LANG CSFix:dword
global LANG RotateAdj:dword

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Variables
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

global LANG Matrix:dword:32
global LANG Objects:tObject:100h
global LANG ObjectsDraw:tObject:100h
global LANG Models:tModel:100h
global LANG Process:tProcess:MAX_PROCESS+1
global LANG Array:dword:512
global LANG SinTable:dword:202h
global LANG CharMap:byte:1000h
global LANG VGAPal:byte:300h
global LANG Buffer:byte:50000h
global LANG Temp:byte:1000h
global LANG Models:tModel:100h
global LANG ObjTexture:dword
global LANG ObjColor:dword
global LANG Reflection:dword
global LANG AniClock:byte
global LANG AniFade:byte
global LANG AniProcess:dword
global LANG AniTemp:dword
global LANG ZBufPos:dword
IFDEF __DEBUG
global LANG VCount:dword
global LANG FCount:dword
ENDIF

global LANG Code32End:near
global LANG StackPos:near
ends

macro MProtMain
                calls   ProtMain
endm

macro MRealInit
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
;
; Realmode Init
;
; -Generate Palette
; -Set GraphMode
; -Set Palette
; -Get CharMap
;
; In:
;  -
; Out:
;  no reg saved, segments saved
;
;±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Generate Palette
; DataType:
;   [[Start(upper 4bit)+Inc(lower 4bit)] * 3(R,G,B)] * 8 (Colors)
;   ValRGB(n) = Start*4 + Inc*n/8        n:0..31
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

                mov     DI,s o VGAPal
                mov     SI,s o Const_PalData
                push    DS DI
                mov     CL,16
GP_ColorLoop:
rept 3
local GP_Loop
                push    DI
                lodsb
                cbw
                shl     AX,2
                mov     DX,AX
                add     DX,DX
                and     AL,0Fh*4
                and     DL,128
                mov     CH,16
GP_Loop:        stosb
                inc     DI
                inc     DI
                add     AH,DL
                adc     AL,DH
                dec     CH
                jne     short GP_Loop
                pop     DI
                inc     DI
endm
                add     DI,15*3
                loop    GP_ColorLoop

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Set GraphMode, set Palette
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

                pop     DX
                push    DI
                mov     AX,13h
                int     10h
                mov     AX,1012h
                inc     CH
                int     10h

;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°
; Get CharMap
;°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°

                push    ES
                mov     AX,1130h                ; get char map
                mov     BH,06h
                int     10h                     ; return ES:BP
                push    ES
                pop     DS ES DI
                mov     CX,800h
                mov     SI,BP
                rep     movsw
                pop     DS
endm


CallBuffer      equ     0               ; must be 0               ; 4K
ZBuffer         equ     4096                                      ; 256K
VirtScreen      equ     (ZBuffer+       SCREEN_SIZE*4)            ; 64K
BackRound       equ     (VirtScreen+    SCREEN_SIZE)              ; 64K
Vertex          equ     (BackRound+     SCREEN_SIZE)              ; 4096K
Faces           equ     (Vertex+        MAX_VERTEX*SIZE tVertex)  ; 1024K
                                                                  ; = 5632K
Textures        equ     580000h                                   ; 512K
ColorMap        equ     600000h                                   ; 64K
;plus 64k bug
; 64K is needed for initial 64K align EBP
XMS_END         equ     (620000h + 10000h)                        ; = 6272K

XMS_MIN         equ     ((XMS_END+1023)/1024)    ; in Kb
CONV_END        equ     74000h                   ; 470 Kb !NOT CHECKED AT RUN!
                                                 ; +DPMI data (QDPMI 70K)
CONV_MIN        equ     570                      ; 570 Kb

DFD_Sy          equ 0
DFD_Sx          equ 4
DFD_dXl         equ 8
DFD_dZl         equ 12
DFD_dSl         equ 16
DFD_dT0l        equ 20
DFD_dT1l        equ 24
DFD_dXr         equ 28
DFD_dZr         equ 32      ; not used
DFD_dSr         equ 36      ; not used
DFD_dT0r        equ 40      ; not used
DFD_dT1r        equ 44      ; not used

DFD_Scr         equ 48
DFD_Xl          equ 52
DFD_Zl          equ 56
DFD_Sl          equ 60
DFD_T0l         equ 64
DFD_T1l         equ 68
DFD_Xr          equ 72
DFD_Zr          equ 76      ; not used
DFD_Sr          equ 80      ; not used
DFD_T0r         equ 84      ; not used
DFD_T1r         equ 88      ; not used

DFD_Temp        equ 92
DFD_Longest     equ 96
DFD_dZx         equ 100
DFD_dSx         equ 104
DFD_dT0x        equ 108
DFD_dT1x        equ 112

DFD_Y           equ 116
DFD_Plus        equ 120
DFD_Y2          equ 124

MACRO DEBUGN n
                local L1,L2,L3
                pushad
                mov     EBX,n
                mov     ECX,8
L1:             mov     EDX,EBX
                shr     EDX,28
                cmp     DL,10
                jb      L2
                add     DL,'A'-'0'-10
L2:             add     DL,'0'
                mov     AH,2
                push    BX CX
                int     21h
                pop     CX BX
                shl     EBX,4
                loop    L1
                mov     ECX,1000000h
L3:             loop    L3
                popad
ENDM
