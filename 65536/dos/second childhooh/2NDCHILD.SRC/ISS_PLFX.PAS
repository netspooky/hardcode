{ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿}
{³ þ ISS_PLFX.PAS - Effect handlers for the module player                   ³}
{³                  Work started     : 1999.10.20.                          ³}
{³                  Last modification: 2001.06.18.                          ³}
{³             OS - Platform Independent                                    ³}
{³                                                                          ³}
{³            ISS - Inquisition Sound Server for Free Pascal                ³}
{³                  Code by Karoly Balogh (a.k.a. Charlie/iNQ)              ³}
{³                  Copyright (C) 1998-2001 Inquisition                     ³}
{ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ}

{ þ >>> NO UNIT HEADER, BECAUSE THIS IS AN INCLUDE FILE!!! <<< þ }

{ þ >>> E F F E C T  I D  N U M B E R S <<< þ }

Const { þ Effect Numbers þ }

      FXPortaUp      =  1; { þ 01-1xx Portamento Up           (MOD) þ }
      FXPortaDown    =  2; { þ 02-2xx Portamento Down         (MOD) þ }
      FXPortaNote    =  3; { þ 03-3xx Portamento to Note      (MOD) þ }
      FXVibrato      =  4; { þ 04-4xy Vibrato                 (MOD) þ }
      FXPortVolSlide =  5; { þ 05-5xy Portamento+Volume Slide (MOD) þ }
      FXVibVolSlide  =  6; { þ 06-6xy Vibrato+Volume Slide    (MOD) þ }
      FXSetPanning   =  8; { þ 08-8xx Set Panning ($0-$80)    (MOD/DMP) þ }
      FXSetOffset    =  9; { þ 09-9xx Set Sample Offset       (MOD) þ }
      FXVolumeSlide  = 10; { þ 10-Axy Volume Slide            (MOD) þ }
      FXJump         = 11; { þ 11-Bxx Jump to pattern         (MOD) þ }
      FXSetVolume    = 12; { þ 12-Cxx Set Volume              (MOD) þ }
      FXPatBreak     = 13; { þ 13-Dxx Pattern Break           (MOD) þ }
                           { þ 14-Exy Extended Effects (36+x)       þ }
      FXSetTempoBPM  = 15; { þ 15-Fxx Set Speed/Set BPM       (MOD) þ }
      FXSetGVolume   = 16; { þ 16-Gxx Set Global Volume       (S3M/XM) þ }
      FXGVolumeSlide = 17; { þ 17-Hxx Global Volume Slide     (XM) þ }

      FXRetrig       = 45; { þ 45-E9x Retrig Note             (MOD) þ }
      FXFineVolSldUp = 46; { þ 46-EAx Fine Volume Slide Up    (MOD) þ }
      FXFineVolSldDn = 47; { þ 47-EBx Fine Volume Slide Down  (MOD) þ }

      FXCutNote      = 48; { þ 48-ECx Cut Note                (MOD) þ }
      FXNoteDelay    = 49; { þ 49-EDx Delay Note              (MOD) þ }

      FXKeyOff       = 97; { þ Key Off þ }

      FXNoEffect     = 255; { þ No effect þ }

      { þ Volume Commands þ }

      FXVolSlideDn   =  1; { þ Volume Slide Down þ }
      FXVolSlideUp   =  2; { þ Volume Slide Up þ }
      FXVolFineSldDn =  3; { þ Fine Volume Slide Down þ }
      FXVolFineSldUp =  4; { þ Fine Volume Slide Up þ }
      FXVolSetVibSpd =  5; { þ Set vibrato speed þ }
      FXVolVibrato   =  6; { þ Vibrato þ }
      FXVolSetPan    =  7; { þ Set Panning þ }
      FXVolPanSlideL =  8; { þ Panning Slide Left þ }
      FXVolPanSlideR =  9; { þ Panning Slide Right þ }
      FXVolPortaNote = 10; { þ Porta To Note þ }

      FXVolNoEffect  = 255; { þ No effect þ }


{ þ >>> V O L U M E  E F F E C T  S U S T A I N <<< þ }

