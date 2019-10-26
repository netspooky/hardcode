{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_GUS .PAS - Device Driver for GF1 based Gravis Ultrasound cards     ³}
{³                  Work started     : 1998.10.16.                          ³}
{³                  Last modification: 2001.03.01.                          ³}
{³             OS - GO32V2 only.                                            ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$ASMMODE INTEL}
{$MODE FPC}

{$HINTS OFF} { þ Enable this if you modify the source! þ }
{$NOTES OFF} { þ Enable this if you modify the source! þ }

Unit ISS_GUS;

Interface

Uses ISS_Var, { þ Uses the system variables and types þ }
     ISS_Tim, { þ Uses the timer services þ }
     GO32,    { þ Uses GO32 unit, because DOS-only driver þ }
     DOS;     { þ Uses DOS unit, for environment variable access þ }

Const ISS_GUSVersionStr = '0.6.6';
      ISS_GUSName     = 'Gravis Ultrasound';
      ISS_GUSLongDesc = 'Gravis Ultrasound GF1 Based Wavetable Device Driver';

Var ISS_GUSDevice : ISS_TSoundDevice; { þ GUS Device Structure þ }
    ISS_GUSDriver : ISS_TSoundDriver; { þ GUS Device Driver þ }

Procedure ISS_GUSDevInit; { þ Inits the GUS driver structures þ }

Implementation

{ þ UltraSound Ports þ }
Const StatusPort      = $6; { þ $2x6 þ }
      TimerCtrlPort   = $8; { þ $2x8 þ }
      TimerDataPort   = $9; { þ $2x9 þ }

      MidiCtrlPort    = $100;
      MidiDataPort    = $101;

      ActiveVoicePort = $102;
      CommandPort     = $103; { þ $3x3 (Reg Select) þ }
      DataLowPort     = $104; { þ $3x4 þ }
      DataHighPort    = $105; { þ $3x5 þ }
      DRAMIOPort      = $107; { þ $3x7 þ }

      JoystickTimer   = $201;

      BoardVersion    = $506; { þ Read þ }
      MixerControl    = $506; { þ Write (ICS Mixer Control) þ }

      { þ UltraSound Commands ( or/and register ) þ }

      WriteVoiceMode  = $00;
      SetVoiceFreq    = $01; { þ Value=Freq/Divisor þ }
      LoopStartLo     = $02;
      LoopStartHi     = $03;
      SampleEndLo     = $04;
      SampleEndHi     = $05;
      VolRampRate     = $06;
      VolRampStart    = $07;
      VolRampEnd      = $08;
      SetVolume       = $09;
      SampleStartLo   = $0A;
      SampleStartHi   = $0B;
      VoiceBalance    = $0C;
      VolumeCtrl      = $0D;
      VoicesActive    = $0E;
      DMACtrl         = $41;
      DMAStartAddress = $42;
      DRAMAddrLo      = $43;
      DRAMAddrHi      = $44;
      TimerCtrl       = $45;
      TimerCount1     = $46;
      TimerCount2     = $47;
      SampleFreq      = $48;
      SampleCtrl      = $49;
      Initialize      = $4C;
      Read            = $80;
      ReadVolume      = Read+SetVolume;     { þ $89 þ }
      VoicePosLo      = Read+SampleStartLo; { þ $8A þ }
      VoicePosHi      = Read+SampleStartHi; { þ $8B þ }
      ReadVolCtrl     = Read+VolumeCtrl;    { þ $8D þ }
      IRQStatus       = $8F;

      GUSFreq : Array[0..31] Of Word =( { þ Ultrasound Frequency Table þ }
                      44100,44100,44100,44100,44100,44100,44100,
                      44100,44100,44100,44100,44100,44100,44100,
                      41160,38587,36317,34300,32494,30870,29400,
                      28063,26843,25725,24696,23746,22866,22050,
                      21289,20580,19916,19293);

      GUS_StopLineIn = 0; { þ 0 = Line In Enabled, 1 = Line In Disabled þ }

