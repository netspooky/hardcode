;TORUS INSIDE by TomCat/Abaddon 2017
;raymarching with speedups + qbparty logo

;FASM source - assume AX:0 CL:255 SI:256 DI:65534
;video - https://youtu.be/4U3xjAsJyTU

;You can find here my first inspiration:
;http://www.taringa.net/posts/imagenes/14665878/Gifs-de-Chuck-Anderson.html
;and this helped me a lot: https://www.shadertoy.com/view/4lVXWw

RESX EQU 320
RESY EQU 200
COLOR EQU 41
LOGO EQU 67

_SI2 EQU SI-256-2
_BP2 EQU BP-RESX-2
_BPSI2 EQU BP-RESX+SI-256-2

ORG 256
 DW     4               ; constant 4 (ADD AL,0)

 STD                    ; clear memory
 MOV    CH,248+4
 REP    STOSB
 CLD
 MOV    CH,4
 REP    STOSB           ; DI: 5*320+191
 MOV    AL,13H
 INT    10H

 MOV    EDX,1F691D21H   ; logo data
l1:
 MOV    CL,70H
 AND    CL,DL
l2:
 MOV    EBX,30180830H
 MOV    AH,DL
l3:
 SHR    AH,1
 SALC
l4:
 IMUL   BP,DI,-2        ; mirroring
 MOV    [DI+BP+64],AL   ; letter "q"
 STOSB                  ; letter "b"
 DEC    BL
 JNZ    l4
 SHR    EBX,8
 JNZ    l3
 ADD    DI,RESX-16*8
 TEST   CL,3
 JNZ    l5
 DEC    DI
l5:
 LOOP   l2
 SHR    EDX,8
 JNZ    l1

 PUSH   0A000H-40       ; hiding 2 lines
 POP    ES
 MOV    BP,RESX
_x1:
 SUB    BX,BP           ; BX: colorcyclestep*4, starting from -80*4

nextpixel:
 FLDZ                   ; 0
 FLDZ                   ; 0 0
 PUSHA
 MOV    CL,64
 CWD
 XCHG   AX,DI
 DIV    BP
 SUB    AX,RESY/2
 XCHG   AX,DX
 CMP    AL,60           ; clip the most expensive pixels
 JB     skip2           ; on the left
 SUB    AX,RESX/2
_x2:
 CMP    AX,100          ; and on the right
 JG     skip2
 FILD   WORD [SI]       ; 4 0 0
 FLDZ                   ; 0 4 0 0

march:                  ; o z y x
 FLD    ST3             ; x o z y x
 FMUL   ST0,ST0         ; x2 o z y x
 FLD    ST2             ; z x2 o z y x
 FMUL   ST0,ST0         ; z2 x2 o z y x
 FADDP  ST1,ST0         ; z2+x2 o z y x
 FSQRT                  ; s o z y x
 FISUB  WORD [SI]       ; s-r o z y x
 NEG    CX
 JS     march
 FADD   DWORD [SI+2]    ; t s o z y x
 FIDIV  WORD [_SI2+_x2] ; t/(RX/2) s o z y x
 FLD    ST0             ; t/(RX/2) t/(RX/2) s o z y x
 FLD    ST0             ; t/(RX/2) t/(RX/2) t/(RX/2) s o z y x
m2:
 MOV    [BP+SI],DX
 XCHG   AX,DX
 FIMUL  WORD [BP+SI]    ; t*dy t/(RX/2) s o z y x
 FADDP  ST6,ST0         ; t/(RX/2) s o z y x
 CMC
 JNC    m2

 FIMUL  WORD [_SI2+_x1] ; 2*t s o z y x
 FLD    ST0
 FSTP   TWORD [BP+SI]   ; accuracy test1
 FIDIV  WORD [SI]       ; dz s o z y x
 FADDP  ST3,ST0         ; s o z y x
 FST    ST1             ; o z y x
 FSTP   TWORD [BP+SI-6] ; accuracy test2

 CMP    BYTE [BP+SI+8],254; very low value? exponent test for dz
 JNL    noskip
 CMP    [BP+SI],BX      ; no significat change? mantisa test for s
 MOV    BX,[BP+SI]
 JE     skip
noskip:
 LOOP   march

skip:
 FXCH   ST3             ; x z y m
 FPATAN                 ; atanzx y m
 FXCH   ST2             ; m y atanzx
 FPATAN                 ; atanym atanzx
 FADDP  ST1,ST0         ; atanym+atanzx
 FLDLG2                 ; lg2 atanym+atanzx
skip2:
 POPA
 MOV    [BP+SI],DX
 FIMUL  WORD [BP+SI]    ; counter atanym+atanzx
 FADDP  ST1,ST0         ; atanym+atanzx+counter
 FIMUL  WORD [_BPSI2+_c7]; 7*(atanym+atanzx+counter)
 FISTP  WORD [BP+SI]    ; -
 AND    WORD [BP+SI],3  ; mask 2 bits -> 4 colors
 IMUL   AX,[BP+SI],COLOR
 CMP    DX,SI           ; logo time?
 JNL    skip3
 CMP    [DI+BP],BH      ; logo or background?
 JB     skip3           ; hiding +1 line by adding BP
 MOV    AL,LOGO
skip3:
 STOSB
 TEST   DI,DI
nextframe:
 JNZ    nextpixel

 INC    DX
 INC    DX
 IN     AL,60H
 DEC    AX
 JZ     p1
 CMP    BX,[SI]
 JE     p2
p1:
 INC    BX
p2:
 MOV    [BP+SI],BX
 FILD   WORD [SI]
 FIDIVR WORD [BP+SI]
 FSTP   DWORD [SI+2]
 CMP    BX,4*4
 JNE    nextframe
;MOV    AL,3
;INT    10H
RETN
 DW     7               ; constant 7
_c7:
