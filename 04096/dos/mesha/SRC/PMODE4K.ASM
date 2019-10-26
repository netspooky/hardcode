ideal
include "std.inc"
include "pmode4k.inc"
include "3d.inc"
include "mesha.inc"

segment PMODE_TEXT byte public use16 'CODE'
assume CS:PMODE_TEXT,DS:aliascode,ES:aliascode
		org 0100h
COMStart:
                org REAL_START_OFFSET
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北
;
; Micro 32bit Protected Mode Manager v2.00                  by Picard 1998 (c)
;
; Features:
;   -XMS,DPMI (no RAW,VCPI)
;   -NO hardware interrupts, only timer interrupt available
;   -NO software interrupts, only INT 3 available
;   -I/O ports are available
;   -timer speed to 100Hz (adjustable)
; Input:
;   -SP should be 0FF00 or above
;   -CS don't have to point to PSP
;   -DS = CS
;   -offset of RealStart don't have to be 0100h
; Macros:
;   -RealInit        : real mode init (interrupts are available)
;     -Input: DS,ES = realmode Code32
;     -Output: all can change (except DS,ES)
;   -RealProcedures  : possible real procedures
;   -ProtMain        : main code in 32bit protected mode
;
;北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北北

MACRO DEBUG n
                pushad
                push    ES
                pushf
                cld

                mov     AX,0A000h
                mov     ES,AX
                xor     DI,DI
                mov     EAX,[RealSwitch]
                mov     CX,320
                rep     stosd
                mov     EAX,0F0F0F0Fh+&n*10101010h
                smsw    BX
                test    BX,1
                je      @@Ok&n
                and     EAX,0FFFFh
@@Ok&n:         mov     CX,&n*320
                rep     stosd
@@Key&n:        in      AL,60h
                cmp     AL,1
                jne     @@Key&n
@@Keyb&n:       in      AL,60h
                cmp     AL,1
                je      @@Keyb&n
                popf
                pop     ES
                popad
ENDM

MACRO DEBUG2 n
                pusha
                mov     DL,n
                mov     AH,2
                int     21h
                mov     AH,1
                int     21h
                popa
ENDM
MACRO DEBUG3 n
                local L1,L2
                pusha
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
                mov     AH,1
                int     21h
                popa
ENDM
RealStart:      finit
                mov     EAX,CS                  ; clears EAX upper word too!
                add     AX,PMODE_SIZE           ; sets data segment
                mov     DS,AX
                mov     ES,AX
                mov     SS,AX
                mov     [s Code16Seg],CS
                push    AX
                MRealInit                       ; init routines in real mode
                pop     AX
                mov     DI,s o PMode_Data.GDT   ; calc PhyAddr in GDT
                shl     EAX,4                   ; calc phy. address
                add     [d DI+2],EAX            ; sets GDT phy. address
                add     DI,8
                add     DI,8
                add     [d DI+2],EAX            ; sets Code32 selector base
                add     DI,8
                add     [d DI+2],EAX            ; sets Data32 selector base
                add     DI,8
                neg     EAX
                stosd                           ; sets Screen lin->phy adjust
                xchg    EAX,EBP                 ; save to EBP
                add     [w DI-2],0Ah            ; phy 0A0000h
                mov     AX,1687h                ; check DPMI
                int     2Fh
                or      AX,AX
                jnz     UseXMS
UseDPMI:        push    CS
                push    o DPMIInit
                push    ES
                push    DI
                mov     AX,DS
                add     AH,CONV_END/4096
                mov     ES,AX                   ; DPMI data
                xor     AX,AX
                inc     AX
                retf
