;New MBR code by TomCat/Abaddon

;version 1.1
;emulating DOS Display String function
;and keeping disk signature

ORG 7C00H
 SUB    BX,BX                   ; BX:0
 MOV    DS,BX
 MOV    SI,LES1
 LES    DI,[SI]
 CLD
 LODSW
 XCHG   CX,AX
 LODSW
 MOV    SS,AX                   ; SS:2334
 MOV    SP,BX
 XCHG   DX,AX                   ; DX:2334
 PUSH   DI
 REP    MOVSB
 LES    DI,[SI]
 LODSD
 MOV    CL,07E00H-8-INT20H
 REP    MOVSB
 MOV    DI,128
 STOSD                          ; INT 20H VECTOR
 MOV    AL,INT21H-7D00H
 STOSD                          ; INT 21H VECTOR
 LODSW                          ; AX:0
 MOV    CL,255                  ; CX:255
 POP    SI                      ; SI:256
 PUSH   BX                      ; SP:65534
 MOV    DI,SP                   ; DI:65534
 MOV    BP,DX                   ; BP:2334
 MOV    DS,DX                   ; DS:2334
 MOV    ES,DX                   ; ES:2334
 MOV    WORD [BX],20CDH         ; INT 20H TO OFFSET 0
 STI
 DB     0EAH                    ; FAR JUMP OPCODE
LES1:
 DW     256,2334                ; 2334:256

INTRO:
 rept 256 { DB ? }

LES2:
 DW     INT20H-7C00H+600H,0

INT20H:
 PUSH   CS
 POP    SS
 MOV    SP,7C00H
 MOV    AX,3
 INT    10H
 PUSH   CS
 POP    ES
 PUSH   CS
 POP    DS
 MOV    SI,7C00H+510
 MOV    BX,-64
 MOV    AL,TXTBAD-7D00H
search:
 CMP    [BX+SI],AH
 JL     found
 JNZ    error
 ADD    BX,16
 JNZ    search
 INT    18H
found:
 MOV    DX,[BX+SI]
 MOV    CX,[BX+SI+2]
 MOV    BX,SP
 MOV    AX,201H
 INT    13H
 MOV    AL,TXTLOAD-7D00H
 JC     error
 MOV    AL,TXTNO-7D00H
 CMP    WORD [SI],0AA55H
 JNE    error
 PUSH   ES
 PUSH   BX
RETF

error:
 MOV    AH,7
 MOV    DX,AX
 INT    21H
halt:
 JMP    halt

INT21H:
 PUSHA
 MOV    BL,7
 CMP    AH,BL
 JC     mute
 MOV    SI,DX
print:
 CLD
 LODSB
 MOV    AH,0EH
 INT    10H
 CMP    BYTE [SI],'$'
 JNE    print
mute:
 POPA
 IRET

TXTBAD  DB 'Bad table$'
TXTLOAD DB 'Load error$'
TXTNO   DB 'No OS$'

NTSN    DD ?
RESERVED DW 0
TABLE:
 rept 4*16 { DB ? }

SIGN:
 DW 0AA55H