Type ISS_TGUSHWSetup = Record { þ Used for GUS detection þ }
       Base_Port  : Word;
       DRAM_DMA   : Word;
       ADC_DMA    : Word;
       GF1_IRQ    : Word;
       MIDI_IRQ   : Word;
       DRAM_Size  : Word;
       GUS_Ver    : Byte;
      End;

Var ISS_GUSHWSetup    : ISS_TGUSHWSetup; { þ GUS Hardware Parameters þ }
    ISS_GUSDRAMOffset : DWord;

    ISS_GUSActiveChannels : Word;  { þ Number of active hardware channels þ }
    ISS_GUSDivisor        : DWord; { þ Frequency divisor (See GUS_Freq) þ }

    ISS_GUSVol : Array[0..512] Of Word; { þ GUS Volume table þ }

{ þ >>> D E B U G  F U N C T I O N S <<< þ }

{$IFDEF _ISS_GUS_DEBUGMODE_}
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

{ þ  !UGLY  SHIT  FROM  GUS  SDK!  þ }
Function ParseToHex(Var FromStr : String; Var ToWord : Word) : Boolean;
{ þ Take the first number found.  Disregard ',' and ' ' chars þ }
Begin
 ParseToHex := False;
 While ((FromStr[1]=' ') Or (FromStr[1]=',') Or
        (FromStr[1]='$')) And (Length(FromStr)<>0) Do Delete(FromStr,1,1);
 If (Ord(FromStr[1])>47) And (Ord(FromStr[1])<58) And
    (FromStr <> '') Then Begin
   ParseToHex:=True;  { þ a number was found þ }
   ToWord:=0;
   While (Ord(FromStr[1])>47) And (Ord(FromStr[1])<58) And
         (FromStr <> '') Do Begin
     ToWord:=(ToWord*$10)+(Ord(FromStr[1])-Ord('0'));
     Delete(FromStr,1,1);
    End;
  End;
End;
{ þ  !UGLY  SHIT  FROM  GUS  SDK!  þ }

{ þ  !UGLY  SHIT  FROM  GUS  SDK!  þ }
Function ParseToNum(Var FromStr : String; Var ToWord : Word) : Boolean;
{ þ Take the first number found.  Disregard ',' And ' ' chars þ }
Var StripStr : String[10];
    Code     : Integer;
Begin
 ParseToNum := False;
 While ((FromStr[1]=' ') Or (FromStr[1]=',')) And
        (Length(FromStr)<>0) Do Delete(FromStr,1,1);
 If (Ord(FromStr[1])>47) And (Ord(FromStr[1])<58) And (FromStr<>'') Then Begin
   ParseToNum:=True;  { þ a number was found þ }
   StripStr:='';
   While (Ord(FromStr[1])>47) And (Ord(FromStr[1])<58) And
         (FromStr<>'') Do Begin
     StripStr:=StripStr+FromStr[1];
     Delete(FromStr,1,1);
    End;
   Val(StripStr,ToWord,Code);
  End;
End;
{ þ  !UGLY  SHIT  FROM  GUS  SDK!  þ }

{ þ  !UGLY  SHIT  FROM  GUS  SDK!  þ }
Function UltraGetConfig(Var Config : ISS_TGUSHWSetup) : Boolean;
Var EnvStr : String;
Begin
 UltraGetConfig:=False;
 EnvStr:=GetEnv('ULTRASND');
 If EnvStr<>'' Then Begin
   With Config Do Begin
     If ParseToHex(EnvStr,Base_Port) And ParseToNum(EnvStr,DRAM_DMA) And
        ParseToNum(EnvStr,ADC_DMA) And ParseToNum(EnvStr,GF1_IRQ) And
        ParseToNum(EnvStr,MIDI_IRQ) Then Begin
       UltraGetConfig:=True;
      End;
    End;
  End;
End;
{ þ  !UGLY  SHIT  FROM  GUS  SDK!  þ }

Procedure GUSGenerateVolTable;
Var Counter  : DWord;
    Counter2 : DWord;
    TempVal  : DWord;
