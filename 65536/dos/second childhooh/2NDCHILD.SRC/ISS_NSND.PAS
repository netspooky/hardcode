{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_NSND.PAS - No Sound Device Driver                                  ³}
{³                  Work started     : 1999.05.26.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - GO32V2 only.                                            ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$MODE FPC}
{$ASMMODE INTEL}

{$HINTS OFF} { þ Enable this if you modify the source! þ }
{$NOTES OFF} { þ Enable this if you modify the source! þ }

Unit ISS_NSND;

Interface

Uses ISS_Var, { þ Uses the system variables and types þ }
     ISS_Tim  { þ Uses the timer services þ }
     {$IFDEF _ISS_NSND_SLOWMODE_}
      ,ISS_Mix { þ Uses the mixer in slow mode þ }
     {$ENDIF}
     ;

Const ISS_NSNDVersionStr = '0.8.5';

      {$IFDEF _ISS_NSND_SLOWMODE_}
       ISS_NSNDName     = 'No Sound (Mixed mode)';
       ISS_NSNDLongDesc = 'No Sound Device Driver (Mixed mode)';
      {$ELSE}
       ISS_NSNDName     = 'No Sound';
       ISS_NSNDLongDesc = 'No Sound Device Driver';
      {$ENDIF}

Var ISS_NSNDDevice : ISS_TSoundDevice; { þ No sound Device Structure þ }
    ISS_NSNDDriver : ISS_TSoundDriver; { þ No sound Device Driver þ }

Procedure ISS_NSNDDevInit;

Implementation

{$IFDEF _ISS_NSND_SLOWMODE_}
 Var ISS_NSNDPlayFreq     : DWord;  { þ Current playing (not mixing!) freq. þ }
     ISS_NSNDMixBufSize   : DWord;   { þ Current mixing buffer size þ }
{$ENDIF}

Function ISS_NSNDDetect : Boolean;
Begin
 ISS_NSNDDetect:=True;
End;

Function ISS_NSNDInit : Boolean;
Begin
 ISS_NSNDInit:=True;
End;

Function ISS_NSNDDone : Boolean;
Begin
 ISS_NSNDDone:=True;
End;

{$IFNDEF _ISS_NSND_SLOWMODE_}
 Function ISS_NSNDLoadSample(SStruc : ISS_PSample) : Boolean;
 Begin
  ISS_NSNDLoadSample:=True;
 End;
 Function ISS_NSNDFreeSample(SStruc : ISS_PSample) : Boolean;
 Begin
  ISS_NSNDFreeSample:=True;
 End;
{$ENDIF}

Function ISS_NSNDSetVolume(Volume : DWord) : Boolean;
Begin
 ISS_NSNDSetVolume:=True;
End;

Function ISS_NSNDStartOutput(PeriodicCall  : Pointer) : Boolean;
Begin
 ISS_NSNDStartOutput:=False;

 {$IFDEF _ISS_NSND_SLOWMODE_}

  ISS_NSNDPlayFreq:=5000;
  ISS_NSNDMixBufSize:=ISS_NSNDPlayFreq Div 50;
  ISS_TimerDiff:=ISS_TimerSpeed Div 50;

  ISS_MixerInit(ISS_NSNDPlayFreq,ISS_NSNDMixBufSize,0,0,ISS_NSNDDevice.DevType);
  With ISS_MixerData^ Do Begin
    MixBufOffs:=DWord(MixBufPtr);
   End;

  If ISS_StartTimer(PeriodicCall,ISS_TimerSpeed Div 50) Then Begin
    ISS_NSNDStartOutput:=True;
    {$IFDEF _ISS_NSND_DEBUGMODE_}
     WriteLn('DEV_INIT: Starting ',ISS_NSNDName,' output...');
    {$ENDIF}
   End Else Begin
    {$IFDEF _ISS_NSND_DEBUGMODE_}
     WriteLn('DEV_FAIL: ERROR! Failed to start ',ISS_NSNDName,' output!');
     ISS_MixerDone;
    {$ENDIF}
   End;

 {$ELSE}

  If ISS_StartTimer(PeriodicCall,(ISS_TimerSpeed Div 140)) Then Begin
    ISS_NSNDStartOutput:=True;
    ISS_TimerDiff:=ISS_TimerSpeed Div 140;
    {$IFDEF _ISS_NSND_DEBUGMODE_}
     WriteLn('DEV_INIT: Starting ',ISS_NSNDName,' output...');
    {$ENDIF}
   End Else Begin
    {$IFDEF _ISS_NSND_DEBUGMODE_}
     WriteLn('DEV_FAIL: ERROR! Failed to start ',ISS_NSNDName,' output!');
    {$ENDIF}
   End;

 {$ENDIF}

