;2(56)unlimited - entry for the qbparty 2017
;256 byte PC DOS intro by TomCat/Abaddon

;No Limit speaker music with generated color palettes
;Thanks for ern0 for the bytebeat tune: https://goo.gl/Hho4Z9

;FASM source - assume AX:0 BX:0 SI:256
;video - https://youtu.be/nAji3ymsKd8

SampleSeg EQU 8000H
Divider EQU 64

ORG 256
 ADD    AL,13H
 INT    10H
 PUSH   WORD 0A000H
 POP    ES
fill:
 MOV    AX,0CCCDH               ; screen modulo trick
 MUL    BX                      ; DL:X coord, DH:Y coord
 MOV    [ES:BX],DL
 INC    BX
 JNZ    fill

 PUSH   BX
 PUSH   00B6H
_OS:
 MOV    AX,3508H
 INT    21H
 PUSH   ES
 PUSH   BX

 CALL   INIT

MAIN:
 MOV    AX,SI
 INT    16H
 JNZ    RESET
;MOV    AL,1
 SALC
 MOV    DX,3C8H
 OUT    DX,AL
 INC    DX
 MOV    CX,SI
l1:
 MOV    BX,SI
l2:
 MOV    AL,[BX]
 SUB    AL,CL
 CBW
 XOR    AL,AH
 SHR    AL,1
 OUT    DX,AL
 INC    BX
 JPO    l2
 LOOP   l1

 JMP    MAIN

INIT:
 PUSH   Divider
 PUSH   0390H
 PUSH   CS
 PUSH   IRQ
RESET:
 POP    DX
 POP    DS
 MOV    AX,2508H
 INT    21H
 POP    AX
 OUT    43H,AL
 IN     AL,61H
 AND    AL,0FCH
 ADD    AL,AH
 OUT    61H,AL
 POP    AX
 OUT    40H,AL
 SALC
 OUT    40H,AL
RETN

IRQ:
 PUSHAD
 MOV    BP,255
 MOV    AL,[BP+2]
 OUT    42H,AL
 MOV    DI,[BP]

 MOV    BX,511
 AND    BX,DI
DRUM:
 XCHG   AX,SI
 MOV    AX,654
 INC    BX
 CWD
 DIV    BX
 MOV    BH,0
 ADD    BX,BX
 INC    BP
 JPE    DRUM
 AND    AL,15
 OR     AX,SI
 IMUL   BX,AX,8

 ADD    BYTE [BP-257+_OS-1],16
 JNZ    IRQ2

 SHLD   AX,DI,8+2

 MOV    DX,DI
 SUB    DH,20H
 JC     ZAK7

 MOV    ESI,8080858EH
 MOV    BH,22
 MOV    ECX,001011616H
 TEST   AL,10H*4
 JZ     ZAK3
 MOV    CL,10H
 TEST   AL,08H*4
 JZ     ZAK3
 MOV    SI,0C8CFH
 MOV    BH,12
 MOV    ECX,0A1A1F1F1H

ZAK3:
 NOT    AL
 AND    AL,7*4
 XCHG   EAX,ECX

 CMP    DH,040H
 JC     ZAK5

 SHR    EAX,CL
 AND    AL,15

 ADD    AL,30
 JPO    ZAK5
 MUL    DL
 ADD    AX,AX
 AND    AL,80H
 OR     BL,AL
ZAK5:

 TEST   DH,040H
 JNZ    ZAK7
 XCHG   EAX,ESI
 SHR    EAX,CL
 AND    AL,15

 JZ     ZAK7
 ADD    AL,BH
 MUL    DI
 OR     BL,AL
ZAK7:

 SHR    BL,2
 INC    WORD [BP-2]
 MOV    [BP],BL
IRQ2:
 MOV    AL,20H
 OUT    20H,AL
 POPAD
IRET
