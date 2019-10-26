UNIT MotEdit;
INTERFACE
USES MainDefs;
PROCEDURE MotionInsertFrame(VAR Motion:tMotion);
PROCEDURE MotionDelFrame(VAR Motion:tMotion);
PROCEDURE ResetPlayerMotion(Motion:tMotion);
PROCEDURE TestMotion(Motion:tMotion);
PROCEDURE DrawDir;
PROCEDURE SaveDaMotion(VAR Motion:tMotion);
PROCEDURE LoadDaMotion(VAR Motion:tMotion);
PROCEDURE Editor;
PROCEDURE StartEditor;
PROCEDURE TestSound;
IMPLEMENTATION

PROCEDURE MotionInsertFrame(VAR Motion:tMotion);
VAR TempMotion:tMotion;
    I,K,M:LongInt;
BEGIN
  WITH Motion DO BEGIN
    IF Len>=MaxParts THEN Exit;
    CreateMotion(TempMotion,Len,Speed);
    FOR I:=1 TO Len DO Move(Dat^[I],TempMotion.Dat^[I],SizeOf(tMotionPart));
    DelMotion(Motion);
    CreateMotion(Motion,TempMotion.Len+1,TempMotion.Speed);
    FOR I:=1 TO Len-1 DO Move(TempMotion.Dat^[I],Dat^[I],SizeOf(tMotionPart));
    Move(TempMotion.Dat^[Len-1],Dat^[Len],SizeOf(tMotionPart));
    DelMotion(TempMotion);
  END;
END;

PROCEDURE MotionDelFrame(VAR Motion:tMotion);
VAR TempMotion:tMotion;
    I,K,M:LongInt;
BEGIN
  WITH Motion DO BEGIN
    IF Len<=1 THEN Exit;
    CreateMotion(TempMotion,Len,Speed);
    FOR I:=1 TO Len DO Move(Dat^[I],TempMotion.Dat^[I],SizeOf(tMotionPart));
    DelMotion(Motion);
    CreateMotion(Motion,TempMotion.Len-1,TempMotion.Speed);
    FOR I:=1 TO Len DO Move(TempMotion.Dat^[I],Dat^[I],SizeOf(tMotionPart));
    DelMotion(TempMotion);
  END;
END;

PROCEDURE ResetPlayerMotion(Motion:tMotion);
VAR I:LongInt;
BEGIN
  WITH Pl[1] DO BEGIN
    Ak:=0;
    AkCnt:=Motion.Speed*(Motion.Len-1)-1;
    Dir:=1;
    Wink:=0;
    FOR I:=0 TO 6 DO WITH Gl[I] DO BEGIN
      XS:=0;
      YS:=0;
      XX:=160+Motion.Dat^[1].Gl[I,1];
      YY:=100+Motion.Dat^[1].Gl[I,2];
    END;
  END;
END;

PROCEDURE TestMotion(Motion:tMotion);
VAR I,K,M,OldTick,ATick:LongInt;
BEGIN
  WITH Motion DO BEGIN
    CreateMotion(AMotion[0],Len,Speed);
    FOR I:=1 TO Len DO Move(Dat^[I],AMotion[0].Dat^[I],SizeOf(tMotionPart));
  END;
  ResetPlayerMotion(Motion);
  Tick:=OrigTick DIV 5;
  Atick:=Tick;
  WITH Pl[1] DO BEGIN
    REPEAT
      OldTick:=ATick;
      Tick:=OrigTick DIV 5;
      ATick:=Tick;
      FillChar(Scrp^,64000,0);
      FOR I:=1 TO ATick-OldTick DO BEGIN
        CalcPlayer(1,100);
        ControlPlayer(Pl[1],False,False,False,False,False,False,1);
        IF Ak<>0 THEN BEGIN
          ResetPlayerMotion(Motion);
          Ak:=0;
          AkCnt:=Motion.Speed*(Motion.Len-1)-1;
        END;
      END;
      DrawPlayer(Pl[1]);
      Move(Scrp^,Screen^,64000);
    UNTIL (KeyPr(1))OR(KeyPr(28));
  END;
  DelMotion(AMotion[0]);
