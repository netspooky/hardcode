{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_PLAY.PAS - XM module player                                        ³}
{³                  Work started     : 1999.07.01.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - Platform Independent                                    ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$MODE FPC}

{$HINTS OFF} { þ Enable this if you modify the source! þ }
{$NOTES OFF} { þ Enable this if you modify the source! þ }

Unit ISS_Play;

Interface

Uses ISS_Var, { þ Uses system variables and types þ }
     ISS_Sys; { þ Uses system functions þ }


Type ISS_TPlayerChannel = Record
       ChControl : DWord; { þ Control Messages (to the devices) þ }

       ChNote    : Byte;    { þ Channel Note þ }
       ChInstr   : Byte;    { þ Channel Instrument þ }
       ChVolume  : Integer; { þ Channel Volume þ }
       ChPanning : Byte;    { þ Channel Panning þ }
       ChFXType  : Byte;    { þ Channel Effect þ }
       ChVFXType : Byte;    { þ Channel Volume Effect þ }

       ChPeriod  : Word; { þ Channel Period þ }

       ChRNote   : Byte; { þ Note of the current row þ }
       ChRInstr  : Byte; { þ Instrument of the current row þ }
       ChRVolume : Byte; { þ Volume of the current row þ }

       { þ Effect Variables þ }
       ChPortaUpData       : Byte; { þ 01 Portamento Up þ }
       ChPortaDownData     : Byte; { þ 02 Portamento Down þ }
       ChPortaToNoteData   : Byte; { þ 03 PortaToNote þ }
       ChPortaToNotePeriod : Word; { þ 03 PortaToNote þ }

       ChVibSpeed          : Byte; { þ 04 Vibrato þ }
       ChVibDepth          : Byte; { þ 04 Vibrato þ }
       ChVibPosition       : Byte; { þ 04 Vibrato þ }
       ChVibWaveForm       : Byte; { þ 04 Vibrato þ }

       ChSampleOffset : DWord; { þ 09 Set Sample Offset þ }

       ChVolSlideData   : ShortInt; { þ 10 Volume Slide þ }

       ChGVolSlideData  : ShortInt; { þ 17 Global Volume Slide þ }

       { þ Volume Effect Variables þ }
       ChVVolSlideData : Byte; { þ VolCol FX - Volume Slide Data þ }
       ChVPanSlideData : Word; { þ VolCol FX - Panning Slide Data þ }

       ChFXTick : Byte; { þ All 'Tick based' effects þ }

      End;

     ISS_TPlayer = Record
       BPMVal : DWord; { þ Module Tempo (1193180*5)/(2*BPM) þ }
       BPMCnt : DWord; { þ Timer Ticks counter þ }
       BPMInc : DWord;
       BPM    : Byte;

       Speed    : Byte;  { þ Module Speed  þ }
       SpeedCnt : Byte;  { þ Tempo counter þ }
       TickCnt  : Byte;  { þ Tick counter  þ }

       Order   : Word; { þ Current Order Pos (Can be used for synchro) þ }
       Pattern : Word; { þ Current Pattern   (Can be used for synchro) þ }
       Row     : Word; { þ Current Row       (Can be used for synchro) þ }
       Rows    : Word; { þ Rows in current pattern þ }

       CChannel : Word; { þ Current Channel number þ }
       CNote    : Word; { þ Current Note þ }
       CInstr   : Word; { þ Current Instrument number þ }
       CVolume  : Word; { þ Current Volume þ }
       CVFXType : Word; { þ Current Volume command þ }
       CVFXParm : Word; { þ Current Volume command parameter þ }
       CFXType  : Word; { þ Current Command þ }
       CFXParm  : Word; { þ Current Command parameter þ }

       PatternOffset : ISS_PPattern; { þ Current Pattern Offset þ }

       PatternDelay : Byte;
       NextOrder    : Integer;
       NextRow      : Integer;

       Channels : Array[0..ISS_MaxPlChannels-1] Of ISS_TPlayerChannel;

      End;
     ISS_PPlayer = ^ISS_TPlayer;

     { þ Unpacked Pattern Structures þ }
     ISSPlay_TUnpackedPattern = Array[1..256,0..31] Of ISS_TPatternRow;
     ISSPlay_PUnpackedPattern = ^ISSPlay_TUnpackedPattern;


