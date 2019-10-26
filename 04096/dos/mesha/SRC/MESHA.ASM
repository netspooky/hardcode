ideal
include "std.inc"
include "pmode4k.inc"
include "3d.inc"
include "mesha.inc"
segcode

global LANG DFL_Ambient:byte
global LANG DFL_Texture:dword
global LANG DFL_ColMap:dword

global LANG Pal_Generate:near
global LANG Calc_Matrix:near
global LANG Text_Fract:near
global LANG Calc_Normals:near
global LANG Calc_XY_Mapping:near
global LANG Calc_Sphere_Mapping:near
global LANG Text_Generate:near
global LANG Font_Generate:near
global LANG InterPolar:near
global LANG MakeModel:near
global LANG Render_Vertices:near
global LANG Draw_Faces:near
global LANG InterPolar:near
global LANG ProtMain:near

macro CalcTo
                call [d EBP-48]
endm
macro DrawFace
                call [d EBP-44]
endm
macro DrawTriangle
                call [d EBP-40]
endm
macro CalcDelta
                call [d EBP-36]
endm
macro ReadS8Bit_EDX
                call [d EDX-32]
endm
macro Random
                call [d EBP-28]
endm
macro Read4Bit
                call [d EBP-24]
endm
macro Read4Bit_EDX
                call [d EDX-24]
endm
macro Text_Avg
                call [d EBP-20]
endm
macro TF_Avg
                call [d EBP-16]
endm
macro Text_Wood
                call [d EBP-12]
endm
macro CN_SubVector
                call [d EBP-8]
endm
macro ReadS4Bit
                call [d EBP-4]
endm
macro ReadS4Bit_EDX
                call [d EDX-4]
endm



ifndef __DEBUG
                org 0h                          ; must start at 0
label SelData dword
PStart:         movzx   ESP,SP
                mov     DS,EAX
                mov     ES,EAX
                mov     SS,EAX
                pushad                          ; main program
                mov     ECX,CONST_TIMER
                mov     AL,36h
                out     43h,AL                  ; set timer speed
                mov     AL,CL
                out     40h,AL
                mov     AL,CH
                out     40h,AL
                sti
                MProtMain

                xor     ECX,ECX
                mov     AL,36h
                out     43h,AL                  ; restore timer speed
                mov     AL,CL
                out     40h,AL
                mov     AL,CH
                out     40h,AL
                popad
                cmp     AL,Sel_Data32           ; DPMI can't use global selector
                je      sh PExit
DPMIExit:       xor     EAX,EAX
                mov     AL,3
                int     10h
                mov     AH,4Ch
                int     21h
PExit:          cli                             ; set GDT to 16bit

                and     [b DI+o PMode_Data.Code32-o PMode_Data.IntSave-8+6],0Fh ;Code32 -> 16bit seg.
                and     [b DI+o PMode_Data.Data32-o PMode_Data.IntSave-8+6],0Fh ;Data32 -> 16bit seg.
                mov     SS,EAX                  ; restore SS to 16bit

                db      066h,0EAh               ; restore CS to 16bit
                dw      s $+4,Sel_Code32        ; now this is 16bit segment
                pop     EAX                     ; pop AX -> realmode SS
                mov     EBX,CR0                 ; return to realmode
                xor     BL,1
                mov     CR0,EBX
                db      0EAh
                dw      s o XMS_Exit
Code16Seg       dw      0
endif

proc _Read4Bit  near
                push    ESI
                shr     ESI,1
ifdef __DEBUG
                pushf
                mov     EAX,ESP
                and     EAX,080000000h
                or      ESI,EAX
                popf
endif
                lodsb
                jc      sh @@High
@@Low:          shl     EAX,4
@@High:         shl     EAX,24
                shr     EAX,28
                pop     ESI
                inc     ESI
                ret
endp

proc _ReadS4Bit near
                push    ESI
                shr     ESI,1
ifdef __DEBUG
                pushf
                mov     EAX,ESP
                and     EAX,080000000h
                or      ESI,EAX
                popf
endif
                lodsb
                jc      sh @@High
@@Low:          shl     EAX,4
@@High:         shl     EAX,24
                sar     EAX,28
                pop     ESI
                inc     ESI
                ret
endp

proc _ReadS8Bit  near
                push    EBX
                Read4Bit_EDX
                xchg    EBX,EAX
                ReadS4Bit_EDX
                shl     EAX,4
                add     EAX,EBX
                pop     EBX
                ret
endp

proc Int_Timer near
                pushad
                push    DS ES
IntSel:         mov     EAX,0
                or      EAX,EAX
                je      _s @@NoAnim
                mov     DS,EAX
                mov     ES,EAX
IntEBP:         mov     EDX,0
                mov     EBX,0FFFFFFFFh

                mov     ESI,o AniFade
                mov     AL,[ESI]
                add     AL,[DFL_Ambient]
                mov     [DFL_Ambient],AL
                jnz     sh @@FadeIn
                mov     [b ESI],0
@@FadeIn:       cmp     AL,64
                jne     sh @@FadeOut
                inc     EBX                    ; maskout all objects
                neg     [b ESI]
                mov     ESI,o Process
                mov     ECX,MAX_PROCESS
@@Disable:      lodsd
                lodsd
                lodsd
                lodsd
                mov     [ESI+tProcess.Data],EBX
                loop    @@Disable
@@FadeOut:

                mov     EDI,o Objects
                in      AL,60h
                cmp     AL,1
                jne     sh @@NoESC
                mov     [b EDI],0FFh               ; exit size
@@NoESC:
;                in      AL,61h
;                xor     AL,2
;                and     AL,254
;                out     61h,AL

                xor     ECX,ECX
                mov     CL,MAX_OBJECT
                xor     EAX,EAX
@@ObjLoop:      mov     AL,9
                and     [EDI],EBX
@@DLoop:        mov     EBP,[EDI+EAX*4+9*4]
                sar     EBP,6
                add     [EDI+EAX*4],EBP
                dec     EAX
                jne     sh @@DLoop
                add     EDI,size tObject
                loop    sh @@ObjLoop

                add     [b AniClock],20h
                jne     _s @@SkipAnim
                mov     ESI,o Process
                mov     ECX,MAX_PROCESS
@@Process:      lodsd
                xchg    EAX,EDI
                dec     [d ESI]
                lodsd
                lodsd
                lodsd
                jns     @@SkipProcess
                or      EAX,EAX
                je      _s @@SkipProcess
                pushad
                or      [b EDI],1
                xchg    EAX,ESI
                xchg    EBP,EAX
; EBP Process+12
; EDI Object
; ESI Code
@@Run:          push    o @@Run
                Read4Bit_EDX
                dec     EAX
                js      _s @@End
                je      _s @@Delay
                dec     EAX
                je      _s @@Jump
                dec     EAX
                je      _s @@Fade
                dec     EAX
                je      _s @@Size
                dec     EAX
                je      _s @@Proc
                dec     EAX
                je      _s @@Adjust
                inc     EAX
                inc     EAX
                push    EDI
                aam     6
                dec     AH
                jne     sh @@Clear
                aam     1               ; AH <- AL
                aad     12              ; AL = AH*12
                lea     EDI,[EDI+EAX+tObject.Dir]
rept 3
                local NotNeg
                Read4Bit_EDX
                shr     EAX,1
                pushfd
                xchg    EAX,ECX
                xor     EAX,EAX
                inc     EAX
                shl     EAX,CL
                popfd
                jnc     NotNeg
                shr     EAX,1
                neg     EAX
NotNeg:         shl     EAX,15
                stosd
endm
                pop     EDI
                ret
@@Clear:        aam     1               ; AH <- AL
                aad     12              ; AL = AH*12
                lea     EDI,[EDI+EAX+tObject.Dir]
                xor     EAX,EAX
                stosd
                stosd
                stosd
                pop     EDI
                ret
@@Jump:         ReadS8Bit_EDX
                add     ESI,EAX
                ret
@@Fade:         mov     [AniFade],2
                mov     EAX,32/8-1              ; half fade time
                jmp     sh @@Delay2
