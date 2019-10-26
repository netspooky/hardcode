{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_SB  .PAS - Device Driver for Sound Blaster and compatibles         ³}
{³                  Work started     : 2000.05.14.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - GO32V2 only.                                            ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$ASMMODE INTEL}

{$HINTS OFF} { þ Enable this if you modify the source! þ }
{$NOTES OFF} { þ Enable this if you modify the source! þ }

Unit ISS_SB;

Interface

Uses ISS_Var,  { þ Uses the system variables and types þ }
     ISS_Mix,  { þ Uses the mixer þ }
     ISS_Tim,  { þ Uses the timer services þ }
     ISS_Hard, { þ Uses low level hardware routines þ }
     GO32,     { þ Uses GO32 unit, because DOS-only driver þ }
     DOS;      { þ Uses DOS unit, for environment variable access þ }

Const ISS_SBVersionStr = '0.2.5';

      ISS_SBName     = 'Sound Blaster';
      ISS_SBLongDesc = 'Sound Blaster and compatible Device Driver';

      ISS_SBNames : Array[0..4] Of String[32] =
          ('Unknown Sound Blaster',
           'Sound Blaster 1.x','Sound Blaster 2.0',
           'Sound Blaster PRO','Sound Blaster 16/ASP');

Var ISS_SBDevice : ISS_TSoundDevice; { þ SB Device Structure þ }
    ISS_SBDriver : ISS_TSoundDriver; { þ SB Device Driver þ }

Procedure ISS_SBDevInit;

Implementation

Type ISS_TSBHWSetup = Record { þ Used for SB detection þ }
       Base_Port  : Word;
       DAC_IRQ    : Word;
       Low_DMA    : Word;
       High_DMA   : Word;
       Card_Type  : Byte;
       DSPVer_Maj : Byte;
       DSPVer_Min : Byte;
       MaxRate    : Word;
       ModeFlags  : Word;
      End;

Var ISS_SBHWSetup      : ISS_TSBHWSetup; { þ SB Hardware Parameters þ }
    ISS_SBPlayFreq     : Word;   { þ Current playing (not mixing!) freq. þ }
    ISS_SBMixBufSize   : DWord;   { þ Current mixing buffer size þ }
    ISS_SBPeriodicCall : Pointer; { þ Pointer to the tracker code þ }
    ISS_SBBufNum       : Byte;    { þ Current buffer number þ }
    ISS_SBDMAChan      : Byte;    { þ DMA channel þ }

    { þ Data Selector Backup from GO32V2 system area for IRQ handling þ }
    BackupDS : Word; External Name '___v2prt0_ds_alias';
    { þ IRQ pointers þ }
    SB_OldIRQ : TSegInfo;
    SB_NewIRQ : TSegInfo;

    {$IFDEF _ISS_SB_FORCEDSPVERSION_}
     DSPForceVersion : Word;
    {$ENDIF}

Const DSPResetPort = $06; { þ DSP Reset port.                  Write Only. þ }
      DSPReadPort  = $0A; { þ DSP Read data port.              Read  Only. þ }
      DSPLifePort  = $0A; { þ DSP Read data port.              Read  Only. þ }
      DSPWStatPort = $0C; { þ DSP Write buffer status port.    Write Only. þ }
      DSPWritePort = $0C; { þ DSP Write data port.             Write Only. þ }
      DSPRStatPort = $0E; { þ DSP Read buffer status port.     Read  Only. þ }
      DSP8AckPort  = $0E; { þ  8 bit DMA IRQ Acknowledge port. Write Only. þ }
      DSP16AckPort = $0F; { þ 16 bit DMA IRQ Acknowledge port. Write Only. þ }

      { þ DSP Commands þ }
      DSP_SetTimeConst  = $040; { þ Sets the frequency time constant þ }
      DSP_SetSampleRate = $041; { þ Sets the sampling rate (DSP4.0+) þ }
      DSP_SetHSpeedSize = $048; { þ Sets blocksize for AI+HS DMA Transfer þ }
      DSP_TurnOnSpeaker = $0D1; { þ Turn on the SB speaker þ }
      DSP_GetVersion    = $0E1; { þ Returns the DSP version þ }


{ þ >>> D E B U G  F U N C T I O N S <<< þ }

