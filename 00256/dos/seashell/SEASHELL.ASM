;seashell - 256b intro by TomCat/Abaddon 

;this effect was first used in our 64k intro called Pied
;shown at ASM'95 in Helsinki

;later it was coded as a 4k called Shells1
;and finally here is the 256b version!

;original object comes from
;the Standard Procedural Database by Eric Haines
;NFF Shell Database coded in C by Thierry Leconte

;FASM source - assume CH:0

RESX EQU 640
RESY EQU 480
SPEED EQU 8
SPEED2 EQU 128
FRAMES EQU SPEED*20
FRAMES2 EQU SPEED2*20
VAR EQU XOFFSET

ORG 256
 PUSH   0A000H
 POP    ES
 MOV    BX,121H
video:
 MOV    AX,4F02H
 INT    10H
 MOV    BL,12H
 CMP    AH,BH
 JE     video

 MOV    SI,VAR
 SUB    BX,BX
 MOV    CL,FRAMES
nextpart:
 FNINIT                         ; -
 FILD   WORD [SI-VAR+Angle]     ; angle
nextframe:
 PUSH   CX
 FLD    DWORD [SI-VAR+ConstE]   ; 0.15*L2E angle
 FMUL   ST0,ST1                 ; 0.15*L2E*angle angle
 FLD    ST0                     ; 0.15*L2E*angle 0.15*L2E*angle angle
 FRNDINT                        ; int 0.15*L2E*angle angle
 FSUB   ST1,ST0                 ; int frac angle
 FXCH   ST1                     ; frac int angle
 F2XM1                          ; 2X-1 int angle
 FLD1                           ; 1 2X-1 int angle
 FADDP  ST1,ST0                 ; 2X int angle
 FSCALE                         ; R int angle
 FIMUL  WORD [SI-VAR+Scale]     ; k*R int angle
 FLD    ST2                     ; angle R int angle
 FSINCOS                        ; cos sin R int angle
 FMUL   ST0,ST2                 ; Rc sin R int angle
 FXCH   ST3                     ; int sin R Rc angle

 MOV    DI,SP
 CWD
 MOV    CX,RESY
nextline:
 MOV    BP,RESX
nextpixel:
 SUB    DI,SP
 JNZ    nobank
 PUSH   AX
 MOV    AX,4F05H
 INT    10H
 POP    AX
 INC    DX
nobank:
 PUSHA
 CMP    AL,4FH                  ; first frame?
 JNZ    TestSphere
 XCHG   AX,BP                   ; temp index fix
 FILD   WORD [SI-VAR+MAXCOL]
 FISUB  WORD [BX-8]             ; background intensity
 MOV    BL,COLOR1-COLOR2        ; background color
back:
 FIST   WORD [SI+BP]            ; Intensity N.H sin R Rc angle
 FLD    DWORD [SI-VAR+Shine]    ; Shine Intensity N.H sin R Rc angle
VideoPtr:
 MOV    AX,[SI+BP]              ; Intensity
 NOT    AH                      ; Shadow test
 AND    AL,AH                   ; Diffuse
 ADD    AL,37                   ; Diffuse+Ambient
 MUL    BYTE [BX+SI-VAR+COLOR2] ; Color*(Diffuse+Ambient)
 FCOMI  ST0,ST2                 ; Shine Intensity N.H sin R Rc angle
 SALC                           ; Highlight test
 OR     AL,AH                   ; Color*(Diffuse+Ambient)+Specular
 STOSB
 INC    BX
 JPO    VideoPtr
 XCHG   AX,DX                   ; Z coord
 STOSB                          ; write Z buffer

pixelok:
 FUCOMPP                        ; ? sin R Rc angle
 POPA
 DEC    BP
 JNZ    nextpixel
 LOOP   nextline
 FUCOMPP                        ; R Rc angle
 FUCOMPP                        ; angle
 FADD   DWORD [SI-VAR+Step]     ; angle+step
 SALC                           ; change AL after the first frame
 POP    CX
 LOOP   nextframe
 MOV    CH,FRAMES2/256          ; part2 frames
 XOR    BYTE [SI-VAR+Step+3],2  ; part2 step
 JPE    nextpart
 INT    16H                     ; wait for keypress
 MOV    AX,3                    ; video mode 3
 INT    10H                     ; happy clean exit
