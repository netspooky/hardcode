{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 65520,0,655360}
USES gm_edgfx,Graph,Crt,Dos,KeyBoard,ModiGraf,PCXVModi;

TYPE tVersion=ARRAY[1..4]OF Char;
CONST AktVersion:tVersion='IMG2';
TYPE tHeader=RECORD
              Version:tVersion;
              XSize,YSize:LongInt;
            END;

CONST ImgDir='DATA';
      BackDir='..';

VAR X,Y:Byte;
    X1,X2,Y1,Y2:Byte;
    Image,I2,IT:ARRAY[0..19,0..19]OF Byte;
    IBuf:ARRAY[0..29]OF Byte;
    I,J,K,M:Integer;
    Ch:Char;
    Farbe:Byte;
    F:FILE OF Byte;
    Header:tHeadeR;
    Path:STRING;
    S:STRING;

PROCEDURE Rahmen;
  VAR I:Byte;
  BEGIN
    SetColor(15);
    FOR I:=0 TO 20 DO
      BEGIN
        Line(0,I*10,200,I*10);
        Line(I*10,0,I*10,200)
      END;
    RectAngle(399,9,420,30);
  END;

PROCEDURE DPalette;
  VAR I:Byte;
  BEGIN
    FOR I:=0 TO 255 DO
      BEGIN
        SetColor(I);
        RectAngle(I*2+10,400,I*2+11,420);
      END;
  END;

PROCEDURE Load(ST:STRING);
VAR I,J,B:Byte;
    F:FILE;
BEGIN
  ChDir(ImgDir);
  IF Pos('.',St)=0 THEN St:=St+'.img';
  Assign(F,St);
  {$I-}
  Reset(F,1);
  {$I+}
  IF IOResult=0 THEN WITH Header DO BEGIN
    BlockRead(F,Header,SizeOf(Header));
    FOR J:=0 TO YSize-1 DO
      FOR I:=0 TO XSize-1 DO BEGIN
        BlockRead(F,B,1);
        IF(J<20)AND(I<20) THEN Image[I,J]:=B;
      END;
    Close(F)
  END;
  ChDir(BackDir);
END;

PROCEDURE SaveAs(ST:STRING);
VAR I,J:Byte;
    F:FILE;
BEGIN
  ChDir(ImgDir);
  IF Pos('.',St)=0 THEN St:=St+'.img';
  Assign(F,St);
  Rewrite(F,1);
  Header.Version:=AktVersion;
  Header.XSize:=20;
  Header.YSize:=20;
{  Inc(Header.XSize);}
  BlockWrite(F,Header,SizeOf(Header));
  FOR J:=0 TO {19}Header.YSize-1 DO
    FOR I:=0 TO {19}Header.XSize-1 DO
      BlockWrite(F,Image[I,J],1);
  Close(F);
  ChDir(BackDir);
END;

PROCEDURE Fill(X,Y,C,F:LongInt);
BEGIN
  IF(X>=0)AND(X<=19)AND(Y>=0)AND(Y<=19)AND(Image[X,Y]=C)THEN BEGIN
    Image[X,Y]:=F;
    Fill(X-1,Y,C,F);
    Fill(X+1,Y,C,F);
    Fill(X,Y-1,C,F);
    Fill(X,Y+1,C,F);
  END;
END;

PROCEDURE InitDaGFX;
VAR T:TexT;
    Palette:PAL_ARRAY;
BEGIN
  grafikein;
  LoadPCX(tScreen(Ptr($A000,0)^),Palette,'DATA.SAV\0492.pcx',0);
  FillChar(Ptr($A000,0)^,64000,0);
  SetPalette(Palette);
  Rahmen;
  DPalette;
  SetColor(15);
  X:=0;
  Y:=0;
  Farbe:=0;
  RectAngle(Farbe*2+10,380,Farbe*2+11,395);
  RectAngle(Farbe*2+10,425,Farbe*2+11,440);
  SetColor(12);
  RectAngle(X*10,Y*10,X*10+10,Y*10+10);
  OutTextXY(400,100,'L            -> Load');
  OutTextXY(400,110,'S            -> Save');
  OutTextXY(400,120,'P            -> Spiegeln');
  OutTextXY(400,130,'Alt + Links  -> Links r…ken');
  OutTextXY(400,140,'Alt + Rechts -> Rechts r…ken');
  OutTextXY(400,150,'Alt + Oben   -> Oben r…ken');
  OutTextXY(400,160,'Alt + Unten  -> Unten r…ken');
  OutTextXY(400,180,'F            -> Fill Fl�che');
  OutTextXY(400,200,'N            -> Nimm Farbe');
  OutTextXY(400,220,'R            -> Rotieren');
END;

PROCEDURE DrawDir;
VAR SR:SearchRec;
    I,K,M:LongInt;
BEGIN
  ChDir(ImgDir);
  FindFirst('*.img',ANYFILE,SR);
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
  ChDir(BackDir);
END;

