{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_SYS .PAS - "Heart of the Tiger" :-)                                ³}
{³                  Work started     : 1999.05.26.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - GO32V2,EMX                                              ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$MODE FPC}
Unit ISS_Sys;

Interface

Uses ISS_Var,  { þ Uses the system variables and types þ }
     ISS_Load  { þ Uses the file-loader functions þ }
     {$IFDEF _ISS_GUS_INCLUDE_}
      ,ISS_GUS { þ Include GUS þ }
     {$ENDIF}
     {$IFDEF _ISS_SB_INCLUDE_}
      ,ISS_SB { þ Include SB þ }
     {$ENDIF}
     {$IFDEF _ISS_NSND_INCLUDE_}
      ,ISS_NSND { þ Include Nosound þ }
     {$ENDIF}
     {$IFDEF _ISS_GUSNATIVE_INCLUDE_}
      ,ISS_GUS2 { þ Include OS/2 native GF1/Interwave driver þ }
     {$ENDIF}
     {$IFDEF _ISS_DART_INCLUDE_}
      ,ISS_DART { þ Include OS/2 Warp DART API driver þ }
     {$ENDIF}
     {$IFDEF _ISS_DSOUND_INCLUDE_}
      ,ISS_DSND { þ Include Win32 DirectSound API driver þ }
     {$ENDIF}
     {$IFDEF _ISS_OSS_INCLUDE_}
      ,ISS_OSS  { þ Include Linux OSS API driver þ }
     {$ENDIF}
     ;

{ þ System Initalization þ }
Function ISS_InitSystem : Boolean;
Function ISS_InitDevices : Boolean;

Function ISS_Setup : Boolean;
Function ISS_AutoSetup : Boolean;
Function ISS_Init : Boolean;
Function ISS_Done : Boolean;

Function ISS_SetActiveChannels(Channels : DWord) : Boolean;

Function ISS_LoadSample(Sample : ISS_PSample) : Boolean;
Function ISS_FreeSample(Sample : ISS_PSample) : Boolean;
Function ISS_StartOutput(PeriodicProc : Pointer) : Boolean;
Function ISS_StopOutput : Boolean;

{ þ Period Control þ }
Function ISS_GetPeriod(Channel : Word) : DWord;
Function ISS_SetPeriod(Channel : Word; Period : Word) : Boolean;
Function ISS_ChGetNotePeriod(Channel : DWord; Note : DWord) : DWord;
Function ISS_SmpGetNotePeriod(SampleAddress : ISS_PSample;
                              Note          : DWord) : DWord;

{ þ Volume & Panning Control þ }
Function ISS_GetGlobalVolume : DWord;
Function ISS_SetGlobalVolume(Volume : Byte) : Boolean;
Function ISS_SetVolume(Channel : Word; Volume : Byte) : Boolean;
Function ISS_GetVolume(Channel : Word) : DWord;
Function ISS_SetPanning(Channel : Word; Panning : Byte) : Boolean;
Function ISS_GetPanning(Channel : Word) : DWord;

{ þ Instrument Control þ }
Procedure ISS_InitInstrument(Channel : Word);
Function  ISS_StartInstrument(Channel : Word; Instr : Word; Note : Word) : Boolean;
Procedure ISS_UpdateInstruments;
Procedure ISS_KeyOff(Channel : Word);

{ þ Misc. þ }
Procedure ISS_UpdateOutput; { þ Updates the output device.    þ }
                            { þ  - Volume calc.               þ }
                            { þ  - Calls the low-level driver þ }

Procedure ISS_SetSampleOffset(Channel : DWord; SampOffset : DWord);

Var ISS_SystemOK       : Boolean; { þ True if the system is initiated and þ }
                                  { þ everything (seems:) OK. þ }

    ISS_DevicesOK      : Boolean; { þ True if there is an useable device þ }
    ISS_DevicesNum     : DWord;   { þ Number of devices þ }
    ISS_SoundDeviceNum : DWord;   { þ Number of selected device þ }

    ISS_SoundDevice  : ISS_PSoundDevice;
    ISS_SoundDriver  : ISS_PSoundDriver;
    ISS_SoundDevices : Array[1..ISS_MaxDevices] Of ISS_PSoundDevice;

    {$IFDEF _ISS_MAIN_DEBUGMODE_}
     ISS_CompileCoder : String;
    {$ENDIF}