End;

Function ISS_NSNDStopOutput(PeriodicCall : Pointer) : Boolean;
Begin
 ISS_NSNDStopOutput:=ISS_StopTimer(PeriodicCall);
 {$IFDEF _ISS_NSND_SLOWMODE_}
  ISS_MixerDone;
 {$ENDIF}
 {$IFDEF _ISS_NSND_DEBUGMODE_}
   WriteLn('DEV_INIT: ',ISS_NSNDName,' output stopped.');
 {$ENDIF}
End;

{$IFNDEF _ISS_NSND_SLOWMODE_}
 Procedure ISS_NSNDUpdateOutput_Fast; { þ Updates the sound output in fast modeþ }
 Var ChannelCounter : Word;
 Begin
  { þ We tell the player, that we did everything it requested... :) þ }
  For ChannelCounter:=0 To ISS_ActiveSSChannels-1 Do Begin
    With ISS_VirtualChannels^[ChannelCounter] Do Begin

      { þ Stop a Channel ? þ }
      If (VChControl And ISS_CCStop)>0 Then Begin
        Dec(VChControl,ISS_CCStop);
       End;

      { þ Start a Sample ? þ }
      If (VChControl And ISS_CCSample)>0 Then Begin
        Dec(VChControl,ISS_CCSample);
       End;

      { þ Change Period ? þ }
      If (VChControl And ISS_CCPeriod)>0 Then Begin
        Dec(VChControl,ISS_CCPeriod);
       End;

      { þ Change Volume ? þ }
      If (VChControl And ISS_CCVolume)>0 Then Begin
        Dec(VChControl,ISS_CCVolume);
       End;

      { þ Change Panning ? þ }
      If (VChControl And ISS_CCPanning)>0 Then Begin
        Dec(VChControl,ISS_CCPanning);
       End;

      { þ Still channel Active ? þ }
      If (VChControl And ISS_CCActive)>0 Then Begin
        Dec(VChControl,ISS_CCActive);
       End;

    End;
   End;

 End;
{$ENDIF}

{ þ This procedure assigns the device driver procedures þ }
Procedure ISS_NSNDDevInit;
Begin
 With ISS_NSNDDriver Do Begin
   Detect    :=@ISS_NSNDDetect;
   Init      :=@ISS_NSNDInit;
   Done      :=@ISS_NSNDDone;
   SetVolume :=@ISS_NSNDSetVolume;
   StartOut  :=@ISS_NSNDStartOutput;
   StopOut   :=@ISS_NSNDStopOutput;
   {$IFDEF _ISS_NSND_SLOWMODE_}
    LoadSample:=@ISS_MixerLoadSample;
    FreeSample:=@ISS_MixerFreeSample;
    UpdateOut :=@ISS_MixerUpdateOutput;
   {$ELSE}
    LoadSample:=@ISS_NSNDLoadSample;
    FreeSample:=@ISS_NSNDFreeSample;
    UpdateOut :=@ISS_NSNDUpdateOutput_Fast;
   {$ENDIF}
  End;
 ISS_NSNDDevice.DevDriver:=@ISS_NSNDDriver;

 {$IFDEF _ISS_NSND_DEBUGMODE_}
  WriteLn('DEV_INIT: Device - ',ISS_NSNDLongDesc,' ',ISS_NSNDVersionStr);
 {$ENDIF}

 { þ No sound always available, so we simply assign 'hardware' parameters þ }
 With ISS_NSNDDevice Do Begin
   DevAvail   :=True;         { þ Device is available (for detection) þ }
   DevName    :=ISS_NSNDName; { þ Name of the device þ }
   DevType    :=ISS_DevMono+ISS_DevSigned+ISS_Dev16Bit+ISS_DevMixed; { þ Device Type þ }
   DevBaseport:=0;
   DevIRQ     :=0;
   DevDMA1    :=0;
   DevDMA2    :=0;
   DevFreq    :=44100;
   DevMaxChan :=256;
   DevDRAMSize:=0;
  End;
End;

Begin
End.
{ þ ISS_NSND.PAS - (C) 1999-2001 Charlie/Inquisition þ }
