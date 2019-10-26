;THIS BYTE IS, THIS BYTE IS, THIS BYTE IS TOMCATRONIC
;bytebeat for PC Speaker

;code - TomCat/Abaddon
;music formula - Mu6k www.goo.gl/lQyDd
;gfx idea from Andrew Glassner www.imaginary-institute.com/the-course.html

;greetings to viznut/pwp, HellMood and Rrrola
;sizecoding is so much fun!

;video https://youtu.be/eh03ck6nvCU

Divider EQU 65
Counter EQU 255

ORG 100H
 PUSH   AX                      ; timer0 -> reset to 18Hz
 MOV    AL,0B6H                 ; timer2 -> reset to mode2
 PUSH   AX
 MOV    AX,3508H                ; get INT8 vector
 INT    21H
 PUSH   ES
 PUSH   BX
 PUSH   3                       ; reset to text mode
 CALL   INIT
MULTIP:
 PUSH   0A01EH
 POP    ES

MAIN:
 MOV    CX,100*256              ; CL:X offset, CH:Y offset
 CALL   ATAN
 PUSH   WORD [BP+SI]
 MOV    BX,[SI]                 ; SI:Counter+1
 MOV    AL,BL
 SHL    BX,4
 MOV    AH,BH
 AND    AX,16384+8192+4096+512+32
 ADD    AX,256*75-16
 TEST   BH,8+4                  ; clear CF
 JZ     NOH
 SALC                           ; clear AL -> no horizontal offset
NOH:
 XCHG   AX,CX                   ; CL:X offset, CH:Y offset
 CALL   ATAN                    ; get the angle
 POP    AX
 ADD    AX,BX                   ; rotating
 SAR    BH,7                    ; bit 8 -> part selection normal or color
 XOR    AX,[BP+SI]
 SHR    AX,10
 JNC    NOBR2
 MOV    AL,CH
 SHR    WORD [BP+SI],10
 JNC    NOBR1
 XOR    AL,8*16                 ; XORing color intesity
NOBR1:
 SHR    AL,4
 NOT    BH
NOBR2:
 AND    AL,BH                   ; part selection normal or color
 STOSB
;TEST   DI,DI
;JNZ    MAIN
 MOV    AH,1
 INT    16H
 JNZ    RESET
 JMP    MAIN

INIT:
 PUSH   Divider                 ; timer0 speed
 PUSH   0390H                   ; timer2 mode0
 PUSH   CS
 PUSH   IRQ                     ; new INT8 vector
 PUSH   13H                     ; video mode 320x200
RESET:
 POP    AX
 INT    10H
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

ATAN:
 MOV    AX,0CCCDH               ; screen modulo trick
 MUL    DI                      ; DL:X coord, DH:Y coord
 SUB    DX,CX                   ; adding the offsets
 MOV    [BP+SI],DX
 FILD   WORD [BP+SI-1]
 FILD   WORD [BP+SI]
 FPATAN
 FIMUL  WORD [SI+MULTIP-256]
 FISTP  WORD [BP+SI]
RETN

IRQ:
 PUSHAD
SAMPLE:
 MOV    AL,Divider/2
 OUT    42H,AL
 PUSH   DS
 PUSH   CS
 POP    DS
 MOV    SI,Counter
 INC    DWORD [SI]

 MOV    BP,8191
 AND    BP,[SI]                 ; Y = t & 8191
 JZ     ZERO
 MOV    AX,1500
 CWD
 DIV    BP
ZERO:
 AND    AL,1
 IMUL   BX,AX,35

 MOV    AX,9866H
 MOV    ECX,[SI]
 SHR    ECX,15-2
 MOV    BH,CL
 AND    CL,3*2*2
 SHR    AX,CL
 AND    AX,15
 MUL    WORD [SI]
 MOV    CX,24
 DIV    CX
 AND    AX,127
 OR     BH,AL                   ; X = t * "6689"[t>>15&3] / 24 & 127
 MUL    BP
 MOV    CX,40000
 DIV    CX
 ADD    BL,AL

 LODSW
 SHL    AX,1
 MOV    DL,AH
 SHR    AX,2+8
 XOR    AL,DL
 OR     AL,BH
 AND    AL,63
 ADD    AL,BL

 SHR    AL,1
 INC    AX
 MOV    [SAMPLE+1],AL

 POP    DS
 MOV    AL,20H
 OUT    20H,AL
 POPAD
IRET
