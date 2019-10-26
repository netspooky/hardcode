; Colorful with page flipping by TomCat/Abaddon
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
 ADD    AL,16           ; 16->AX (assume AX:0)
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
 STOSW                  ; +1 reflective sphere: 16,16,2
 CMPSW                  ; 258->SI (assume SI:256)
 STOSW
 CMPSW                  ; 260->SI, greets to Pirx :)
 LODSB                  ; 02H->AL, 261->SI
 STOSW
;MOV    BP,2334         ; (assume BP:2334)
;FNINIT                 ; extremly slow instruction on new CPUs :(
;---------------------------------------------------------------------
restart:
 MOV    DX,000H
.1:
 MOV    AH,4FH          ; greets to HellMood :)
 INT    10H
 MOV    AL,02H
;MOV    BL,12H
;AND    AH,BH
;JNZ    .1
 XCHG   AX,DX
 PUSH   0A000H          ; greets to Picard :)
 MOV    [BYTE SI+(VideoPtr+3-261)],SP
 POP    ES
 MOV    BX,-512
nextline:
 MOV    AX,-640         ; greets to devreci :)
nextpixel:
 PUSHA
projection:             ; greets to Digimind :)
 ADD    AX,354          ; X(-286...354), Y(-126...354)
 MOV    [SI],AX
 XCHG   AX,BX           ; change axis, greets to Boreal :)
 FILD   WORD [BYTE SI+(DIVIDER+1-261)]
 FIDIVR WORD [SI]
 FSINCOS                ; cosx sinx
 INC    DX              ; loop 2x, 4->DX, greets to Rrrola :)
 JPE    projection      ; cosy siny cosx sinx
 FMUL   ST2,ST0         ; cosy siny cosx*cosy sinx
 FMULP  ST3,ST0         ; DX:siny DY:cosx*cosy DZ:sinx*cosy
 MOV    BX,12*2
 MOV    AX,4F05H
vector0:
 SUB    BX,DX
 FSTP   DWORD [BX+SI]   ; Direction vector + Camera location
 JNZ    vector0
 FILD   WORD [BYTE SI+(Radius2+1-261)]
Radius2:
 CALL   Trace           ; r2
 JNZ    nobank
Bank:
 MOV    DL,20
 INT    10H
 INC    BYTE [BYTE SI+(Bank+1-261)]
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
 XOR    [BYTE SI+(restart+2-261)],DL
 JZ     noreset
 MOV    [BYTE SI+(Bank+1-261)],CL
noreset:
;MOV    BL,80H          ; waiting for vertical retrace
 MOV    AL,07h
 INC    BP              ; frame counter
 JPO    restart         ; skip the 1st three frames
;MOV    [DI-1],CL       ; show the main sphere
 DEC    WORD [DI-10]    ; main sphere step left
;CMP    [DI-10],SP      ; final position of the main sphere
 JNZ    restart
;INT    16H
quit:
;XCHG   AX,DX           ; 2->AX
;INC    AX
;INT    10H             ; greets to Spin :)
;RETN
;---------------------------------------------------------------------
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
 ADD    WORD [BYTE SI+(VideoPtr+3-261)],DX
RETN 