Begin
 ISS_GUSVol[0]:=0;
 ISS_GUSVol[512]:=$0FFF;
 For Counter:=1 To 511 Do Begin
   Counter2:=$0600;
   TempVal :=Counter;
   While TempVal>0 Do Begin
     Inc(Counter2,$0100);
     TempVal:=TempVal Shr 1;
    End;
   ISS_GUSVol[Counter]:=Counter2 Or ((Counter Shl (8-((Counter2-$0700) Shr 8))) And $0FF);
  End;
End;

Procedure GUSDelay; Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 IN  AL,DX
 IN  AL,DX
 IN  AL,DX
 IN  AL,DX
 IN  AL,DX
 IN  AL,DX
 IN  AL,DX
End;

Procedure GUSWrite(Register, Value : Byte); Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,Register
 OUT DX,AL { þ Selects the register to write þ }
 ADD DX,2  { þ Data High port þ }
 MOV AL,Value
 OUT DX,AL { þ Writes value out to the GUS þ }
End;

Procedure GUSWriteDelay(Register, Value : Byte); Assembler;
Asm
 MOV  DX,CommandPort
 ADD  DX,ISS_GUSDevice.DevBaseport
 MOV  AL,Register
 OUT  DX,AL { þ Selects the register to write þ }
 ADD  DX,2  { þ Data High port þ }
 MOV  AL,Value
 OUT  DX,AL { þ Writes value out to the GUS þ }
 CALL GUSDelay
 OUT  DX,AL { þ Writes value out to the GUS þ }
End;

Procedure GUSWriteW(Register : Byte; Value : Word); Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,Register
 OUT DX,AL { þ Selects the register to write þ }
 INC DX    { þ Data Low port þ }
 MOV AX,Value
 OUT DX,AX { þ Writes value out to the GUS þ }
End;

Function GUSRead(Register : Byte) : Byte; Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,Register
 OUT DX,AL { þ Selects the register to read þ }
 ADD DX,2  { þ Data High Port þ }
 IN  AL,DX { þ Reads value out from the GUS þ }
End;

Function GUSReadW(Register : Byte) : Word; Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,Register
 OUT DX,AL { þ Selects the register to read þ }
 INC DX    { þ Data Low Port þ }
 IN  AX,DX { þ Reads value out from the GUS þ }
End;

{ þ Set the current active voice þ }
Procedure GUSSetVoice(Voice : Byte); Assembler;
Asm
 MOV AL,Voice
 MOV DX,ActiveVoicePort
 ADD DX,ISS_GUSDevice.DevBaseport
 OUT DX,AL
End;

{ þ Reads a byte from GUS DRAM þ }
Function GUSPeek(Address : DWord) : Byte; Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,DRAMAddrLo
 OUT DX,AL { þ Select Register (3x3) þ }
 INC DX    { þ DataLowPort     (3x4) þ }
 MOV EAX,Address
 OUT DX,AX
 DEC DX    { þ CommandPort     (3x3) þ }
 MOV AL,DRAMAddrHi
 OUT DX,AL
 ADD DX,2  { þ DataHighPort    (3x5) þ }
 SHR EAX,16
 OUT DX,AL
 ADD DX,2  { þ DRAMIOPort      (3x7) þ }
 IN  AL,DX
End;

{ þ Writes a byte to GUS DRAM þ }
Procedure GUSPoke(Address : DWord; Value : Byte); Assembler;
Asm
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,DRAMAddrLo
 OUT DX,AL { þ Select Register (3x3) þ }
 INC DX    { þ DataLowPort     (3x4) þ }
 MOV EAX,Address
 OUT DX,AX
 DEC DX    { þ CommandPort     (3x3) þ }
 MOV AL,DRAMAddrHi
 OUT DX,AL
 ADD DX,2  { þ DataHighPort    (3x5) þ }
 SHR EAX,16
 OUT DX,AL
 ADD DX,2  { þ DRAMIOPort      (3x7) þ }
 MOV AL,Value
 OUT DX,AL
End;