{ þ Command : Do Volume Slide Down þ }
Procedure DoVVolumeSlideDn;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     If ChVolume<ChVVolSlideData Then ChVolume:=0
                                 Else Dec(ChVolume,ChVVolSlideData);
     ISS_SetVolume(CChannel,ChVolume);
    End;
  End;
End;

{ þ Command : Do Volume Slide Up þ }
Procedure DoVVolumeSlideUp;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     Inc(ChVolume,ChVVolSlideData);
     If ChVolume>64 Then ChVolume:=64;
     ISS_SetVolume(CChannel,ChVolume);
    End;
  End;
End;


{ þ Command : Do Panning Slide Left þ }
Procedure DoVPanningSlideLeft;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     If ChPanning<ChVPanSlideData Then ChPanning:=0
                                  Else Dec(ChPanning,ChVPanSlideData);
     ISS_SetPanning(CChannel,ChPanning);
    End;
  End;
End;

{ þ Command : Do Panning Slide Right þ }
Procedure DoVPanningSlideRight;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     If ChPanning+ChVPanSlideData>255 Then ChPanning:=255
                                      Else Inc(ChPanning,ChVPanSlideData);
     ISS_SetPanning(CChannel,ChPanning);
    End;
  End;
End;

{ þ >>> V O L U M E  E F F E C T  P R O C E S S I N G <<< þ }