@@Size:         ReadS4Bit_EDX
                mov     [EDI],EAX
                ret
@@Proc:         ReadS8Bit_EDX
                lea     EBX,[ESI+EAX]           ; code address
                ReadS8Bit_EDX
                push    EBP
                xchg    EAX,EBP
                Read4Bit_EDX
                xchg    EAX,ECX
                xor     EAX,EAX
                stc
                rcl     EAX,CL
                xchg    EAX,ECX
                Read4Bit_EDX
                cmp     AL,8
                jb      sh @@CountOk
                add     AL,AL
                sub     AL,8
@@CountOk:      xchg    EAX,ECX
                pushad
                shl     EBP,7                   ; size tObject
                lea     EDX,[Objects+EBP+size tObject*128] ; EDX is signed! -128..127 -> 0..255
                xor     EBP,EBP
                xchg    EAX,EDX
                mov     EDI,[AniProcess]
@@ProcLoop:     stosd
                add     EAX,size tObject
                xchg    EAX,EBP
                stosd
                add     EAX,EDX
                xchg    EAX,ECX
                stosd
                xchg    EAX,EBX
                stosd
                xchg    EAX,EBX
                xchg    EAX,ECX
                xchg    EAX,EBP
                loop    @@ProcLoop
                mov     [AniProcess],EDI
                popad
                pop     EBP
                ret
@@Adjust:       mov     ECX,[DS:EBP-8]
                Read4Bit_EDX
                add     ECX,EAX
                xor     EAX,EAX
                mov     AL,9
@@AdjLoop:      mov     EBX,[EDI+EAX*4+9*4]
                imul    EBX,ECX
                sub     [EDI+EAX*4],EBX
                dec     EAX
                jne     sh @@AdjLoop
                ret
@@End:          xor     ESI,ESI
                jmp     @@Quit
@@Delay:        Read4Bit_EDX
                xchg    EAX,ECX
                xor     EAX,EAX
                stc
                rcl     EAX,CL
                dec     EAX
@@Delay2:       mov     [DS:EBP-12],EAX
@@Quit:         mov     [DS:EBP-4],ESI
                pop     EAX               ;get @@Run from stack
                popad
@@SkipProcess:  dec     ECX
                jne     _s @@Process

@@SkipAnim:
@@NoAnim:
ifndef __DEBUG
                mov     AL,20h
                out     20h,AL
endif
                pop     ES DS
                popad
ifndef __DEBUG
                iretd
else
                ret
endif
endp

; Same as Rotate, but output adjusted with move value

macro MRotateAdj
                MRotate
                fiadd    [d ESI]
                add      ESI,4
endm

; Rotate
; in:
;  *EDI coord x,y,z                      DWORD[3]
;  *ESI matrix row                       DWORD[3]
; out:
;  *ESI next array
;  EDX out coord
;  EAX,EBX changed, other saved

macro MRotate
                 fld     [d ESI]
                 fimul   [d EDI]
                 add     ESI,4
                 add     EDI,4
                 fld     [d ESI]
                 fimul   [d EDI]
                 add     ESI,4
                 add     EDI,4
                 fld     [d ESI]
                 fimul   [d EDI]
                 add     ESI,4
                 sub     EDI,8
                 faddp   st(1),st
                 faddp   st(1),st
endm


;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
;  DrawScreen : virt->screen,backround->virt,clear Z-Buffer
;
; Out:
;  ECX = 0
;  EAX,ESI,EDI changed
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MDrawScreen
                lea     EDI,[EBP+ZBuffer]
                mov     ECX,SCREEN_SIZE
                mov     EAX,0FFFFFFFFh                  ; clear ZBuffer
                rep     stosd
                mov     DX,3DAh
@@Delay1:       in      AL,DX
                test    AL,8
                jne     sh @@Delay1
@@Delay2:       in      AL,DX
                test    AL,8
                je      sh @@Delay2
                mov     ESI,EDI
                push    ESI
                mov     EDI,[PMode_Data.Screen]
                mov     ECX,SCREEN_SIZE/4
                rep     movsd
                pop     EDI
                mov     ECX,SCREEN_SIZE/4
                xor     EAX,EAX
ifdef __DEBUG
                rep     movsd
else
                rep     stosd
endif
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; CalcMatrix : calc rotate matrix
;
; In:
;  EAX  : size
;  *ESI : dir[3]
;         pos[3]
;         ofs[3]
;  Matrix[3] = rotate,pos
;  Matrix[4] = [Z0y,SizeY/2,Z0x,SizeX/2]
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MCalcMatrix
;                call Calc_Matrix
;endm
;proc Calc_Matrix
                mov     EDI,o Matrix - 4
                push    EDI
                stosd
                pop     EAX
;                mov     [d EDI],35490FDBh      ; Pi/400000h
;                mov     [d EDI],35C90FDBh      ; Pi/200000h
                mov     [d EDI],36490FDBh      ; Pi/100000h
;                mov     [d EDI],38490FDBh      ; Pi/10000h
rept 3
                fild    [d ESI]
                fmul    [d EDI]
                fcos
                fild    [d ESI]
                fmul    [d EDI]
                fsin
                add     ESI,4
endm
; sinC cosC sinB cosB sinA cosA
                fld     st(1)                  ; cosC
                fmul    st,st(4)               ; cosB
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]                ;[0][0] cosB*CosC
                add     EDI,4
                fld     st                     ; sinC
                fchs                           ; -
                fmul    st,st(4)               ; cosB
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]                ;[0][1] -cosB*sinC
                add     EDI,4
                fld     st(2)                  ; sinB
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]                ;[0][2] sinB
                add     EDI,4
                movsd                          ;[0][3] pos x
                fld     st(5)                  ; cosA
                fmul    st,st(4)               ; cosB
                fst     [d EDI+24+64]
                fidiv   [d EAX]
                fstp    [d EDI+24]             ;[2][2] cosA*cosB
                fld     st(4)                  ; sinA
                fchs                           ; -
                fmulp   st(4),st               ; cosB
; sinC cosC sinB [1][2] sinA cosA
                fld     st(5)                  ; cosA
                fmul    st,st(1)               ; sinC
                fld     st(2)                  ; cosC
                fmulp   st(7),st               ; cosA
; cosAsinC sinC cosC sinB [1][2] sinA cosAcosC
                fxch    st(2)                  ; cosC
                fmul    st,st(5)               ; sinA
                fxch    st(1)                  ; sinC
                fmulp   st(5),st               ; cosA
; sinAcosC cosAsinC sinB [1][2] sinCsinA cosAcosC
                fld     st                     ; sinAcosC
                fmul    st,st(3)               ; sinB
                fadd    st,st(2)               ; cosAsinC
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]                ;[1][0] cosA*sinC+sinA*sinB*cosC
                add     EDI,4
                fld     st(4)                  ; sinAsinC
                fmul    st,st(3)               ; sinB
                fchs
                fadd    st,st(6)               ; cosAcosC
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]                ;[1][1] cosA*cosC-sinA*sinB*sinC
                add     EDI,4
                fxch    st(3)                  ;[1][2]
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]
                add     EDI,4
                movsd
; cosAsinC sinB sinAcosC sinCsinA cosAcosC
                fmul    st,st(1)               ; sinB * cosAsinC
                faddp   st(2),st               ; sinAcosC
                fmulp   st(3),st               ; sinB * cosCcosA
                fst     [d EDI+4+64]
                fidiv   [d EAX]
                fstp    [d EDI+4]              ; [2][1] sinA*cosC+cosA*sinB*sinC
                fxch    st(1)
                fsubp   st(1),st
                fst     [d EDI+64]
                fidiv   [d EAX]
                fstp    [d EDI]                ; [2][0] sinA*sinC-cosA*sinB*cosC
                add     EDI,12
                movsd
                mov     EDI,ESI
                mov     ESI,o Matrix + 64
                MRotate
                fiadd    [d ESI-64]
                fistp    [d ESI-64]
                lodsd
                MRotate
                fiadd    [d ESI-64]
                fistp    [d ESI-64]
                lodsd
                MRotate
                fiadd    [d ESI-64]
                fistp    [d ESI-64]