END;

PROCEDURE DrawDir;
VAR SR:SearchRec;
    I,K,M:LongInt;
BEGIN
  FindFirst('*.Mot',ANYFILE,SR);
  I:=3;
  K:=0;
  WHILE(DosError=0)AND(K<>4) DO BEGIN
    GotoXY(K*15+1,I);
    Write(SR.Name);
    Inc(I);
    IF I=23 THEN BEGIN
      I:=3;
      Inc(K);
    END;
    FindNext(SR);
  END;
  GotoXY(1,1);
END;


PROCEDURE SaveDaMotion(VAR Motion:tMotion);
VAR FName:STRING;
BEGIN
  TextMode(3);
  ChDir('DATA');
  DoneKeyBoard;
  DrawDir;
  REPEAT
    WriteLn('<- SAVE Motion ->');
    Write('Filename (8Bst ohne .mot) : ');
    ReadLn(FName);
  UNTIL (Pos('.',FName)=0)AND(Length(FName)>0)AND(Length(FName)<9);
  SaveMotion(Motion,FName+'.mot');
  InitKeyBoard;
  Init(19);
  SetPalette(Palette);
  ChDir('..');
END;

PROCEDURE LoadDaMotion(VAR Motion:tMotion);
VAR FName:STRING;
BEGIN
  TextMode(3);
  ChDir('DATA');
  DoneKeyBoard;
  DrawDir;
  REPEAT
    WriteLn('<- LOAD Motion ->');
    Write('Filename (8Bst ohne .mot) : ');
    ReadLn(FName);
  UNTIL (Pos('.',FName)=0)AND(Length(FName)>0)AND(Length(FName)<9);
  LoadMotion(Motion,FName+'.mot');
  InitKeyBoard;
  Init(19);
  SetPalette(Palette);
  ChDir('..');
END;

PROCEDURE Editor;
VAR Motion:tMotion;
    AkGl,AkMot,I,K,M,AX,AY,XN,YN:LongInt;
    OldTick,ATick:LongInt;
