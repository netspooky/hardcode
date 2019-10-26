
IDEAL

P386N

SEGMENT CODE BYTE PUBLIC 'CODE'
ASSUME CS:CODE, DS:CODE

Org 100h
MAIN:
        Mov     BH, 0ffh
        Mov     FS, BX
        Mov     BH, 0a0h
        Mov     ES, BX
        Mov     AL, 13h
        Int     10h
        Mov     BP, 0A6Eh
@@PalLoop:
        Mov     AL, CL
        Mov     DX, 03C8h
        Out     DX, AL
        Inc     DX
        Shr     AL, 2
        Mov     BH, 3
@@Loop1:
        Out     DX, AL
        mul     AL
        Shr     AX, 6
        Dec     BH
        Jnz     @@Loop1
        Loop    @@PalLoop
@@Reload:
        Mov     SI, Offset StringData
@@Loop:
        Dec     BX
        Test    BL, 0011111b
        Jne     @@No

        Lodsb
        Lea     DI, [EAX+25600]
        And     AL, 07h
@@CharLoop:
        push    AX
        Mov     CL, 8
        Lodsb
        Push    SI
        Lea     SI, [EAX*8+EBP]
        Xor     AX, AX
        Dec     AX
@@LoopY:
        Mov     DH, [FS:SI]
        Mov     CH, 8
@@LoopX:
        Mov     DL, 8
@@LoopC:
        Rol     DH, 1
        Jnc     @@Forw
        Stosw
        Stosw
        Stosw
        Stosw
        Jmp     @@Forw2
@@Forw:
        Add     DI, 8
@@Forw2:
        Dec     DL
        Jnz     @@LoopC
        Add     DI, 256
        Dec     CH
        Jne     @@LoopX
        Inc     SI
        Loop    @@LoopY
        Sub     DI, 20416
        Pop     SI
        Pop     AX
        Dec     AX
        Jnz     @@CharLoop
        Cmp     SI, offset EndData
        Je      @@Reload
@@No:
        Mov     CH, 90
        Mov     DI, CX
@@SmallLoop:
        Mov     AL, [ES:DI-321]
@@m1:
        Add     AL, [ES:DI+321]
@@m2:
        Rcr     AL, 1
        Stosb
        Loop    @@SmallLoop
        Xor [Byte Ptr @@m1-2], 126
        Xor [Byte Ptr @@m2-2], 126
        In      AL, 96
        Dec     AX
        Jnz     @@Loop
        Add     AL, 03
        Int     10h
        Ret

StringData DB 32 or 4, 'Kids'
           DB 64 or 3, 'Out'
           DB 96 or 2, 'Of'
           DB 64 or 3, 'Std'
EndData:

ENDS CODE

END MAIN