RETN                            ; :)

COLOR2  DB 102;,204,255         ; B G R - sphere
Angle   DW -44                  ; -14*PI ... 6*PI

TestSphere:
 FCMOVNE ST0,ST2                ; R sin R Rc angle
 FADD   ST0,ST0                 ; 2R sin R Rc angle
 FIADD  WORD [BX-8]             ; 2R+SY sin R Rc angle
 FMUL   DWORD [SI-VAR+ASPECT]   ; Aspect*DY sin R Rc angle
 FISUB  WORD [SI-VAR+XOFFSET]   ; DY sin R Rc angle
 FLD    ST3                     ; Rc DY sin R Rc angle
 FIADD  WORD [SI-VAR+XOFFSET]   ; CX DY sin R Rc angle
 FISUB  WORD [BX-16]            ; DX DY sin R Rc angle

 FLD    ST0                     ; DX DX DY sin R Rc angle
 FMUL   ST0,ST0                 ; DX2 DX DY sin R Rc angle
 FLD    ST2                     ; DY DX2 DX DY sin R Rc angle
 FADD   ST2,ST0                 ; DY DX2 DX+DY DY sin R Rc angle
 FMUL   ST0,ST0                 ; DY2 DX2 DX+DY DY sin R Rc angle
 FADDP  ST1,ST0                 ; DX2+DY2 DX+DY DY sin R Rc angle
 FLD    ST4                     ; R DX2+DY2 DX+DY DY sin R Rc angle
 FMUL   ST0,ST0                 ; R2 DX2+DY2 DX+DY DY sin R Rc angle
 FCOMI  ST0,ST1                 ; R2 DX2+DY2 DX+DY DY sin R Rc angle
 FSUBRP ST1,ST0                 ; R2-DX2-DY2 DX+DY DY sin R Rc angle
 JNA    pixelok
intersection:
 FSQRT                          ; DZ DX+DY DY sin R Rc angle
 FLD    ST3                     ; sin DZ DX+DY DY sin R Rc angle
 FMUL   ST0,ST5                 ; Rs DZ DX+DY DY sin R Rc angle
 FSUBR  ST0,ST5                 ; R-Rs DZ DX+DY DY sin R Rc angle
 FADD   ST0,ST1                 ; Z DZ DX+DY DY sin R Rc angle
 FISTP  WORD [SI+BP]            ; DZ DX+DY DY sin R Rc angle
 MOV    DL,[SI+BP]
 CMP    [ES:DI+3],DL            ; Z buffer test
 JA     pixelok
 FADD   ST1,ST0                 ; DZ DX+DY+DZ DY sin R Rc angle
 FADD   ST0,ST1                 ; DZ+DX+DY+DZ DX+DY+DZ DY sin R Rc angle
 FDIV   ST0,ST4                 ; N.H DX+DY+DZ DY sin R Rc angle
 FSTP   ST2                     ; DX+DY+DZ N.H sin R Rc angle
 FDIV   ST0,ST3                 ; N.S N.H sin R Rc angle
 FIMUL  WORD [SI-VAR+MAXCOL]    ; Intensity N.H sin R Rc angle
 JMP    back

COLOR1  DB 192,92;,20,0         ; B G R - background
ASPECT:                         ; 0.75
Scale   DB 6,0,40H
ConstE  DB 3FH,99H,5DH,3EH      ; 0.15*L2E
;ConstE DB 14H,99H,5DH,3EH      ; 0.216404256133344

Step:                           ; PI/SPEED
MAXCOL  DW 125
if SPEED=4
        DW 3F49H
else if SPEED=8
        DW 3EC9H
else if SPEED=16
        DW 3E49H
else if SPEED=32
        DW 3DC9H
else if SPEED=64
        DW 3D49H
else if SPEED=128
        DW 3CC9H
else if SPEED=256
        DW 3C49H
else if SPEED=512
        DW 3BC9H
else if SPEED=1024
        DW 3B49H
end if

Shine:                          ; 2.4427
XOFFSET DW 295,401CH