Var ISS_Player   : ISS_PPlayer;
    ISS_MusicEnd : Boolean; { þ True if the current music reached it's end. þ }

    ISSPlay_InAction       : Boolean;     { þ True if player in work þ }
    { þ Pointer to current _UNPACKED_ pattern data þ }
    ISSPlay_CurrentPatternData : ISSPlay_PUnpackedPattern;

Function  ISS_GetOrder : Word;
Procedure ISS_SetOrder(OrderToSet : Word);

Function ISS_InitModulePlay(Module : ISS_PModule) : Boolean;
Function ISS_StartModulePlay : Boolean;
Function ISS_StopModulePlay : Boolean;
Function ISS_DoneModulePlay : Boolean;

Implementation

{ þ Internal variables used by effect processing þ }
Var FXToCall : Procedure(FXParam : Word);
    FXToDo   : Procedure;

{ þ >>> F O R W A R D  D E C L A R A T I O N S <<< þ }

Procedure ISSPlay_DoFX(FXNum : DWord); Forward; { þ Used by: ProcTick þ }
Procedure ISSPlay_StartNote; Forward; { þ Used by: DoNoteDelay þ }

{ þ >>> E F F E C T  F U N C T I O N S <<< þ }
{$INCLUDE ISS_PLFX.PAS}


{ þ >>> I N T E R N A L  F U N C T I O N S <<< þ }

{ þ Starts an instrument on the current channel (ISS_Player^.CChannel) þ }
{ þ with the channel's current note and instrument. (see the declaration) þ }
Procedure ISSPlay_StartInstrument;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     ISS_StartInstrument(CChannel,ChInstr,ChNote);
     ChPeriod:=ISS_GetPeriod(CChannel);

    End;
  End;
End;

{ þ Starts a note on the current channel (ISS_Player^.CChannel) þ }
Procedure ISSPlay_StartNote;
Begin
 With ISS_Player^ Do Begin

   With Channels[CChannel] Do Begin
     If CInstr<>0 Then Begin
       ChInstr:=CInstr;
      End;
     ChNote:=CNote;

     Case ChNote Of
       FXKeyOff : Begin ISS_KeyOff(CChannel); End;
       0..96 : Begin
              ISS_InitInstrument(CChannel);
              If (CFXType<>FXPortaNote) And
                 (CVFXType<>FXVolPortaNote) Then Begin
                ISSPlay_StartInstrument;
               End;
             End;

      End;
    End;

  End;
End;

{ þ Process a volume effect þ }
Procedure ISSPlay_ProcessVolumeFX(FXNum : DWord; FXParam : Word);
Begin
 If FXNum>10 Then Exit;
 FXToCall:=FXVolProcs[FXNum].Proc;
 FXToCall(FXParam);
End;

{ þ Process an effect þ }
Procedure ISSPlay_ProcessFX(FXNum : DWord; FXParam : Word);
Begin
 If FXNum>51 Then Exit;
 FXToCall:=FXProcs[FXNum].Proc;
 FXToCall(FXParam);
End;

{ þ Process Volume Effects þ }
Procedure ISSPlay_DoVolumeFX(FXNum : DWord);
Begin
 If FXNum>10 Then Exit;
 FXToDo:=FXVolProcs[FXNum].Sust;
 FXToDo;
End;

{ þ Execute an ongoing Effect þ }
Procedure ISSPlay_DoFX(FXNum : DWord);
Begin
 If FXNum>51 Then Exit;
 FXToDo:=FXProcs[FXNum].Sust;
 FXToDo;
End;

{ þ Execute ongoing Effects þ }
Procedure ISSPlay_DoEffects;
Var Counter : DWord;
Begin
 With ISS_Player^ Do Begin
   Inc(TickCnt);

   { þ Do volume effects _before_ normal effects þ }
   For Counter:=0 To ISS_CurrentModule^.MChannels-1 Do Begin
     CChannel:=Counter;
     ISSPlay_DoVolumeFX(Channels[Counter].ChVFXType);
    End;

   { þ Now do normal effects þ }
   For Counter:=0 To ISS_CurrentModule^.MChannels-1 Do Begin
     CChannel:=Counter;
     ISSPlay_DoFX(Channels[Counter].ChFXType);
    End;

  End;
End;


{ þ Processes the current row, starts note and effects þ }
Procedure ISSPlay_ProcessRow;
Var Counter : DWord;
Begin
 With ISS_Player^ Do Begin

   For Counter:=0 To ISS_CurrentModule^.MChannels-1 Do Begin

     CChannel:=Counter; { þ Setting current channel for effects þ }

     With Channels[Counter] Do Begin
       With ISSPlay_CurrentPatternData^[Row,Counter] Do Begin
         CNote   :=RNote;  { þ Reading Note þ }
         ChRNote :=RNote;
         CInstr  :=RInstr; { þ Reading Instrument þ }
         ChRInstr:=RInstr;

         CVolume:=RVolCol; { þ Reading Volume þ }
         CFXType:=RFXType; { þ Reading Effect Type þ }
         CFXParm:=RFXParm; { þ Reading Effect Parameter þ }
        End;
      End;

     { þ This is needed for arpeggio processing, because arpeggio þ }
     { þ effect code is zero, but it always has a parameter which þ }
     { þ differs from zero. þ }
     If (CFXType=0) And (CFXParm=0) Then CFXType:=FXNoEffect;

     { þ If actual effect isn't the previous effect, restore the period þ }
     With Channels[Counter] Do Begin
       If CFXType<>ChFXType Then Begin
         If ISS_GetPeriod(CChannel)<>ChPeriod Then
           ISS_SetPeriod(CChannel,ChPeriod);
        End;
      End;

     { þ Setting Volume Commands þ }
     CVFXType:=FXVolNoEffect;
     If CVolume>$50 Then Begin { þ Volume>$50 => Volume Command þ }
       CVFXType:=((CVolume-$60) Shr 4)+1;
       CVFXParm:=(CVolume-$60) And $0F;
       CVolume :=0;
      End;

     { þ Start note if there is no note delay and note<>0 þ }
     If (CFXType<>FXNoteDelay) And (CNote<>0) Then ISSPlay_StartNote;

     With Channels[Counter] Do Begin
       { þ Process Channel Volume þ }
       If CVolume<>0 Then Begin
         { þ If CVolume<>0 set the channel volume from volume column þ }
         ChVolume:=CVolume-$10;
        End Else Begin
         { þ If CVolume=0 and CInst<>0 set sample vol. as channel volume þ }
         If CInstr<>0 Then Begin
           With ISS_VirtualChannels^[CChannel] Do Begin
             If VChSmpAddr<>Nil Then ChVolume:=VChSmpAddr^.SVolume;
            End;
          End;
        End;
       ISS_SetVolume(CChannel,ChVolume);

       { þ Process Channel Panning þ }
       If CInstr<>0 Then Begin
         With ISS_VirtualChannels^[CChannel] Do Begin
           If VChSmpAddr<>Nil Then ChPanning:=VChSmpAddr^.SPanning;
           ISS_SetPanning(CChannel,ChPanning);
          End;
        End;

      End;

     { þ Processing Volume Effects þ }
     ISSPlay_ProcessVolumeFX(CVFXType,CVFXParm);

     { þ Processing Effects þ }
     ISSPlay_ProcessFX(CFXType,CFXParm);

     { þ Save command values here, so the command proc þ }
     { þ can check the previous command number         þ }
     Channels[Counter].ChFXType :=CFXType;
     Channels[Counter].ChVFXType:=CVFXType;

    End;

  End;
End;

{ þ Changes the row to ISS_Player^.NextRow þ }
Procedure ISSPlay_DoChangeRow;
Begin
 With ISS_Player^ Do Begin

   If PatternOffset<>Nil Then Begin
     If PatternOffset^.PatRowsNum<NextRow Then Row:=0 Else Row:=NextRow;
    End;

   NextRow:=-1;

  End;
End;

{ þ Unpacks the current pattern. Should be optimized, because it's slow. þ }
Procedure ISSPlay_UnpackPattern;
Var BufPtr   : Pointer;
    BufValue : Byte;
    Counter  : DWord;
    Counter2 : DWord;
Begin
 With ISS_Player^ Do Begin

   BufPtr:=PatternOffset^.PatRows;

   For Counter:=1 To Rows Do Begin
     For Counter2:=0 To ISS_CurrentModule^.MChannels-1 Do Begin
       With ISSPlay_CurrentPatternData^[Counter,Counter2] Do Begin

         BufValue:=Byte(BufPtr^);
         Inc(DWord(BufPtr),1);

         { þ Packed Note? þ }
         If (BufValue And %10000000)>0 Then Begin
           { þ Yes, it's packed unpack note þ }

           { þ Note Follows? þ }
           If (BufValue And %00000001)>0 Then Begin
             RNote:=Byte(BufPtr^);
             Inc(DWord(BufPtr),1);
            End Else Begin
             RNote:=0;
            End;

           { þ Instrument Follows? þ }
           If (BufValue And %00000010)>0 Then Begin
             RInstr:=Byte(BufPtr^);
             Inc(DWord(BufPtr),1);
            End Else Begin
             RInstr:=0;
            End;

           { þ Volume Column Follows? þ }
           If (BufValue And %00000100)>0 Then Begin
             RVolCol:=Byte(BufPtr^);
             Inc(DWord(BufPtr),1);
            End Else Begin
             RVolCol:=0;
            End;

           { þ Effect Type Follows? þ }
           If (BufValue And %00001000)>0 Then Begin
             RFXType:=Byte(BufPtr^);
             Inc(DWord(BufPtr),1);
            End Else Begin
             RFXType:=0;
            End;

           { þ Effect Parameter Follows? þ }
           If (BufValue And %00010000)>0 Then Begin
             RFXParm:=Byte(BufPtr^);
             Inc(DWord(BufPtr),1);
            End Else Begin
             RFXParm:=0;
            End;

          End Else Begin
           { þ No, it's unpacked, just copy values þ }

           { þ Copies 5 bytes to unpacked pattern data þ }
           RNote:=BufValue;
           RInstr:=Byte(BufPtr^);  Inc(DWord(BufPtr),1);
           RVolCol:=Byte(BufPtr^); Inc(DWord(BufPtr),1);
           RFXType:=Byte(BufPtr^); Inc(DWord(BufPtr),1);
           RFXParm:=Byte(BufPtr^); Inc(DWord(BufPtr),1);

          End;

         { þ Now convert Exx effect code to 36+ effect code þ }
         If RFXType=14 Then Begin
           RFXType:=((RFXParm And $0F0) Shr 4)+36;
           RFXParm:=(RFXParm And $00F);
          End;

        End;
      End;
    End;

  End;
End;

{ þ Changes the order to ISS_Player^.NextOrder þ }
Procedure ISSPlay_DoChangeOrder;
Begin
 With ISS_Player^ Do Begin
   With ISS_CurrentModule^ Do Begin

     { þ Loop the song if next order > song length þ }
     If NextOrder>MSongLength-1 Then Begin
       ISS_MusicEnd:=True;
       Order:=MRestart;
      End Else Order:=NextOrder;

     Pattern:=MOrders[Order];
     PatternOffset:=MPatterns[Pattern];
     If PatternOffset=Nil Then Rows:=64 { þ Play a 64 rows empty pattern þ }
                          Else Rows:=PatternOffset^.PatRowsNum;

     ISSPlay_UnpackPattern; { þ Unpacks new actual pattern þ }
     NextOrder:=-1; { þ Reset Order Value þ }

    End;
  End;
End;

{ þ Process a pattern change or a row þ }
Procedure ISSPlay_PlayerTick;
Begin
 { þ Process Speed þ }
 With ISS_Player^ Do Begin
   Inc(SpeedCnt);
   If Speed=SpeedCnt Then Begin
     SpeedCnt:=0; TickCnt:=0;

     { þ Process Pattern Delay and Music Order þ }
     If PatternDelay>0 Then Begin
       Dec(PatternDelay); ISSPlay_DoEffects;
       Exit; { þ Do not process the Row => Delay the pattern þ }
      End;

     { þ Pattern Break Or Jump Pattern Command Occurs þ }
     If NextOrder<>-1 Then ISSPlay_DoChangeOrder
      Else Begin
       If Row>=Rows Then Begin { þ If actual Row is pattern length. þ }
         NextRow  :=0; { þ Jump to the next order (with Row=0) þ }
         NextOrder:=Order+1;
         ISSPlay_DoChangeOrder;
        End;
      End;

     If NextRow<>-1 Then ISSPlay_DoChangeRow; { þ Change Row Number þ }

     Inc(Row); { þ Go to next Row þ }
     ISSPlay_ProcessRow; { þ Process Row þ }

    End Else ISSPlay_DoEffects;

  End;
End;

{ þ The main timer procedure þ }
Procedure ISSPlay_PeriodicProc;
Begin
 With ISS_Player^ Do Begin

   Inc(BPMCnt,ISS_TimerDiff);
   Repeat
    If BPMCnt<BPMVal Then Begin ISS_UpdateOutput; Exit; End;
    Dec(BPMCnt,BPMVal);

    ISSPlay_PlayerTick;    { þ Player Main Tick þ }
    ISS_UpdateInstruments; { þ Updating Instruments þ }

   Until False; { þ Hacking an Endless Loop :) þ }

  End;
End;


{ þ >>> P U B L I C  F U N C T I O N S <<< þ }

{ þ Returns Current Order þ }
Function ISS_GetOrder : Word;
Begin
 ISS_GetOrder:=0;
 If Not ISSPlay_InAction Then Exit;
 ISS_GetOrder:=ISS_Player^.Order;
End;

{ þ Sets Order þ }
Procedure ISS_SetOrder(OrderToSet : Word);
Begin
 If Not ISSPlay_InAction Then Exit;
 With ISS_Player^ Do Begin
   With ISS_CurrentModule^ Do Begin
     If OrderToSet>MSongLength-1 Then OrderToSet:=MSongLength-1;
    End;
   NextRow:=0;
   NextOrder:=OrderToSet;
  End;
End;


Function ISS_InitModulePlay(Module : ISS_PModule) : Boolean;
Var Counter      : DWord;
    Counter2     : DWord;
    {$IFDEF _ISS_PLAY_DEBUGMODE_}
     LoadedSmpNum : Word;
    {$ENDIF}
Begin
 ISS_InitModulePlay:=False;
 If Not ISSPlay_InAction Then Begin

   { þ Is module pointer valid? þ }
   If (Module=Nil) Or (Module^.MID<>ISS_ModuleID) Then Begin
     { þ ERROR CODE! þ }
     { þ Invalid module pointer specified. þ }
     Exit;
    End;

   { þ Resetting Player Variables þ }
   New(ISS_Player); { þ Allocating Variable Memory þ }
   FillChar(ISS_Player^,SizeOf(ISS_TPlayer),#0);
   ISS_MusicEnd:=False;

   { þ Setting Current Module þ }
   ISS_CurrentModule:=Module;

   With ISS_CurrentModule^ Do Begin

     {$IFDEF _ISS_PLAY_DEBUGMODE_}
      WriteLn('ISS_PLAY: Initializing module player...');
     {$ENDIF}

     { þ Sets BPM/Tempo values þ }
     ProcSetBPM(MBPM);
     With ISS_Player^ Do Begin
       Speed   :=MTempo;
       SpeedCnt:=Speed-1;
      End;

     { þ Set the active channels number þ }
     If ISS_MaxPlChannels<MChannels Then Begin
       { þ ERROR CODE! þ }
       { þ Too many channels for the player þ }
       ISS_InitModulePlay:=False;
       Exit;
      End;
     ISS_SetActiveChannels(MChannels);

     {$IFDEF _ISS_PLAY_DEBUGMODE_}
      WriteLn('ISS_PLAY: Loading samples to the player device...');
      Write  ('ISS_PLAY: ');
      LoadedSmpNum:=0;
     {$ENDIF}
     { þ Uploading Samples to the player device þ }
     For Counter:=1 To MInstrNum Do Begin
       With MInstruments[Counter]^ Do Begin
         If ISampleNum>0 Then Begin
           For Counter2:=0 To ISampleNum-1 Do Begin
             If ISamples[Counter2]^.SLength>0 Then Begin
               If ISS_LoadSample(ISamples[Counter2]) Then Begin
                 {$IFDEF _ISS_PLAY_DEBUGMODE_}
                  Write('þ');
                  Inc(LoadedSmpNum);
                 {$ENDIF}
                End Else Begin
                 {$IFDEF _ISS_PLAY_DEBUGMODE_}
                  Write('!');
                  Inc(LoadedSmpNum);
                 {$ENDIF}
                End;
              End;
            End;
          End;
        End;
      End;
     {$IFDEF _ISS_PLAY_DEBUGMODE_}
      WriteLn(' [',LoadedSmpNum,'] - DONE');
     {$ENDIF}

     { þ Allocating Unpacked Pattern Memory þ }
     New(ISSPlay_CurrentPatternData);

    End;

  End;
 ISS_InitModulePlay:=True;
End;

Function ISS_StartModulePlay : Boolean;
Begin
 ISS_StartModulePlay:=False;
 If Not ISSPlay_InAction Then Begin

   { þ Is module pointer valid? þ }
   If (ISS_CurrentModule=Nil) Or
      (ISS_CurrentModule^.MID<>ISS_ModuleID) Then Begin
     { þ ERROR CODE! þ }
     { þ Invalid module pointer specified. þ }
     Exit;
    End;

   { þ Setting global volume to maximum þ }
   ISS_GlobalPlVolume:=64;

   ISSPlay_InAction:=ISS_StartOutput(@ISSPlay_PeriodicProc);
   ISS_StartModulePlay:=ISSPlay_InAction;

   { þ Set playing flag on in the active module header þ }
   If ISSPlay_InAction Then Begin
     With ISS_CurrentModule^ Do MStatus:=MStatus Or ISS_StPlaying;
    End;

  End;
End;

Function ISS_StopModulePlay : Boolean;
Begin
 ISS_StopModulePlay:=False;
 If ISSPlay_InAction Then Begin
   ISS_StopModulePlay:=ISS_StopOutput;
   ISSPlay_InAction:=False;

   { þ Set playing flag off in the active module header þ }
   With ISS_CurrentModule^ Do Dec(MStatus,ISS_StPlaying);
  End;
End;

Function ISS_DoneModulePlay : Boolean;
Var Counter, Counter2 : DWord;
    {$IFDEF _ISS_PLAY_DEBUGMODE_}
     FreedSmpNum : Word;
    {$ENDIF}
Begin
 ISS_DoneModulePlay:=False;
 If ISSPlay_Inaction Then Exit;

 With ISS_CurrentModule^ Do Begin
   {$IFDEF _ISS_PLAY_DEBUGMODE_}
    WriteLn('ISS_PLAY: Clearing samples from the player device...');
    Write  ('ISS_PLAY: ');
    FreedSmpNum:=0;
   {$ENDIF}
   { þ Clearing samples from the player device þ }
   For Counter:=1 To MInstrNum Do Begin
     With MInstruments[Counter]^ Do Begin
       If ISampleNum>0 Then Begin
         For Counter2:=0 To ISampleNum-1 Do Begin
           If ISamples[Counter2]^.SLength>0 Then Begin
             If ISS_FreeSample(ISamples[Counter2]) Then Begin
               {$IFDEF _ISS_PLAY_DEBUGMODE_}
                Write('þ');
                Inc(FreedSmpNum);
               {$ENDIF}
              End Else Begin
               {$IFDEF _ISS_PLAY_DEBUGMODE_}
                Write('!');
                Inc(FreedSmpNum);
               {$ENDIF}
              End;
            End;
          End;
        End;
      End;
    End;
   {$IFDEF _ISS_PLAY_DEBUGMODE_}
    WriteLn(' [',FreedSmpNum,'] - DONE');
   {$ENDIF}
  End;

 { þ Deallocating Unpacked Pattern Memory þ }
 Dispose(ISSPlay_CurrentPatternData);
 { þ Deallocating Player Variables þ }
 Dispose(ISS_Player);
 { þ Clearing currentmodule pointer þ }
 ISS_CurrentModule:=Nil;

 ISS_DoneModulePlay:=True;
End;

{ þ Main procedure initializes some variables þ }
Begin
 ISSPlay_InAction:=False;
End.
{ þ ISS_PLAY.PAS - (C) 1999-2001 Charlie/Inquisition þ }