DPMIInit:       jc      sh InitError
                push    DS
                pop     ES
                mov     AX,501h			; allocate memory
                mov     CX,XMS_END mod 65536
                mov     BX,XMS_END / 65536
                int     31h
                jc      sh InitError
                push    BX
                push    CX
                pop     EBX
                add     EBP,EBX
                xor     AX,AX                   ; allocate code32 selector
                mov     CX,1
                int     31h
                jc      sh InitError
                push    AX
                xchg    AX,BX
                mov     DI,s o PMode_Data.Code32
                mov     AX,CS                   ; sets DPL
                and     AX,3
                shl     AL,5
                or      [b DI+5],AL
                mov     AX,000Ch                ; sets code32 sel. desc.
                int     31h
                jc      sh InitError
                pop     BX
                push    BX
                push    0
                push    BX
                mov     AX,2508h                ; set timer interrupt
                mov     DS,BX
                mov     EDX,o Int_Timer
                int     21h
                pop     BX
                mov     AX,000Ah                ; create alias selector
                int     31h
                retf                            ; jmp PStart
UseXMS:         mov     AX,4300h                ; check himem.sys
                int     2Fh
                cmp     AL,80h
                jz      sh XMS_Ok
InitError:
Quit:           xor     AX,AX
                mov     AL,3
                int     10h
                mov     AH,4Ch
                int     21h
XMS_Ok:         smsw    AX                      ; test V86 mode
                test    AL,1
                jne     sh InitError            ; if virtual -> error
                mov     AX,4310h                ; get entry point
                int     2Fh
                push    ES
                push    BX
                push    DS
                pop     ES
                mov     SI,SP
                mov     AH,3
                call    [d SI]                  ; enable A20
                mov     DX,XMS_MIN              ; allocate memory
                mov     AH,9
                call    [d SI]
                push    DX
                push    SI
                test    AL,1
                je      sh InitError
                mov     AH,0Ch
                call    [d SI]                  ; lock memory
                push    DX
                push    BX
                pop     EBX
                add     EBP,EBX                 ; adjust BaseMem (XMS) to CODE32

                lgdt    [f DI+o PMode_Data.GDT-o PMode_Data.IntMask]
                in      AL,021h                 ; store irq masks
                stosb
                in      AL,0A1h
                stosb
                mov     AX,0FFFEh               ; enable only IRQ0 Timer
                out     21h,AL
                mov     AL,AH
                out     0A1h,AL

                xor     AX,AX                   ; save int.table
                mov     DS,AX
                mov     SI,64
                movsw
                movsw
                mov     [d SI-4],s o Int_Timer + Sel_Code32 * 10000h
                movsw
                movsw
                mov     [d SI-4],8E00h

                push    AX                      ;  push 0
                push    SS                      ;  push Code32
;                push    CS
;                push    o XMS_Exit
                push    SS                      ;  push Code32 (poped in pmode)

                push    Sel_Code32              ;  push selector
                push    AX                      ;  push o PStart
                mov     AL,Sel_Data32
                cli

                mov     EBX,CR0                 ; chage to protected mode
                xor     BL,1
                mov     CR0,EBX                 ; EAX = 0 -> ok
                                                ; IP upper word = 0, because
                                                ; 16bit real segment -> ok
                retf                            ; jmp PStart
                MRealProcedures

; DI data field end
; SI 96
XMS_Exit:       mov     SS,AX                   ; restore realmode SS
                pop     DS                      ; pop Code32
                pop     ES                      ; pop 0

                std
                lodsw                           ; sub DI,2 (SI<->DI)
                xchg    SI,DI
                lodsw                           ; sub SI,2

                movsw                           ; restore Timer interupt
                movsw
                movsw
                movsw

                lodsw
                out     21h,AL                  ; restore IRQ masks
                mov     AL,AH
                out     0A1h,AL
                sti

                pop     SI
                pop     DX
                mov     AH,0Dh
                call    [d SI]
                mov     AH,0Ah
                call    [d SI]

                xor     AX,AX
                mov     AL,3
                int     10h
                mov     AH,4Ch
                int     21h
         org    PMODE_SIZE*16
ends

end RealStart