{$IFDEF _ISS_SB_DEBUGMODE_}
 Function WriteHex(Num : Word) : String[4];
 Const DigitTab : String[16]='0123456789ABCDEF';
 Var HexStr  : String[4];
     Counter : Integer;
 Begin
  HexStr:='';
  For Counter:=3 DownTo 0 Do Begin
    HexStr:=HexStr+DigitTab[(Num And ($F Shl (Counter*4))) Shr
            (Counter*4)+1];
   End;
  WriteHex:=HexStr;
 End;
{$ENDIF}


{ þ >>> I N T E R N A L  F U N C T I O N S <<< þ }

Function UpcaseString(S : String) : String;
Var Counter : DWord;
    BufStr  : String;
Begin
 BufStr:=S;
 For Counter:=1 To Length(S) Do BufStr[Counter]:=Upcase(BufStr[Counter]);
 UpcaseString:=BufStr;
End;

Function BlasterGetBasePort(S : String) : DWord;
Var BasePortStr : String[3];
    BasePortNum : DWord;
    Counter     : DWord;
Begin
 BlasterGetBasePort:=0;
 If Pos('A',S)=0 Then Exit;
 BasePortStr:=Copy(S,Pos('A',S)+1,3);

 For Counter:=1 To 3 Do
   Byte(BasePortStr[Counter]):=Ord(BasePortStr[Counter])-Ord('0');
 BasePortNum:=Ord(BasePortStr[1])*$100+
              Ord(BasePortStr[2])*$10+
              Ord(BasePortStr[3]);

 If (BasePortNum>=$220) And (BasePortNum<=$280) Then
   BlasterGetBasePort:=BasePortNum;
End;

Function BlasterGetIRQ(S : String) : DWord;
Var IRQStr : String;
    IRQNum : DWord;
    ValErr : DWord;
Begin
 BlasterGetIRQ:=0;
 If Pos('I',S)=0 Then Exit;
 IRQStr:=Copy(S,Pos('I',S)+1,2);

 If (Ord(IRQStr[2])>Ord('9')) Or (Ord(IRQStr[2])<Ord('0')) Then Begin
   IRQStr:=Copy(IRQStr,1,1);
  End;

 Val(IRQStr,IRQNum,ValErr);
 If ValErr=1 Then Exit;

 BlasterGetIRQ:=IRQNum;
End;

Function BlasterGetLowDMA(S : String) : DWord;
Var DMAStr : String;
    DMANum : DWord;
    ValErr : DWord;
Begin
 BlasterGetLowDMA:=0;
 If Pos('D',S)=0 Then Exit;
 DMAStr:=Copy(S,Pos('D',S)+1,1);

 Val(DMAStr,DMANum,ValErr);
 If ValErr=1 Then Exit;

 BlasterGetLowDMA:=DMANum;
End;

Function BlasterGetHighDMA(S : String) : DWord;
Var DMAStr : String;
    DMANum : DWord;
    ValErr : DWord;
Begin
 BlasterGetHighDMA:=0;
 If Pos('H',S)=0 Then Exit;
 DMAStr:=Copy(S,Pos('H',S)+1,1);

 Val(DMAStr,DMANum,ValErr);
 If ValErr=1 Then Exit;

 BlasterGetHighDMA:=DMANum;
End;

Function BlasterGetConfig(Var Config : ISS_TSBHWSetup) : Boolean;
Var EnvStr : String;
Begin
 BlasterGetConfig:=False;
 EnvStr:=GetEnv('BLASTER');
 If EnvStr<>'' Then Begin
   EnvStr:=UpcaseString(EnvStr); { þ Convert the env setting to uppercase þ }
   With Config Do Begin
     Base_Port:=BlasterGetBasePort(EnvStr);
     DAC_IRQ:=BlasterGetIRQ(EnvStr);
     Low_DMA:=BlasterGetLowDMA(EnvStr);
     High_DMA:=BlasterGetHighDMA(EnvStr);
    End;
   BlasterGetConfig:=True;
  End;
End;


{ þ Reads the DSP status value þ }
Function SB_DSPRead : Byte; Assembler;
Asm
 MOV  DX,DSPRStatPort
 ADD  DX,ISS_SBDevice.DevBaseport

 MOV  ECX,10000
 @ReadWait:
  IN   AL,DX
  OR   AL,AL
  JS   @ReadOK
 LOOP @ReadWait
 XOR  EAX,EAX
 JMP  @Exit

 @ReadOk:
  MOV  DX,DSPReadPort
  ADD  DX,ISS_SBDevice.DevBaseport
  IN   AL,DX
 @Exit:
End;

{ þ Wait before writing to the DSP þ }
Function SB_Wait : Boolean; Assembler;
Asm
 MOV DX,DSPWritePort
 ADD DX,ISS_SBDevice.DevBaseport

 MOV ECX,10000
 @WaitDSPLoop:
  IN AL,DX
  OR AL,AL
  JNS @WaitDSPEnd
 LOOP @WaitDSPLoop
 XOR EAX,EAX
 JMP @Exit

 @WaitDSPEnd:
  MOV EAX,1

 @Exit:
End;

{ þ Writes command value out to the DSP þ }
Function SB_DSPWrite(Value : Byte) : Boolean;
Begin
 SB_DSPWrite:=False;
 If SB_Wait Then Begin
   Asm
    MOV DX,DSPWritePort
    ADD DX,ISS_SBDevice.DevBaseport
    MOV AL,Value
    OUT DX,AL
   End;
   SB_DSPWrite:=True;
  End;
End;

{ þ Resets the Sound Blaster DSP þ }
Function SB_DSPInit : Boolean; Assembler;
Asm
 MOV  DX,DSPResetPort
 ADD  DX,ISS_SBDevice.DevBaseport
 MOV  AL,1
 OUT  DX,AL
 MOV  ECX,10
 @WaitInit:
  IN   AL,DX
 LOOP @WaitInit
 XOR  EAX,EAX
 OUT  DX,AL

 MOV  DX,DSPRStatPort
 ADD  DX,ISS_SBDevice.DevBaseport
 MOV  ECX,1000
 @InitReadWait:
  IN   AL,DX
  TEST AL,AL
  JS   @InitReadOK
 LOOP @InitReadWait
 JMP  @DSPInitFail
 @InitReadOK:


 MOV  DX,DSPReadPort
 ADD  DX,ISS_SBDevice.DevBaseport
 MOV  ECX,1000
 @InitReadLoop:
  IN   AL,DX
  CMP  AL,$0AA
  JE   @DSPInitSuccess
 LOOP @InitReadLoop

 @DSPInitFail:
  XOR EAX,EAX
  JMP @Exit

 @DSPInitSuccess:
  MOV EAX,1

 @Exit:
End;

{ þ Gets the Sound Blaster DSP version. þ }
Function SB_DSPGetVersion : Word;
Var TempVersion  : Word;
Begin
 SB_DSPGetVersion:=0;

 { þ Sending GetVersion DSP Command þ }
 If Not SB_DSPWrite(DSP_GetVersion) Then Exit;

 { þ Reading version þ }
 TempVersion:=SB_DSPRead*256;
 TempVersion:=TempVersion+SB_DSPRead;

 {$IFDEF _ISS_SB_FORCEDSPVERSION_}
  TempVersion:=DSPForceVersion*256;
 {$ENDIF}

 { þ DSP versions below 2.0 currently not supported þ }
 If TempVersion<$200 Then Exit;

 { þ Writing values into SBHWSetup record þ }
 With ISS_SBHWSetup Do Begin
   DSPVer_Maj:=Hi(TempVersion);
   DSPVer_Min:=Lo(TempVersion);
   Card_Type:=DSPVer_Maj;
   If Card_Type>4 Then Card_Type:=4;

   Case Card_Type Of
     2 : Begin
           MaxRate:=22050;
           ModeFlags:=ISS_Dev8Bit+ISS_DevMono+ISS_DevUnsigned+ISS_DevMixed;
          End;
     3 : Begin
           MaxRate:=22050;
           ModeFlags:=ISS_Dev8Bit+ISS_DevMono+ISS_DevStereo+
                      ISS_DevUnsigned+ISS_DevMixed;
          End;
     Else Begin { þ DSP 4.0+ þ }
           MaxRate:=44100;
           ModeFlags:=ISS_Dev8Bit+ISS_Dev16Bit+ISS_DevMono+ISS_DevStereo+
                      ISS_DevSigned+ISS_DevUnsigned+ISS_DevMixed;
          End;
    End;
  End;

 SB_DSPGetVersion:=TempVersion;
End;

{ þ Detects SoundBlaster Hardware presence þ }
Function SB_HardDetect : Boolean;
Begin
 SB_HardDetect:=False;
 If Not SB_DSPInit Then Exit;
 If SB_DSPGetVersion=0 Then Exit;
 SB_HardDetect:=True;
