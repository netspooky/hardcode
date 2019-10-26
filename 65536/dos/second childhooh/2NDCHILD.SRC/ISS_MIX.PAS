{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_MIX .PAS - Software mixer for non-wavetable devices                ³}
{³                  Work started     : 2000.05.14.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - Platform Independent                                    ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ NOTE: The code contained by this unit is in ALPHA stage. May, and WILL ³}
{³         change without warning. Make sure your own software don't rely   ³}
{³         on this code.                                                    ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$ASMMODE INTEL}
{$MODE FPC}
Unit ISS_Mix;

Interface

Uses ISS_Var;

Type ISS_TMixChannel = Record
       MixSmpPtr  : ISS_PSample;
       MixSmpPos  : DWord; { þ Current sample position þ }
       MixSmpRate : DWord;
       MixSmpHighStep : DWord;
       MixSmpLowStep  : DWord;
       MixSmpInc      : DWord;
       MixSmpPan  : Word;
       MixSmpVol  : Word;
       MixSmpVolL : Word;
       MixSmpVolR : Word;
       MixSmpEnd  : DWord;
      End;

     ISS_TMixer = Record
       MixRate      : DWord;   { þ Mixing rate þ }
       MixBufSize   : DWord;   { þ Mixing buffer size þ }
       MixBufCount  : DWord;   { þ Current bufferpos counter þ }
       MixBufPtr    : Pointer; { þ Address of the buffer þ }
       MixLenPos    : DWord;   { þ Current position between the syscalls þ }
       MixBufOffs   : DWord;   { þ Mixer targetbuffer offset þ }
       MixBufSel    : Word;    { þ Mixer targetbuffer selector þ }
       MixBufType   : Word;    { þ Mixer targetbuffer type þ }
       MixRevStereo : Boolean; { þ Reversing stereo þ }
       { þ Independent data for each channel þ }
       MixChannels : Array[0..ISS_MaxSSChannels-1] Of ISS_TMixChannel;
      End;
     ISS_PMixer = ^ISS_TMixer;

Var ISS_MixerData : ISS_PMixer;
    ISS_MixerOK   : Boolean;
    ISS_MixVolTab : Array[0..64,0..255] Of Word;

Function ISS_MixerInit(MixFreq : DWord; BufSize : DWord;
                       TSelector : Word; TOffset : DWord;
                       Mode : Word) : Boolean;
Function ISS_MixerDone : Boolean;

Function ISS_MixerLoadSample(SStruc : ISS_PSample) : Boolean;
Function ISS_MixerFreeSample(SStruc : ISS_PSample) : Boolean;

Procedure ISS_MixerUpdateOutput;

Implementation

Procedure MixCalcVolumeTable;
Var Counter,Counter2 : DWord;
Begin
 For Counter:=0 To 64 Do Begin
   For Counter2:=0 To 255 Do Begin
     ISS_MixVolTab[Counter,Counter2]:=((Counter2 Shl 8)*Counter) Div 64;
    End;
  End;
End;

Function ISS_MixerInit(MixFreq : DWord; BufSize : DWord;
                       TSelector : Word; TOffset : DWord;
                       Mode : Word) : Boolean;
Begin
 ISS_MixerInit:=False;
 If ISS_MixerOK Then Exit;

 New(ISS_MixerData);
 FillChar(ISS_MixerData^,SizeOf(ISS_TMixer),#0);

 With ISS_MixerData^ Do Begin
   MixRate:=MixFreq;
   MixBufSize:=BufSize;
   { þ Allocating Memory for mixer buffer þ }
   GetMem(MixBufPtr,MixBufSize*8);
   MixBufOffs:=TOffset;
   MixBufSel:=TSelector;
   MixBufType:=Mode;
  End;

 MixCalcVolumeTable;

 ISS_MixerOK:=True;
 ISS_MixerInit:=True;
End;

Function ISS_MixerDone : Boolean;
Begin
 ISS_MixerDone:=False;
 If Not ISS_MixerOK Then Exit;

 With ISS_MixerData^ Do Begin
   { þ Freeing up memory for mixer buffer þ }
   FreeMem(MixBufPtr,MixBufSize*8);
  End;

 Dispose(ISS_MixerData);

 ISS_MixerOK:=False;
 ISS_MixerDone:=True;
End;

Function ISS_MixerLoadSample(SStruc : ISS_PSample) : Boolean;
Type PByte    = ^Byte;
     PInteger = ^Integer;
Var SmpRealLength : DWord;
    SmpLoopLength : DWord;
    SmpPointer    : Pointer;
    Counter       : DWord;
Begin
 ISS_MixerLoadSample:=False;
 With SStruc^ Do Begin
   { þ Unrolling bidirectional loops, so main mixing routine will be þ }
   { þ much simpler (and faster) þ }
   If (SType And (ISS_SmpPingPongLoop-ISS_SmpForwardLoop))>0 Then Begin

     { þ Calculating unrolled sample size þ }
     SmpLoopLength:=SLoopEnd-SLoopStart;
     SmpRealLength:=SLoopEnd+SmpLoopLength;
     { þ Allocating memory þ }
     GetMem(SmpPointer,SmpRealLength); If SmpPointer=Nil Then Exit;

     { þ Unrolling loop þ }
     If (SType And ISS_Smp16BitData)>0 Then Begin
       For Counter:=0 To (SLoopEnd Div 2)-1 Do Begin
         PInteger(SmpPointer)[Counter]:=PInteger(SData)[Counter];
        End;
       For Counter:=0 To (SmpLoopLength Div 2)-1 Do Begin
         PInteger(SmpPointer)[(SLoopEnd Div 2)+Counter]:=PInteger(SData)[(SLoopEnd Div 2)-Counter];
        End;
      End Else Begin
       For Counter:=0 To SLoopEnd-1 Do Begin
         PByte(SmpPointer)[Counter]:=PByte(SData)[Counter];
        End;
       For Counter:=0 To SmpLoopLength-1 Do Begin
         PByte(SmpPointer)[SLoopEnd+Counter]:=PByte(SData)[SLoopEnd-Counter];
        End;
      End;

     { þ Converting loop values þ }
     SLoopEnd:=SLoopEnd+SmpLoopLength;

     { þ When unrolling is done, we assign the samplepointer þ }
     SDRAMOffs:=DWord(SmpPointer);

    End Else Begin
     { þ If there is no bidi loop, it's not needed to unroll the sampledata þ }
     { þ so we simply assign the pointer þ }
     SDRAMOffs:=DWord(SData);
    End;
  End;
 ISS_MixerLoadSample:=True;
End;

Function ISS_MixerFreeSample(SStruc : ISS_PSample) : Boolean;
Var SmpRealLength : DWord;
    SmpLoopLength : DWord;
    SmpPointer    : Pointer;
Begin
 ISS_MixerFreeSample:=False;
 With SStruc^ Do Begin
   { þ We only free up the samples with unrolled loops þ }
   If (SType And (ISS_SmpPingPongLoop-ISS_SmpForwardLoop))>0 Then Begin

     { þ Calculating rolled sample size þ }
     SmpLoopLength:=SLoopEnd-SLoopStart;
     SmpLoopLength:=SmpLoopLength Div 2;
     SLoopEnd:=SLoopStart+SmpLoopLength;
     SmpRealLength:=SLoopEnd+SmpLoopLength;

     DWord(SmpPointer):=SDRAMOffs;
     SDRAMOffs:=0;
     If SmpPointer=Nil Then Exit;

     { þ Deallocating memory þ }
     FreeMem(SmpPointer,SmpRealLength);

    End;
  End;
 ISS_MixerFreeSample:=True;
End;

{ þ >>> A D D I T I O N A L  M I X I N G  F U N C T I O N S þ <<< }

Procedure ISS_MixerClearBuffer(OutputType : Word); Assembler;
Asm
 PUSHF
 MOV EDX,ISS_MixerData
 MOV EDI,[EDX+12] { þ MixBufPtr þ }
 MOV ECX,[EDX+4]  { þ MixBufSize þ }

 MOVZX EAX,OutputType
 AND EAX,ISS_DevStereo
 JZ  @NotStereo
  SHL ECX,1
 @NotStereo:

 XOR EAX,EAX
 CLD
 REP STOSD
 POPF
End;


{ þ Possible buffer conversions þ }
{ þ 16bit signed -> 16bit signed (no conversion) þ }
{ þ 16bit signed -> 8bit signed þ }
{ þ 16bit signed -> 8bit unsigned þ }

Procedure ISS_MixerMakeClip(OutputType : Word); Assembler;
Asm
 PUSH GS
 MOV EDX,ISS_MixerData
 MOV AX,[EDX+24]  { þ MixBufSel þ }
 CMP AX,0
 JNE @NonZeroSelector
  MOV AX,DS

 @NonZeroSelector:
 MOV GS,AX
 MOV ECX,[EDX+4]  { þ MixBufSize þ }
 MOV ESI,[EDX+12] { þ MixBufPtr þ }
 MOV EDI,[EDX+20] { þ MixBufOffs þ }

 MOVZX EAX,OutputType
 TEST  EAX,ISS_DevStereo
 JZ    @NotStereo
  SHL   ECX,1
 @NotStereo:

 TEST EAX,ISS_Dev16Bit
 JZ   @Dev8Bit

 @LoopHead16Bit: { þ 16bit signed -> 16bit signed þ }

  MOV EAX,[ESI]
  SAR EAX,8
  CMP EAX,32767
  JNG @UpOK16
   MOV EAX,32767
   JMP @CheckOk16
  @UpOk16:
  CMP EAX,-32768
  JNL @CheckOk16
   MOV EAX,-32768
  @CheckOk16:
  MOV GS:[EDI],AX
  ADD EDI,2
  ADD ESI,4

  DEC ECX
 JNZ @LoopHead16Bit
 JMP @Exit

 @Dev8Bit:

 TEST EAX,ISS_DevSigned
 JZ   @LoopHead8BitUnsigned

 @LoopHead8BitSigned:   { þ 16bit signed -> 8bit signed þ }

  MOV EAX,[ESI]
  SAR EAX,8
  CMP EAX,32767
  JNG @UpOK8S
   MOV EAX,32767
   JMP @CheckOk8S
  @UpOk8S:
  CMP EAX,-32768
  JNL @CheckOk8S
   MOV EAX,-32768
  @CheckOk8S:
  MOV GS:[EDI],AH
  ADD ESI,4
  INC EDI

  DEC ECX
 JNZ @LoopHead8BitSigned
 JMP @Exit

 @LoopHead8BitUnsigned: { þ 16Bit signed -> 8bit unsigned þ }

  MOV EAX,[ESI]
  SAR EAX,8
  CMP EAX,32767
  JNG @UpOK8U
   MOV EAX,32767
   JMP @CheckOk8U
  @UpOk8U:
  CMP EAX,-32768
  JNL @CheckOk8U
   MOV EAX,-32768
  @CheckOk8U:
  ADD AH,128
  MOV GS:[EDI],AH
  ADD ESI,4
  INC EDI

  DEC ECX
 JNZ @LoopHead8BitUnsigned

 @Exit:
 POP GS
End;


{ þ >>> S T E R E O  M I X I N G  F U N C T I O N S <<< þ }

{ þ Mixes a 8bit sample into a stereo buffer þ }
Function MixChannel8BitSampleSTEREO(MChIndexPtr : Pointer) : DWord; Assembler;
Var MixCounter     : DWord;
Asm
 MOV   ESI,MChIndexPtr
 MOV   MixCounter,0

 MOV   ECX,[ESI+4]   { þ MixSmpPos þ }
 @LoopHead:

  { þ Getting out samplevalue þ }
  MOV   EDX,[ESI]     { þ MixSmpPtr þ }
  MOV   EDI,[EDX+44]  { þ SDRAMOffs þ }
  MOVSX EAX,BYTE PTR [EDI+ECX]
  SAL   EAX,8

  { þ Mix sample with volume þ }
  MOV   EBX,EAX
  MOVZX EDX,WORD PTR [ESI+28]  { þ MixSmpVolL þ }
  IMUL  EAX,EDX
  MOVZX EDX,WORD PTR [ESI+30]  { þ MixSmpVolR þ }
  IMUL  EBX,EDX

  { þ Adding current sample value to buffer position þ }
  MOV   EDX,ISS_MixerData
  MOV   EDI,[EDX+12]  { þ MixBufPtr þ }
  MOV   EDX,MixCounter
  SHL   EDX,3
  ADD   [EDI+EDX],EAX
  ADD   [EDI+EDX+4],EBX

  { þ Calculating stepping rate step two þ }
  { þ Getting the real step value from the fixedpoint rate þ }
  { þ calculated previous þ }
  MOV   EAX,[ESI+20]  { þ MixSmpInc þ }
  ADD   EAX,[ESI+16]  { þ MixSmpLowStep þ }
  MOV   EBX,EAX
  SHR   EBX,16
  ADD   EBX,[ESI+12]  { þ MixSmpHighStep þ }
  AND   EAX,$0000FFFF
  MOV   [ESI+20],EAX  { þ MixSmpInc þ }

  { þ Increasing sample position þ }
  ADD   ECX,EBX

  { þ Checking sample limits þ }
  CMP   ECX,[ESI+32]  { þ MixSmpEnd þ }
  JB    @SmpOk
   MOV   EDI,[ESI]        { þ MixSmpPtr þ }
   MOV   DL,[EDI+36]      { þ SType þ }
   AND   DL,ISS_SmpPingPongLoop
   JZ    @SmpEnd
    MOV   ECX,[EDI+26]    { þ SLoopStart þ }
    JMP   @SmpOk
   @SmpEnd:
    MOV   ECX,[EDI+22]    { þ SLength þ }
    MOV   MixCounter,$0FFFF
  @SmpOk:

  MOV   EAX,MixCounter
  INC   EAX
  MOV   MixCounter,EAX

  MOV   EDI,ISS_MixerData
  CMP   EAX,[EDI+4]   { þ MixBufSize þ }
 JB    @LoopHead

 { þ Moving new sample pos into the record þ }
 MOV   [ESI+4],ECX       { þ MixSmpPos þ }
End;

{ þ Mixes a 16bit sample into a stereo buffer þ }
Function MixChannel16BitSampleSTEREO(MChIndexPtr : Pointer) : DWord; Assembler;
Var MixCounter     : DWord;
Asm
 MOV   ESI,MChIndexPtr
 MOV   MixCounter,0

 MOV   ECX,[ESI+4]   { þ MixSmpPos þ }
 SHL   ECX,1
 @LoopHead:

  { þ Getting out samplevalue þ }
  MOV   EDX,[ESI]     { þ MixSmpPtr þ }
  MOV   EDI,[EDX+44]  { þ SDRAMOffs þ }
  MOVSX EAX,WORD PTR [EDI+ECX]

  { þ Mix sample with volume þ }
  MOV   EBX,EAX
  MOVZX EDX,WORD PTR [ESI+28]  { þ MixSmpVolL þ }
  IMUL  EAX,EDX
  MOVZX EDX,WORD PTR [ESI+30]  { þ MixSmpVolR þ }
  IMUL  EBX,EDX

  { þ Adding current sample value to buffer position þ }
  MOV   EDX,ISS_MixerData
  MOV   EDI,[EDX+12]  { þ MixBufPtr þ }
  MOV   EDX,MixCounter
  SHL   EDX,3
  ADD   [EDI+EDX],EAX
  ADD   [EDI+EDX+4],EBX

  { þ Calculating stepping rate step two þ }
  { þ Getting the real step value from the fixedpoint rate þ }
  { þ calculated previous þ }
  MOV   EAX,[ESI+20]  { þ MixSmpInc þ }
  ADD   EAX,[ESI+16]  { þ MixSmpLowStep þ }
  MOV   EBX,EAX
  SHR   EBX,16
  ADD   EBX,[ESI+12]  { þ MixSmpHighStep þ }
  AND   EAX,$0000FFFF
  MOV   [ESI+20],EAX  { þ MixSmpInc þ }
  SHL   EBX,1

  { þ Increasing sample position þ }
  ADD   ECX,EBX

  { þ Checking sample limits þ }
  CMP   ECX,[ESI+32]  { þ MixSmpEnd þ }
  JB    @SmpOk
   MOV   EDI,[ESI]        { þ MixSmpPtr þ }
   MOV   DL,[EDI+36]      { þ SType þ }
   AND   DL,ISS_SmpPingPongLoop
   JZ    @SmpEnd
    MOV   ECX,[EDI+26]    { þ SLoopStart þ }
    JMP   @SmpOk
   @SmpEnd:
    MOV   ECX,[EDI+22]    { þ SLength þ }
    MOV   MixCounter,$0FFFF
  @SmpOk:

  MOV   EAX,MixCounter
  INC   EAX
  MOV   MixCounter,EAX

  MOV   EDI,ISS_MixerData
  CMP   EAX,[EDI+4]   { þ MixBufSize þ }
 JB    @LoopHead

 { þ Moving new sample pos into the record þ }
 SHR   ECX,1
 MOV   [ESI+4],ECX       { þ MixSmpPos þ }
End;

Procedure ISS_MixerUpdateBufferSTEREO;
Var ChannelCounter : DWord;
    MChIndexPtr    : Pointer;
    MixedLength    : DWord;
Begin
 With ISS_MixerData^ Do Begin

   { þ Clearing mixer buffer þ }
   ISS_MixerClearBuffer(ISS_DevStereo);

   { þ Main mixing loop þ }
   { þ Going through all the active channels þ }
   For ChannelCounter:=0 To ISS_ActiveSSChannels-1 Do Begin
     With ISS_VirtualChannels^[ChannelCounter] Do Begin

       { þ If channel is active, then updating... þ }
       If (VChControl And ISS_CCActive)>0 Then Begin
         With MixChannels[ChannelCounter] Do Begin

           With MixSmpPtr^ Do Begin
             If (SType And ISS_SmpPingPongLoop)>0 Then Begin
               MixSmpEnd:=SLoopEnd;
              End Else Begin
               MixSmpEnd:=SLength;
              End;

             MChIndexPtr:=@MixChannels[ChannelCounter];
             If (SType And ISS_Smp16BitData)>0 Then Begin
               MixedLength:=MixChannel16BitSampleSTEREO(MChIndexPtr);
              End Else Begin
               MixedLength:=MixChannel8BitSampleSTEREO(MChIndexPtr);
              End;

             If MixedLength=$10000 Then Dec(VChControl,ISS_CCActive);

            End;

          End;
        End;
      End;

    End;

  End;
End;


{ þ >>> M O N O  M I X I N G  F U N C T I O N S <<< þ }

{ þ Mixes a 8bit sample into a stereo buffer þ }
Function MixChannel8BitSampleMONO(MChIndexPtr : Pointer) : DWord; Assembler;
Var MixCounter     : DWord;
Asm
 MOV   ESI,MChIndexPtr
 MOV   MixCounter,0

 MOV   ECX,[ESI+4]   { þ MixSmpPos þ }
 @LoopHead:

  { þ Getting out samplevalue þ }
  MOV   EDX,[ESI]     { þ MixSmpPtr þ }
  MOV   EDI,[EDX+44]  { þ SDRAMOffs þ }
  MOVSX EAX,BYTE PTR [EDI+ECX]
  SAL   EAX,8

  { þ Mix sample with volume þ }
  MOVZX EBX,BYTE PTR [ESI+26]  { þ MixSmpVol þ }
  IMUL  EAX,EBX

  { þ Adding current sample value to buffer position þ }
  MOV   EDX,ISS_MixerData
  MOV   EDI,[EDX+12]  { þ MixBufPtr þ }
  MOV   EDX,MixCounter
  SHL   EDX,2
  ADD   [EDI+EDX],EAX

  { þ Calculating stepping rate step two þ }
  { þ Getting the real step value from the fixedpoint rate þ }
  { þ calculated previous þ }
  MOV   EAX,[ESI+20]  { þ MixSmpInc þ }
  ADD   EAX,[ESI+16]  { þ MixSmpLowStep þ }
  MOV   EBX,EAX
  SHR   EBX,16
  ADD   EBX,[ESI+12]  { þ MixSmpHighStep þ }
  AND   EAX,$0000FFFF
  MOV   [ESI+20],EAX  { þ MixSmpInc þ }

  { þ Increasing sample position þ }
  ADD   ECX,EBX

  { þ Checking sample limits þ }
  CMP   ECX,[ESI+32]  { þ MixSmpEnd þ }
  JB    @SmpOk
   MOV   EDI,[ESI]        { þ MixSmpPtr þ }
   MOV   DL,[EDI+36]      { þ SType þ }
   AND   DL,ISS_SmpPingPongLoop
   JZ    @SmpEnd
    MOV   ECX,[EDI+26]    { þ SLoopStart þ }
    JMP   @SmpOk
   @SmpEnd:
    MOV   ECX,[EDI+22]    { þ SLength þ }
    MOV   MixCounter,$0FFFF
  @SmpOk:

  MOV   EAX,MixCounter
  INC   EAX
  MOV   MixCounter,EAX

  MOV   EDI,ISS_MixerData
  CMP   EAX,[EDI+4]   { þ MixBufSize þ }
 JB    @LoopHead

 { þ Moving new sample pos into the record þ }
 MOV   [ESI+4],ECX       { þ MixSmpPos þ }
End;

{ þ Mixes a 16bit sample into a stereo buffer þ }
Function MixChannel16BitSampleMONO(MChIndexPtr : Pointer) : DWord; Assembler;
Var MixCounter     : DWord;
Asm
 MOV   ESI,MChIndexPtr
 MOV   MixCounter,0

 MOV   ECX,[ESI+4]   { þ MixSmpPos þ }
 SHL   ECX,1
 @LoopHead:

  { þ Getting out samplevalue þ }
  MOV   EDX,[ESI]     { þ MixSmpPtr þ }
  MOV   EDI,[EDX+44]  { þ SDRAMOffs þ }
  MOVSX EAX,WORD PTR [EDI+ECX]

  { þ Mix sample with volume þ }
  MOVZX EBX,WORD PTR [ESI+26]  { þ MixSmpVol þ }
  IMUL  EAX,EBX

  { þ Adding current sample value to buffer position þ }
  MOV   EDX,ISS_MixerData
  MOV   EDI,[EDX+12]  { þ MixBufPtr þ }
  MOV   EDX,MixCounter
  SHL   EDX,2
  ADD   [EDI+EDX],EAX

  { þ Calculating stepping rate step two þ }
  { þ Getting the real step value from the fixedpoint rate þ }
  { þ calculated previous þ }
  MOV   EAX,[ESI+20]  { þ MixSmpInc þ }
  ADD   EAX,[ESI+16]  { þ MixSmpLowStep þ }
  MOV   EBX,EAX
  SHR   EBX,16
  ADD   EBX,[ESI+12]  { þ MixSmpHighStep þ }
  AND   EAX,$0000FFFF
  MOV   [ESI+20],EAX  { þ MixSmpInc þ }
  SHL   EBX,1

  { þ Increasing sample position þ }
  ADD   ECX,EBX

  { þ Checking sample limits þ }
  CMP   ECX,[ESI+32]  { þ MixSmpEnd þ }
  JB    @SmpOk
   MOV   EDI,[ESI]        { þ MixSmpPtr þ }
   MOV   DL,[EDI+36]      { þ SType þ }
   AND   DL,ISS_SmpPingPongLoop
   JZ    @SmpEnd
    MOV   ECX,[EDI+26]    { þ SLoopStart þ }
    JMP   @SmpOk
   @SmpEnd:
    MOV   ECX,[EDI+22]    { þ SLength þ }
    MOV   MixCounter,$0FFFF
  @SmpOk:

  MOV   EAX,MixCounter
  INC   EAX
  MOV   MixCounter,EAX

  MOV   EDI,ISS_MixerData
  CMP   EAX,[EDI+4]   { þ MixBufSize þ }
 JB    @LoopHead

 { þ Moving new sample pos into the record þ }
 SHR   ECX,1
 MOV   [ESI+4],ECX       { þ MixSmpPos þ }
End;

Procedure ISS_MixerUpdateBufferMONO;
Var ChannelCounter : DWord;
    MChIndexPtr    : Pointer;
    MixedLength    : DWord;
Begin
 With ISS_MixerData^ Do Begin

   { þ Main mixing loop þ }
   { þ Going through all the active channels þ }
   For ChannelCounter:=0 To ISS_ActiveSSChannels-1 Do Begin
     With ISS_VirtualChannels^[ChannelCounter] Do Begin

       { þ If channel is active, then updating... þ }
       If (VChControl And ISS_CCActive)>0 Then Begin
         With MixChannels[ChannelCounter] Do Begin

           With MixSmpPtr^ Do Begin
             If (SType And ISS_SmpPingPongLoop)>0 Then Begin
               MixSmpEnd:=SLoopEnd;
              End Else Begin
               MixSmpEnd:=SLength;
              End;

             MChIndexPtr:=@MixChannels[ChannelCounter];
             If (SType And ISS_Smp16BitData)>0 Then Begin
               MixedLength:=MixChannel16BitSampleMONO(MChIndexPtr);
              End Else Begin
               MixedLength:=MixChannel8BitSampleMONO(MChIndexPtr);
              End;

             If MixedLength=$10000 Then Dec(VChControl,ISS_CCActive);

            End;

          End;
        End;
      End;

    End;

  End;
End;



Procedure ISS_MixerUpdateOutput;
Var ChannelCounter : DWord;
Begin

 With ISS_MixerData^ Do Begin

 { þ Start Voices Update þ }
 For ChannelCounter:=0 To ISS_ActiveSSChannels-1 Do Begin
   With ISS_VirtualChannels^[ChannelCounter] Do Begin
     With MixChannels[ChannelCounter] Do Begin

       { þ Anything to do on this channel? þ }
       If (VChControl>1) And ((VChControl And ISS_CCActive)>0) Then Begin

         { þ Stop Voice? þ }
         If (VChControl And ISS_CCStop)>0 Then Begin
           Dec(VChControl,ISS_CCStop);
           Dec(VChControl,ISS_CCActive);
          End;

         { þ Start a Sample ? þ }
         If (VChControl And ISS_CCSample)>0 Then Begin
           Dec(VChControl,ISS_CCSample);
           MixSmpPtr:=VChSmpAddr;
           With MixSmpPtr^ Do Begin
             { þ Offset limit checking þ }
             If (VChSmpOffs>=SLength) And
                ((SType And ISS_SmpPingPongLoop)>0) Then Begin
                VChSmpOffs:=SLoopStart;
              End;
            End;
           MixSmpPos:=VChSmpOffs;
           If (MixSmpPtr<>Nil) And (MixSmpPtr^.SLength>0) Then
             VChControl:=VChControl Or ISS_CCActive;
          End;

         { þ Change Channel Volume ? þ }
         { þ Change Channel Panning ? þ }
         If ((VChControl And ISS_CCVolume)>0) Or
            ((VChControl And ISS_CCPanning)>0) Then Begin

           VChControl:=VChControl And Not ISS_CCVolume;
           VChControl:=VChControl And Not ISS_CCPanning;

           MixSmpVol:=VChFinalVolume;
           MixSmpPan:=VChFinalPanning;

           If Not MixRevStereo Then Begin
             MixSmpVolL:=(MixSmpPan+1);
             MixSmpVolR:=(256-MixSmpPan);
            End Else Begin
             MixSmpVolR:=(MixSmpPan+1);
             MixSmpVolL:=(256-MixSmpPan);
            End;

           {If MixSmpVolL>127 Then MixSmpVolL:=127;}
           {If MixSmpVolR>127 Then MixSmpVolR:=127;}
           MixSmpVolL:=(MixSmpVolL*MixSmpVol) Div 64;
           MixSmpVolR:=(MixSmpVolR*MixSmpVol) Div 64;
          End;

         { þ Change Channel Frequency ? þ }
         If (VChControl And ISS_CCPeriod)>0 Then Begin
           Dec(VChControl,ISS_CCPeriod);
           MixSmpRate:=VChFreq;
           { þ Calculating stepping rates þ }
           MixSmpHighStep:=(MixSmpRate Div MixRate);
           { þ This is divided into 2 lines, because of an FPC bug (?) :( þ }
           MixSmpLowStep:=(MixSmpRate Mod MixRate) Shl 16;
           MixSmpLowStep:=MixSmpLowStep Div MixRate;
          End;

        End;

      End;
    End;
  End;

  { þ Clearing mixer buffer þ }
  ISS_MixerClearBuffer(MixBufType);

  If (MixBufType And ISS_DevStereo)>0 Then ISS_MixerUpdateBufferSTEREO
                                      Else ISS_MixerUpdateBufferMONO;

  { þ Do final buffer clipping, and convert it into the format þ }
  { þ requested by the output device þ }
  ISS_MixerMakeClip(MixBufType);

 End;

End;

Begin
 ISS_MixerOK:=False;
End.

{ þ ISS_MIX.PAS - (C) 2000-2001 Charlie/Inquisition þ }