BEGIN
{  CreateMotion(Motion,1,MinMotionSpeed);
  Motion.Dat^[1].Gl:=StandardMotion;
  Motion.Dat^[1].Rot:=0;}
  Motion.Dat:=NIL;
  LoadMotion(Motion,'DATA\'+DefMotLoad+'.MOT');
  AkMot:=1;
  AkGl:=1;
  Tick:=OrigTick DIV 5;
  ATick:=Tick;
  WITH Motion DO
  REPEAT
    OldTick:=ATick;
    Tick:=OrigTick DIV 5;
    ATick:=Tick;
    FillChar(Scrp^,64000,0);
    FOR I:=1 TO 6 DO BEGIN
      AX:=Dat^[AkMot].Gl[I,1];
      AY:=Dat^[AkMot].Gl[I,2];
      XN:=(AX*Sinus[Dat^[AkMot].Rot+90]-AY*Sinus[Dat^[AkMot].Rot]) DIV Gen;
      YN:=(AY*Sinus[Dat^[AkMot].Rot+90]+AX*Sinus[Dat^[AkMot].Rot]) DIV Gen;
      IF I=6 THEN M:=(360+90-Dat^[AkMot].Rot)MOD 360
             ELSE M:=GlRot(XN,YN,Dat^[AkMot].Gl[0,1],Dat^[AkMot].Gl[0,2],I);
      PutTSpr(160+XN,100+YN,Pl[1].Spr[GetCorrSpr(I),1]^,M+GLOff[I],31);
    END;
    AX:=Dat^[AkMot].Gl[AkGl,1];
    AY:=Dat^[AkMot].Gl[AkGl,2];
    XN:=(AX*Sinus[Dat^[AkMot].Rot+90]-AY*Sinus[Dat^[AkMot].Rot]) DIV Gen;
    YN:=(AY*Sinus[Dat^[AkMot].Rot+90]+AX*Sinus[Dat^[AkMot].Rot]) DIV Gen;
    FillChar(Scrp^[(100+YN-1)*320+160+XN-1],3,15);
    FOR I:=-1 TO 1 DO BEGIN
      Scrp^[(100+YN+I)*320+160+XN-1]:=15;
      Scrp^[(100+YN+I)*320+160+XN+1]:=15;
    END;
    FillChar(Scrp^[(100+YN+1)*320+160+XN-1],3,15);

    BufText(Scrp^,0,0,'Frame '+ToStr(AkMot)+'/'+ToStr(Len)+'          Speed '+ToStr(Speed));
    BufText(Scrp^,0,160,'PgDn       F2                              PgUp');
    BufText(Scrp^,0,180,'Prev       Save                              Next');
    Move(Scrp^,Screen^,64000);
    FOR I:=1 TO ATick-OldTick DO BEGIN
      IF KeyPr(15) THEN IF AkGl=6 THEN AkGl:=1 ELSE Inc(AkGl);
      IF KeyPr(82) THEN MotionInsertFrame(Motion);
      IF KeyPr(83) THEN MotionDelFrame(Motion);
      IF(KeyPr(73))AND(AkMot<Len)THEN Inc(AkMot);
      IF(KeyPr(81))AND(AkMot>1)THEN Dec(AkMot);
      IF(KeyPr(28))THEN TestMotion(Motion);
      IF(KeyPr(60))THEN SaveDaMotion(Motion);
      IF(KeyPr(61))THEN LoadDaMotion(Motion);
      IF Key[72] THEN Dec(Dat^[AkMot].Gl[AkGl,2]);
      IF Key[80] THEN Inc(Dat^[AkMot].Gl[AkGl,2]);
      IF Key[75] THEN Dec(Dat^[AkMot].Gl[AkGl,1]);
      IF Key[77] THEN Inc(Dat^[AkMot].Gl[AkGl,1]);
      IF Key[78] THEN IF Speed+MotionSpeedStep<MaxMotionSpeed THEN Inc(Speed,MotionSpeedStep) ELSE Speed:=MaxMotionSpeed;
      IF Key[74] THEN IF Speed-MotionSpeedStep>MinMotionSpeed THEN Dec(Speed,MotionSpeedStep) ELSE Speed:=MinMotionSpeed;
      IF Key[53] THEN IF Dat^[AkMot].Rot<360 THEN Inc(Dat^[AkMot].Rot) ELSE Dat^[AkMot].Rot:=0;
      IF Key[55] THEN IF Dat^[AkMot].Rot>0 THEN Dec(Dat^[AkMot].Rot) ELSE Dat^[AkMot].Rot:=359;
    END;
    IF AkMot<1 THEN AkMot:=1;
    IF AkMot>Len THEN AkMot:=LEn;
  UNTIL KeyPr(1);
END;

PROCEDURE StartEditor;
BEGIN
  Players:=_CompPlayers_+_HumPlayers_;
  StartUpGame;
  Editor;{}
  UnloadGame;
END;

PROCEDURE TestSound;
VAR SNr,SNote,SLen,I,K,M:LongInt;
    NStep:LongInt;
    Ch:Char;
BEGIN
  SaveScreen;
  TextBackGround(0);
  TextColor(15);
  ClrScr;
  SNr:=0;
  SNote:=64;
  SLen:=100;
  NStep:=10;
  REPEAT
    GotoXY(1,2);
    ClrEol;
    Write('(',SNr,') ','  Note : ',SNote,'  Length : ',SLen);
    Ch:=UpCase(ReadKey);
    CASE Ch OF
      'Q':IF SNr<127 THEN Inc(SNr) ELSE SNr:=0;
      'A':IF SNr>0 THEN Dec(SNr) ELSE SNr:=127;
      'W':IF SNote+NStep<=127 THEN Inc(SNote,NStep);
      'S':IF SNote-NStep>=0 THEN Dec(SNote,NStep);
      #13:BEGIN
            GotoXY(1,3);
            ClrEol;
            Write('Playing ... ');
            SetProgram(1,SNr);
            SetNoteOn(1,SNote,127);
            Delay(500);
            SetNoteOff(1,SNote,0);
            WriteLn('Done');
          END;
    END;
  UNTIL Ch=#27;
  LoadSavedScreen;
END;
BEGIN
END.