;                ret
;endp
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; RenderVertices : rotates model's vertices & normals with matrix
;   vertex distance & normal angle to Z coord
;
; In:
;  *ESI = model
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MRender_Vertices
;                call Render_Vertices
;endm
;proc Render_Vertices
                pushad
                mov     EDI,[d ESI+tModel.VertexStart]
                mov     ECX,[d ESI+tModel.VertexEnd]

@@VertexLoop:   mov     ESI,o Matrix
                MRotateAdj                      ; rotate & move X
                MRotateAdj                      ; rotate & move Y
                MRotateAdj                      ; rotate & move Z
                add     EDI,32
@@NotBehind:    fxch    st(1)
                fdiv    st,st(1)
                fimul   [d ESI]                 ; Z0y
                fiadd   [d ESI+4]               ; SizeY/2
                fistp   [d EDI]                 ; store yy
                add     ESI,8
                add     EDI,4
                fxch    st(1)
                fdiv    st,st(1)
                fimul   [d ESI]                 ; Z0x
                fiadd   [d ESI+4]               ; SizeX/2
                fistp   [d EDI]                 ; store xx
                add     ESI,8
                add     EDI,4
                fistp   [d EDI]                 ; store Dist
                wait
                sub     [d EDI],4000h           ; limit distance
                add     ESI,32                  ; skip normalX normalY
                sub     EDI,24                  ; point to normal vector
                mov     EAX,[d EDI+12]
                mov     [d EDI+36],EAX
                sub     EDI,4                   ; clears carry flag
                mov     EAX,[d EDI+12]
                mov     [d EDI+36],EAX
LABEL RV_DoRefMap BYTE
                jc      sh @@NoRefMap           ; jc | jnc
                sub     ESI,32                  ; restore matrix to X
                MRotate                         ; rotate nx
                add     ESI,4                   ; skip pos in matrix
                fistp   [d EDI+36]              ; store t0
                shl     [d EDI+36],6
                MRotate                         ; rotate ny
                add     ESI,4                   ; skip pos in matrix
                fistp   [d EDI+40]              ; store t1
                shl     [d EDI+40],6
@@NoRefMap:     MRotate                         ; rotate nz
                add     EDI,32
                fistp   [d EDI]
                mov     EAX,[EDI]
                or      EAX,EAX
                js      sh @@NotNeg
                xor     EAX,EAX
@@NotNeg:       sar     EAX,6
                imul    EAX
                sar     EAX,9
                inc     AH                      ; avoid negative overflow at polydraw
                stosd                           ; store shade
                add     EDI,16
                cmp     EDI,ECX
                jne     _s @@VertexLoop         ; short jump
                popad
;                ret
;endp
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; DrawFaces : draw faces
;
; In:
;  *ESI : model
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
; EBX,ECX,EDX saved
proc _DrawTriangle
DT_Loop:        mov     EAX,[EBP+DFD_Y2]
                cmp     [EBP+DFD_Y],EAX
                jl      sh DT_Ok
                ret
DT_Ok:          lea     ESI,[EBP+DFD_Scr]
                lodsd                        ; Pos
                push    EAX
                lodsd                        ; Xl
                xchg    EDI,EAX
                lodsd                        ; Dist
                mov     [d EBP+DFD_Temp],EAX
                lodsd                        ; Shade
                xchg    EBX,EAX
                lodsd                        ; T0
                xchg    ECX,EAX
                lodsd                        ; T1
                xchg    EDX,EAX
                sar     EDI,16
                jns     sh @@NoLeft          ; check left cliping
                add     ESI,DFD_dZx - DFD_T1l - 4
                lodsd
                imul    EAX,EDI
                sub     [EBP+DFD_Temp],EAX
                lodsd
                imul    EAX,EDI
                sub     EBX,EAX
                lodsd
                imul    EAX,EDI
                sub     ECX,EAX
                lodsd
                imul    EAX,EDI
                sub     EDX,EAX
                add     ESI,DFD_Xr - DFD_dT1x - 4
                xor     EDI,EDI
@@NoLeft:       lodsd                        ; Xr
                sar     EAX,16
                cmp     EAX,[EBP+DFD_Sx]     ; check right cliping
                jl      sh @@NoRight
                mov     EAX,[EBP+DFD_Sx]
@@NoRight:      mov     ESI,EAX
                sub     ESI,EDI             ; EAX = pixel length
                pop     EAX
                jle     sh @@Skip
                add     EDI,EAX

@@PixelLoop:    mov     EAX,[EBP+DFD_Temp]
                cmp     EAX,[EBP+EDI*4+ZBuffer]
                jae     sh @@Behind
                mov     [EBP+EDI*4+ZBuffer],EAX
                mov     EAX,ECX
                shr     EAX,16
                ror     EDX,16
                mov     AH,DL
                ror     EDX,16
ORG $+3
LABEL DFL_Texture DWORD
ORG $-3
                mov     AL,[EAX+EBP+Textures]
                mov     AH,BH
ORG $+3
LABEL DFL_ColMap DWORD
ORG $-3
ORG $+4
LABEL DFL_Ambient BYTE
ORG $-4
                mov     AL,[EAX+EBP+ColorMap]
                mov     [EBP+EDI+VirtScreen],AL
@@Behind:
                add     EBX,[EBP+DFD_dSx]
                mov     EAX,[EBP+DFD_dZx]
                add     ECX,[EBP+DFD_dT0x]
                add     EDX,[EBP+DFD_dT1x]
                add     [EBP+DFD_Temp],EAX
                inc     EDI
                dec     ESI
                jnz     sh @@PixelLoop
@@Skip:
                lea     ESI,[EBP+DFD_Sx]
rept 7
                lodsd
                add     [ESI+DFD_Scr-DFD_Sx-4],EAX
endm
                inc     [d EBP+DFD_Y]
                jmp     _s DT_Loop
endp

; EBX ECX
; EDX saved
proc _CalcTo
                lea     EDI,[EBP+DFD_Y]
                mov     EAX,[EDI]
                mov     ESI,EAX
                sub     ESI,[EBX+tVertex.yy2]
                jns     sh @@NoPlus
                mov     EAX,[EBX+tVertex.yy2]
                imul    EAX,[EBP+DFD_Sx]
                mov     [EBP+DFD_Scr],EAX
                mov     EAX,[EBX+tVertex.yy2]
                xor     ESI,ESI
@@NoPlus:       inc     ESI
                stosd
                shl     ESI,16
                mov     EAX,[EBX+tVertex.yy]
                and     EAX,0FFFFh
                sub     ESI,EAX
                xchg    EAX,ESI
                stosd
                mov     EAX,[ECX+tVertex.yy2]
                cmp     EAX,[EBP+DFD_Sy]
                jl      sh @@NoBotton
                mov     EAX,[EBP+DFD_Sy]
@@NoBotton:     stosd
                ret
endp

; EBX ECX
; EDI = EBP+DFD_Xl | EBP+DFD_Xr
proc _CalcDelta
                lea     ESI,[EBX+tVertex.xx]
rept 5
                movsd
endm
                mov     EAX,[ECX+tVertex.yy]
                sub     EAX,[EBX+tVertex.yy]
                cmp     EAX,8000h
                jle     _s @@NoDelta
                add     EDI,DFD_dXl-DFD_Xl-5*4
                lea     ESI,[ECX+tVertex.xx]
                push    ECX EDX
                xchg    EAX,ECX
rept 5
                lodsd
                sub     EAX,[EDI+DFD_Xl-DFD_dXl]
                mov     EDX,EAX
                shl     EAX,16
                sar     EDX,16
                idiv    ECX
                stosd
                imul    [d EBP+DFD_Plus]
                shrd    EAX,EDX,16
                add     [EDI+DFD_Xl-DFD_dXl-4],EAX
endm
                pop     EDX ECX
@@NoDelta:      ret
endp

