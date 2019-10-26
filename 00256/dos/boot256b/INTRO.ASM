; SAMPLE FOR BOOT256B by TomCat/Abaddon
; Simple palette scroll

ORG 256
 XCHG   DI,DX
 MOV    CH,3
 REP    STOSB
 MOV    AL,13H
 INT    10H

 MOV    SI,text1
 MOV    BL,1
char:
 LODSB
 TEST   AL,AL
 JZ     textok
 MOV    AH,0EH
 INT    10H
 JMP    char
textok:

 MOV    BP,320
 PUSH   0A000H
 POP    ES

 MOV    SI,scr1
main3:
 LEA    DI,[BP+320*7]
 SUB    CX,DI
 REP    STOSB
 SCASB
 JZ     bpok
 SUB    BP,BP
bpok:

scroll1:
 PUSHA

 PUSH   DI
 LODSW
 XCHG   DH,AL
 XCHG   BX,AX
 LODSW
 XCHG   AX,DI
 MOV    AX,300H
.1:
 PUSH   DI
.2:
 DEC    AX
 MOV    CL,DH
.3:
 PUSHA
 MOV    CL,BH
 REP    STOSB
 POPA
 ADD    DI,320
 LOOP   .3
 ADD    DX,[SI]
 PUSH   AX
 AAM    7
 CMP    AL,4
 POP    AX
 JNE    .2
 POP    DI
 MOV    CL,BH
.4:
 INC    DI
 LOOP   .4
 ADD    BX,[SI+2]
 ADD    DI,[SI+4]
 CMP    AL,4
 JNE    .1
 POP    DI

scroll2:
 MOV    DX,3C8H
 SUB    AX,AX
 OUT    DX,AL
 INC    DX
 MOV    CH,3
 MOV    SI,CS
 REP    OUTSB

 MOV    CX,3*7*35
.2:
 DEC    SI
 MOV    DL,[SI-7*3]
 MOV    [SI],DL
 LOOP   .2

 PUSH   DI
 ADD    DI,BP
 MOV    DL,20-1
 MOV    BL,14-1
 MOV    CL,7
.3:
 INC    DX
 INC    DH
 INC    BX
 DEC    SI
 SCASB
 JNZ    .4
 DEC    SI
 MOV    [SI],AX
 DEC    SI
 MOV    [SI],AL
 JMP    .5
.4:
 MOV    [SI],BL
 DEC    SI
 DEC    SI
 MOV    [SI],DX
.5:
 ADD    DI,319
 LOOP   .3

 MOV    AH,1
 INT    16H
 JNZ    exit

 MOV    DX,3DAH
.0:
 IN     AL,DX
 AND    AL,8
 JNZ    .0
.1:
 IN     AL,DX
 AND    AL,8
 JZ     .1

 POP    DI
 INC    DI
 CMP    DI,320
 JNE    scroll2

 POPA
 MOV    SI,scr3
 JMP    main3
exit:
;MOV    AX,3
;INT    10H
 INT    20H

scr1: DB 4,2
      DW 320*150+232,0,0,320*0
scr3: DB 24,15
      DW 320*18+0,-18,-060H,320*2

text1:
 DB 'BOOT WITH YOUR FAVORITE 256B INTRO!',0