End;

Procedure SB_SetPROStereo; Assembler;
Asm
 MOV DX,$04
 ADD DX,ISS_SBDevice.DevBaseport
 MOV AL,$0E
 OUT DX,AL   { þ Select register $0E þ }
 INC DX
 IN  AL,DX   { þ Read register $0E þ }

 OR  AL,2    { þ Mask bit 1 to 1 þ }
 MOV AH,AL

 DEC DX
 MOV AL,$0E  { þ MixerOutSetting þ }
 OUT DX,AL
 INC DX

 MOV AL,AH
 OUT DX,AL   { þ Selecting stereo þ }
End;

Procedure SB_SetPROMono; Assembler;
Asm
 MOV DX,$04
 ADD DX,ISS_SBDevice.DevBaseport
 MOV AL,$0E
 OUT DX,AL   { þ Select register $0E þ }
 INC DX
 IN  AL,DX   { þ Read register $0E þ }

 OR  AL,NOT 2    { þ Mask bit 1 to 0 þ }
 MOV AH,AL

 DEC DX
 MOV AL,$0E  { þ MixerOutSetting þ }
 OUT DX,AL
 INC DX

 MOV AL,AH
 OUT DX,AL   { þ Selecting stereo þ }
End;


{ þ Calculates time constant & playing frequency þ }
Function SB_GetTimeConstant(Var SmpRate : Word) : Byte;
Var TimeConst : Byte;
    SRate     : Word;
Begin
 { þ Calculating time constant from the specified mixing rate þ }
 { þ and calculating the correct mixing rate from timeconst þ }
 SRate:=SmpRate;
 With ISS_SBDevice Do Begin
   If (DevType And ISS_DevStereo)>0 Then Begin

     TimeConst:=(1000000 Div (SRate*2));
     TimeConst:=(256-TimeConst);
     If ISS_SBHWSetup.Card_Type<4 Then Begin
       If TimeConst>233 Then TimeConst:=233;
      End;
     SRate:=(1000000 Div (256-TimeConst)) Div 2;

    End Else Begin
     TimeConst:=(256-(1000000 Div SRate))-1;
     If ISS_SBHWSetup.Card_Type<4 Then Begin
       If TimeConst>233 Then TimeConst:=233;
      End;
     SRate:=(1000000 Div (256-TimeConst));
    End;

  End;
 SmpRate:=SRate;
 SB_GetTimeConstant:=TimeConst;
End;

{ þ Starts playing the buffer using 8-bit mono Auto-initialize mode þ }
Procedure SB_PlayDMAAutoInit(TimeConst : Byte; TFLength : Word;
                             HighSpeed : Boolean);
Begin
 { þ Writing time constant þ }
 SB_DSPWrite(DSP_SetTimeConst);
 SB_DSPWrite(TimeConst);

 { þ Setting Transfer block length þ }
 SB_DSPWrite(DSP_SetHSpeedSize);
 SB_DSPWrite((TFLength-1) And $00FF); { þ Transfer length low byte þ }
 SB_DSPWrite((TFLength-1) Shr 8); { þ Transfer length high byte þ }

 If HighSpeed Then SB_DSPWrite($90)  { þ Start 8-bit PCM high-speed output þ }
              Else SB_DSPWrite($1C); { þ Start 8-bit PCM output þ }
End;

{ þ Starts playing the buffer using the DSP 4.00 Auto-initialize mode þ }
Procedure SB_Play400(SmpRate : Word; ModeFlags : Byte; TFLength : Word);
Var RealBufSize : Word;
Begin
 { þ Setting samplerate þ }
 SB_DSPWrite(DSP_SetSampleRate);
 SB_DSPWrite(SmpRate Shr 8);
 SB_DSPWrite(SmpRate And $00FF);

 { þ Setting up DSP4+ for the transfer þ }
 If (ModeFlags And ISS_Dev16Bit)>0 Then Begin
   SB_DSPWrite($B4); { þ Start DMA Output, FIFO, 16Bit, AutoInit þ }
   RealBufSize:=(TFLength Div 2)-1;
  End Else Begin
   SB_DSPWrite($C6); { þ Start DMA Output, FIFO, 8Bit, AutoInit þ }
   RealBufSize:=TFLength-1;
  End;

 If (ModeFlags And ISS_DevStereo)>0 Then Begin
   SB_DSPWrite($30); { þ DMA is signed and stereo þ }
  End Else Begin
   SB_DSPWrite($10); { þ DMA is signed and mono þ }
  End;

 { þ Setting Transfer block length þ }
 SB_DSPWrite(RealBufSize And $00FF); { þ Transfer length low byte þ }
 SB_DSPWrite(RealBufSize Shr 8);     { þ Transfer length high byte þ }