; EBX,ECX,EDX tVertex*
macro CheckSwap
                local NoSwap
                mov     EAX,[EBX+tVertex.yy]
                cmp     EAX,[ECX+tVertex.yy]
                jle     sh NoSwap
                xor     ESI,-1
                xchg    EBX,ECX
NoSwap:
endm

proc _DrawFace                                           ; EBX ECX EDX
                push    EBX ECX EDX
                mov     ESI,[EBX+tVertex.dist]
                or      ESI,[ECX+tVertex.dist]
                or      ESI,[EDX+tVertex.dist]
                js      _s @@Skip
                mov     ESI,0FFFFh                       ; A B C
                CheckSwap
                xchg    ECX,EDX                          ; A C B
                CheckSwap
                xchg    EBX,EDX                          ; B C A
                CheckSwap
                mov     EAX,[EBX+tVertex.yy]
                sar     EAX,16
                mov     [EBX+tVertex.yy2],EAX
                xchg    EBX,ECX                          ; C B A
                mov     EAX,[EBX+tVertex.yy]
                sar     EAX,16
                mov     [EBX+tVertex.yy2],EAX
                js      _s @@Skip
                mov     EDI,EAX
                xchg    EBX,EDX                          ; A B C
                mov     EAX,[EBX+tVertex.yy]
                sar     EAX,16
                mov     [EBX+tVertex.yy2],EAX
                cmp     EAX,[EBP+DFD_Sy]
                jge     _s @@Skip
                sub     EAX,EDI
                jge     _s @@Skip

                push    ESI
                lea     EDI,[EBP+DFD_Temp]
                mov     ESI,32                 ; tVertex.yy

                push    ECX EDX                ; Calc Temp
                mov     EAX,[ECX+ESI]
                sub     EAX,[EBX+ESI]
                mov     ECX,[EDX+ESI]
                sub     ECX,[EBX+ESI]
                mov     EDX,EAX
                shl     EAX,16
                sar     EDX,16
                idiv    ECX
                stosd
                lodsd
                pop     EDX ECX

                push    EDX                    ; Calc Longest
                mov     EAX,[EDX+ESI]
                sub     EAX,[EBX+ESI]
                imul    [d EBP+DFD_Temp]
                shrd    EAX,EDX,16
                xor     EDX,EDX
                add     EAX,[EBX+ESI]
                sub     EAX,[ECX+ESI]
                jns     sh @@NotNeg
                dec     EDX
@@NotNeg:       xor     EAX,EDX
                cmp     EAX,07FFFh
                ja      sh @@LongOk
                mov     EAX,07FFFh
@@LongOk:       xor     EAX,EDX

                stosd
                lodsd                          ; add ESI,4
                pop     EDX EAX

                xor     EAX,[d EBP+DFD_Longest]
                jns     _s @@Skip
rept 4
                push    EDX
                mov     EAX,[EDX+ESI]
                sub     EAX,[EBX+ESI]
                imul    [d EBP+DFD_Temp]
                shrd    EAX,EDX,16
                add     EAX,[EBX+ESI]
                sub     EAX,[ECX+ESI]
                mov     EDX,EAX
                shl     EAX,16
                sar     EDX,16
                idiv    [d EBP+DFD_Longest]
                stosd
                lodsd                         ; add ESI,4
                pop     EDX
endm
                xor     EAX,EAX
                mov     [EBP+DFD_Y],EAX
                mov     [EBP+DFD_Scr],EAX
                push    EBX ECX EDX
                CalcTo
                lea     EDI,[EBP+DFD_Xl]
                cmp     [d EBP+DFD_Longest],0      ; a b c
                jns     sh @@Ok1
                xchg    ECX,EDX                    ; a c b
@@Ok1:          CalcDelta
                xchg    ECX,EDX
                lea     EDI,[EBP+DFD_Xr]
                CalcDelta
                DrawTriangle
                pop     EDX ECX EBX
                mov     EAX,[EBP+DFD_Y]
                cmp     EAX,[EBP+DFD_Sy]
                jge     sh @@Skip
                push    EBX ECX EDX
                xchg    EBX,ECX                    ; b a c
                xchg    ECX,EDX                    ; b c a
                CalcTo
                lea     EDI,[EBP+DFD_Xl]
                cmp     [d EBP+DFD_Longest],0
                jns     sh @@Ok2
                lea     EDI,[EBP+DFD_Xr]
@@Ok2:          CalcDelta
                DrawTriangle
                pop     EDX ECX EBX
@@Skip:         pop     EDX ECX EBX
                ret
endp

macro MDrawFaces
;                call Draw_Faces
;endm
;proc Draw_Faces
                mov     ECX,[ESI+tModel.FaceEnd]
                mov     ESI,[ESI+tModel.FaceStart]
DF_LoopFace:    push    ECX
                lodsd
                xchg    EAX,EBX
                lodsd
                xchg    EAX,ECX
                lodsd
                xchg    EAX,EDX
                push    ESI
                DrawFace
                pop     ESI
                xchg    ECX,EDX
                lodsd
                or      EAX,EAX
                je      sh DF_Tri
                xchg    EAX,EDX
                push    ESI
                DrawFace
                pop     ESI
DF_Tri:         pop     ECX
                cmp     ESI,ECX
                jne     sh DF_LoopFace                  ; short jump
;                ret
;endp
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; RenderObject : render & draw object
;
; In:
;  *ESI : tObject+4
;  *EBX : ConstObject
;  EAX  : Size
; Out:
;  ESI,EBX next object
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MRenderObject
;                call RenderObject
;endm
;proc RenderObject
                pushad
                inc     EAX
                MCalcMatrix
                movzx   EAX,[b EBX]
                or      EAX,EAX
                je      _s @@Skip
                lea     ESI,[Models+EAX*8]
                mov     AL,[b EBX+MAX_OBJECT]
                shr     EAX,5
                adc     AH,72h
                mov     [RV_DoRefMap],AH        ; set refmap
                add     AL,Textures/10000h
                mov     [b DFL_Texture+2],AL    ; set texture
                mov     AL,[b EBX+MAX_OBJECT]
                shl     EAX,4
                mov     [b DFL_ColMap],AL       ; set color
                MRender_Vertices
                MDrawFaces
@@Skip:         popad
;                ret
;endp
endm
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; DrawLoop : main loop, until one object has a negative state
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MDrawLoop
;               call DrawLoop
;endm
;proc DrawLoop
DL_Loop:       cli
               mov      ESI,o Objects
               mov      EDI,o ObjectsDraw
               mov      ECX,SIZE tObject/4*100h
               rep      movsd
               sti                                 ; ESI = o ObjectsDraw
               mov      EBX,o Const_Object
               mov      CL,MAX_OBJECT
DL_Object:     lodsd
               sar      AL,1
               jnc      _s DL_NotValid             ; short jump
               js       _s DL_Exit                 ; short jump
               MRenderObject
DL_NotValid:   inc      EBX
               add      ESI,size tObject - 4
               dec      ECX
               jne      _s DL_Object
               MDrawScreen
               jmp      _s DL_Loop                 ; short jump
DL_Exit:
;               ret
;endp
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; MakeModel : makes model from packed data
;
; In:
;  EDX = vertex count
;  EBX = face count
;  EDI = first free model
; Out:
;  EBX,EDX,EDI updated
;  EAX,ECX,ESI changed
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MMakeModel
;                call MakeModel
;endm
;proc MakeModel
                mov     ESI,o Const_Model
                add     ESI,ESI                         ; OPTI!
                jmp     sh MM_NewModel
MM_Code:        Read4Bit                                ; get CODE
                shr     EAX,1
                jnc     _s MM_Mirror                    ; case 0,2,4: Mirror
                shr     EAX,1
                jnc     sh MM_Vertex                    ; case 1: Vertex short jump
                push    EAX
                Read4Bit
                calls   InterPolar
                calls   Calc_Normals
;               calls   Calc_XY_Mapping
                pop     EAX
                shr     EAX,1
                pushfd
                jnc     sh MM_NoSphere                  ; 3,11 XY 7,15 Shpere
                calls   Calc_Sphere_Mapping