Implementation

{ þ Including Linear Frequency Table þ }
{$INCLUDE ISS_FREQ.INC}

Var ISS_SysStarted   : Boolean;
    ISS_PeriodicCall : Pointer;

{ þ >>> I N T E R N A L  F U N C T I O N S <<< þ }

Function ISS_DetectBestDev : DWord; { þ Returns Best Device Number þ }
Var Counter   : DWord;
Begin
 Counter:=0;
 Repeat
  Inc(Counter);
  If Counter>ISS_DevicesNum Then Begin
    { þ Musn't happen, because Nosound device should be always linked þ }
    ISS_DetectBestDev:=$FFFFFFFF;
    ISS_SoundDeviceNum:=$FFFFFFFF;
    ISS_DevicesOK:=False;
    Exit;
   End;
 Until ISS_SoundDevices[Counter]^.DevDriver^.Detect();
 ISS_DevicesOK:=True;
 ISS_SoundDeviceNum:=Counter;
 ISS_DetectBestDev:=Counter;
End;

Function ISS_InitDev : Boolean; { þ Initializes the selected Device þ }
Begin
 ISS_SoundDevice:=ISS_SoundDevices[ISS_SoundDeviceNum];
 ISS_SoundDriver:=ISS_SoundDevice^.DevDriver;
 ISS_InitDev:=ISS_SoundDriver^.Init(); { þ Initializes the Device þ }
End;

Function ISS_DoneDev : Boolean; { þ Closes the selected Device þ }
Begin
 ISS_DoneDev:=False;
 If ISS_SoundDriver^.Done() Then Begin
   ISS_SoundDevice:=Nil;
   ISS_SoundDriver:=Nil;
   ISS_DoneDev:=True;
  End;
End;

{ þ >>> P U B L I C  F U N C T I O N S <<< þ }

Function ISS_Setup : Boolean;
Begin
 ISS_Setup:=ISS_AutoSetup;
End;

Function ISS_AutoSetup : Boolean;
Begin
 ISS_AutoSetup:=False;
 ISS_DetectBestDev; { þ Detecting Best Device þ }
 If ISS_DevicesOK Then Begin { þ If OK, setting up the device! þ }
   ISS_SoundDevice:=ISS_SoundDevices[ISS_SoundDeviceNum];
   ISS_SoundDriver:=ISS_SoundDevice^.DevDriver;
   With ISS_SoundDevice^ Do Begin
     DevMixRate:=DevFreq;
     DevMode:=DevType;
     {$IFDEF _ISS_MAIN_DEBUGMODE_}
      WriteLn('ISS_INIT: Selected Device - ',DevName);
     {$ENDIF}
    End;
   ISS_AutoSetup:=True;
  End Else Begin
   {$IFDEF _ISS_MAIN_DEBUGMODE_}
    WriteLn('ISS_FAIL: Failed To Auto Select Device!');
   {$ENDIF}
  End;
End;

Function ISS_Init : Boolean;
Begin
 ISS_Init:=False;
 If (Not ISS_SysStarted) And (Not ISS_SystemOK) Then Begin
   If Not ISS_InitDev Then Exit; { þ Currently selected device is in error! þ }
   If ISS_VirtualChannels=Nil Then New(ISS_VirtualChannels);
   FillChar(ISS_VirtualChannels^,SizeOf(ISS_TVirtualChannels),#0);
   ISS_Init:=True;
   ISS_SystemOK:=True;
  End;
 ISS_GlobalSSVolume:=128;
End;

Function ISS_Done : Boolean;
Begin
 ISS_Done:=False;
 If (Not ISS_SysStarted) And (ISS_SystemOK) Then Begin
   If ISS_VirtualChannels<>Nil Then Dispose(ISS_VirtualChannels);
   ISS_SystemOK:=False;
   ISS_Done:=ISS_DoneDev;
  End;
End;

{ þ Sets the active channels number þ }
Function ISS_SetActiveChannels(Channels : DWord) : Boolean;
Begin
 ISS_SetActiveChannels:=False;
 If (Channels<=ISS_MaxSSChannels) And
    (Channels<=ISS_SoundDevice^.DevMaxChan) Then Begin
   ISS_ActiveSSChannels:=Channels;
   ISS_SetActiveChannels:=True;
   Exit;
  End Else Begin
   { þ ERROR CODE! þ }
   { þ Too many channels þ }
  End;
End;

Function ISS_LoadSample(Sample : ISS_PSample) : Boolean;
Begin
 ISS_LoadSample:=False;
 If ISS_DevicesOK Then Begin
   ISS_LoadSample:=ISS_SoundDriver^.LoadSample(Sample);
  End;
End;

Function ISS_FreeSample(Sample : ISS_PSample) : Boolean;
Begin
 ISS_FreeSample:=False;
 If ISS_DevicesOK Then Begin
   ISS_FreeSample:=ISS_SoundDriver^.FreeSample(Sample);
  End;
End;

Function ISS_StartOutput(PeriodicProc : Pointer) : Boolean;
Begin
 ISS_StartOutput:=False;
 If ISS_DevicesOK Then Begin
   If ISS_SysStarted Then Exit; { þ Exit if output device is active þ }

   { þ Starting Device þ }
   ISS_PeriodicCall:=PeriodicProc;
   ISS_SysStarted:=ISS_SoundDriver^.StartOut(ISS_PeriodicCall);

   ISS_StartOutput:=ISS_SysStarted;
  End;
End;

Function ISS_StopOutput : Boolean;
Begin
 ISS_StopOutput:=False;
 If ISS_DevicesOK Then Begin
   If Not ISS_SysStarted Then Exit; { þ Exit if output device is inactive þ }

   { þ Stopping Device þ }
   ISS_SysStarted:=Not ISS_SoundDriver^.StopOut(ISS_PeriodicCall);

   ISS_StopOutput:=Not ISS_SysStarted;
  End;
End;


{ þ Returns Actual Period for the specified Channel þ }
Function ISS_GetPeriod(Channel : Word) : DWord;
Begin
 If ISS_DevicesOK And ISS_SysStarted Then Begin
   ISS_GetPeriod:=ISS_VirtualChannels^[Channel].VChPeriod;
  End;
End;

{ þ Sets Period for the specified Channel þ }
Function ISS_SetPeriod(Channel : Word; Period : Word) : Boolean;
Begin
 ISS_SetPeriod:=False;
 If ISS_DevicesOK And ISS_SysStarted Then Begin

   With ISS_VirtualChannels^[Channel] Do Begin
     { þ Don't set the period, if there is no sample address þ }
     If VChSmpAddr=Nil Then Exit;

     VChPeriod :=Period;
     VChControl:=VChControl Or ISS_CCPeriod;
    End;
  End;
End;

{ þ Get the period from the note and the sample definition þ }
Function ISS_SmpGetNotePeriod(SampleAddress : ISS_PSample;
                              Note          : DWord) : DWord;
Var BufPeriod : DWord;
    RealNote  : LongInt;
Begin
 ISS_SmpGetNotePeriod:=0;

 If (SampleAddress<>Nil) And (Note<=95) Then Begin
   With SampleAddress^ Do Begin

     RealNote:=(Note-1)+SRelNote;

     { þ Check Sample Realtive Note þ }
     If (RealNote>0) Or (RealNote<=118) Then Begin
       { þ Linear Period þ }
       { þ Amiga periods should be implemented later. þ }
       BufPeriod:=7680-(RealNote*64)-(SFineTune Div 2);
       ISS_SmpGetNotePeriod:=BufPeriod;
      End;

    End;
  End;

End;

{ þ Get the period from the note and channel number. þ }
Function ISS_ChGetNotePeriod(Channel : DWord; Note : DWord) : DWord;
Begin
 ISS_ChGetNotePeriod:=
   ISS_SmpGetNotePeriod(ISS_VirtualChannels^[Channel].VChSmpAddr,Note);
End;

{ þ Calculates the frequency from the specified period, sets it to þ }
{ þ the specified channel, and returns it to the caller. þ }
Function ISS_SetFrequency(Channel : DWord; Period : DWord) : DWord;

Var BufFreq : DWord;
Begin
 ISS_SetFrequency:=0;
 With ISS_VirtualChannels^[Channel] Do Begin

   { þ Linear Frequency þ }
   { þ Amiga frequency should be implemented later. þ }
   BufFreq:=ISS_LinearFreqTable[Period Mod 768];
   BufFreq:=BufFreq Shr (Period Div 768);

   VChFreq:=BufFreq;
   ISS_SetFrequency:=VChFreq;

  End;
End;


{ þ Returns Global System Volume þ }
Function ISS_GetGlobalVolume : DWord;
Begin
 ISS_GetGlobalVolume:=ISS_GlobalSSVolume;
End;

{ þ Sets Global System Volume - Volume Range : 0-64 þ }
Function ISS_SetGlobalVolume(Volume : Byte) : Boolean;
Var Counter : DWord;
Begin
 ISS_SetGlobalVolume:=False;
 If Volume>$80 Then Volume:=$80;

 ISS_GlobalSSVolume:=Volume; { þ Setting Global Volume þ }

 For Counter:=0 To ISS_ActiveSSChannels-1 Do Begin
   With ISS_VirtualChannels^[Counter] Do Begin
     VChControl:=VChControl Or ISS_CCVolume;
    End;
  End;

 ISS_SetGlobalVolume:=True;
End;

{ þ Sets volume on the specified channel - Volume range : 0-64 þ }
Function ISS_SetVolume(Channel : Word; Volume : Byte) : Boolean;
Begin
 ISS_SetVolume:=False;
 If Volume>$40 Then Volume:=$40;

 If Channel>ISS_MaxSSChannels Then Exit;

 With ISS_VirtualChannels^[Channel] Do Begin
   VChVolume:=Volume;
   VChControl:=VChControl Or ISS_CCVolume;
  End;

 ISS_SetVolume:=True;
End;

{ þ Gets volume from the specified channel þ }
Function ISS_GetVolume(Channel : Word) : DWord;
Begin
 If Channel>ISS_MaxSSChannels Then Begin
   ISS_GetVolume:=0; Exit;
  End;
 ISS_GetVolume:=ISS_VirtualChannels^[Channel].VChVolume;
End;

{ þ Sets panning on the specified channel - Panning range : 0-255 þ }
Function ISS_SetPanning(Channel : Word; Panning : Byte) : Boolean;
Begin
 ISS_SetPanning:=False;
 If Channel>ISS_MaxSSChannels Then Exit;

 With ISS_VirtualChannels^[Channel] Do Begin
   VChPanning:=Panning;
   VChControl:=VChControl Or ISS_CCPanning;
  End;
End;

{ þ Gets panning from the specified channel þ }
Function ISS_GetPanning(Channel : Word) : DWord;
Begin
 If Channel>ISS_MaxSSChannels Then Begin
   ISS_GetPanning:=0; Exit;
  End;
 ISS_GetPanning:=ISS_VirtualChannels^[Channel].VChPanning;
End;


{ þ Sets instrument envelope default values on the specified channel þ }
Procedure ISS_InitInstrument(Channel : Word);
Begin
 If Channel>ISS_MaxSSChannels Then Exit;

 With ISS_VirtualChannels^[Channel] Do Begin

   VChFadeOutVolume:=$08000; { þ Default FadeOut Volume þ }
   VChEnvVolume    :=64;     { þ Default Envelope Volume þ }
   VChEnvVolPoint  :=0;      { þ Default Volume Envelope Positions þ }
   VChEnvVolPos    :=0;

   VChEnvPanning   :=32;     { þ Default Envelope Panning þ }
   VChEnvPanPoint  :=0;      { þ Default Panning Envelope Positions þ }
   VChEnvPanPos    :=0;

   VChAVibPitch    :=0;      { þ Default Autovibrato Pitch þ }
   VChAVibPos      :=0;      { þ Default Autovibrato Position þ }
   VChAVibSwpPos   :=0;      { þ Default Autovibrato Sweep Position þ }

   VChControl:=VChControl And Not ISS_CCVolFadeOut; { þ  Disable FadeOut þ }
   VChControl:=VChControl Or ISS_CCVolume; { þ Volume Change þ }

  End;
End;

{ þ Starts a specified Instrument on the specified channel þ }
Function ISS_StartInstrument(Channel : Word;
                             Instr   : Word;
                             Note    : Word) : Boolean;
Var SampleToStart : ISS_PSample;
    InstrToStart  : ISS_PInstrument;
    BufPeriod     : DWord;
Begin
 ISS_StartInstrument:=False;
 If ISS_DevicesOK And ISS_SysStarted Then Begin

   With ISS_CurrentModule^ Do Begin

     { þ Values Range Checking þ }
     If Channel>ISS_MaxSSChannels Then Exit; { þ Channel number valid? þ }
     If Instr>MInstrNum Then Exit; { þ Exit if Instrument Number invalid þ }
     If Note>95 Then Exit; { þ Exit if Note is invalid þ }

     { þ Device Control þ }
     With ISS_VirtualChannels^[Channel] Do Begin

       { þ Specifying a new note will always stop the current. þ }
       VChControl:=VChControl Or ISS_CCStop;

       { þ Selecting Sample to be started þ }
       SampleToStart:=Nil;
       InstrToStart:=MInstruments[Instr];
       With InstrToStart^ Do Begin
         If ISampleNum=0 Then Exit;
         SampleToStart:=ISamples[INoteTable[Note]];
        End;

       If SampleToStart=Nil Then Exit; { þ Exit if sample is invalid þ }

       { þ Checking if sample size is valid þ }
       With SampleToStart^ Do Begin
         If SLength=0 Then Exit;
        End;

       VChSmpAddr:=SampleToStart; { þ Set sample address þ }
       VChInsAddr:=InstrToStart;  { þ Set instrument address þ }
       VChSmpOffs:=0;             { þ Set sample offset to zero þ }

       { þ Period Setup þ }
       BufPeriod:=ISS_SmpGetNotePeriod(SampleToStart,Note);
       If BufPeriod<>0 Then ISS_SetPeriod(Channel,BufPeriod)
                       Else Exit;

       { þ Setting Channel Control (See Flags in ISS_VAR.PAS) þ }
       VChControl:=VChControl Or (ISS_CCSample+ISS_CCPeriod+
                                  ISS_CCVolume+ISS_CCActive+ISS_CCPanning);

      End;

    End;

   ISS_StartInstrument:=True;

  End;
End;

{ þ Update Instruments in every tick þ }
Procedure ISS_UpdateInstruments;
Var Counter     : DWord;
    DPosition   : LongInt; { þ Delta EnvPosition þ }
    DVolume     : LongInt; { þ Delta EnvVolume þ }
    DPanning    : LongInt; { þ Delta Panning þ }
    BufVibValue : Byte;
Begin
 For Counter:=0 To ISS_ActiveSSChannels-1 Do Begin
   With ISS_VirtualChannels^[Counter] Do Begin

     { þ Check if instrument is active on the current channel þ }
     If (VChInsAddr<>Nil) And ((VChControl And ISS_CCActive)>0) Then Begin
       With VChInsAddr^ Do Begin

         { þ Do FadeOut þ }
         If (VChControl And ISS_CCVolFadeOut)>0 Then Begin
           { þ Fadeout reached 0? þ }
           If IVolFadeOut<VChFadeOutVolume Then Begin
             { þ No, still fade out volume þ }
             Dec(VChFadeOutVolume,IVolFadeOut);
             VChControl:=VChControl Or ISS_CCVolume;
            End Else Begin
             { þ Yes, stop voice. þ }
             VChFadeOutVolume:=0;
             VChControl:=VChControl Or ISS_CCStop;
            End;
           End;

         { þ Do Volume Envelope þ }
         With IVolumeEnv Do Begin
           If (EnvType And ISS_EnvEnabled)>0 Then Begin

             { þ Processing Envelope Loops þ }
             If VChEnvVolPos=0 Then Begin

               { þ Envelope Looped? þ }
               If (EnvType And ISS_EnvLoop)>0 Then Begin
                 { þ Do envelope loop, if no sustain or fadeout in progess þ }
                 If (VChEnvVolPoint<>EnvSustain) Or
                    ((EnvType And ISS_EnvSustain)=0) Or
                    ((VChControl And ISS_CCVolFadeOut)>0) Then Begin

                   { þ Loop, if envelope reached loop endpoint, and the þ }
                   { þ endpoint is not the sustain point. þ }
                   If (VChEnvVolPoint=EnvLoopEnd) And
                      (VChEnvVolPoint<>EnvSustain) Then Begin
                     VChEnvVolPoint:=EnvLoopStart;
                    End;

                  End;
                End;

              End;

             { þ Envelope Reached Last Point? þ }
             If VChEnvVolPoint+1<>EnvPointsNum Then Begin

               { þ Delta Initial Values þ }
               With EnvPoints[VChEnvVolPoint+1] Do Begin
                 DPosition:=EPPosition;
                 DVolume:=EPValue;
                End;

               With EnvPoints[VChEnvVolPoint] Do Begin
                 { þ Calculating Delta Values þ }
                 DPosition:=Abs(DPosition-EPPosition);
                 DVolume:=DVolume-EPValue;

                 { þ Calculating Final Volume þ }
                 VChEnvVolume:=EPValue+((DVolume*VChEnvVolPos) Div DPosition);
                 VChControl:=VChControl Or ISS_CCVolume;
                End;

               { þ Always increase envelope position if fadeout active, þ }
               { þ sustain disabled or envelope position is between points þ }
               If ((EnvType And ISS_EnvSustain)=0) Or
                  ((VChControl And ISS_CCVolFadeOut)>0) Or
                  (VChEnvVolPos<>0) Or
                  (VChEnvVolPoint<>EnvSustain) Then Begin

                 Inc(VChEnvVolPos); { þ Increase envelope þ }
                 { þ Position reached next point? þ }
                 If VChEnvVolPos>=DPosition Then Begin
                   VChEnvVolPos:=0;
                   Inc(VChEnvVolPoint);
                  End;

                End;

              End Else Begin
               { þ Envelope reached end þ }
               VChEnvVolume:=EnvPoints[VChEnvVolPoint].EPValue;
               VChControl:=VChControl Or ISS_CCVolume;
              End;

            End;

          End;

         { þ Do Panning Envelope þ }
         With IPanningEnv Do Begin
           If (EnvType And ISS_EnvEnabled)>0 Then Begin

             { þ Processing Envelope Loops þ }
             If VChEnvPanPos=0 Then Begin

               { þ Envelope Looped? þ }
               If (EnvType And ISS_EnvLoop)>0 Then Begin
                 { þ Do envelope loop, if no sustain in progess þ }
                 If (VChEnvPanPoint<>EnvSustain) Or
                    ((EnvType And ISS_EnvSustain)=0) Then Begin

                   { þ Loop, if envelope reached loop endpoint þ }
                   If (VChEnvPanPoint=EnvLoopEnd) And
                      (VChEnvPanPoint<>EnvSustain) Then Begin
                     VChEnvPanPoint:=EnvLoopStart;
                    End;

                  End;
                End;

              End;

             { þ Envelope Reached Last Point? þ }
             If VChEnvPanPoint+1<>EnvPointsNum Then Begin

               { þ Delta Initial Values þ }
               With EnvPoints[VChEnvPanPoint+1] Do Begin
                 DPosition:=EPPosition;
                 DPanning:=EPValue;
                End;

               With EnvPoints[VChEnvPanPoint] Do Begin
                 { þ Calculating Delta Values þ }
                 DPosition:=Abs(DPosition-EPPosition);
                 DPanning:=DPanning-EPValue;

                 { þ Calculating Final Panning þ }
                 VChEnvPanning:=EPValue+((DPanning*VChEnvPanPos) Div DPosition);
                 VChControl:=VChControl Or ISS_CCPanning;
                End;

               { þ Always increase envelope position, if sustain disabled þ }
               { þ or envelope position is between points þ }
               If ((EnvType And ISS_EnvSustain)=0) Or
                  (VChEnvPanPos<>0) Or
                  (VChEnvPanPoint<>EnvSustain) Then Begin

                 Inc(VChEnvPanPos); { þ Increase envelope þ }
                 { þ Position reached next point? þ }
                 If VChEnvPanPos>=DPosition Then Begin
                   VChEnvPanPos:=0;
                   Inc(VChEnvPanPoint);
                  End;

                End;

              End Else Begin
               { þ Envelope reached end þ }
               VChEnvPanning:=EnvPoints[VChEnvPanPoint].EPValue;
               VChControl:=VChControl Or ISS_CCPanning;
              End;

            End;
          End;

         { þ Do Auto Vibrato þ }
         If IVibDepth>0 Then Begin

           BufVibValue:=(ISS_SineTable[VChAVibPos And 127]*IVibDepth) Div 256;
           If VChAVibPos>127 Then VChAVibPitch:=BufVibValue
                             Else VChAVibPitch:=-BufVibValue;
           Inc(VChAVibPos,IVibRate);

           { þ Calculating Vibrato Sweep þ }
           If VChAVibSwpPos<IVibSweep Then Begin
             VChAVibPitch:=(VChAVibPitch*VChAVibSwpPos) Div IVibSweep;
             Inc(VChAVibSwpPos,1);
            End;

           { þ Enabling Frequency Control þ }
           VChControl:=VChControl Or ISS_CCPeriod;

          End;

        End;
      End;

    End;
  End;
End;

{ þ Instrument Key Off þ }
Procedure ISS_KeyOff(Channel : Word);
Begin
 If Channel>ISS_MaxSSChannels Then Exit;

 With ISS_VirtualChannels^[Channel] Do Begin

   If VChInsAddr=Nil Then Exit;

   If (VChInsAddr^.IVolumeEnv.EnvType And ISS_EnvEnabled)>0 Then Begin
     VChControl:=VChControl Or ISS_CCVolFadeOut;
    End Else Begin
     VChControl:=VChControl Or ISS_CCStop;
    End;

  End;

End;


Procedure ISS_UpdateOutput; { þ Updates the output device þ }
Var Counter   : Word;
    BufPeriod : DWord;
    BufVolume : DWord;
Begin
 For Counter:=0 To ISS_ActiveSSChannels-1 Do Begin
   With ISS_VirtualChannels^[Counter] Do Begin

     { þ Process Final Frequency Calculations þ }
     If (VChControl And ISS_CCPeriod)>0 Then Begin
       BufPeriod:=VChPeriod;
       Inc(BufPeriod,VChAVibPitch); { þ Adding AutoVibrato Pitch þ }
       ISS_SetFrequency(Counter,BufPeriod);
      End;

     { þ Process Final Volume Calculations þ }
     If (VChControl And ISS_CCVolume)>0 Then Begin
       BufVolume:=VChVolume; { þ Sample Volume (0-64) þ }

       { þ Global System Volume (0-128) þ }
       BufVolume:=BufVolume*ISS_GlobalSSVolume;
       BufVolume:=BufVolume Shr 7;

       { þ FadeOut Volume ($0-$8000) þ }
       BufVolume:=BufVolume*VChFadeOutVolume;
       BufVolume:=BufVolume Shr 15;

       { þ Envelope Volume (0-64) þ }
       BufVolume:=BufVolume*VChEnvVolume;
       BufVolume:=BufVolume Shr 6;

       { þ Global Player Volume (0-64) þ }
       BufVolume:=BufVolume*ISS_GlobalPlVolume;
       BufVolume:=BufVolume Shr 6;

       VChFinalVolume:=BufVolume;
       If VChMute Then VChFinalVolume:=0; { þ Force Mute Channel þ }

      End;

     { þ Process Final Panning Calculations þ }
     If (VChControl And ISS_CCPanning)>0 Then Begin
       VChFinalPanning:=VChPanning+((VChEnvPanning-32)*
                        (128-Abs(VChPanning-128)) Div 32);
      End;

    End;
  End;

 ISS_SoundDriver^.UpdateOut; { þ Low-level driver call þ }
End;


{ þ Set sample offset on the specified channel þ }
Procedure ISS_SetSampleOffset(Channel : DWord; SampOffset : DWord);
Begin
 If Channel>ISS_MaxSSChannels Then Exit; { þ Channel number valid? þ }

 With ISS_VirtualChannels^[Channel] Do Begin
    VChSmpOffs:=SampOffset;
    VChControl:=VChControl Or (ISS_CCStop+ISS_CCSample+ISS_CCVolume);
  End;
End;

{ þ Device drivers initalization þ }
Function ISS_InitDevices : Boolean;
Begin
 ISS_DevicesNum:=0;
 {$IFDEF _ISS_GUS_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_GUSDevInit; { þ Init GUS þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_GUSDevice; { þ Include GUS þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}
 {$IFDEF _ISS_SB_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_SBDevInit; { þ Init SB þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_SBDevice; { þ Include SB þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}
 {$IFDEF _ISS_NSND_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_NSNDDevInit; { þ Init Nosound þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_NSNDDevice; { þ Include Nosound þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}
 {$IFDEF _ISS_GUSNATIVE_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_GUS2DevInit; { þ Init OS/2 native GF1/Interwave þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_GUS2Device; { þ Include OS/2 GUS þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}
 {$IFDEF _ISS_DART_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_DARTDevInit; { þ Init DART þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_DARTDevice; { þ Include DART þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}
 {$IFDEF _ISS_DSOUND_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_DSNDDevInit; { þ Init DirectSound þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_DSNDDevice; { þ Include DirectSound þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}
 {$IFDEF _ISS_OSS_INCLUDE_}
  Inc(ISS_DevicesNum);
  ISS_OSSDevInit; { þ Init OSS þ }
  ISS_SoundDevices[ISS_DevicesNum]:=@ISS_OSSDevice; { þ Include OSS þ }
  If Not ISS_SoundDevices[ISS_DevicesNum]^.DevAvail Then Dec(ISS_DevicesNum);
 {$ENDIF}

 {$IFDEF _ISS_MAIN_DEBUGMODE_}
  If ISS_DevicesNum<>0 Then
    WriteLn('ISS_INIT: ',ISS_DevicesNum,' Device Driver(s) Initialized')
   Else
    WriteLn('ISS_INIT: WARNING! No Device Drivers Initialized!');
  WriteLn;
 {$ENDIF}

 ISS_InitDevices:=(ISS_DevicesNum>0);
End;

{ þ System Initialization þ }
Function ISS_InitSystem : Boolean;
Var DevInit : Boolean;
    LdrInit : Boolean;
Begin
 {$IFDEF _ISS_MAIN_DEBUGMODE_}
  {$WARNINGS OFF} ISS_CompileCoder:={$I %CODER%}; {$WARNINGS ON}
  If ISS_CompileCoder='' Then ISS_CompileCoder:='an unknown guy';
  WriteLn('ISS_INIT: Inquisition Sound Server version ',ISS_VersionStr,' [',
           {$I %DATE%},'] for ',ISS_PlatformStr);
  WriteLn('ISS_INIT: Copyright (C) 1998-2001 by Charlie/Inquisition');
  WriteLn('ISS_INIT: Compiled by : ',ISS_CompileCoder,' at ',{$I %TIME%});
  WriteLn('ISS_INIT: FPC Version : ',{$I %FPCVERSION%});
  WriteLn;
  WriteLn('ISS_INIT: Device Drivers Initialization...');
 {$ENDIF}

 DevInit:=ISS_InitDevices;

 {$IFDEF _ISS_MAIN_DEBUGMODE_}
  WriteLn('ISS_INIT: Module Loaders Initialization...');
 {$ENDIF}

 LdrInit:=ISS_InitLoaders;

 {$IFDEF _ISS_MAIN_DEBUGMODE_}
  Write('ISS_INIT: System initialization ');
  If LdrInit And DevInit Then WriteLn('completted.') Else WriteLn('FAILED!');
 {$ENDIF}

 ISS_InitSystem:=(DevInit And LdrInit);
End;

Begin
End.
{ þ ISS_SYS.PAS - (C) 1999-2001 Charlie/Inquisition þ }