Function GUSHardDetect : Boolean;
Begin
 GUSHardDetect:=False;
 With ISS_GUSDevice Do Begin
   If DevBaseport=0 Then Exit;

   Asm
    MOV DX,CommandPort
    ADD DX,ISS_GUSDevice.DevBaseport
    MOV AL,Initialize { þ Take the GUS out of a reset state þ }
    OUT DX,AL
    ADD DX,2          { þ DataHighPort þ }
    MOV AL,00000111B
    OUT DX,AL
   End;

   { þ Detecting amount of GUS memory þ }
   DevDRAMSize:=0;
   GUSPoke(DevDRAMSize,$AA);
   While (GUSPeek(DevDRAMSize)=$AA) And (DevDRAMSize<1024*1024) Do Begin
     Inc(DevDRAMSize,256*1024);
     GUSPoke(DevDRAMSize,$AA);
    End;

   { þ If no RAM available then GUS cannot be used, so exit. þ }
   If DevDRAMSize=0 Then Exit;

   { þ Querying hardware revision ID. þ }
   Asm
    MOV DX,BoardVersion
    ADD DX,ISS_GUSDevice.DevBaseport
    IN  AL,DX
    MOV ISS_GUSHWSetup.GUS_Ver,AL
   End;

  End;
 GUSHardDetect:=True;
End;

Procedure GUS_OutputInit;
Var Counter : Byte;
Begin
 Asm
  CLI
 End;
 GUSWrite(Initialize,0); { þ GF1 Master Reset þ }
 GUSDelay;
 GUSDelay;
 GUSWrite(Initialize,1); { þ GF1 Enable þ }
 GUSDelay;
 GUSDelay;
 GUSWrite(VoicesActive,31 Or $0C0);
 For Counter:=0 To 31 Do Begin
   Asm
    MOV DX,ActiveVoicePort
    ADD DX,ISS_GUSDevice.DevBaseport
    MOV AL,Counter
    OUT DX,AL { þ Now we select channel þ }
   End;
   GUSWriteDelay(WriteVoiceMode,3); { þ Voice Off þ }
   GUSWriteDelay(VolumeCtrl,3);     { þ Volume Ramp Off þ }
   GUSWrite(VolRampRate,%00111111); { þ Max RampRate þ }
   GUSWriteW(SetVolume,$5000); { þ Volume <- 0 þ }
   GUSDelay;
   GUSDelay;
  End;
 GUSWrite(Initialize,3);
 GUSDelay;
 Asm
  MOV DX,ISS_GUSDevice.DevBaseport
  MOV AL,8+GUS_StopLineIn;
  OUT DX,AL
  STI
 End;
End;

Procedure GUS_RAM2DRAM(SData : Pointer; GUSOffset : DWord; Count : DWord); Assembler;
Asm
 CLI
 MOV EBX,GUSOffset
 MOV EDI,EBX
 SHR EBX,16
 MOV DX,CommandPort
 ADD DX,ISS_GUSDevice.DevBaseport
 MOV AL,DRAMAddrHi
 OUT DX,AL { þ 3x3 Select Register þ }
 ADD DX,2
 MOV AX,BX
 OUT DX,AL { þ 3x5 Data High þ }
 SUB DX,2
 MOV AL,DRAMAddrLo
 OUT DX,AL { þ 3x3 Select Register þ }
 INC DX
 MOV ECX,Count
 MOV ESI,SData { þ Data Source þ }
 @CycleHead:
  MOV AX,DI
  OUT DX,AX { þ 3x4 Data Low þ }
  ADD DX,3
  MOV AL,[ESI]
  INC ESI
  OUT DX,AL { þ 3x7 DRAM I/O þ }
  SUB DX,3
  ADD DI,1
  JNC @DoLoop
   DEC DX
   INC BX
   MOV AL,DRAMAddrHi
   OUT DX,AL { þ 3x3 Select Register þ }
   ADD DX,2
   MOV AX,BX
   OUT DX,AL { þ 3x5 Data High þ }
   SUB DX,2
   MOV AL,DRAMAddrLo
   OUT DX,AL { þ 3x3 Select Register þ }
   INC DX
  @DoLoop:
  DEC ECX
 JNZ @CycleHead
 STI