MM_NoSphere:    mov     EAX,EDX
                stosd
                mov     EAX,EBX
                stosd
                popfd
                je      _s MM_Quit                      ; 3,7: Quit
                                                        ; 11,15: NewModel (& Vertex) short jump
MM_NewModel:    mov     EAX,EDX
                stosd
                mov     EAX,EBX
                stosd
                inc     ESI
                and     ESI,-2

MM_Vertex:      push    EDI
                Read4Bit                                ; read vertex count (max 15)
                or      EAX,EAX
                je      sh MM_NoVertex
                mov     CH,AL
                xchg    EDI,EDX
                Read4Bit                                ; shl vertex
                add     AL,8
                mov     DL,AL
                Read4Bit                                ; shl normal
                add     AL,8
                mov     DH,AL
MM_ReadVertex:  mov     CL,DL
                ReadS4Bit                               ; X
                shl     EAX,CL
                stosd
                ReadS4Bit                               ; Y
                shl     EAX,CL
                stosd
                ReadS4Bit                               ; Z
                shl     EAX,CL
                stosd
                mov     CL,DH
                ReadS4Bit                               ; nx
                shl     EAX,CL
                stosd
                ReadS4Bit                               ; ny
                shl     EAX,CL
                stosd
                ReadS4Bit                               ; nz
                shl     EAX,CL
                stosd
                add     EDI,SIZE tVertex-24
                dec     CH
                jne     sh MM_ReadVertex
                xchg    EDI,EDX
MM_NoVertex:    push    EDX
                Read4Bit                                ; face count
                or      EAX,EAX
                je      sh MM_NoFace
                xchg    ECX,EAX
                xchg    EDI,EBX                         ; new faces
MM_ReadFace:    ReadS4Bit
                shl     EAX,6
                add     EDX,EAX                         ; A | 1A
                mov     EAX,EDX
                stosd
                ReadS4Bit                               ; B | 1B 2B
                shl     EAX,6
                add     EDX,EAX
                mov     EAX,EDX
                stosd
                mov     [EDI+12],EAX
                ReadS4Bit                               ; C | 1C 2A
                shl     EAX,6
                add     EDX,EAX
                mov     EAX,EDX
                stosd
                mov     [EDI+4],EAX
                ReadS4Bit                               ; D | 2C
                shr     EAX,1
                je      sh MM_Skip
                jc      sh MM_2Tri
                shl     EAX,6
                add     EDX,EAX
                mov     EAX,EDX
                stosd
                jmp     sh MM_RF_Loop
MM_2Tri:        add     EDI,12
                shl     EAX,6
                add     EDX,EAX
                mov     EAX,EDX
                stosd
MM_Skip:        add     EDI,4
MM_RF_Loop:     loop    sh MM_ReadFace
                xchg    EDI,EBX
MM_NoFace:      pop     EDX EDI
MM_Code3:       jmp     _s MM_Code                      ; short jump

MM_Move:        push    EDI
                mov     EDI,[EDI-8+tModel.VertexStart]
                lea     EDI,[EDI+EAX*4]
                Read4Bit                                ; shl
                add     AL,8
                mov     CL,AL
                ReadS4Bit                               ; movement length
                shl     EAX,CL
MM_M_Loop:      add     [EDI],EAX
                add     EDI,size tVertex
                cmp     EDI,EDX
                jb      sh MM_M_Loop
                pop     EDI
MM_Code2:       jmp     sh MM_Code3

MM_Mirror:      MMirror
MM_Code1:       jmp     sh MM_Code2
MM_Quit:
;                ret
;endp
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; AnimatorInit : initalize animator
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MAnimatorInit
                mov     [d Process.Object],o Objects
                mov     ESI,o Const_Code
                add     ESI,ESI                         ; OPTI!
                mov     [d Process.Data],ESI
                mov     [d IntEBP+1],EBP
                mov     [d IntSel+1],DS
endm

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Random : generates random number
; In:
;   EBX  = interval size
; Out:
;   AL = AL+random(EBX/2)-EBX/4
;   other saved
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

proc _Random near
                push    EDX
                push    EAX
                mov     EAX,8088405h
                mul     [d RandomSeed]
                inc     EAX
                mov     [RandomSeed],EAX
                imul    EBX
                pop     EAX
                add     AL,DL
                pop     EDX
                ret
endp

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Text_Fract : generate fractal texture
;
; In:
;  *EDI = 256x256x8 texture ( texture must be filled with 10h)
;   EAX  = Fract_Const (32bit) (upper 24bit must 0!)
; Out:
;   *ESI = texture
;   *EDI = next texture
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

proc Text_Fract near
                mov     ESI,EDI
                add     EDI,10000h
                pushad
                xchg    EAX,EBX
                mov     CL,128

TF_Loop2:       mov     EDX,ESI
TF_Loop1:       mov     AL,[EDX]
                pushad
                add     DL,CL
                mov     EDI,EDX
                add     DL,CL
                TF_Avg
                popad
                add     DH,CL
                mov     EDI,EDX
                add     DH,CL
                TF_Avg
                push    EDX
                sub     DH,CL
                mov     AL,[EDX]
                add     DL,CL
                mov     EDI,EDX
                sub     DH,CL
                TF_Avg
                pop     EDX
                or      DH,DH
                jne     sh TF_Loop1
                add     DL,CL
                add     DL,CL
                jnz     sh TF_Loop1

                shr     EBX,1                   ; must clear EAX upper 24
                mov     EAX,EBX
                shr     EAX,1
                add     EBX,EAX
                inc     EBX                     ; EBX must > 0
                shr     CL,1
                jnz     sh TF_Loop2
                popad
                rets
endp

proc _TF_Avg near
                add     AL,[EDX]
                shr     AL,1
                Random
                cmp     AL,2
                jns     sh TF_MinOk
                mov     AL,2
TF_MinOk:       cmp     AL,1Fh
                js      sh TF_MaxOk
                mov     AL,1Fh
TF_MaxOk:       stosb
                ret
endp

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Text_Wood
;
; In:
;  *EDI = 256x256x8 texture
;   EAX upper 24bit =0!
;   EBX = Wood_Const (upper 24bit 0!)
;   ECX = 0!
; Out:
;  *EDI = next texture
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

proc _Text_Wood near
                push    EDI
                xor     EDX,EDX
TW_LineLoop:    push    EBX
                mov     CL,80h
                mov     AL,08h
                Random
                add     EDI,ECX
                mov     ESI,EDI
                shr     EBX,1
TW_XLoop:       Random
                inc     EAX
                cmp     AL,2
                jns     sh TW_MinOk
                mov     AL,2
TW_MinOk:       cmp     AL,1Fh
                js      sh TW_MaxOk
                mov     AL,1Fh
TW_MaxOk:       shr     AL,1
                stosb
                dec     ESI
                mov     [ESI],AL
                add     AL,AL
                loop    TW_XLoop
                pop     EBX
                inc     DL
                jne     sh TW_LineLoop
                pop     ESI
                mov     BL,2
                Text_Avg
                ret
endp

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Text_Avg : averages texture
;
; In:
;   *ESI = 256x256x8 texture
;   BL   = Avg count
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

proc _Text_Avg near
TA_Loop2:       pushad
                mov     EDI,o Buffer
                mov     ECX,10000h
                pushad
TA_Loop:        mov     AL,[ESI]
                add     AL,AL
                mov     EBX,ESI
                inc     BL
                add     AL,[EBX]
                inc     BL
                add     AL,[EBX]
                mov     EBX,ESI
                dec     BL
                add     AL,[EBX]
                dec     BL
                add     AL,[EBX]
                mov     EBX,ESI
                inc     BH
                add     AL,[EBX]
                mov     EBX,ESI
                dec     BH
                add     AL,[EBX]
                shr     AL,3
                inc     ESI
                stosb
                loop    TA_Loop
                popad
                xchg    ESI,EDI
                rep     movsb
                popad
                dec     BL
                jne     sh TA_Loop2
                ret