{ þ Command : Process Volume Slide Up or Down þ }
Procedure ProcVVolumeSlide(VolToSlide : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     ChVVolSlideData:=VolToSlide;
    End;
  End;
End;

{ þ Command : Process Volume Panning þ }
Procedure ProcVSetPanning(PanToSet : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     ChPanning:=(PanToSet Shl 4)+PanToSet;
     ISS_SetPanning(CChannel,ChPanning);
    End;
  End;
End;

{ þ Command : Process Volume Panning Slide þ }
Procedure ProcVPanningSlide(PanToSlide : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     ChVPanSlideData:=PanToSlide;
    End;
  End;
End;


{ þ >>> E F F E C T  S U S T A I N <<< þ }

{ þ Command : Do Portamento Up   þ }
Procedure DoPortaUp;
Var Buf1,Buf2 : DWord;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     Buf1:=ChPortaUpData;
     Buf1:=Buf1 Shl 2;
     Buf2:=ChPeriod;
     Dec(Buf2,Buf1);
     ISS_SetPeriod(CChannel,Buf2);
     ChPeriod:=Buf2;
    End;
  End;
End;

{ þ Command : Do Portamento Down þ }
Procedure DoPortaDown;
Var Buf1,Buf2 : DWord;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     Buf1:=ChPortaDownData;
     Buf1:=Buf1 Shl 2;
     Buf2:=ChPeriod;
     Inc(Buf2,Buf1);
     ISS_SetPeriod(CChannel,Buf2);
     ChPeriod:=Buf2;
    End;
  End;
End;

{ þ Command : Do Porta To Note   þ }
Procedure DoPortaNote;
Var Buf1,Buf2,Buf3 : DWord;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     Buf1:=ChPortaToNoteData;
     Buf1:=Buf1 Shl 2;
     Buf2:=ChPeriod;
     Buf3:=ChPortaToNotePeriod;
     If (Buf3<>0) And (Buf3<>Buf2) Then Begin
       If Buf2<=Buf3 Then Begin
         Inc(Buf2,Buf1);
         If Buf2<=Buf3 Then Begin
           ISS_SetPeriod(CChannel,Buf2);
           ChPeriod:=Buf2;
           Exit;
          End;
          Buf2:=Buf3;
        End;
       If Buf2<=Buf1 Then Buf2:=Buf3
                     Else Begin
                      Buf2:=Buf2-Buf1;
                      If Buf2<Buf3 Then Buf2:=Buf3;
                     End;
       ISS_SetPeriod(CChannel,Buf2);
       ChPeriod:=Buf2;
      End;
    End;
  End;
End;

{ þ Command : Do Vibrato þ }
Procedure DoVibrato;
Var BufPeriod   : DWord;
    BufVibValue : Byte;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     BufPeriod:=ChPeriod;
     BufVibValue:=((ISS_SineTable[ChVibPosition And 127]*ChVibDepth) Div 128);
     If ChVibPosition>127 Then Inc(BufPeriod,BufVibValue)
                          Else Dec(BufPeriod,BufVibValue);

     ISS_SetPeriod(CChannel,BufPeriod);

     Inc(ChVibPosition,ChVibSpeed*4);

    End;
  End;
End;

{ þ Command : Do Volume Slide þ }
Procedure DoVolumeSlide;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     ChVolume:=ChVolume+ChVolSlideData;

     If ChVolume>64 Then ChVolume:=64;
     If ChVolume<0 Then ChVolume:=0;
     ISS_SetVolume(CChannel,ChVolume);

    End;
  End;
End;

{ þ Command : Do Retrig  þ }
Procedure DoRetrig;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     If ChFXTick=0 Then Exit;

     If (TickCnt Mod ChFXTick)=0 Then Begin
       ISS_SetSampleOffset(CChannel,0); { þ Retrig þ }
      End;

    End;
  End;
End;

{ þ Command : Do Portamento+VolumeSlide þ }
Procedure DoPortVolSlide;
Begin
 DoPortaNote;
 DoVolumeSlide;
End;

{ þ Command : Do Vibrato+VolumeSlide þ }
Procedure DoVibVolSlide;
Begin
 DoVibrato;
 DoVolumeSlide;
End;

{ þ Command : Do Global Volume Slide þ }
Procedure DoGVolumeSlide;
Var BufVol : LongInt;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     BufVol:=ISS_GlobalPlVolume+ChGVolSlideData;

     If BufVol<0  Then Begin ISS_GlobalPlVolume:=0;  Exit; End;
     If BufVol>64 Then Begin ISS_GlobalPlVolume:=64; Exit; End;

     ISS_GlobalPlVolume:=BufVol;

    End;
  End;
End;


{ þ Command : Cut Note þ }
Procedure DoCutNote;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     If TickCnt=ChFXTick Then Begin
       ChVolume:=0;
       ISS_SetVolume(CChannel,ChVolume); { þ Cut Note þ }
      End;

    End;
  End;
End;

{ þ Command : Do Note Delay þ }
Procedure DoNoteDelay;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     { þ If Tick counter reached specified value, we start the note þ }
     If TickCnt=ChFXTick Then Begin
       CNote :=ChRNote;
       CInstr:=ChRInstr;
       If CNote<>0 Then Begin
         ISSPlay_StartNote;
        End;
      End;

    End;
  End;
End;


{ þ >>> E F F E C T  P R O C E S S I N G <<< þ }

{ þ Command : Process Portamento Up þ }
Procedure ProcPortaUp(PortaTo : Word);
Begin
 With ISS_Player^ Do Begin
   If PortaTo<>0 Then Channels[CChannel].ChPortaUpData:=PortaTo;
  End;
End;

{ þ Command : Process Portamento Down þ }
Procedure ProcPortaDown(PortaTo : Word);
Begin
 With ISS_Player^ Do Begin
   If PortaTo<>0 Then Channels[CChannel].ChPortaDownData:=PortaTo;
  End;
End;

{ þ Command : Process Porta To Note þ }
Procedure ProcPortaNote(PortaTo : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin;
     If PortaTo<>0 Then
       ChPortaToNoteData:=PortaTo;
     If CNote<>0 Then
       ChPortaToNotePeriod:=ISS_ChGetNotePeriod(CChannel,CNote);
    End;
  End;
End;

{ þ Command : Process Vibrato þ }
Procedure ProcVibrato(VibValues : Word);
Var VibSpeed : Byte;
    VibDepth : Byte;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     VibSpeed:=(VibValues And $0F0) Shr 4;
     VibDepth:=VibValues And $00F;

     { þ If a parameter is zero, we're using previous values þ }
     If VibSpeed>0 Then ChVibSpeed:=VibSpeed;
     If VibDepth>0 Then ChVibDepth:=VibDepth;

     { þ If previous command wasn't vibrato and we're in retrigger þ }
     { þ mode, then retrig vibrato þ }
     If (ChFXType<>FXVibrato) And (ChFXType<>FXVibVolSlide) And
        (ChVibWaveForm<4) Then ChVibPosition:=0;

     { þ Vibrato processed in the head tick too þ }
     DoVibrato;

    End;
  End;
End;

{ þ Command : Process Set Panning þ }
Procedure ProcSetPanning(PanToSet : Word);
Begin
 With ISS_Player^ Do Begin
   ISS_SetPanning(CChannel,PanToSet);
  End;
End;

{ þ Command : Process Sample Offset þ }
Procedure ProcSetSampOffset(OffsetToSet : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     { þ Store offset if it it's not zero þ }
     If OffsetToSet<>0 Then ChSampleOffset:=OffsetToSet;

     { þ Set the sample offset. If the current parameter is zero, we þ }
     { þ using the previous value þ }
     If CNote<>0 Then ISS_SetSampleOffset(CChannel,ChSampleOffset * $100);

    End;
  End;
End;

{ þ Command : Process Volume Slide þ }
Procedure ProcVolumeSlide(VolToSlide : Word);
Var VolSlideUp : Byte;
    VolSlideDn : Byte;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     VolSlideUp:=(VolToSlide And $0F0) Shr 4;
     VolSlideDn:=VolToSlide And $00F;

     { þ Up & Downslide can't performed together, so we do nothing þ }
     { þ in this case þ }
     If (VolSlideUp>0) And (VolSlideDn>0) Then Exit;

     { þ Upslide? þ }
     If (VolSlideUp>0) Then Begin
       ChVolSlideData:=VolSlideUp;
      End;

     { þ Downslide? þ }
     If (VolSlideDn>0) Then Begin
       ChVolSlideData:=0-VolSlideDn;
      End;

    End;
  End;
End;

{ þ Command : Process Jump To Pattern þ }
Procedure ProcJump(OrderToJump : Word);
Begin
 With ISS_Player^ Do Begin
   With ISS_CurrentModule^ Do Begin
     If OrderToJump>MSongLength-1 Then OrderToJump:=MSongLength-1;
    End;
   NextRow:=0;
   NextOrder:=OrderToJump;
  End;
End;

{ þ Command : Process Set Volume þ }
Procedure ProcSetVolume(VolumeToSet : Word);
Begin
 With ISS_Player^ Do Begin
   Channels[CChannel].ChVolume:=VolumeToSet;
   ISS_SetVolume(CChannel,VolumeToSet);
  End;
End;

{ þ Command : Process Pattern Break þ }
Procedure ProcPatBreak(RowToBreak : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     NextRow:=(((RowToBreak And $0F0) Shr 4)*10)+(RowToBreak And $00F);
     If NextOrder=-1 Then NextOrder:=Order+1;

    End;
  End;
End;

{ þ Command : Process Portamento+VolumeSlide þ }
Procedure ProcPortVolSlide(VolToSlide : Word);
Begin
 ProcPortaNote(0);
 ProcVolumeSlide(VolToSlide);
End;

{ þ Command : Process Vibrato+VolumeSlide þ }
Procedure ProcVibVolSlide(VolToSlide : Word);
Begin
 ProcVibrato(0);
 ProcVolumeSlide(VolToSlide);
End;

{ þ Command : Process Set BPM þ }
Procedure ProcSetBPM(BPMToSet : Word);
Begin
 If BPMToSet=0 Then Exit;
 With ISS_Player^ Do Begin
   BPM   :=BPMToSet;
   BPMVal:=(1193180*5) Div (BPMToSet Shl 1);
  End;
End;

{ þ Command : Process Set Tempo/BPM þ }
Procedure ProcSetTempo_BPM(TempoToSet : Word);
Begin
 If TempoToSet>=$20 Then Begin ProcSetBPM(TempoToSet); Exit; End;
 ISS_Player^.Speed:=TempoToSet;
End;

{ þ Command : Process Set Global Volume þ }
Procedure ProcSetGlobalVolume(VolToSet : Word);
Begin
 If VolToSet>64 Then ISS_GlobalPlVolume:=64
                Else ISS_GlobalPlVolume:=VolToSet;
End;

{ þ Command : Process Global Volume Slide þ }
Procedure ProcGVolumeSlide(VolToSlide : Word);
Var VolSlideUp : Byte;
    VolSlideDn : Byte;
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin

     VolSlideUp:=(VolToSlide And $0F0) Shr 4;
     VolSlideDn:=VolToSlide And $00F;

     { þ Up & Downslide can't performed together, so we do nothing þ }
     { þ in this case þ }
     If (VolSlideUp>0) And (VolSlideDn>0) Then Exit;

     { þ Upslide? þ }
     If (VolSlideUp>0) Then Begin
       ChGVolSlideData:=VolSlideUp;
      End;

     { þ Downslide? þ }
     If (VolSlideDn>0) Then Begin
       ChGVolSlideData:=0-VolSlideDn;
      End;

    End;
  End;
End;

{ þ Command : Process Fine Volume Slide Up þ }
Procedure ProcFineVolSldUp(VolToAdd : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     Inc(ChVolume,VolToAdd);
     If ChVolume>64 Then ChVolume:=64;
     ISS_SetVolume(CChannel,ChVolume);
    End;
  End;
End;

{ þ Command : Process Fine Volume Slide Down þ }
Procedure ProcFineVolSldDn(VolToSub : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     If ChVolume<VolToSub Then ChVolume:=0
                          Else Dec(ChVolume,VolToSub);
     ISS_SetVolume(CChannel,ChVolume);
    End;
  End;
End;

{ þ Command : Cut Note þ }
Procedure ProcCutNote(TickUntilCut : Word);
Begin
 With ISS_Player^ Do Begin
   Channels[CChannel].ChFXTick:=TickUntilCut;
  End;
End;

{ þ Command : Note Delay þ }
Procedure ProcNoteDelay(TickUntilNote : Word);
Begin
 With ISS_Player^ Do Begin
   With Channels[CChannel] Do Begin
     If CNote<>0 Then Begin
       If TickUntilNote=0 Then ChFXTick:=Speed+1
                          Else ChFXTick:=TickUntilNote;
      End;
    End;
  End;
 DoNoteDelay;
End;

{ þ Process Tick Based Commands (NoteCut, etc) þ }
Procedure ProcTick(Parameter : Word);
Begin
 With ISS_Player^ Do Begin
   Channels[CChannel].ChFXTick:=Parameter;
   ISSPlay_DoFX(CFXType);
  End;
End;

{ þ >>> T H E  D U M M Y  P R O C E D U R E S <<< þ }

Procedure ProcDummy(Parameter : Word);
Begin
End;

Procedure DoDummy;
Begin
End;

{ þ >>> E F F E C T  P R O C E D U R E  T A B L E S <<< þ }

Type  TFXHandler = Record
        Proc : Procedure(FXParam : Word);
        Sust : Procedure;
       End;

Const { þ The processing table þ }
      FXProcs : Array[0..51] Of TFXHandler = (

 { þ Normal effects þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 00-0xx Arpeggio               !(MOD) þ }
 (Proc:@ProcPortaUp;        Sust:@DoPortaUp),         { þ 01-1xx Portamento Up           (MOD) þ }
 (Proc:@ProcPortaDown;      Sust:@DoPortaDown),       { þ 02-2xx Portamento Down         (MOD) þ }
 (Proc:@ProcPortaNote;      Sust:@DoPortaNote),       { þ 03-3xx Portamento to Note      (MOD) þ }
 (Proc:@ProcVibrato;        Sust:@DoVibrato),         { þ 04-4xy Vibrato                 (MOD) þ }
 (Proc:@ProcPortVolSlide;   Sust:@DoPortVolSlide),    { þ 05-5xy Portamento+Volume Slide (MOD) þ }
 (Proc:@ProcVibVolSlide;    Sust:@DoVibVolSlide),     { þ 06-6xy Vibrato+Volume Slide    (MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 07-7xy Tremolo                !(MOD) þ }
 (Proc:@ProcSetPanning;     Sust:@DoDummy),           { þ 08-8xx Set Panning ($0-$80)    (MOD/DMP) þ }
 (Proc:@ProcSetSampOffset;  Sust:@DoDummy),           { þ 09-9xx Set Sample Offset       (MOD) þ }
 (Proc:@ProcVolumeSlide;    Sust:@DoVolumeSlide),     { þ 10-Axy Volume Slide            (MOD) þ }
 (Proc:@ProcJump;           Sust:@DoDummy),           { þ 11-Bxx Jump to pattern         (MOD) þ }
 (Proc:@ProcSetVolume;      Sust:@DoDummy),           { þ 12-Cxx Set Volume              (MOD) þ }
 (Proc:@ProcPatBreak;       Sust:@DoDummy),           { þ 13-Dxx Pattern Break           (MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 14-Exy Extended Effects (36+x)       þ }
 (Proc:@ProcSetTempo_BPM;   Sust:@DoDummy),           { þ 15-Fxx Set Speed/Set BPM       (MOD) þ }
 (Proc:@ProcSetGlobalVolume;Sust:@DoDummy),           { þ 16-Gxx Set Global Volume       (S3M/XM) þ }
 (Proc:@ProcGVolumeSlide;   Sust:@DoGVolumeSlide),    { þ 17-Hxx Global Volume Slide     (XM)  þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 18-I                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 19-J                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 20-Kxx Key Off (after xx tick)!(XM)  þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 21-Lxx Set Envelope Pos       !(XM)  þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 22-M                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 23-N                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 24-O                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 25-Pxx Panning Slide          !(XM)  þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 26-Q                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 27-Rxy Multi Retrig Note      !(S3M) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 28-S                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 29-Txy Tremor                 !(STM) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 30-U                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 31-V                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 32-W                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 33-Xxy Extra Fine Portamento  !(S3M) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 31-Y                                 þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 32-Z                                 þ }
 { þ Extended effects þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 36-E0x Set AMiGA Filter       #(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 37-E1x Fine Portamento Up     !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 38-E1x Fine Portamento Down   !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 39-E3x Glissando Control      #(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 40-E4x Set Vibrato Waveform   !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 41-E5x Set Finetune           !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 42-E6x Pattern Loop           !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 43-E7x Set Tremolo WaveForm   !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 44-E8x Unused/Set Panning     !(MOD/S3M) þ }
 (Proc:@ProcTick;           Sust:@DoRetrig),          { þ 45-E9x Retrig Note             (MOD) þ }
 (Proc:@ProcFineVolSldUp;   Sust:@DoDummy),           { þ 46-EAx Fine Volume Slide Up    (MOD) þ }
 (Proc:@ProcFineVolSldDn;   Sust:@DoDummy),           { þ 47-EAx Fine Volume Slide Down  (MOD) þ }
 (Proc:@ProcCutNote;        Sust:@DoCutNote),         { þ 48-ECx Cut Note                (MOD) þ }
 (Proc:@ProcNoteDelay;      Sust:@DoNoteDelay),       { þ 49-EDx Delay Note              (MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),           { þ 50-EEx Pattern Delay          !(MOD) þ }
 (Proc:@ProcDummy;          Sust:@DoDummy));          { þ 51-EFx Invert Loop, Synchro   #(MOD) þ }

Const { þ The volume effect processing table þ }
      FXVolProcs : Array[0..10] Of TFXHandler = (

 (Proc:@ProcDummy;          Sust:@DoDummy),              { þ 0 - þ }
 (Proc:@ProcVVolumeSlide;   Sust:@DoVVolumeSlideDn),     { þ 1 - Volume Slide Down        þ }
 (Proc:@ProcVVolumeSlide;   Sust:@DoVVolumeSlideUp),     { þ 2 - Volume Slide Up          þ }
 (Proc:@ProcFineVolSldDn;   Sust:@DoDummy),              { þ 3 - Fine Volume Slide Down   þ }
 (Proc:@ProcFineVolSldUp;   Sust:@DoDummy),              { þ 4 - Fine Volume Slide Up     þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),              { þ 5 - Set vibrato speed      ! þ }
 (Proc:@ProcDummy;          Sust:@DoDummy),              { þ 6 - Vibrato                ! þ }
 (Proc:@ProcVSetPanning;    Sust:@DoDummy),              { þ 7 - Set Panning              þ }
 (Proc:@ProcVPanningSlide;  Sust:@DoVPanningSlideLeft),  { þ 8 - Panning Slide Left     ! þ }
 (Proc:@ProcVPanningSlide;  Sust:@DoVPanningSlideRight), { þ 9 - Panning Slide Right    ! þ }
 (Proc:@ProcDummy;          Sust:@DoDummy));             { þ A - Porta to Note          ! þ }

{ þ ISS_PLFX.PAS - (C) 1999-2001 Charlie/Inquisition þ }