End;

{ þ Start a volume ramp on the current channel from the actual volume to þ }
{ þ the specified volume þ }
Procedure GUS_FadeVol(Vol2 : Word);
Var Vol1    : Word;
    Buffer  : Word;
    Swapped : Byte;
Begin

 { þ Read current volume from the GUS þ }
 Vol1:=GUSReadW(ReadVolume) Shr 4;

 { þ Setup ramp direction þ }
 If Vol1>Vol2 Then Begin
   Buffer:=Vol1; Vol1:=Vol2; Vol2:=Buffer; Swapped:=$40;
  End Else Begin
   Swapped:=$0;
  End;

 Dec(Vol2,Vol1); If Vol2=0 Then Exit;

 { þ Just simply set the volume if ramp would be too small þ }
 If Vol2<64 Then Begin
   If Swapped=0 Then Inc(Vol1,Vol2);
   GUSWriteW(SetVolume,Vol1 Shl 4);
   Exit;
  End;

 { þ Limit checks þ }
 Inc(Vol2,Vol1);

 if (Vol1<64)   then Vol1:=64;
 if (Vol2>4032) then Vol2:=4032;

 { þ Setup new ramp þ }
 GUSWrite(VolRampStart,Vol1 Shr 4);
 GUSWrite(VolRampEnd,Vol2 Shr 4);
 { þ Start new ramp þ }
 GUSWriteDelay(VolumeCtrl,Swapped);
End;

Procedure GUS_FadeVolDown;
Begin
 GUSWrite(VolRampStart,$04);
 GUSWrite(VolRampEnd,$FC);
 GUSWriteDelay(VolumeCtrl,$40);
End;

Procedure GUS_SetAddress(Register : Byte; Address : DWord);
Begin
 GUSWriteW(Register,Address Shr 7);
 GUSWriteW(Register+1,Address Shl 9);
End;

{ þ >>> E X T E R N A L  D E V I C E - D R I V E R  F U N C T I O N S <<< þ }

Function ISS_GUSDetect : Boolean;
Begin
 ISS_GUSDetect:=GUSHardDetect;
End;

Function ISS_GUSInit : Boolean;
Begin
 ISS_GUSInit:=False;
 If Not GUSHardDetect Then Begin
   { þ ERROR CODE! þ }
   Exit;
  End;
 ISS_GUSDRAMOffset:=0;
 GUSGenerateVolTable;
 GUS_OutputInit;
 ISS_GUSInit:=True;
End;

Function ISS_GUSDone : Boolean;
Begin
 ISS_GUSDone:=True;
End;

Function ISS_GUSLoadSample(SStruc : ISS_PSample) : Boolean;
Type PInteger  = ^Integer;
     PShortInt = ^ShortInt;
Var SmpConvBuf  : Pointer;
    Counter     : DWord;
    RealSLength : DWord;