endp

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Pal_Generate : generates index palette
;
; In:
;   ECX = 0
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MPal_Generate
;                call Pal_Generate
;endm
;proc Pal_Generate
ifdef __DEBUG
                pushad
                mov     EBP,[d BaseMem]
endif
                lea     EDI,[EBP+ColorMap-16]
PG_Loop:        cmp     CL,16
                ja      sh PG_SkipInit
                mov     ESI,o VGAPal
PG_SkipInit:    mov     BL,CH
                cmp     BL,63
                jb      sh PG_Ok2
                mov     BL,63
PG_Ok2:         mov     BH,63
                sub     BH,BL
rept 3
                lodsb
                mov     DL,BL
                mul     BH
                shr     EAX,6
                add     DL,AL
                ror     EDX,8
endm
                mov     DL,0FFh
                ror     EDX,8
                push    ESI
                mov     ESI,o VGAPal
                xor     EBX,EBX
PG_Search:      xor     EAX,EAX
rept 3
local PG_Abs
                lodsb
                sub     AL,DL
                jns     sh PG_Abs
                neg     AL
PG_Abs:         add     AH,AL
                ror     EDX,8
endm
                cmp     DL,AH
                jbe     sh PG_Ok
                mov     DL,AH
                mov     BL,BH
PG_Ok:          ror     EDX,8
                inc     BH
                jne     sh PG_Search
                xchg    EAX,EBX
                stosb
                pop     ESI
                inc     CX
                jns     _s PG_Loop
ifdef __DEBUG
                popad
endif
;                ret
;endp
endm

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Text_Generate : generates textures
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MText_Generate
;                call Text_Generate
;endm
;proc Text_Generate
                lea     EDI,[EBP+Textures]
; Init textures & generate Solid Texture
                mov     ECX,80000h
                push    EDI
                mov     AL,10h                  ; fill everything with 10h
                rep     stosb
                pop     EDI
; Generate Chessboard Texture
                push    EDI
                xor     AH,AH
                mov     BH,10h
TC_Loop2:       xor     BL,BL
TC_Loop:        mov     CL,16
                rep     stosb
                xchg    AL,AH
                dec     BL
                jne     sh TC_Loop
                dec     BH
                jne     sh TC_Loop2
                pop     ESI
                inc     EBX                     ; mov BL,1
                Text_Avg
; Generate Fract Textures
                xor     EAX,EAX
                xor     EBX,EBX
                mov     ESI,o Const_Fract
                mov     CL,4
TF_TLoop:       lodsb
                xchg    EBX,EAX
                lodsb
                push    ESI
                calls   Text_Fract
                Text_Avg
                pop     ESI
                loop    TF_TLoop
; Generate Wood Textures
                mov     BL,16
                Text_Wood
                mov     BL,8
                Text_Wood
;                ret
;endp
endm

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Mirror : mirrors object (no mapping, but normal copied too)
;
; In:
;   EAX = coord to mirror (0,1,2)
;  *(EDI-8) = model
;   EDX = free vertex pointer
;   EBX = free face pointer
; Out:
;   EDX = new free vertex pointer
;   EBX = new free face pointer
;   EAX,ESI,EDI,ECX saved
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MMirror
                local M_Vertex,M_Middle,M_Face,@@Skip,M_FaceEnd
;proc _Mirror near
                push    EAX ESI EDI
                push    [d EDI-8+tModel.FaceStart]
                mov     ESI,[EDI-8+tModel.VertexStart]
                mov     EDI,EDX
M_Vertex:       cmp     [d ESI+EAX*4],0                  ; check if in middle
                mov     [d ESI+tVertex.xx],ESI           ; store pointer
                je      sh M_Middle
M_NotMiddle:    mov     [d ESI+tVertex.xx],EDI
                movsd                                    ; copy X,Y,Z to new
                movsd
                movsd
                movsd                                    ; copy nx,ny,nz
                movsd
                movsd
                sub     ESI,12                           ; mirror
                neg     [d ESI+EAX*4]
                sub     ESI,12                           ; mirror normal
                neg     [d ESI+EAX*4]
                add     EDI,SIZE tVertex-24
M_Middle:       add     ESI,SIZE tVertex
                cmp     ESI,EDX
                jne     sh M_Vertex
                mov     EDX,EDI
                pop     ESI
                push    EDX
                mov     EDI,EBX
M_Face:         cmp     ESI,EBX
                je      sh M_FaceEnd
                lodsd
                xchg    EDX,EAX
                mov     EAX,[EDX+tVertex.xx]
                stosd
                lodsd
                mov     [ESI-4],EDX
                mov     [ESI-8],EAX
                xchg    EDX,EAX
                mov     EAX,[EDX+tVertex.xx]
                stosd
                lodsd
                xchg    EDX,EAX
                mov     EAX,[EDX+tVertex.xx]
                stosd
                lodsd
                or      EAX,EAX                         ; D point -> may NULL
                je      sh @@Skip
                mov     [ESI-4],EDX
                mov     [ESI-8],EAX
                xchg    EDX,EAX
                mov     EAX,[EDX+tVertex.xx]
@@Skip:         stosd
                jmp     sh M_Face
M_FaceEnd:      mov     EBX,EDI
                pop     EDX EDI ESI EAX
;                ret
;endp
endm

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; InterPolar : interpolar object ( mapping will be damaged )
;   sizeof Buffer must be min ObjMaxVertex * 128
;   maximum 11 sides from one vertex to another vertices
; In:
;   AL = count
;  *(EDI-8) = model
;   EDX = free vertex pointer
;   EBX = free face pointer
; Out:
;   EDX = new free vertex pointer
;   EBX = new free face pointer
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

; IP_Vertex : interpolar 2 vertices
; In:
;   ECX,EAX = tVertex*
;   EDX = free vertex pointer
; Out:
;   EAX = new vertex pointer
;   EDX = updated
;   ECX not saved
;   ESI,EDI,EBX saved

macro MIP_Search
                local Search,NotFound
                push    EAX
                mov     ESI,o Buffer
                sub     EAX,[ESI]
                lea     ESI,[ESI+EAX*2]
Search:         lodsd                                   ; search for ECX
                cmp     EAX,ECX
                lodsd                                   ; EAX = new vertex
                jne     sh NotFound
                pop     ECX                             ; found return EAX
                jmp     sh IPV_Exit
NotFound:       or      EAX,EAX                         ; next
                jne     sh Search
                mov     [ESI-8],ECX
                mov     [ESI-4],EDX
                pop     EAX                             ; restore original EAX
endm

proc InterPolar near
IP_Loop:        dec     EAX
                je      _s IP_Quit
                push    ESI EDI EAX
                mov     EAX,[EDI-8+tModel.VertexStart]
                push    EAX
                push    [EDI-8+tModel.FaceStart]
                mov     [EDI-8+tModel.FaceStart],EBX
                dec     EAX
                dec     EAX                             ; start from buffer[4]
                mov     EDI,o Buffer
ifndef __DEBUG
                mov     ECX,EDI                         ; mov ECX,10000h
ELSE
                mov     ECX,10000h
endif
                stosd                                   ; Buffer[0] = start
                                                        ; (what is index for Buffer[4])
                xor     EAX,EAX                         ; clear buffer
                rep     stosd
                mov     EDI,EBX
                mov     ECX,EBX
                pop     EBX

IP_FaceLoop:    push    ECX
                mov     ESI,o Const_InterPolar3
                add     ESI,ESI                         ; OPTI!
                cmp     [d EBX+12],0                    ; check triangle or quad
                je      sh IP_SideLoop
                add     ESI,13*2                        ; other const table
IP_SideLoop:    ReadS4Bit
                sar     AL,1                            ; new vertex ? quit ?
                js      _s IP_SideEnd
                mov     EAX,[EBX+EAX*4]                 ; old vertex
                jc      sh IP_OldVertex
                xchg    EAX,ECX                         ; New vertex
                Read4Bit
                mov     EAX,[EBX+EAX*4]                 ; other vertex

                push    EBX ESI
                MIP_Search
                xchg    EAX,ECX
                MIP_Search
                xor     EBX,EBX
