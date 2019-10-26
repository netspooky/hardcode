{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ ş ISS_VAR .PAS - Extended module (XM) loader                             ³}
{³                  Work started     : 1999.10.19.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - Platform Independent                                    ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
{$INCLUDE ISS_SET.INC}
{$MODE FPC}
{$IOCHECKS OFF}
Unit ISS_XM;

Interface

Uses ISS_Var; { ş Uses the system variables and types ş }

Const ISS_XMLoaderVerStr = '1.1.11'; { ş Loader Version Str ş }
      ISS_XMLoaderVer    = $11B;    { ş Loader Version Num ş }

Var ISS_XMLoader : ISS_TModuleLoader; { ş Loader Declaration ş }

Procedure ISS_XMLoaderInit; { ş Loader init code ş }

Implementation

Const {$IFDEF _ISS_LOAD_CREATELOGFILE_}
       XMDebugLogName = 'xmloader.log'; { ş Debug Log Filename ş }
      {$ENDIF}

      { ş Sample Type Consts ş } { ş XM Values ş }
      XM_Smp16BitData    = %00010000; { ş 16bit SampleData ş }
      XM_SmpForwardLoop  = %00000001; { ş Forward Looping ş }
      XM_SmpPingPongLoop = %00000010; { ş Bidirectional Looping ş }

Type { ş XM File Format Header ş }
     ISS_TXMHeader = Packed Record
       XMID    : Array[0..16] Of Char; { ş 'Extended Module: ' ş }
       XMTitle : Array[0..19] Of Char; { ş Module name, padded with zeroes ş }
       XM1A    : Char; { ş $1A 'End Of File' For DOS 'Type' Command ş }

       XMTracker : Array[0..19] Of Char; { ş Tracker Name ş }
       XMVersion : Word; { ş Version Number, Hi byte major, low minor ş }

       XMHeadSize : DWord; { ş File Header Size ş }
       XMSongLen  : Word;  { ş Song Length (in pattern order table) ş }
       XMRestart  : Word;  { ş Song Restart Position ş }
       XMChannels : Word;  { ş Number Of Channels (2-32) ş }
       XMPatterns : Word;  { ş Number Of Patterns (max 256) ş }
       XMInstr    : Word;  { ş Number Of Instruments (max 128) ş }
       XMFlags    : Word;  { ş Module Flags ş }

       XMTempo    : Word; { ş Module Tempo ş }
       XMBPM      : Word; { ş Module BPM ş }

       XMOrder    : Array[0..255] Of Byte; { ş Order Table ş }
      End;
     ISS_PXMHeader = ^ISS_TXMHeader;

     { ş XM Pattern Header ş }
     ISS_TXMPatternHeader = Packed Record
       XMPHeaderL  : DWord; { ş Pattern Header Length ş }
       XMPPackType : Byte;  { ş Pattern Pack Type (Always = 0) ş }
       XMPRowsNum  : Word;  { ş Number of Rows in the Pattern ş }
       XMPDataSize : Word;  { ş Packed PatternData Size ş }
      End;
     ISS_PXMPatternHeader = ^ISS_TXMPatternHeader;

     { ş XM Instrument Header ş }
     ISS_TXMInstrument = Packed Record
       XMISize   : DWord; { ş Instrument Size ş }
       XMIName   : Array[0..21] Of Char; { ş Instrument Name ş }
       XMIType   : Byte; { ş Instrument Type (Always 0) ş }
       XMISmpNum : Word; { ş Number of samples in this instrument ş }

       XMIHeaderSize : DWord; { ş Instrument Header Size ş }
       XMINoteTable  : Array[1..96] Of Byte; { ş Sample Number for all notes ş }

       XMIVolEnvPoints : Array[0..23] Of Word; { ş Volume Envelope Points ş }
       XMIPanEnvPoints : Array[0..23] Of Word; { ş Panning Envelope Points ş }

       XMIVolEnvPNum : Byte; { ş Volume Envelope Points ş }
       XMIPanEnvPNum : Byte; { ş Panning Envelope Points ş }

       XMIVolEnvSustain   : Byte; { ş Volume Sustain Point ş }
       XMIVolEnvLoopStart : Byte; { ş Volume Loop Start Point ş }
       XMIVolEnvLoopEnd   : Byte; { ş Volume Loop End Point ş }

       XMIPanEnvSustain   : Byte; { ş Panning Sustain Point ş }
       XMIPanEnvLoopStart : Byte; { ş Panning Loop Start Point ş }
       XMIPanEnvLoopEnd   : Byte; { ş Panning Loop End Point ş }

       XMIVolEnvType : Byte; { ş Volume Envelope Type ş }
       XMIPanEnvType : Byte; { ş Panning Envelope Type ş }

       XMIVibratoType  : Byte; { ş Vibrato Type ş }
       XMIVibratoSweep : Byte; { ş Vibrato Sweep ş }
       XMIVibratoDepth : Byte; { ş Vibrato Depth ş }
       XMIVibratoRate  : Byte; { ş Vibrato Rate ş }

       XMIVolFadeOut : Word; { ş Volume FadeOut ş }
       Reserved      : Word;
      End;
     ISS_PXMInstrument = ^ISS_TXMInstrument;

     { ş XM Sample Header ş }
     ISS_TXMSample = Packed Record
       XMSSize       : DWord;
       XMSLoopStart  : DWord;
       XMSLoopLength : DWord;
       XMSVolume     : Byte;
       XMSFineTune   : ShortInt;
       XMSType       : Byte;
       XMSPanning    : Byte;
       XMSRelNote    : ShortInt; { ş Relative Note Number (signed byte) ş }
       XMSReserved   : Byte;
       XMSName       : Array[0..21] Of Char;
      End;
     ISS_PXMSample = ^ISS_TXMSample;

Var XMHeader   : ISS_PXMHeader;
    {$IFDEF _ISS_LOAD_CREATELOGFILE_}
     XMDebugLog : Text;
    {$ENDIF}

    XMInsOffs   : Pointer; { ş Pointer to current instrument offset ş }

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_XMLoaderDebugInit                                                   ³}
{³                                                                          ³}
{³. Description : Opens the debug file. Call it only from ISS_Load! Unsafe. ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Procedure ISS_XMLoaderDebugInit;
Begin
 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  Assign(XMDebugLog,XMDebugLogName);
  Rewrite(XMDebugLog);
  WriteLn('ISS_LOAD: XM Loader is creating logfile : ',XMDebugLogName);
  WriteLn(XMDebugLog,#13,#10,' ş Inquisition Sound Server version ',
          ISS_VersionStr,' - XM Loader Debug Log File');
  WriteLn(XMDebugLog,' ş Created by loader version : ',ISS_XMLoaderVerStr);
  WriteLn(XMDebugLog,' ş Code by Charlie/Inquisition',#13,#10);
 {$ENDIF}
End;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_XMLoaderDebugDone                                                   ³}
{³                                                                          ³}
{³. Description : Closes the debug file. Call it only from ISS_Load! Unsafe ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Procedure ISS_XMLoaderDebugDone;
Begin
 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  Close(XMDebugLog);
 {$ENDIF}
End;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_XMLoaderCheckModule                                                 ³}
{³                                                                          ³}
{³. Description : Checks the possibility that the current module can be     ³}
{³                loaded with this loader. Call it only from ISS_Load!      ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_XMCheckModule : Boolean;
Begin
 XMHeader:=ISS_XMLoader.ModuleMem;
 With XMHeader^ Do Begin
 If (XMID='Extended Module: ') Then ISS_XMCheckModule:=True
                               Else ISS_XMCheckModule:=False;
  End;
End;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_XMLoadHeader                                                        ³}
{³                                                                          ³}
{³. Description : Loads the current module's header.                        ³}
{³                Call it only from ISS_Load!                               ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_XMLoadHeader : Boolean;
Var BufString : String;
    {$IFDEF _ISS_LOAD_CREATELOGFILE_}
     Counter   : Word;
    {$ENDIF}
Begin
 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  WriteLn(XMDebugLog,' ş Loading module header...');
 {$ENDIF}
 XMHeader:=ISS_XMLoader.ModuleMem;
 With XMHeader^ Do Begin
   With ISS_XMLoader.ModulePtr^ Do Begin

     BufString:=XMTitle;           { ş Assigning the module title ş }
     MTitle   :=BufString;
     {$IFDEF _ISS_LOAD_CREATELOGFILE_}
      WriteLn(XMDebugLog,'   - Module Title          : ',BufString);
     {$ENDIF}
     MTracker :=ISS_TrackerID_FT2; { ş Assigning the tracker type ş }

     MFlags   :=XMFlags;    { ş Assigning the module flags ş }
     MChannels:=XMChannels; { ş Assigning number of Channels ş }
     MPatternNum:=XMPatterns; { ş Assigning number of Patterns (max 256) ş }

     { ş LoadPatterns will create an empty pattern in this case... ş }
     If MPatternNum=0 Then MPatternNum:=1;

     MInstrNum:=XMInstr; { ş Assigning number Of Instruments (max 128) ş }
     {$IFDEF _ISS_LOAD_CREATELOGFILE_}
      WriteLn(XMDebugLog,'   - Number Of Channels    : ',MChannels);
      WriteLn(XMDebugLog,'   - Number Of Patterns    : ',MPatternNum);
      WriteLn(XMDebugLog,'   - Number Of Instruments : ',MInstrNum);
     {$ENDIF}

     MTempo   :=XMTempo;    { ş Assigning the default tempo ş }
     MBPM     :=XMBPM;      { ş Assigning the default BPM ş }
     {$IFDEF _ISS_LOAD_CREATELOGFILE_}
      WriteLn(XMDebugLog,'   - Default Tempo/BPM     : ',MTempo,'/',MBPM);
     {$ENDIF}

     MSongLength:=XMSongLen; { ş Assigning number of orders ş }
     MRestart   :=XMRestart; { ş Assigning the restart position ş }
     MOrders    :=XMOrder;   { ş Assigning the order table ş }
     {$IFDEF _ISS_LOAD_CREATELOGFILE_}
      WriteLn(XMDebugLog,'   - Song Length (Orders)  : ',MSongLength);
      WriteLn(XMDebugLog,'   - Song Restart Position : ',MRestart,#13,#10);
      Write(XMDebugLog,'   - Order Table : ');
      For Counter:=0 To MSongLength-1 Do Begin
        If Counter<MSongLength-1 Then Write(XMDebugLog,MOrders[Counter],',')
                                 Else WriteLn(XMDebugLog,MOrders[Counter]);
       End;
     {$ENDIF}

    End;
  End;

 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  WriteLn(XMDebugLog,' ');
 {$ENDIF}

 ISS_XMLoadHeader:=True;
End;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_XMLoadPatterns                                                      ³}
{³                                                                          ³}
{³. Description : Loads the current module's patterns.                      ³}
{³                Call it only from ISS_Load!                               ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_XMLoadPatterns : Boolean;
Var CurrentOffset        : Pointer;
    CurrentPatternHeader : ISS_PXMPatternHeader;
    Counter : DWord;
Begin
 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  WriteLn(XMDebugLog,' ş Loading patterns...');
 {$ENDIF}

 XMHeader:=ISS_XMLoader.ModuleMem;
 With XMHeader^ Do Begin

   DWord(CurrentOffset):=DWord(ISS_XMLoader.ModuleMem)+60+XMHeadSize;

   { ş If there is no pattern, we'll create one for the player... ş }
   If XMPatterns=0 Then Begin

     With ISS_XMLoader.ModulePtr^.MPatterns[0]^ Do Begin
       PatSize   :=64*XMChannels;
       PatRowsNum:=64;
       GetMem(PatRows,PatSize);
       FillChar(PatRows^,PatSize,#128);
       {$IFDEF _ISS_LOAD_CREATELOGFILE_}
        WriteLn(XMDebugLog,'   - There was no pattern data. Empty pattern created.');
       {$ENDIF}
      End;

    End Else Begin

     For Counter:=0 To XMPatterns-1 Do Begin
       CurrentPatternHeader:=CurrentOffset;
       With CurrentPatternHeader^ Do Begin
         With ISS_XMLoader.ModulePtr^.MPatterns[Counter]^ Do Begin
           PatSize   :=XMPDataSize;
           PatRowsNum:=XMPRowsNum;
           {$IFDEF _ISS_LOAD_CREATELOGFILE_}
            WriteLn(XMDebugLog,'   - Pattern ',Counter,'.');
            WriteLn(XMDebugLog,'     - Packed Pattern Size : ',PatSize,' bytes');
            WriteLn(XMDebugLog,'     - Number of Rows      : ',PatRowsNum);
           {$ENDIF}

           { ş Checking for empty pattern ş }
           If PatSize=0 Then Begin
             { ş Creating Empty Pattern ş }
             PatSize:=PatRowsNum*XMChannels;
             GetMem(PatRows,PatSize);
             FillChar(PatRows^,PatSize,#128);
             Inc(DWord(CurrentOffset),XMPHeaderL);
             {$IFDEF _ISS_LOAD_CREATELOGFILE_}
              WriteLn(XMDebugLog,'     - Pattern is empty.');
             {$ENDIF}
            End Else Begin
             { ş Allocating Memory for Pattern Data ş }
             GetMem(PatRows,PatSize);
             Inc(DWord(CurrentOffset),XMPHeaderL);
             Move(CurrentOffset^,PatRows^,PatSize); { ş Moving Pattern Data ş }
             Inc(DWord(CurrentOffset),PatSize);
            End;
          End;
        End;
      End;

    End;

   { ş Creating another empty pattern, if not all possible patterns stored ş }
   { ş in the XM file. This will handle "phantom" patterns in the order table ş }
   If XMPatterns<255 Then Begin
     With ISS_XMLoader.ModulePtr^ Do Begin
       With MPatterns[MPatternNum]^ Do Begin
         PatSize   :=64*XMChannels;
         PatRowsNum:=64;
         GetMem(PatRows,PatSize);
         FillChar(PatRows^,PatSize,#128);
        End;
      End;
     { ş Now scanning order table for "phantom" patterns, and force them ş }
     { ş to use the empty pattern just created... ş }
     With ISS_XMLoader.ModulePtr^ Do Begin
       For Counter:=0 To MSongLength-1 Do Begin
         If MOrders[Counter]>MPatternNum Then MOrders[Counter]:=MPatternNum
        End;
      End;
    End;

  End;

 XMInsOffs:=CurrentOffset;
 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  WriteLn(XMDebugLog,#13,#10);
 {$ENDIF}

 ISS_XMLoadPatterns:=True;
End;

{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ş ISS_XMLoadInstruments                                                   ³}
{³                                                                          ³}
{³. Description : Loads the current module's instruments and samples.       ³}
{³                Call it only from ISS_Load!                               ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}
Function ISS_XMLoadInstruments : Boolean;

Type PInteger  = ^Integer;
     PShortInt = ^ShortInt;

Var CurrentOffset     : Pointer;
    CurrentInstrument : ISS_PXMInstrument;
    CurrentSample     : ISS_PXMSample;

    BufString : String;
    BufValue1 : Integer; { ş Used for delta conversion ş }
    BufValue2 : Integer; { ş Used for delta conversion ş }

    Counter   : DWord;
    Counter2  : DWord;
    Counter3  : DWord;

    XMLoadedSmp : Word; { ş Number of loaded samples (debug) ş }

Begin

 XMLoadedSmp:=0;
 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  WriteLn(XMDebugLog,' ş Loading instruments...');
 {$ENDIF}

 CurrentOffset:=XMInsOffs;
 XMHeader:=ISS_XMLoader.ModuleMem;
 With XMHeader^ Do Begin

   For Counter:=1 To XMInstr Do Begin
     CurrentInstrument:=CurrentOffset;
     With CurrentInstrument^ Do Begin
       With ISS_XMLoader.ModulePtr^.MInstruments[Counter]^ Do Begin
         BufString:=XMIName;
         IName:=BufString; { ş Assigning instrument name ş }

         INoteTable:=XMINoteTable; { ş Assigning notetable ş }

         With IVolumeEnv Do Begin { ş Assigning volume envelope values ş }
           EnvType     :=XMIVolEnvType; { ş Envelope Type ş }
           EnvPointsNum:=XMIVolEnvPNum;    { ş Number Of Envelope Points ş }
           EnvSustain  :=XMIVolEnvSustain; { ş Envelope Sustain Point ş }
           EnvLoopStart:=XMIVolEnvLoopStart; { ş Envelope Loop Start Point ş }
           EnvLoopEnd  :=XMIVolEnvLoopEnd;   { ş Envelope Loop End Point ş }
           For Counter2:=0 To 11 Do Begin { ş Envelope Points ş }
             With EnvPoints[Counter2] Do Begin
               EPPosition:=XMIVolEnvPoints[Counter2*2];
               EPValue   :=XMIVolEnvPoints[Counter2*2+1];
              End;
            End;
          End;
         IVolFadeOut:=XMIVolFadeOut; { ş Assigning Volume FadeOut ş }

         With IPanningEnv Do Begin { ş Assigning panning envelope values ş }
           EnvType     :=XMIPanEnvType; { ş Envelope Type ş }
           EnvPointsNum:=XMIPanEnvPNum;    { ş Number Of Envelope Points ş }
           EnvSustain  :=XMIPanEnvSustain; { ş Envelope Sustain Point ş }
           EnvLoopStart:=XMIPanEnvLoopStart; { ş Envelope Loop Start Point ş }
           EnvLoopEnd  :=XMIPanEnvLoopEnd;   { ş Envelope Loop End Point ş }
           For Counter2:=0 To 11 Do Begin { ş Envelope Points ş }
             With EnvPoints[Counter2] Do Begin
               EPPosition:=XMIPanEnvPoints[Counter2*2];
               EPValue   :=XMIPanEnvPoints[Counter2*2+1];
              End;
            End;
          End;

         { ş Assign Autovibrato Values ş }
         IVibType:=XMIVibratoType;   { ş Vibrato Type ş }
         IVibSweep:=XMIVibratoSweep; { ş Vibrato Sweep ş }
         IVibDepth:=XMIVibratoDepth; { ş Vibrato Depth ş }
         IVibRate:=XMIVibratoRate;   { ş Vibrato Rate ş }

         ISampleNum:=XMISmpNum; { ş Assigning number of samples ş }

         {$IFDEF _ISS_LOAD_CREATELOGFILE_}
          WriteLn(XMDebugLog,'   - Instrument ',Counter,'.');
          WriteLn(XMDebugLog,'     - Instrument Size   : ',XMISize,' bytes');
          WriteLn(XMDebugLog,'     - Instrument Name   : ',IName);
          WriteLn(XMDebugLog,'     - Number Of Samples : ',ISampleNum);
          If ISampleNum>0 Then Begin
            WriteLn(XMDebugLog,'     - Autovibrato Type  : ',IVibType);
            WriteLn(XMDebugLog,'     - Autovibrato Sweep : ',IVibSweep);
            WriteLn(XMDebugLog,'     - Autovibrato Depth : ',IVibDepth);
            WriteLn(XMDebugLog,'     - Autovibrato Rate  : ',IVibRate);
            Write  (XMDebugLog,'     - Note Table : ');
            For Counter2:=1 To 96 Do Begin
              Write(XMDebugLog,INoteTable[Counter2],' ');
             End;
            WriteLn(XMDebugLog);

            Write  (XMDebugLog,'     - Volume Envelope :');
            For Counter2:=0 To 11 Do Begin
              With IVolumeEnv.EnvPoints[Counter2] Do
                Write(XMDebugLog,' Pos:',EPPosition,',Vol:',EPValue);
             End;
            WriteLn(XMDebugLog);
            WriteLn(XMDebugLog,'     - Sustain point :',IVolumeEnv.EnvSustain);
            WriteLn(XMDebugLog,'     - Loop start point :',IVolumeEnv.EnvLoopStart);
            WriteLn(XMDebugLog,'     - Loop end point :',IVolumeEnv.EnvLoopEnd);
           End;
         {$ENDIF}

         Inc(DWord(CurrentOffset),XMISize);
         If XMISmpNum>0 Then Begin
           For Counter2:=0 To XMISmpNum-1 Do Begin

             { ş Allocating Memory for sample header ş }
             New(ISamples[Counter2]);
             CurrentSample:=CurrentOffset;
             With CurrentSample^ Do Begin
               With ISamples[Counter2]^ Do Begin

                 { ş Assigning Sample Values ş }
                 SName    :=XMSName; { ş Sample Name ş }
                 SLength  :=XMSSize; { ş Sample Size ş }
                 SDRAMOffs:=0;

                 If XMSLoopLength>0 Then Begin
                   SLoopStart:=XMSLoopStart; { ş Sample Loop Start ş }
                   SLoopEnd  :=XMSLoopLength+XMSLoopStart; { ş Loop End ş }
                  End Else Begin
                   SLoopStart:=0;
                   SLoopEnd:=0;
                  End;

                 { ş Sample Type Conversion to GUS values ş }
                 SType:=0;
                 If (XMSType And XM_Smp16BitData)>0 Then
                   SType:=SType Or ISS_Smp16BitData;
                 If (SLoopEnd-SLoopStart)>0 Then Begin
                   If (XMSType And XM_SmpForwardLoop)>0 Then Begin
                     SType:=SType Or ISS_SmpForwardLoop; End;
                   If (XMSType And XM_SmpPingPongLoop)>0 Then Begin
                     SType:=SType Or ISS_SmpPingPongLoop; End;
                  End;

                 SVolume   :=XMSVolume;    { ş Sample Volume ş }
                 SFineTune :=XMSFineTune;  { ş Sample FineTune ş }
                 SRelNote  :=XMSRelNote;   { ş Sample Relative Note ş }
                 SPanning  :=XMSPanning;   { ş Sample Panning ş }

                 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
                  WriteLn(XMDebugLog,'    - Sample ',Counter2,'.');
                  WriteLn(XMDebugLog,'      - Sample Name : ',SName);
                  WriteLn(XMDebugLog,'      - Sample Size : ',SLength,' bytes');
                  WriteLn(XMDebugLog,'      - Sample Loop Start : ',SLoopStart,'.');
                  WriteLn(XMDebugLog,'      - Sample Loop End   : ',SLoopEnd,'.');
                 {$ENDIF}
                 Inc(DWord(CurrentOffset),SizeOf(ISS_TXMSample));
                End;
              End;
            End;

           { ş Loading Sample Data ş }
           For Counter2:=0 TO XMISmpNum-1 Do Begin
             With ISamples[Counter2]^ Do Begin
               If SLength>0 Then Begin
                 GetMem(SData,SLength); { ş Allocating Memory for Sample Data ş }
                 Move(CurrentOffset^,SData^,SLength); { ş Moving SampleData ş }
                 Inc(DWord(CurrentOffset),SLength);
                 Inc(XMLoadedSmp); { ş Inc number of loaded samples (debug) ş }

                 { ş Delta Conversion ş }
                 If (SType And ISS_Smp16BitData)>0 Then Begin
                   { ş 16bit sampledata ş }
                   BufValue2:=0;
                   For Counter3:=0 To (SLength Div 2)-1 Do Begin
                     BufValue1:=PInteger(SData)[Counter3]+BufValue2;
                     PInteger(SData)[Counter3]:=BufValue1;
                     BufValue2:=BufValue1;
                    End;

                   {$IFDEF _ISS_LOAD_CREATELOGFILE_}
                    WriteLn(XMDebugLog,'    - Sample ',Counter2,
                                       '. data is 16 bits.');
                   {$ENDIF}

                  End Else Begin
                   { ş 8bit sampledata ş }
                   BufValue2:=0;
                   For Counter3:=0 To SLength-1 Do Begin
                     BufValue1:=PShortInt(SData)[Counter3]+BufValue2;
                     PShortInt(SData)[Counter3]:=BufValue1;
                     BufValue2:=BufValue1;
                    End;
                   SLength:=SLength;

                   {$IFDEF _ISS_LOAD_CREATELOGFILE_}
                    WriteLn(XMDebugLog,'    - Sample ',Counter2,
                                       '. data is 8 bits.');
                   {$ENDIF}
                  End;
                End;
              End;
            End;

          End;
        End;
      End;
    End;

  End;

 {$IFDEF _ISS_LOAD_CREATELOGFILE_}
  WriteLn(XMDebugLog,'   - Number of samples loaded: ',XMLoadedSmp,#13,#10);
 {$ENDIF}

 ISS_XMLoadInstruments:=True;
End;

{ ş This procedure assigns the loader procedures ş }
Procedure ISS_XMLoaderInit;
Begin
 FillChar(ISS_XMLoader,SizeOf(ISS_XMLoader),#0);
 With ISS_XMLoader Do Begin
   DebugInit      :=@ISS_XMLoaderDebugInit;
   DebugDone      :=@ISS_XMLoaderDebugDone;
   CheckModule    :=@ISS_XMCheckModule;
   LoadHeader     :=@ISS_XMLoadHeader;
   LoadPatterns   :=@ISS_XMLoadPatterns;
   LoadInstruments:=@ISS_XMLoadInstruments;
  End;
 {$IFDEF _ISS_LOAD_DEBUGMODE_}
  WriteLn('LDR_INIT: FastTracker 2 .XM loader ',ISS_XMLoaderVerStr);
 {$ENDIF}
End;

Begin
End.
{ ş ISS_LOAD.PAS - (C) 1999-2001 Charlie/Inquisition ş }
