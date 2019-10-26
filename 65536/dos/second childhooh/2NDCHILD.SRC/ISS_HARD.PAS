{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_HARD.PAS - Routines for IRQ and DMA and other system hardware      ³}
{³                  Work started     : 2000.12.10.                          ³}
{³                  Last modification: 2001.03.03.                          ³}
{³             OS - GO32V2 only.                                            ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$ASMMODE INTEL}
{$MODE FPC}
Unit ISS_Hard;

Interface

Uses ISS_Var, { þ Uses the system variables and types þ }
     GO32;    { þ Uses GO32 unit, because DOS-only driver þ }

Const ISS_IRQMapping : Array[$00..$0F] Of Byte =(
                       $08,$09,$0A,$0B,$0C,$0D,$0E,$0F,  { þ 1st controller þ }
                       $70,$71,$72,$73,$74,$75,$76,$77); { þ 2nd controller þ }

      ISS_DMARead       = %00000100;
      ISS_DMAWrite      = %00001000;
      ISS_DMAAutoInit   = %00010000;
      ISS_DMAModeDemand = %00000000;
      ISS_DMAModeSingle = %01000000;

Var  ISS_DMASegment  : Word; { þ DMA Buffer Segment Address þ }
     ISS_DMAAddress  : Pointer; { þ DMA Buffer Pascal Pointer þ }
     ISS_DMASelector : Word; { þ DMA Buffer Selector þ }

Procedure ISS_IRQEnable(IRQNum : Byte);
Procedure ISS_IRQDisable(IRQNum : Byte);

Procedure ISS_DMAAllocBuffer;
Procedure ISS_DMAFreeBuffer;

Procedure ISS_DMAStart(DMAChannel : DWord; Address: Pointer;
                       BlockLength,Mode : DWord);
Procedure ISS_DMAStop(DMAChan : DWord);

Implementation

Const DMACPage   : Array[0..7] Of Byte = ($087,$083,$081,$082,$08F,$08B,$089,$08A);
      DMACOffset : Array[0..7] Of Byte = ($000,$002,$004,$006,$0C0,$0C4,$0C8,$0CC);
      DMACLength : Array[0..7] Of Byte = ($001,$003,$005,$007,$0C2,$0C6,$0CA,$0CE);
      DMACMask   : Array[0..7] Of Byte = ($00A,$00A,$00A,$00A,$0D4,$0D4,$0D4,$0D4);
      DMACMode   : Array[0..7] Of Byte = ($00B,$00B,$00B,$00B,$0D6,$0D6,$0D6,$0D6);
      DMACClear  : Array[0..7] Of Byte = ($00C,$00C,$00C,$00C,$0D8,$0D8,$0D8,$0D8);

{ þ Enables the specified IRQ þ }
Procedure ISS_IRQEnable(IRQNum : Byte); Assembler;
Asm
 MOV CL,IRQNum
 MOV BX,Not 1
 ROL BX,CL

 CMP CL,7
 JA  @EnableOnPic2

 { þ Specified IRQ is on controller 1 þ }
 IN  AL,$21
 AND AL,BL
 OUT $21,AL
 JMP @Exit

 @EnableOnPIC2:

 { þ Specified IRQ is on controller 2 þ }
 IN  AL,$0A1
 AND AL,BH
 OUT $0A1,AL

 IN  AL,$21
 AND AL,11111011B { þ Enable IRQ 2 cascade þ }
 OUT $21,AL

 @Exit:
End ['EAX','EBX','ECX'];

{ þ Disables the specified IRQ þ }
Procedure ISS_IRQDisable(IRQNum : Byte); Assembler;
Asm
 MOV CL,IRQNum
 MOV BX,1
 SHL BX,CL

 CMP CL,7
 JA  @DisableOnPIC2

 { þ Specified IRQ is on controller 1 þ }
 IN  AL,$21
 OR  AL,BL
 OUT $21,AL
 JMP @Exit

 @DisableOnPIC2:

 { þ Specified IRQ is on controller 2 þ }
 IN  AL,$0A1
 OR  AL,BH
 OUT $0A1,AL

 @Exit:
End ['EAX','EBX','ECX'];

{ þ Allocates the DMA Buffer þ }
Procedure ISS_DMAAllocBuffer;
Var Linear   : DWord;
Begin
 { þ We allocate 32kb for DMA buffer, but we using only 16kb of it. þ }
 { þ One 16kb piece of DMA buffer will not cross DMA Page for sure. þ }
 { þ Yepp, this hacking another good example to show, how "good"    þ }
 { þ the PC architecture is... þ }
 Linear:=Global_DOS_Alloc(32768);
 ISS_DMASegment :=Linear Shr 16;    { þ High Word is Segment Address þ }
 ISS_DMAAddress :=Pointer((Linear And $FFFF0000) Shr 12);
 ISS_DMASelector:=Linear And $FFFF; { þ Low Word is Selector þ }

 { þ Clearing DMA buffer þ }
 Asm
  MOV EDI,ISS_DMAAddress
  MOV ECX,32768/4
  XOR EAX,EAX
  @ClearLoop:
   MOV FS:[EDI],EAX
   ADD EDI,4
  LOOP @ClearLoop
 End ['EAX','ECX','EDI'];

 { þ Checking DMA Page Limit þ }
 If (((DWord(ISS_DMAAddress) And $0FFFF)+16384)>$10000) Then Begin
   Inc(DWord(ISS_DMAAddress),16384);
  End;

End;

{ þ Free up the DMA Buffer  þ }
Procedure ISS_DMAFreeBuffer;
Begin
 Unlock_Linear_Region(DWord(ISS_DMAAddress)+
        Get_Segment_Base_Address(DosMemSelector),32768);
 Global_DOS_Free(ISS_DMASelector);
 ISS_DMASelector:=0;
 ISS_DMASegment:=0;
End;

{ þ This routine is by Aleksey V. Vaneev, from his FPSound API. þ }
Procedure ISS_DMAStart(DMAChannel : DWord; Address: Pointer;
                       BlockLength,Mode : DWord); Assembler;
Asm
 CMP [DMAChannel],7
 JA  @Done

 AND [Mode],$0FC

 MOV EAX,4
 MOV ESI,[DMAChannel]
 ADD EAX,ESI

 CMP ESI,4
 JB  @LowDMA1

 SHR [BlockLength],1
 SHR [Address],1
 SHL WORD PTR [Address+2],1

 SUB EAX,4

 @LowDMA1:
 CMP [BlockLength],0
 JE  @Done

 XOR EDX,EDX
 MOV DL,[DMACMask+ESI]
 OUT DX,AL

 MOV DL,[DMACClear+ESI]
 OUT DX,AL

 MOV EAX,[Mode]
 ADD EAX,ESI

 CMP ESI,4
 JB  @LowDMA2

 SUB EAX,4

 @LowDMA2:
 MOV DL,[DMACMode+ESI]
 OUT DX,AL

 MOV AL,BYTE PTR [Address+2]
 MOV DL,[DMACPage+ESI]
 OUT DX,AL

 MOV AX,WORD PTR [Address]
 MOV DL,[DMACOffset + esi]
 OUT DX,AL
 MOV AL,AH
 OUT DX,AL

 MOV DL,[DMACLength + esi]
 MOV EAX, [BlockLength]
 DEC EAX
 OUT DX,AL
 MOV AL,AH
 OUT DX,AL

 MOV EAX,ESI
 CMP EAX,4
 JB  @LowDMA3

 SUB EAX,4

 @LowDMA3:
 MOV DL,[DMACMask+ESI]
 OUT DX,AL

 @Done:
End ['EAX', 'EDX', 'ESI'];

Procedure ISS_DMAStop(DMAChan : DWord);
Begin
 DMAChan:=DMAChan And 7;
 OutPortB(DMACClear[DMAChan],0);
 OutPortB(DMACMask[DMAChan],DMAChan Or 4);
End;

Begin
End.
{ þ ISS_HARD.PAS - (C) 2000-2001 Charlie/Inquisition þ }
