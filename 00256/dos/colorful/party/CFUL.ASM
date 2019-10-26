; Colorful by TomCat/Abaddon
; 256b entry for Function 2016

; HiResTrueColor - 640x480x32bit
; MOV BX,121H
; .1:
; MOV AX,4F02H
; INT 10H
; MOV BL,12H
; AND AH,BH
; JNZ .1

ORG 100H
DIVIDER:
 MOV    BX,121H         ; VESA mode fixed now: 121H or 112H
 MOV    DI,4F02H
 MOV    AL,16           ; 16->AX (assume AX:0)
 MOV    CL,24           ; 24->CX (assume CH:0)
sphere1:
 MOV    DX,AX
sphere2:
 DEC    DX
sphere3:
 XCHG   AX,DX
 STOSW                  ; X:14...-14
 XCHG   AX,DX
 STOSW                  ; padding:16
 XCHG   AX,CX
 STOSW                  ; Y:24...1
 XCHG   AX,CX
 STOSW                  ; padding:16
 STOSW                  ; Z:16
 NEG    DX
 JS     sphere3
 JNZ    sphere2
 LOOP   sphere1         ; 31x24 spheres
 STOSW                  ; +1 reflective sphere: 16,16,4
 CMPSW                  ; 258->SI (assume SI:256)
 STOSW
 CMPSW                  ; 260->SI, greets to Pirx :)
 LODSW                  ; 04F02H->AX, 262->SI
.1:
;MOV    AX,4F02H
 INT    10H             ; greets to HellMood :)
;MOV    BL,12H
;AND    AH,BH
;JNZ    .1
;MOV    BP,2334         ; (assume BP:2334)
;FNINIT                 ; extremly slow instruction on new CPUs :(
;-------------------------------------------------------------------------
 MOV    BX,-480-1816    ; 2*PI = 1816 (1722 for VESA 112H)
 XCHG   AX,DX           ; 04FH->AX, hide the main sphere
restart0:
 MOV    [DI],DX         ; DX->Z coord of the main sphere
 MOV    DL,4            ; next time 4->Z
restart:
 PUSH   0A000H          ; greets to Picard :)
 MOV    [BYTE SI+(VideoPtr+3-262)],SP
 POP    ES
nextline:
 MOV    AX,-640         ; greets to devreci :)
nextpixel:
 PUSHA
projection:             ; greets to Digimind :)
 ADD    AX,344          ; X(-296...344), Y(-136...344) (326 for VESA 112H)
 MOV    [SI],AX
 XCHG   AX,BX           ; change axis, greets to Boreal :)
 FILD   WORD [BYTE SI+(DIVIDER+1-262)]
 FIDIVR WORD [SI]
 FSINCOS                ; cosx sinx
 INC    DI              ; loop 2x, greets to Rrrola :)
 JPE    projection      ; cosy siny cosx sinx
 FMUL   ST2,ST0         ; cosy siny cosx*cosy sinx
 FMULP  ST3,ST0         ; DX:siny DY:cosx*cosy DZ:sinx*cosy
 MOV    BX,12*2
 MOV    AX,4F05H
vector0:
 SUB    BX,DX
 FSTP   DWORD [BX+SI]   ; Direction vector + Camera location
 JNZ    vector0
 FILD   WORD [BYTE SI+(Radius2+1-262)]
Radius2:
 CALL   Trace           ; r2
 JNZ    nobank
Bank:
 MOV    DL,0
 INT    10H
 INC    BYTE [BYTE SI+(Bank+1-262)]
nobank:
random:
 IMUL   CX,BP           ; greets to sensenstahl :)
 MOV    [DI],CL         ; random color, CX:random seed
 FLDLG2                 ; Ambient
 FLD    DWORD [SI+12]   ; DZ Ambient
 FUCOMI ST0,ST1         ; greets to Baudsurfer :)
 FCMOVB ST0,ST1         ; MAX(Ambient,DZ) Ambient
 FIMUL  WORD [DI]       ; random*MAX(Ambient,DZ) Ambient
VideoPtr:               ; greets to baze :)
 FISTP  WORD [WORD ES:BX+0FFFCH]
 INC    BX
 JPO    random          ; loop 3x, lg2,lg2,lg2->Camera location
 POPA
 INC    AX
 JNZ    nextpixel
;IN     AL,60H          ; check for keypress
;CMP    AL,1            ; ESC quit
;JE     quit
 INC    BX
 JNZ    nextline
 MOV    [BYTE SI+(Bank+1-262)],CL
 MOV    BX,-480
 INC    BP              ; frame counter
 JPO    restart         ; skip the 1st three frames
 DEC    WORD [DI-8]     ; main sphere step left
 CMP    [DI-8],SP       ; final position of the main sphere
 JNL    restart0
 INT    16H
 XCHG   AX,CX           ; video mode #0
quit:
;MOV    AL,3
 INT    10H             ; greets to Spin :)
;RETN
;-------------------------------------------------------------------------
reflection:
 DEC    CX              ; no more reflection
nextsphere:
 FUCOMPP                ; greets to khamoon :)
 CMP    DI,AX
 JL     back
 FUCOMPP
 DEC    CX              ; sphere counter
 FLDLG2                 ; r2
Trace:
 FLDZ                   ; 0 r2
 FLDZ                   ; 0 0 r2
 MOV    BL,12
 SUB    DI,10
vector1:
 SUB    BX,DX
 FILD   WORD [BX+DI]    ; C' 0 0 r2
 FSUB   DWORD [BX+SI]   ; C'-P' 0 0 r2
 FLD    DWORD [BX+SI+12]; D' V' 0 0 r2
 FMUL   ST0,ST1         ; D*V V' 0 0 r2
 FADDP  ST3,ST0         ; V' 0 D.V r2
 FMUL   ST0,ST0         ; V*V 0 b r2
 FADDP  ST1,ST0         ; V.V b r2
 JNZ    vector1
 FLD    ST1             ; b V.V b r2
 FMUL   ST0,ST0         ; b2 V.V b r2
 FADD   ST0,ST3         ; b2+r2 V.V b r2
 FUCOMI ST1             ; b2+r2 V.V b r2
 JB     nextsphere
 FSUBRP ST1,ST0         ; b2+r2-V.V b r2
 FSQRT                  ; d b r2, greets to frag :)
 FUCOMI ST1             ; d b r2
 JNB    nextsphere
 FSUB   ST1,ST0         ; d b-d r2
 FADD   ST0,ST0         ; 2*d t0 r2
 FDIVRP ST2,ST0         ; t0 2*d/r2, greets to shr :)
 MOV    BL,12
vector2:
 SUB    BX,DX
 FLD    DWORD [BX+SI+12]; D' t0 2*d/r2
 FMUL   ST0,ST1         ; D'*t0 t0 2*d/r2
 FADD   DWORD [BX+SI]   ; I' t0 2*d/r2
 FST    DWORD [BX+SI]   ; Intersection point
 FISUB  WORD [BX+DI]    ; I'-C' t0 2*d/r2
 FMUL   ST0,ST2         ; N*2*d/r2  t0 2*d/r2
 FADD   DWORD [BX+SI+12]; N'+D' t0 2*d/r2
 FSTP   DWORD [BX+SI+12]; Reflection vector
 JNZ    vector2
 JCXZ   reflection
 ADD    CX,DI           ; for better random color pattern
back:                   ; seed = sphere number + memory location
 FUCOMPP
 SCASW                  ; [DI+1]:0
 ADD    WORD [BYTE SI+(VideoPtr+3-262)],DX
RETN 