IPV_Loop:       xor     ESI,ESI
                inc     EBX
                inc     EBX
                inc     EBX
                add     ESI,[EAX+EBX*4]                  ; load normal
                add     ESI,[ECX+EBX*4]                  ; add other normal
                sar     ESI,1                            ; calc average (normal)
                mov     [EDX+EBX*4],ESI                  ; n = (n1+n2)/2
                sar     ESI,1
                dec     EBX
                dec     EBX
                dec     EBX
                add     ESI,[EAX+EBX*4]                  ; add vertex coord
                add     ESI,[ECX+EBX*4]                  ; add vertex coord
                sar     ESI,1
                mov     [EDX+EBX*4],ESI                  ; n = (n1+n2)/2
                inc     EBX
                cmp     EBX,3
                jne     sh IPV_Loop
                mov     EAX,EDX
                add     EDX,SIZE tVertex
IPV_Exit:       pop     ESI EBX

IP_OldVertex:   stosd
                jmp     _s IP_SideLoop                  ; short jump

IP_SideEnd:     pop     ECX
                add     EBX,size tFace
                cmp     EBX,ECX
                jne     _s IP_FaceLoop
                mov     EBX,EDI

                pop     ESI
IP_NormDiv:     sar     [d ESI+tVertex.nx],2
                lodsd
                sar     [d ESI+tVertex.nx],2
                lodsd
                sar     [d ESI+tVertex.nx],2
                lodsd
                add     ESI,32-12
                cmp     ESI,EDX
                jne     sh IP_NormDiv

                pop     EAX EDI ESI
                jmp     _s IP_Loop
IP_Quit:
                rets
endp

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Calc_Sphere_Mapping
;
; In:
;  *(EDI-8) = tModel
;  EDX = last Vertex
; Out:
;  save all regs
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

proc Calc_Sphere_Mapping near
                pushad
                mov     ESI,[EDI-8+tModel.VertexStart]
CSM_Loop:       fild    [ESI+tVertex.x]
                lodsd
                fabs
                fld     st
                fmul    st,st
                fild    [ESI-4+tVertex.y]
                lodsd
                fld     st
                fmul    st,st
                fxch    st(3)
                fpatan
                fimul   [CSFix]
                fistp   [ESI-8+tVertex.tx]
                faddp   st(1)
                fsqrt
                fild    [ESI-8+tVertex.z]
                lodsd
                fpatan
                fimul   [CSFix]
                fadd    st,st
                fistp   [ESI-12+tVertex.ty]
rept 3
                lodsd
                sar     EAX,2
                sub     [ESI-4],EAX
endm
                add     [ESI-24+tVertex.tx],80000h
                add     ESI,SIZE tVertex-24
                cmp     ESI,EDX
                jne     sh CSM_Loop
                popad
                rets
endp

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Calc_XY_Mapping : generates X,Y texture mapping
; In:
;  *(EDI-8) = tModel
;  EDX = last Vertex
; Out:
;  save all regs
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

macro MCalc_XY_Mapping
                pushad
                mov     ESI,[EDI-8+tModel.VertexStart]
CXY_Loop:       mov     ECX,[ESI+tVertex.z]
                lodsd                           ; load X
                add     EAX,ECX
                shl     EAX,4
                mov     [ESI-4+tVertex.ty],EAX
                lodsd                           ; load Y
                add     EAX,ECX
                shl     EAX,4
                mov     [ESI-8+tVertex.tx],EAX
                add     ESI,SIZE tVertex-8
                cmp     ESI,EDX
                jne     sh CXY_Loop
                popad
endm

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Calc_Normals : generates normals of vertices (mapping lost!)
;
; in:
;  *(EDI-8) = tModel
;  EDX = last Vertex+1
;  EBX = last Face+1
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

; Calc_Normal : calculate face's normal vector, with 1 length
; In:
;  *ESI = Face
; Out:
;   ECX,ESI saved

; EBX EDX = tVertex*
; EBX,EDI inc by 12, EDX saved
proc _CN_SubVector near
                push    EDX
                mov     EAX,[EBX]
                sub     EAX,[EDX]
                stosd
                add     EDX,4
                add     EBX,4
                mov     EAX,[EBX]
                sub     EAX,[EDX]
                stosd
                add     EDX,4
                add     EBX,4
                mov     EAX,[EBX]
                sub     EAX,[EDX]
                stosd
                add     EDX,4
                add     EBX,4
                pop     EDX
                ret
endp

proc Calc_Normals near
                pushad
                mov     ESI,[EDI-8+tModel.FaceStart]
                mov     EDI,[EDI-8+tModel.VertexStart]
                push    EDX EDI
                xor     EAX,EAX
CN_Clear:       add     EDI,12               ; clears nx,ny,nz
                stosd
                stosd
                stosd
                add     EDI,SIZE tVertex-24
                cmp     EDI,EDX
                jne     sh CN_Clear

                mov     ECX,EBX

CN_CalcFace:    push    ESI
                mov     EDI,o Temp
                lodsd                                   ; vertex A
                xchg    EBX,EAX
                lodsd                                   ; vertex B
                xchg    EDX,EAX
                CN_SubVector                            ; vector BA
                lodsd                                   ; vertex C
                xchg    EBX,EAX
                CN_SubVector                            ; vector BC
                mov     ESI,o Const_CalcNormal
                add     ESI,ESI                         ; OPTI!
                mov     BL,3
MCN_Loop:       ReadS4Bit
                fild    [d EDI+EAX*4]
                ReadS4Bit
                fimul   [d EDI+EAX*4]
                ReadS4Bit
                fild    [d EDI+EAX*4]
                ReadS4Bit
                fimul   [d EDI+EAX*4]
                fsubp   st(1),st
                dec     BL
                jne     sh MCN_Loop
                pop     ESI
                mov     BL,4
CN_FaceLoop:    lodsd                            ; vertex pointer
ifdef __DEBUG
                or      EAX,EAX
                je      sh NoVertex
endif
                fld     st(2)
                fld     st(2)
                fld     st(2)
rept 3
                fld     [d EAX+tVertex.nx]       ; D point -> may NULL
                faddp   st(1),st                 ; PStart begin is overwrited
                fstp    [d EAX+tVertex.nx]       ; no problem :))) (before PMain)
                add     EAX,4
endm
NoVertex:       dec     BL
                jne     sh CN_FaceLoop
                fstp    st
                fstp    st
                fstp    st
                cmp     ESI,ECX
                jne     sh CN_CalcFace

                pop     EDI EDX
CN_DivLoop:     fldz
rept 3
                fld     [d EDI+tVertex.nx]
                fld     st
                fmul    st,st
                faddp   st(2),st
                fxch    st(1)
                add     EDI,4
endm
                fsqrt
                fild    [d Fix16]
                fxch    st(1)
                fdivp   st(1)
rept 3
                sub     EDI,4
                fmul    st(1),st
                fxch    st(1)
                fistp   [d EDI+tVertex.nx]
endm
                fstp    st
                add     EDI,SIZE tVertex
                cmp     EDI,EDX
                jne     sh CN_DivLoop

CN_NoFace:      popad
                MCalc_XY_Mapping
                rets
endp

;같� 98' CHECKED 같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Font_Generate : generates font
;
; must be before the object generator rutines
; out:
;    EDX = vertex pointer
;    EBX = face pointer
;    ECX = next free model
;
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

; CheckFace : check if face exists there, if not, create it
; In:
;  *ESI = calc data
;    Pos:BYTE  = Pos+10h for check is face valid
;    Pos[4]:BYTE = for vertices to build face
;  *EDI = Buffer Boolean matrix item
;  EBX = face pointer

macro MFG_CheckFace
                xor     EAX,EAX
                lodsb
                or      AL,AL
                je      sh FG_Ok
                test    [b EAX*4+EDI-40h],80h
FG_Ok:          lodsd
                jne     sh FG_NoFace

                pushad
                mov     ESI,EDI
                mov     EDI,EBX
                xchg    EBX,EAX
                mov     ECX,4

FG_Loop:        movzx   EDX,BL
                shr     EBX,8
                shr     EDX,1
                mov     EAX,[d EDX*4+ESI+200h]
                jc      sh FG_NotBehind
                add     EAX,SIZE tVertex
FG_NotBehind:   stosd
                loop    FG_Loop

                popad
                add     EBX,SIZE tFace
FG_NoFace:
endm

; CheckVertex : check if vertex exists there,
;               if not then create it (forward & back too)
; In:
;  *ESI = calc data
;  *EDI = Boolean matrix next item
;  EDX = Vertex pointer
;  EBX = pos * 256
; Out:
;  EDX updated
;  ESI++
;  EAX changed, all other saved

macro MFG_CheckVertex
                                                ; check if there is a vertex
                Read4Bit
                lea     EAX,[EAX*4+EDI+200h-4]
                cmp     [d EAX],0
                jne     sh @@Exists
                mov     [d EAX],EDX
                pushad
                mov     EDI,EDX
                inc     EDI
                dec     ESI
                Read4Bit
                sub     BH,AL
                dec     BH
                mov     EAX,EBX
                and     AH,7
                sub     EAX,400h
                neg     EAX
                mov     [EDI+SIZE tVertex],EAX
                stosd
                mov     EAX,EBX
                shr     AH,3
                sub     EAX,800h
                neg     EAX
                mov     [EDI+SIZE tVertex],EAX
                stosd
                mov     EAX,100h
                mov     [EDI+SIZE tVertex],EAX
                neg     EAX
                stosd
                popad
                add     EDX,SIZE tVertex * 2
@@Exists:
endm

macro MFont_Generate
;                call Font_Generate
;endm
;proc Font_Generate
                mov     ESI,o CharMap+32*16
                mov     CL,96                   ; 32..96 ascii char
                lea     EDX,[EBP+Vertex]        ; first vertex
                lea     EBX,[EBP+Faces]         ; first face
                mov     EDI,o Models

FG_CharLoop:    mov     EAX,EDX
                stosd
                mov     EAX,EBX
                stosd
                push    ECX EDX EDI

                mov     EDI,o Temp              ; *EDI = BoolMatrix, *(EDI+200h) = VertexMatrix
                push    EDI
                xor     EAX,EAX
                mov     ECX,400h
                rep     stosd                   ; init buffer
                pop     EDI
                push    EDI
                mov     CL,128
FG_PixelLoop:   test    CL,7
                jne     sh FG_NoRead
                lodsb
FG_NoRead:      stosd                           ; 7bit in bool table
                add     AL,AL
                jnc     sh FG_NoPixel           ; check pixel
                                                ; add vertices or adjust them
                pushad
                mov     ESI,o Const_FontVertex
                add     ESI,ESI                 ; OPTI!
                xor     EBX,EBX
                mov     BH,CL
                mov     CL,4
@@FG_VLoop:     MFG_CheckVertex
                loop    @@FG_VLoop
                mov     [ESP+14h],EDX
                popad

FG_NoPixel:     loop    FG_PixelLoop

                pop     EDI
                push    ESI
                mov     CL,80h
FG_PixelLoop2:  test    [b EDI],80h
                je      sh FG_NoPixel2
                mov     CH,6
                mov     ESI,o Const_FontFace
FG_FaceLoop:    MFG_CheckFace
                dec     CH
                jne     sh FG_FaceLoop
FG_NoPixel2:    add     EDI,4
                loop    FG_PixelLoop2

                pop     ESI EDI EAX
                cmp     EAX,EDX
                je      sh FG_NoVertex
                calls   Calc_Normals
;               calls   Calc_XY_Mapping
FG_NoVertex:    mov     EAX,EDX
                stosd
                mov     EAX,EBX
                stosd
                pop     ECX
                dec     CL
                jne     _s FG_CharLoop                   ; short jump
;                ret
;endp
endm

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; ProtMain protected mode main function
; In:  -
; Out:
;  no regs saved
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

ifdef __DEBUG
Const_CallData2 dd o _CalcTo
                dd o _DrawFace
                dd o _DrawTriangle
                dd o _CalcDelta
                dd o _ReadS8Bit
                dd o _Random
                dd o _Read4Bit
                dd o _Text_Avg
                dd o _TF_Avg
                dd o _Text_Wood
                dd o _CN_SubVector
                dd o _ReadS4Bit
endif
proc _Mirror near
endp

proc ProtMain near
ifdef __DEBUG
                pushad
                mov     EBP,[d BaseMem]
endif
                xor     EAX,EAX
                mov     EDI,EBP
                mov     ECX,XMS_END/4
                rep     stosd
ifndef __DEBUG
                add     EBP,CALL_SIZE*4
                or      EBP,0FFFFh
                inc     EBP
                mov     EDI,10000h
                mov     ECX,(CONV_END-10000h)/4
                rep     stosd
else
                mov     EDI,o StackPos
                mov     ECX,o Code32End
                sub     ECX,EDI
                shr     ECX,2
                rep     stosd
endif
                lea     EDI,[EBP-CALL_SIZE*4]
ifndef __DEBUG
                mov     ESI,o Const_CallData
                mov     CL,CALL_SIZE+2
CallInit:       movsw
                stosw
                loop    CallInit
else
                mov     ESI,o Const_CallData2
                mov     CL,CALL_SIZE
                rep     movsd
                mov     ESI,o Const_CallData + CALL_SIZE*2
                movsw
                stosw
                movsw
                stosw
endif
                mov     EDI,o Matrix + 50
                mov     CL,4
MatrixInit:     movsw
                stosw
                loop    MatrixInit

;ifndef __DEBUG
                MPal_Generate
;endif
                MText_Generate
                MFont_Generate
                MMakeModel
                MAnimatorInit
ifndef __DEBUG
                MDrawLoop
ELSE
                sub EDX,Vertex
                sub EDX,EBP
                shr EDX,6
                mov [VCount],EDX
                sub EBX,Faces
                sub EBX,EBP
                shr EBX,4
                mov [FCount],EBX
                popad
endif
                rets
endp

;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

ifdef __DEBUG
global LANG DebugInit:near
global LANG DebugLoop:near
global LANG DebugDraw:near

proc DebugInit near
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같
;
; Generate Palette
;
; DataType:
;   [[Start(upper 4bit)+Inc(lower 4bit)] * 3(R,G,B)] * 8 (Colors)
;   ValRGB(n) = Start*4 + Inc*n/8        n:0..31
;같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같같

                pushad
                mov     EDI,o VGAPal
                mov     ESI,o Const_PalData
                mov     BL,16
GP_ColorLoop:   mov     BH,3
GP_RGBLoop:     push    EDI
                lodsb
                cbw
                shl     AX,2
                mov     DX,AX
                add     DX,DX
                and     AL,0Fh*4
                and     DL,128
                mov     ECX,16

GP_Loop:        stosb
                inc     EDI
                inc     EDI
                add     AH,DL
                adc     AL,DH
                loop    GP_Loop
                pop     EDI
                inc     EDI
                dec     BH
                jne     sh GP_RGBLoop
                add     EDI,15*3
                dec     BL
                jne     sh GP_ColorLoop
                popad
                ret
endp
proc DebugLoop near
                pushad
                mov     EBP,[d BaseMem]
                cli
                mov     ESI,o Objects
                mov     EDI,o ObjectsDraw
                mov     ECX,(SIZE tObject)*100h/4
                rep     movsd
                sti
                mov     EBX,o Const_Object
                mov     CL,MAX_OBJECT
@@LoopObj:      lodsd
                sar     AL,1
                jnc     _s @@NotValid
                js      _s @@Fail
                MRenderObject
@@NotValid:     inc     EBX
                add     ESI,size tObject - 4
                dec     ECX
                jne     _s @@LoopObj
                MDrawScreen
                popad
                xor     EAX,EAX
                ret
@@Fail:         popad
                mov     EAX,1
                ret
endp
proc DebugDraw near
                pushad
                mov     EBP,[d BaseMem]
                MDrawScreen
                popad
                ret
endp
endif

ends

include "static.inc"

end