Begin
 ISS_GUSLoadSample:=False;

 { þ Uploading sample þ }
 With SStruc^ Do Begin

   { þ If sample is 16bit, divide size with 2 þ }
   If (SType And ISS_Smp16BitData)>0 Then Begin
     RealSLength:=SLength Div 2;
    End Else Begin
     RealSLength:=SLength;
    End;

   { þ Is the sample fits into GUSRAM? þ }
   If RealSLength+ISS_GUSDRAMOffset+1>ISS_GUSDevice.DevDRAMSize Then Begin
     { þ ERROR CODE! þ }
     Exit;
    End;

   GetMem(SmpConvBuf,RealSLength);

   { þ GUS has some limitations when using 16bit samples, noteably a 16bit þ }
   { þ sample can't cross a 256k boundary. To simplify the driver, and þ }
   { þ because the lack of time, i decided to convert the samples to 8bit þ }
   { þ before loading into the GUS RAM. Later, a GUS heap manager should þ }
   { þ be implemented to handle 16bit samples correctly, but the mixer þ }
   { þ and other tasks has higher priority now. þ }
   { þ UPDATE: instead of a heap handler, an intelligent sample manager þ }
   { þ         should be implemented, to allow playing XM's bigger than þ }
   { þ         the available wavetable memory on wavetable soundcards.  þ }
   If (SType And ISS_Smp16BitData)>0 Then Begin
     For Counter:=0 To RealSLength-1 Do Begin
       PShortInt(SmpConvBuf)[Counter]:=PInteger(SData)[Counter] Shr 8;
      End;
    End Else Begin
     Move(SData^,SmpConvBuf^,RealSLength);
    End;

   { þ Modifying sample beginning to avoid some clickings þ }
   PShortInt(SmpConvBuf)[0]:=0;

   GUS_RAM2DRAM(SmpConvBuf,ISS_GUSDRAMOffset,RealSLength);

   FreeMem(SmpConvBuf,RealSLength);

   SStruc^.SDRAMOffs:=ISS_GUSDRAMOffset;
   Inc(ISS_GUSDRAMOffset,RealSLength);
  End;

 ISS_GUSLoadSample:=True;
End;

Function ISS_GUSFreeSample(SStruc : ISS_PSample) : Boolean;
Begin
 ISS_GUSFreeSample:=True;
End;

Function ISS_GUSSetVolume(Volume : DWord) : Boolean;
Begin
 { þ Dummy. Old GUSes have no mixer. :( Later, the support for the þ }
 { þ newer-series GF1's ICS mixer should be added. I'm looking for þ }
 { þ some programing docs about the ICS mixer! If you have the docs, þ }
 { þ please contact me, so i can add support for it. þ }
 ISS_GUSSetVolume:=True;
End;

Function ISS_GUSStartOutput(PeriodicCall  : Pointer) : Boolean;
Begin
 ISS_GUSStartOutput:=False;

 If ISS_ActiveSSChannels>32 Then ISS_GUSActiveChannels:=32
                            Else ISS_GUSActiveChannels:=ISS_ActiveSSChannels;
 If ISS_GUSActiveChannels<14 Then ISS_GUSActiveChannels:=14;

 { þ Boostin' up "The Queen Of The SoundCards" :) þ }
 GUSWrite(VoicesActive,Byte((ISS_GUSActiveChannels-1) Or $C0));
 { þ Phew, this was easy, wasn't it? Compare this with a Sound Blaster þ }
 { þ initialization code... :) þ }

 ISS_GUSDivisor:=GUSFreq[ISS_GUSActiveChannels-1];

 { þ Now initializing the timer call þ }
 If ISS_StartTimer(PeriodicCall,(ISS_TimerSpeed Div 140)) Then Begin
   ISS_GUSStartOutput:=True;
   ISS_TimerDiff:=ISS_TimerSpeed Div 140;
   {$IFDEF _ISS_GUS_DEBUGMODE_}
     WriteLn('DEV_INIT: Starting ',ISS_GUSName,' output...');
   {$ENDIF}
  End Else Begin
   {$IFDEF _ISS_GUS_DEBUGMODE_}
     WriteLn('DEV_FAIL: ERROR! Failed to start ',ISS_GUSName,' output!');
   {$ENDIF}
  End;
End;

Function ISS_GUSStopOutput(PeriodicCall : Pointer) : Boolean;
Begin
 ISS_GUSStopOutput:=ISS_StopTimer(PeriodicCall); { þ Stops timer call þ }
 ISS_GUSInit; { þ Reinitalizes soundcard þ }
 {$IFDEF _ISS_GUS_DEBUGMODE_}
   WriteLn('DEV_INIT: ',ISS_GUSName,' output stopped.');
 {$ENDIF}
End;

Procedure ISS_GUSUpdateOutput; { þ Updates the sound output þ }
{ þ This is the main driver, which runs on the timer at 140hz frequency þ }
{ þ so it should be as fast as possible. Because it's a low-level driver, þ }
{ þ hardware and platform dependent, it's a good idea to implement this þ }
{ þ later again - in full-assembly. þ }
Var ChannelCounter : Word;
    SampleBegin    : DWord;
    SampleEnd      : DWord;
    SampleFreq     : DWord;
    LoopBegin      : DWord;
    LoopEnd        : DWord;
    RealLength     : DWord;
    RealLoopStart  : DWord;
    RealLoopEnd    : DWord;
Begin

 { þ Stop Voices If Needed þ }
 For ChannelCounter:=0 To ISS_GUSActiveChannels-1 Do Begin
   With ISS_VirtualChannels^[ChannelCounter] Do Begin
     If ((VChControl And ISS_CCActive)>0) And
        ((VChControl And ISS_CCStop)>0) Then Begin
       Dec(VChControl,ISS_CCStop);
       GUSSetVoice(ChannelCounter);
       GUSWriteDelay(WriteVoiceMode,3);
       GUS_FadeVolDown;
      End;
    End;
  End;

 { þ Wait until volume slides ends þ }
 For ChannelCounter:=0 To ISS_GUSActiveChannels-1 Do Begin
   GUSSetVoice(ChannelCounter);
   Repeat Until (GUSRead(ReadVolCtrl) And 1)>0;
  End;

 { þ Start Voices Update þ }
 For ChannelCounter:=0 To ISS_GUSActiveChannels-1 Do Begin
   GUSSetVoice(ChannelCounter);
   With ISS_VirtualChannels^[ChannelCounter] Do Begin

     { þ Anything to do on this channel? þ }
     If (VChControl>1) And ((VChControl And ISS_CCActive)>0) Then Begin

       { þ Start a Sample ? þ }
       If (VChControl And ISS_CCSample)>0 Then Begin
         Dec(VChControl,ISS_CCSample);

         With VChSmpAddr^ Do Begin

           { þ 16bit sample values conversion þ }
           If (SType And ISS_Smp16BitData)>0 Then Begin
             RealLength   :=SLength    Div 2;
             RealLoopStart:=SLoopStart Div 2;
             RealLoopEnd  :=SLoopEnd   Div 2;
            End Else Begin
             RealLength   :=SLength;
             RealLoopStart:=SLoopStart;
             RealLoopEnd  :=SLoopEnd;
            End;

           { þ Sample & Loop End Address Calc. þ }
           { þ -1 is needed, because SampleEnd value _must_ contain the þ }
           { þ _last_ sample position and not the last+1!!! þ }
           SampleEnd:=SDRAMOffs+RealLength-1;

           If (SType And ISS_SmpPingPongLoop)>0 Then Begin
             { þ Offset limit checking þ }
             If (VChSmpOffs>RealLength-1) Then VChSmpOffs:=RealLoopStart;
             { þ Sample end value checking þ }
             LoopEnd:=SDRAMOffs+RealLoopEnd-1; { þ Same here as above... þ }
             If LoopEnd>SampleEnd Then LoopEnd:=SampleEnd;
            End Else Begin
             LoopEnd:=SampleEnd;
            End;

           { þ Sample & Loop Start Address Calc. þ }
           SampleBegin:=SDRAMOffs+VChSmpOffs;
           LoopBegin  :=SDRAMOffs+RealLoopStart;

           { þ Now we're going to tell to the GUS these values þ }
           GUS_SetAddress(SampleEndLo,LoopEnd);       { þ Sample End þ }
           GUS_SetAddress(LoopStartLo,LoopBegin);     { þ Loop Start þ }

           { þ Setting sample position þ }
           GUS_SetAddress(SampleStartLo,SampleBegin); { þ Sample Start þ }
           { þ Starting the sample... þ }
           GUSWriteDelay(WriteVoiceMode,SType And %00011000); { þ Sample Mode þ }

          End;

        End;

       { þ Change Channel Panning ? þ }
       If (VChControl And ISS_CCPanning)>0 Then Begin
         Dec(VChControl,ISS_CCPanning);
         GUSWrite(VoiceBalance,(VChFinalPanning Shr 4));
        End;

       { þ Change Channel Volume ? þ }
       If (VChControl And ISS_CCVolume)>0 Then Begin
         Dec(VChControl,ISS_CCVolume);
         GUS_FadeVol(ISS_GUSVol[VChFinalVolume Shl 2]);
        End;

       { þ Change Channel Frequency ? þ }
       If (VChControl And ISS_CCPeriod)>0 Then Begin
         Dec(VChControl,ISS_CCPeriod);
         SampleFreq:=((VChFreq Shl 9)+(ISS_GUSDivisor Shr 1)) Div ISS_GUSDivisor;
         SampleFreq:=SampleFreq Shl 1;
         GUSWriteW(SetVoiceFreq,SampleFreq);
        End;

       { þ Is Channel Still Active ? þ }
       If (GUSRead(Read) And 1)>0 Then Begin
         VChControl:=VChControl And Not ISS_CCActive;
        End;

      End;

    End;

  End;

End;

{ þ >>> P U B L I C  F U N C T I O N S <<< þ }

{ þ Inits the GUS driver structures þ }
Procedure ISS_GUSDevInit;
Begin
 With ISS_GUSDriver Do Begin
   Detect    :=@ISS_GUSDetect;
   Init      :=@ISS_GUSInit;
   Done      :=@ISS_GUSDone;
   LoadSample:=@ISS_GUSLoadSample;
   FreeSample:=@ISS_GUSFreeSample;
   SetVolume :=@ISS_GUSSetVolume;
   StartOut  :=@ISS_GUSStartOutput;
   StopOut   :=@ISS_GUSStopOutput;
   UpdateOut :=@ISS_GUSUpdateOutput;
  End;
 ISS_GUSDevice.DevDriver:=@ISS_GUSDriver;

 {$IFDEF _ISS_GUS_DEBUGMODE_}
  WriteLn('DEV_INIT: Device - ',ISS_GUSLongDesc,' ',ISS_GUSVersionStr);
 {$ENDIF}

 { þ Reading ULTRASND Environment Settings þ }
 If UltraGetConfig(ISS_GUSHWSetup) Then Begin
   { þ If ULTRASND found, assigning hardware parameters þ }
   With ISS_GUSDevice Do Begin
     DevName    :=ISS_GUSName; { þ Name of the device þ }
     DevType    :=ISS_Dev16Bit+ISS_DevStereo+ISS_DevSigned
                  +ISS_DevWaveTable;{ þ Device Type þ }
     With ISS_GUSHWSetup Do Begin
       DevBaseport:=Base_Port;
       DevIRQ     :=GF1_IRQ;
       DevDMA1    :=DRAM_DMA;
       DevDMA2    :=ADC_DMA;
       DevFreq    :=44100;
       DevMaxChan :=32;
       DevDRAMSize:=0; { þ HardDetect will give a proper value þ }
       DevAvail   :=GUSHardDetect;
       Case GUS_Ver Of
         $FF  : Begin
                  DevHWVer:='Classic';
                 End;
         5..9 : Begin
                  DevHWVer:='3.7+ (with ICS Mixer)';
                 End;
         $0A..$0F :Begin
                  DevHWVer:='MAX/PnP (with CS4231 Codec)';
                 End;
         Else   Begin
                  DevHWVer:='Unknown';
                 End;
        End;
      End;
    End;
  End;

 If ISS_GUSDevice.DevAvail Then Begin
   With ISS_GUSDevice Do Begin
     {$IFDEF _ISS_GUS_DEBUGMODE_}
      WriteLn('DEV_INIT:        - Hardware Revision: ',DevHWVer);
      WriteLn('DEV_INIT:        - Baseport: $',WriteHex(DevBaseport),
             ' IRQ:',DevIRQ,' DMA1:',DevDMA1,' DMA2:',DevDMA2,
             ' DRAM:',DevDRAMSize Div 1024,'KB');
     {$ENDIF}
    End;
  End Else Begin
   {$IFDEF _ISS_GUS_DEBUGMODE_}
    WriteLn('DEV_INIT:        - ULTRASOUND DETECTION FAILED!');
   {$ENDIF}
  End;
End;

Begin
End.
{ þ ISS_GUS.PAS - (C) 1998-2001 Charlie/Inquisition þ }