BEGIN
  InitDaGFX;
  FillChar(Image,20*20,0);
  Load(ParamStr(1));
  InitKeyBoard;
  REPEAT
    FOR J:=0 TO 19 DO
      FOR I:=0 TO 19 DO
        BEGIN
          SetFillStyle(SolidFill,Image[I,J]);
          SetColor(Image[I,J]);
          Bar(I*10+1,J*10+1,I*10+9,J*10+9);
          PutPixel(400+I,10+J,Image[I,J]);
        END;
    SetColor(0);
    RectAngle(Farbe*2+10,380,Farbe*2+11,395);
    RectAngle(Farbe*2+10,425,Farbe*2+11,440);
    IF KeyPr(78) THEN Inc(Farbe);
    IF KeyPr(74) THEN Dec(Farbe);
    IF KeyPr(49) THEN Farbe:=Image[X,Y];
    IF KeyPr(28) THEN
      BEGIN
        SetRGBPalette(0,255,0,0);
        REPEAT UNTIL KeyPr(28);
        SetRGBPalette(0,0,0,0)
      END;
    IF KeyPr(19) THEN BEGIN
      I2:=Image;
      FOR I:=0 TO 19 DO
        FOR J:=0 TO 19 DO
          Image[I,J]:=I2[J,19-I]
    END;
    IF KeyPr(25) THEN
      FOR I:=0 TO 9 DO
        FOR J:=0 TO 19 DO
          BEGIN
            K:=Image[I,J];
            Image[I,J]:=Image[19-I,J];
            Image[19-I,J]:=K
          END;
    SetColor(15);
    RectAngle(Farbe*2+10,380,Farbe*2+11,395);
    RectAngle(Farbe*2+10,425,Farbe*2+11,440);
    SetColor(0);
    SetFillStyle(SolidFill,0);
    Bar(400,85,424,93);
    SetColor(15);
    Str(Farbe,S);
    OutTextXY(400,85,S);
    SetColor(Farbe);
    SetFillStyle(SolidFill,Farbe);
    Bar(400,50,429,79);
    SetColor(15);
    RectAngle(X*10,Y*10,X*10+10,Y*10+10);
    IF Key[56] THEN BEGIN
      IF KeyPr(75) THEN BEGIN
        FOR I:=0 TO 19 DO IBuf[I]:=Image[0,I];
        FOR I:=0 TO 18 DO FOR K:=0 TO 19 DO Image[I,K]:=Image[I+1,K];
        FOR I:=0 TO 19 DO Image[19,I]:=IBuf[I];
      END;
      IF KeyPr(77) THEN BEGIN
        FOR I:=0 TO 19 DO IBuf[I]:=Image[19,I];
        FOR I:=19 DOWNTO 1 DO FOR K:=0 TO 19 DO Image[I,K]:=Image[I-1,K];
        FOR I:=0 TO 19 DO Image[0,I]:=IBuf[I];
      END;
      IF KeyPr(72) THEN BEGIN
        FOR I:=0 TO 19 DO IBuf[I]:=Image[I,0];
        FOR I:=0 TO 19 DO FOR K:=0 TO 18 DO Image[I,K]:=Image[I,K+1];
        FOR I:=0 TO 19 DO Image[I,19]:=IBuf[I];
      END;
      IF KeyPr(80) THEN BEGIN
        FOR I:=0 TO 19 DO IBuf[I]:=Image[I,19];
        FOR I:=0 TO 19 DO FOR K:=19 DOWNTO 1 DO Image[I,K]:=Image[I,K-1];
        FOR I:=0 TO 19 DO Image[I,0]:=IBuf[I];
      END;
    END ELSE BEGIN
      IF KeyPr(75) THEN Dec(X);
      IF KeyPr(77) THEN Inc(X);
      IF KeyPr(72) THEN Dec(Y);
      IF KeyPr(80) THEN Inc(Y);
    END;
    IF KeyPr(38) THEN BEGIN {Load}
      CloseGraph;
      DrawDir;
      DoneKeyBoard;
      Write('Was laden : ');
      ReadLn(Path);
      InitKeyBoard;
      Load(Path);
      InitDaGFX;
    END;
    IF KeyPr(31) THEN BEGIN {Save}
      CloseGraph;
      DrawDir;
      DoneKeyBoard;
      Write('Als was saven : ');
      ReadLn(Path);
      InitKeyBoard;
      SaveAs(Path);
      InitDaGFX;
    END;
    IF X=255 THEN X:=0;
    IF X=20 THEN X:=19;
    IF Y=255 THEN Y:=0;
    IF Y=20 THEN Y:=19;
    SetColor(12);
    RectAngle(X*10,Y*10,X*10+10,Y*10+10);
    IF Key[57] THEN Image[X,Y]:=Farbe;
    IF Key[14] THEN Image[X,Y]:=0;
    IF(KeyPr(33))AND(Farbe<>Image[X,Y])THEN Fill(X,Y,Image[X,Y],Farbe);
    IF(KeyPr(87))THEN IT:=Image;
    IF(KeyPr(88))THEN BEGIN
      FOR I:=0 TO 19 DO
        FOR K:=0 TO 19 DO
          IF IT[I,K]<>0 THEN Image[I,K]:=IT[I,K];
    END;
  UNTIL KeyPr(1);
  CloseGraph;
  DoneKeyBoard;
END.