End;


{ þ >>> S O U N D  B L A S T E R  I R Q  R O U T I N E <<< þ }

Procedure ISS_SBIRQHandler;
Type Proc = Procedure;
Var Counter : DWord;
Begin
 With ISS_MixerData^ Do Begin
   For Counter:=0 To 7 Do Begin
     Proc(ISS_SBPeriodicCall);
     Inc(MixBufOffs,ISS_SBMixBufSize Div 8);
    End;
  End;
End;


Procedure ISS_SBIRQ; Assembler;
Asm
  CLI
  PUSH   DS
  PUSH   ES
  PUSH   FS
  PUSH   GS
  PUSHAD
  MOV    AX,CS:[BackupDS]
  MOV    DS,AX
  MOV    ES,AX
  MOV    AX,DosMemSelector
  MOV    FS,AX

  { þ SB DSP IRQ Acknowledge þ }
  MOV    DX,ISS_SBDevice.DevBaseport
  CMP    ISS_SBDMAChan,4
  JA     @DSP16BitAck
   ADD    DX,DSP8AckPort
   IN     AL,DX  { þ Acknowledge 8bit DSP IRQ þ }
   JMP    @SBAckOk
  @DSP16BitAck:
   ADD    DX,DSP16AckPort
   IN     AL,DX  { þ Acknowledge 16bit DSP IRQ þ }
  @SBAckOk:

  { þ Changing buffer þ }
  MOVZX  EAX,ISS_SBBufNum
  ADD    EAX,1
  AND    EAX,1

  XOR    EBX,EBX
  CMP    EAX,1
  JNE    @BeginCopy
   MOV    EBX,ISS_SBMixBufSize
  @BeginCopy:
  MOV    ISS_SBBufNum,AL

  { þ Setting mixer to the new buffer þ }
  MOV    EDX,ISS_MixerData
  MOV    EAX,ISS_DMAAddress
  ADD    EAX,EBX
  MOV    [EDX+20],EAX

  { þ Calling soundsystem code þ }
  CALL   ISS_SBIRQHandler

  { þ PC IRQ Controller þ }
  MOV    DX,$20 { þ Interrupt request acknowledge (8bit PIC) þ }
  MOV    AL,$20
  OUT    DX,AL
  CMP    ISS_SBDevice.DevIRQ,7
  JBE    @Done
   MOV    DX,$0A0
   MOV    AL,$20
   OUT    DX,AL  { þ Interrupt request acknowledge (16bit PIC#2) þ }

  @Done:
  POPAD
  POP    GS
  POP    FS
  POP    ES
  POP    DS
  IRET
End;


{ þ >>> E X T E R N A L  D E V I C E - D R I V E R  F U N C T I O N S <<< þ }

Function ISS_SBDetect : Boolean;
Begin
 ISS_SBDetect:=SB_HardDetect;
End;

Function ISS_SBInit : Boolean;
Begin
 ISS_SBInit:=SB_DSPInit;
End;

Function ISS_SBDone : Boolean;
Begin
 ISS_SBDone:=SB_DSPInit;
End;

Function ISS_SBSetVolume(Volume : DWord) : Boolean;
Begin
 ISS_SBSetVolume:=True;
End;

Function ISS_SBStartOutput(PeriodicCall : Pointer) : Boolean;
Var MixBufSize  : DWord;
    TimeConst   : Byte;
    DMAMode     : DWord;
Begin
 ISS_SBStartOutput:=False;

 Disable; { þ Stopping interrupts þ }

 { þ Initialize Sound Blaster hardware þ }
 If Not SB_DSPInit Then Exit;
 If Not SB_DSPWrite(DSP_TurnOnSpeaker) Then Exit;
 { þ Set stereo mode for SB Pro þ }
 If ISS_SBHWSetup.DSPVer_Maj=3 Then Begin
   SB_SetPROStereo;
  End;

 { þ Calculating values for 50hz timer þ }
 ISS_SBPlayFreq:=ISS_SBDevice.DevMixRate;
 TimeConst:=SB_GetTimeConstant(ISS_SBPlayFreq);
 ISS_SBDevice.DevMixRate:=ISS_SBPlayFreq;
 ISS_SBMixBufSize:=ISS_SBPlayFreq Div 25;

 { þ Align buffer size þ }
 ISS_SBMixBufSize:=ISS_SBMixBufSize+7;
 ISS_SBMixBufSize:=ISS_SBMixBufSize And $000FFFF8;

 With ISS_SBDevice Do Begin

   { þ Setting mixer buffer size þ }
   MixBufSize:=ISS_SBMixBufSize Div 8;

   { þ Stereo buffer is two times bigger þ }
   If (DevType And ISS_DevStereo)>0 Then Begin
     ISS_SBMixBufSize:=ISS_SBMixBufSize*2;
    End;
   { þ Mixer bufsize is not depends on sample resolution, since mixing is þ }
   { þ always done in 16 bits þ }
   { þ 16bit DMA buffer is two times bigger þ }
   If (DevType And ISS_Dev16Bit)>0 Then Begin
     ISS_SBMixBufSize:=ISS_SBMixBufSize*2;
    End;

   { þ Calculating timer calling frequency þ }
   ISS_TimerDiff:=ISS_TimerSpeed Div 200;

   { þ Allocating DMA buffer þ }
   ISS_DMAAllocBuffer;

   { þ Initialize the mixer þ }
   ISS_MixerInit(ISS_SBPlayFreq,MixBufSize,DosMemSelector,DWord(ISS_DMAAddress),DevType);

   { þ Setting up DMA þ }
   If (DevType And ISS_Dev16Bit)>0 Then Begin
     ISS_SBDMAChan:=ISS_SBHWSetup.High_DMA;
    End Else Begin
     ISS_SBDMAChan:=ISS_SBHWSetup.Low_DMA;
    End;

   DMAMode:=%01011000;
   ISS_DMAStop(ISS_SBDMAChan);
   ISS_DMAStart(ISS_SBDMAChan,ISS_DMAAddress,ISS_SBMixBufSize*2,DMAMode);

   { þ Setting up the IRQ þ }
   SB_NewIRQ.Offset:=@ISS_SBIRQ; { þ Getting the new routine's address þ }
   SB_NewIRQ.Segment:=Get_CS;

   Get_PM_Interrupt(ISS_IRQMapping[DevIRQ],SB_OldIRQ); { þ Storing the old routine þ }
   If Set_PM_Interrupt(ISS_IRQMapping[DevIRQ],SB_NewIRQ) Then Begin
     ISS_SBPeriodicCall:=PeriodicCall;
     ISS_IRQEnable(DevIRQ); { þ Enabling IRQ þ }
     {$IFDEF _ISS_SB_DEBUGMODE_}
      WriteLn('DEV_INIT: Mixing Frequency:',ISS_SBPlayFreq,'Hz - Buffer Size:',ISS_SBMixBufSize,' bytes');
      WriteLn('DEV_INIT: Starting ',ISS_SBName,' output...');
     {$ENDIF}
     ISS_SBBufNum:=1;

     If ISS_SBHWSetup.DSPVer_Maj<4 Then Begin
       { þ If DSP version below 4, then use the old way to start the output þ }
       If ISS_SBPlayFreq>20000 Then Begin
         { þ If frequency is above 20khz, use high speed transfer þ }
         SB_PlayDMAAutoInit(TimeConst,ISS_SBMixBufSize,True);
        End Else Begin
         SB_PlayDMAAutoInit(TimeConst,ISS_SBMixBufSize,False);
        End;
      End Else Begin
       { þ If SB16 or better, we use DSP4+ commands to start the output þ }
       SB_Play400(ISS_SBPlayFreq,DevType,ISS_SBMixBufSize);
      End;
     ISS_SBStartOutput:=True;
    End Else Begin
     {$IFDEF _ISS_SB_DEBUGMODE_}
      WriteLn('DEV_FAIL: ERROR! Failed to start ',ISS_SBName,' output!');
      ISS_MixerDone;
      ISS_DMAFreeBuffer;
     {$ENDIF}
    End;
  End;

 Enable; { þ Enabling Interrupts þ }

End;

Function ISS_SBStopOutput(PeriodicCall : Pointer) : Boolean;
Begin
 ISS_SBStopOutput:=False;
 Disable;
 ISS_DMAStop(ISS_SBDMAChan);
 If (ISS_SBDevice.DevType And ISS_Dev16Bit)>0 Then Begin
   SB_DSPWrite($D9);
   Asm
    MOV    DX,ISS_SBDevice.DevBaseport
    ADD    DX,DSP16AckPort
    IN     AL,DX  { þ Acknowledge 16bit DSP IRQ þ }
   End;
  End Else Begin
   SB_DSPWrite($DA);
   Asm
    MOV    DX,ISS_SBDevice.DevBaseport
    ADD    DX,DSP8AckPort
    IN     AL,DX  { þ Acknowledge 8bit DSP IRQ þ }
   End;
  End;
 SB_DSPInit;
 With ISS_SBDevice Do Begin
   ISS_IRQDisable(DevIRQ);
   ISS_SBStopOutput:=Set_PM_Interrupt(ISS_IRQMapping[DevIRQ],SB_OldIRQ);
  End;
 ISS_MixerDone;     { þ Closing the mixer þ }
 ISS_DMAFreeBuffer; { þ Deallocating DMA buffer þ }
 Enable;
 {$IFDEF _ISS_NSND_DEBUGMODE_}
   WriteLn('DEV_INIT: ',ISS_SBName,' output stopped.');
 {$ENDIF}
End;

{ þ This procedure assigns the device driver procedures þ }
Procedure ISS_SBDevInit;
Begin
 ISS_TimerFreq:=50;
 With ISS_SBDriver Do Begin
   Detect    :=@ISS_SBDetect;
   Init      :=@ISS_SBInit;
   Done      :=@ISS_SBDone;
   LoadSample:=@ISS_MixerLoadSample;
   FreeSample:=@ISS_MixerFreeSample;
   SetVolume :=@ISS_SBSetVolume;
   StartOut  :=@ISS_SBStartOutput;
   StopOut   :=@ISS_SBStopOutput;
   UpdateOut :=@ISS_MixerUpdateOutput;
  End;
 ISS_SBDevice.DevDriver:=@ISS_SBDriver;

 {$IFDEF _ISS_SB_DEBUGMODE_}
  WriteLn('DEV_INIT: Device - ',ISS_SBLongDesc,' ',ISS_SBVersionStr);
 {$ENDIF}

 {$IFDEF _ISS_SB_FORCEDSPVERSION_}
  Write('DEV_INIT: Enter DSP Major version:');
  ReadLn(DSPForceVersion);
 {$ENDIF}

 { þ Reading BLASTER Environment Settings þ }
 If BlasterGetConfig(ISS_SBHWSetup) Then Begin
   { þ If BLASTER found, assigning hardware parameters þ }
   With ISS_SBDevice Do Begin
     DevName    :=ISS_SBName;  { þ Name of the device þ }
     With ISS_SBHWSetup Do Begin
       DevBaseport:=Base_Port;
       DevAvail   :=SB_HardDetect;
       If DevAvail Then Begin
         DevName    :=ISS_SBNames[Card_Type];
         DevType    :=ModeFlags;
         DevFreq    :=MaxRate;
         DevIRQ     :=DAC_IRQ;
         DevDMA1    :=Low_DMA;
         { þ There is no High DMA on SBPro and below þ }
         If Card_Type>3 Then DevDMA2:=High_DMA
                        Else DevDMA2:=$0FF;
         DevMaxChan :=ISS_MaxSSChannels;
         DevDRAMSize:=0; { þ SBs' have no On-Board RAM. þ }
        End;
      End;

    End;
  End;

 {$IFDEF _ISS_SB_DEBUGMODE_}
  If ISS_SBDevice.DevAvail Then Begin
     With ISS_SBHWSetup Do Begin
       WriteLn('DEV_INIT:        - ',ISS_SBNames[Card_Type],' with DSP version ',DSPVer_Maj,'.',DSPVer_Min);
      End;
     With ISS_SBDevice Do Begin
       Write('DEV_INIT:        - Baseport: $',WriteHex(DevBaseport),
             ' IRQ:',DevIRQ,' DMA8:',DevDMA1);
       If DevDMA2<>$0FF Then Write(' DMA16:',DevDMA2);
       WriteLn;
      End;
   End Else Begin
     WriteLn('DEV_INIT:        - SOUND BLASTER DETECTION FAILED!');
   End;
 {$ENDIF}
End;

Begin
End.
{ þ ISS_SB.PAS - (C) 2000-2001 Charlie/Inquisition þ }
