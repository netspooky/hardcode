{  Masodik Djermekkor   }
{  Ultraminimal Style Takeover  }
{  Hatvannegykaintro for Flag $07D1  }

{  (C):Bluebox Cinematique Gmbh.  }
{  Ez itt ilyen publikus domain meg source, oruljetek.  }

{  LICENSZ: Ha felhaszalod valahol eme termeket, hat ugy kell neked!  }
{  MOTTO: A pascal nem programozasi nyelv! /Arpi^Astral/  }

{ DEFINE _DEBUGMODE_}
{$IFNDEF FPC}
 Micsinalsz vazgert, Freepaszkal kell!!!
{$ENDIF}
{$ASMMODE INTEL}
{$MODE FPC}
Program _2ndChild;

Uses Crt,GO32,ISS_Play,ISS_Sys,ISS_Load,ISS_Var,ISS_Tim
     {$IFDEF _DEBUGMODE_}
     ,LineInfo,HeapTrc
     {$ENDIF}
     ;

Type T3DVertex = Record
       X       : Single;
       Y       : Single;
       Z       : Single;
      End;

Const Kocka : Array[0..7] Of T3DVertex = (
       (X:-30; Y:-30; Z:-30), {alul-elol-baloldalt}
       (X:30;  Y:-30; Z:-30), {alul-elol-jobboldalt}
       (X:30;  Y:-30; Z: 30), {alul-hatul-jobboldalt}
       (X:-30; Y:-30; Z: 30), {alul-hatul-baloldalt}
       (X:-30; Y: 30; Z:-30), {felul-elol-baloldalt}
       (X:30;  Y: 30; Z:-30), {felul-elol-jobboldalt}
       (X:30;  Y: 30; Z: 30), {felul-hatul-jobboldalt}
       (X:-30; Y: 30; Z: 30));{felul-hatul-baloldalt}

      { korbe-korbe-mindenhol}
      Oldalak : Array[0..11,0..2] Of Byte = (
       (0,1,2),(0,2,3),(0,4,5),(0,5,1),(1,5,6),(1,6,2),
       (2,6,7),(2,7,3),(3,7,4),(3,4,0),(4,7,6),(4,6,5));

{$INCLUDE 2NDPOLY.PAS}
{$INCLUDE 2NDZAX.PAS}
{$INCLUDE 2NDPIC.PAS}

Var Music     : ISS_PModule;
    ExitAllow : Boolean;
    VirtScr   : Pointer;
    Transformedkocka : Array[0..7] Of T3DVertex;
    Transformedkocka2d : Array[0..7] Of TPoint;
    CubeSize  : Single;

    Eltolas   : ShortInt;
    DEltolas  : ShortInt;
    teglalaptajmer : pointer;
    kockatajmer    : pointer;
    delaypotlek    : pointer; { :) ISS rulez :) }
    delaycounter   : dword;
    P1,P2,P3   : TPoint;
    Karakterek : Array[0..2047] Of Byte;

    {  EGK gorbek, vagy mi, ilyen tablazatba  }
    Sinus   : Array[-720..720] Of Single;
    Cosinus : Array[-720..720] Of Single;

    XCenter : Integer;
    YCenter : Integer;
    ZCenter : Integer;

    XRot    : Integer;
    YRot    : Integer;
    ZRot    : Integer;
    XRotT   : Integer;
    YRotT   : Integer;
    ZRotT   : Integer;
    DX,DY,DZ : ShortInt;
    CurrentRotVal : Byte;
    PrevOrder : Byte;
    PrevInstr : Byte;
    KepCounter : DWord;

{  Tajmerek bazz  }
Procedure teglalapokoldalt;
Begin
 Inc(Eltolas,DEltolas);
 If DEltolas>0 Then Begin If Eltolas>=0 Then Eltolas:=-8; End
               Else Begin If Eltolas<-8 Then Eltolas:=-1; End;
 If KepCounter<>0 Then Dec(KepCounter);
End;
Procedure kockaforgas;
Begin
 Case CurrentRotVal Of
   1 : Inc(XRotT,DX*2);
   2 : Inc(YRotT,DY*2);
   3 : Inc(ZRotT,DZ*2);
  End;
 Inc(XRotT,DX);
 Inc(YRotT,DY);
 Inc(ZRotT,DZ);
 If (XRotT>720)  Then Dec(XRotT,720);
 If (XRotT<-720) Then Inc(XRotT,720);
 If (YRotT>720)  Then Dec(YRotT,720);
 If (YRotT<-720) Then Inc(YRotT,720);
 If (ZRotT>720)  Then Dec(ZRotT,720);
 If (ZRotT<-720) Then Inc(ZRotT,720);
End;

procedure potdelay;
Begin
 Inc(DelayCounter);
end;

Procedure PutImage64(X,Y : DWord; Kep : Pointer); Assembler;
Asm
 MOV ESI,Kep
 MOV EAX,320
 MUL Y
 ADD EAX,X
 MOV EDI,VirtScr
 ADD EDI,EAX
 MOV EDX,64
 @LoopHead:
  MOV ECX,64
  @LoopHead2:
   MOV AL,[ESI]
   CMP AL,0
   JE  @NoPixel
    ADD AL,32
    MOV [EDI],AL
   @NoPixel:
   INC EDI
   INC ESI
   DEC ECX
  JNZ @LoopHead2
  ADD EDI,320-64
  DEC EDX
 JNZ @LoopHead
End;

Function Rad(I : Integer) : Single;
Begin
 Rad := I * (Pi / 360);
End;

Procedure GenerateSinCosTable;
Var Counter : Integer;
Begin
 For Counter:=-720 To 720 Do
  Begin
   Sinus  [Counter]:=Sin(Rad(Counter));
   Cosinus[Counter]:=Cos(Rad(Counter));
  End;
End;

Procedure Perspective(Vertex3D : T3DVertex; Var XReal,YReal : Integer);
Begin
 With Vertex3D Do
  Begin
   XReal:=Round((XCenter * Z - X * ZCenter) / (Z - ZCenter));
   YReal:=Round((YCenter * Z - Y * ZCenter) / (Z - ZCenter));
  End;
End;

Procedure RotateVertex(    Vertex3D : T3DVertex;
                       Var RotVer3D : T3DVertex;
                       XAngle,YAngle,ZAngle  : Integer);
Var X,Y,Z    : Single;
    X1,Y1,Z1 : Single;
Begin
 X:=Vertex3D.X; Y:=Vertex3D.Y; Z:=Vertex3D.Z;

         X1 := Cosinus[YAngle] * X  - Sinus  [YAngle] * Z;
         Z1 := Sinus  [YAngle] * X  + Cosinus[YAngle] * Z;
 RotVer3D.X := Cosinus[ZAngle] * X1 + Sinus  [ZAngle] * Y;
         Y1 := Cosinus[ZAngle] * Y  - Sinus  [ZAngle] * X1;
 RotVer3D.Z := Cosinus[XAngle] * Z1 - Sinus  [XAngle] * Y1;
 RotVer3D.Y := Sinus  [XAngle] * Z1 + Cosinus[XAngle] * Y1;
End;

Procedure RenderKocka;
Var Counter : DWord;
    BufX, BufY : Integer;
Begin
 XRot:=XRotT; YRot:=YRotT; ZRot:=ZRotT;
 For Counter:=0 To 7 Do Begin
   RotateVertex(Kocka[Counter],Transformedkocka[Counter],XRot,YRot,ZRot);
  End;
 For Counter:=0 To 7 Do Begin
   Perspective(Transformedkocka[Counter],BufX,BufY);
   Transformedkocka2d[Counter].XP:=(BufX*CubeSize)+140;
   Transformedkocka2d[Counter].YP:=(BufY*CubeSize)+100;
   Transformedkocka2d[Counter].Z:=Transformedkocka[Counter].Z;
  End;

 For Counter:=0 To 11 Do Begin
   P1:=TransformedKocka2D[Oldalak[Counter,0]];
   P2:=TransformedKocka2D[Oldalak[Counter,1]];
   P3:=TransformedKocka2D[Oldalak[Counter,2]];
   PoliFiller(@P1,@P3,@P2,4+(Counter Shr 1),VirtScr);
  End;

End;

Procedure RenderBlueBox;
Var Counter : DWord;
    BufX, BufY : Integer;
Begin
 XRot:=45; YRot:=60; ZRot:=45;
 For Counter:=0 To 7 Do Begin
   RotateVertex(Kocka[Counter],Transformedkocka[Counter],XRot,YRot,ZRot);
  End;
 For Counter:=0 To 7 Do Begin
   Perspective(Transformedkocka[Counter],BufX,BufY);
   Transformedkocka2d[Counter].XP:=(BufX*0.7)+40;
   Transformedkocka2d[Counter].YP:=(BufY*0.7)+150;
   Transformedkocka2d[Counter].Z:=Transformedkocka[Counter].Z;
  End;

 For Counter:=0 To 11 Do Begin
   P1:=TransformedKocka2D[Oldalak[Counter,0]];
   P2:=TransformedKocka2D[Oldalak[Counter,1]];
   P3:=TransformedKocka2D[Oldalak[Counter,2]];
   PoliFiller(@P1,@P3,@P2,4+(Counter Shr 1),VirtScr);
  End;

End;

Procedure OwnDelay(WaitCount : DWord);
Begin
 DelayCounter:=0;
 Repeat Until DelayCounter>=WaitCount;
End;

Procedure InitVGA; Assembler;
Asm
 MOV AX,13h
 INT 10h
End;

Procedure VideoCopy; Assembler;
Asm
 MOV ECX,16000
 MOV ESI,VirtScr
 MOV EDI,$A0000
 @LoopHead:
  MOV EAX,[ESI]
  MOV GS:[EDI],EAX
  ADD ESI,4
  ADD EDI,4
  DEC ECX
 JNZ @LoopHead
End ['EAX','ESI','EDI','ECX'];

Procedure SetRGBPalette(Color : Byte; R,G,B : Byte); Assembler;
Asm
 MOV DX,$03C8; MOV AL,Color; OUT DX,AL; INC DX
 MOV AL,R; OUT DX,AL
 MOV AL,G; OUT DX,AL
 MOV AL,B; OUT DX,AL
End;

Procedure SetPalette;
Var Counter : DWord;
Begin
 SetRGBPalette(0,0,0,0);
 SetRGBPalette(1,63,31,63);
 SetRGBPalette(2,31,31,63);
 SetRGBPalette(3,63,31,63);

 {  Kocka  }
 SetRGBPalette(4,54,16,47);
 SetRGBPalette(5,40,16,47);
 SetRGBPalette(6,47,16,47);
 SetRGBPalette(7,40,16,47);
 SetRGBPalette(8,47,16,47);
 SetRGBPalette(9,54,16,47);

 {  Reklis tata  }
 For Counter:=0 To 192 Do Begin
   SetRGBPalette(32+Counter,KepPaletta[3*Counter] Shr 2,
                            KepPaletta[3*Counter+1] Shr 2,
                            KepPaletta[3*Counter+2] Shr 2);
  End;

 SetRGBPalette(255,63,63,63);
End;

Procedure HLine(X1,X2,Y,Color : DWord); Assembler;
Asm
 MOV EAX,320
 MUL Y
 ADD EAX,X1
 MOV EDI,VirtScr
 ADD EDI,EAX
 MOV ECX,X2
 SUB ECX,X1
 ADD ECX,1
 JZ  @Exit
 MOV EAX,Color
 REP STOSB
 @Exit:
End;

Procedure HLineAdd(X1,X2,Y : LongInt); Assembler;
Asm
 CMP Y,0
 JB  @Exit
 CMP Y,200
 JAE @Exit
 MOV EAX,320
 MUL Y
 ADD EAX,X1
 MOV EDI,VirtScr
 ADD EDI,EAX
 MOV ECX,X2
 SUB ECX,X1
 JZ  @Exit
 @LoopHead:
  MOV AL,[EDI]
  ADD AL,$01
  MOV [EDI],AL
  ADD EDI,1
  DEC ECX
 JNZ @LoopHead
 @Exit:
End;

Procedure DrawBackGround;
Var Counter : Word;
Begin
 Asm
  MOV EDI,VirtScr
  MOV ECX,16000
  MOV EAX,$01010101;
  REP STOSD
 End;
 For Counter:=0 To 69 Do Begin
   HLine(319-Counter,319,130+Counter,2);
  End;
End;

Procedure DrawFuggolegesTeglalapok;
Var Counter : Integer;
Begin
 For Counter:=0 To 207 Do Begin
   If ((Counter Mod 8)>3) Then Begin
     HLineAdd(270,310,Counter+Eltolas);
    End;
  End;
End;

Procedure GetBIOSFont;
Var Regs : TRealRegs;
Begin
 With Regs Do Begin
   AX:=$1130;
   BX:=$0300;
   RealIntr($10,Regs);
   DOSMemGet(ES,BP,Karakterek,2048);
  End;
End;

Procedure WriteXY(X,Y : DWord; Szoveg : String);
Var Counter,Counter2 : DWord;
    BufByte      : Byte;
    BytePtr      : Pointer;
    DrwBeginAddr : DWord;
Begin
 DrwBeginAddr:=Y*320+X;
 For Counter:=1 To Length(Szoveg) Do Begin
   BytePtr:=@Karakterek;
   Inc(DWord(BytePtr),Byte(Szoveg[Counter])*8);
   For Counter2:=0 To 7 Do Begin
     Asm
      MOV ESI,BytePtr
      MOV AL,[ESI]
      MOV EDI,VirtScr
      ADD EDI,DrwBeginAddr
      MOV ECX,8
      @DrawLoop:
       SHL AL,1
       JNC @NoPixel
        MOV BYTE PTR [EDI],$FF
       @NoPixel:
       INC EDI
      LOOP @DrawLoop
     End;
     Inc(DrwBeginAddr,320);
     Inc(DWord(BytePtr));
    End;
   Dec(DrwBeginAddr,(320*8)-8);
  End;
End;

Procedure BlueBoxMarketing;
Begin

 OwnDelay(303*2);

 SetRGBPalette(4,08,08,54);
 SetRGBPalette(5,08,08,24);
 SetRGBPalette(6,08,08,40);
 SetRGBPalette(7,08,08,24);
 SetRGBPalette(8,08,08,40);
 SetRGBPalette(9,08,08,54);

 ClearZBuffer;
 RenderBlueBox;

 WriteXY(84,150,'BLUEBOX CINEMATIQUE GMBH');
 WriteXY(84,160,'2001');
 VideoCopy;

 OwnDelay(303*5);

 FillChar(VirtScr^,64000,#0);
 VideoCopy;

 OwnDelay(303*1);
End;

Begin
 CubeSize:=1.5;
 GetBIOSFont;
 XRotT :=0;
 YRotT :=0;
 ZRotT :=0;
 PrevOrder:=$FF;
 PrevInstr:=$FF;
 KepCounter:=0;
 DX:=2;
 DY:=1;
 DZ:=1;

 XCenter:=0;    XRot:=0;
 YCenter:=0;    YRot:=0;
 ZCenter:=150;  ZRot:=0;
 CurrentRotVal:=0;

 GenerateSinCosTable;

 { "A modplayer szar, de mentsegunkre legyen mondva, hogy loptuk" }
 ISS_InitSystem;
 ISS_AutoSetup;

 ISS_Init;

 ExitAllow:=False;

 If Not ISS_LoadInternalModule(@Zene,Music) Then Begin
   WriteLn('Whoops executable damaged?');
   Halt;
  End;

 { þ Kep bekapcs þ }
 GetMem(VirtScr,64000);
 FillChar(VirtScr^,64000,#0);
 InitVGA;
 SetPalette;

 teglalaptajmer:=@teglalapokoldalt;
 ISS_StartTimer(teglalaptajmer,(ISS_TimerSpeed Div 50));
 kockatajmer:=@kockaforgas;
 ISS_StartTimer(kockatajmer,(ISS_TimerSpeed Div 140));
 delaypotlek:=@potdelay;
 ISS_StartTimer(delaypotlek,(ISS_TimerSpeed Div 303));

 BlueBoxMarketing;

 SetPalette;

 Eltolas:=-8;
 DEltolas:=-1;

 ISS_InitModulePlay(Music);
 ISS_StartModulePlay; {  Mjuzik indul  }
 Repeat

  ClearZBuffer;
  DrawBackGround;
  DrawFuggolegesTeglalapok; { effekt bazmeg! }

  If KepCounter<>0 Then Begin
    PutImage64(5,5,@AKep);
   End;

  RenderKocka; { 3D motor alkalmazasa a szoftverben }

  With ISS_Player^ Do Begin

    {  Ez itt a state-of-art text idozites a zenere bazgert  }

    Case Order Of
      0 : Begin
            If (Row>$10) And (Row<$21) Then WriteXY(124, 86,'CUBE');
            If (Row>$20) And (Row<$31) Then WriteXY(132, 96,'IS');
            If Row>$30 Then WriteXY(124,106,'COOL');
           End;
      1 : Begin
            If (Row>$10) And (Row<$21) Then WriteXY(124, 86,'PLAY');
            If (Row>$20) And (Row<$31) Then WriteXY(124,106,'WITH');
            If (Row>$30) Then WriteXY(108,96,'THE CUBE');
           End;
      2 : Begin
            If (Row>$10) And (Row<$21) Then WriteXY(124, 86,'LIVE');
            If (Row>$20) And (Row<$31) Then WriteXY(124,106,'YOUR');
            If Row>$30 Then WriteXY( 76,96,'SECOND CHILDHOOD');
           End;
      4 : Begin
            If Row>$10 Then WriteXY(108, 86,'PRODUCED');
            If Row>$20 Then WriteXY(132, 96,'BY');
            If Row>$30 Then WriteXY(104,106,'SPIELBERG');
           End;
      5 : Begin
            If Row>$10 Then WriteXY(120, 86,'MUSIC');
            If Row>$20 Then WriteXY(132, 96,'BY');
            If Row>$30 Then WriteXY(104,106,'MORRICONE');
           End;
      7 : Begin
            If (Row>$10) And (Row<$21) Then WriteXY(112,106,'MINIMAL');
            If (Row>$20) And (Row<$31) Then WriteXY(120, 86,'STYLE');
            If Row>$30 Then WriteXY(108,96,'TAKEOVER');
           End;
      8 : Begin
            If Row>$10 Then WriteXY(132, 86,'BE');
            If Row>$20 Then WriteXY(120, 96,'CHILD');
            If Row>$30 Then WriteXY(120,106,'AGAIN');
           End;
      9 : Begin
            If Row>$10 Then WriteXY(124, 86,'TAKE');
            If Row>$20 Then WriteXY(108, 96,'THE LIFE');
            If Row>$30 Then WriteXY(124,106,'EASY');
           End;
     10 : Begin
            If Row>$10 Then WriteXY( 84, 86,'YOUR SOUL WILL');
            If Row>$20 Then WriteXY( 84, 96,'GIVE DIRECTION');
            If Row>$30 Then WriteXY( 88,106,'TO FIND PEACE');
           End;

     12 : Begin
            If Row>$10 Then WriteXY(112, 86,'AND NOW');
            If Row>$20 Then WriteXY( 96, 96,'WE WISH YOU');
            If Row>$30 Then WriteXY( 92,106,'SWEET DREAMS');
           End;
     End;

    If Order<>PrevOrder Then Begin
      DEltolas:=-DEltolas;
      DX:=-DX;
      DY:=-DY;
      DZ:=-DZ;
      CurrentRotVal:=0;
      PrevOrder:=Order;
     End;

    With Channels[10] Do Begin
      If (PrevInstr<>ChInstr) Then Begin
        If ChInstr=8 Then Begin
          DX:=-DX;
          DY:=-DY;
          DZ:=-DZ;
          KepCounter:=20;
         End;
        PrevInstr:=ChInstr;
       End;
     End;
   End;

  VideoCopy; { Kopi kepbuffer  }
  With ISS_Player^ Do Begin
    ExitAllow:=((Order=$0C) And (Row>$3C));
   End;
  If KeyPressed Then ExitAllow:=True;
 Until ExitAllow;  {  Kilepesre varunk }

 ISS_StopModulePlay; { Player alljmeghovamesz }
 ISS_DoneModulePlay;
 ISS_FreeModule(Music);
 ISS_Done;

 FillChar(VirtScr^,64000,#0);
 WriteXY(112, 86,'AND NOW');
 WriteXY( 96, 96,'WE WISH YOU');
 WriteXY( 92,106,'SWEET DREAMS');
 VideoCopy;
 OwnDelay(303*2);
 FillChar(VirtScr^,64000,#0);
 VideoCopy;
 OwnDelay(303*1);
 WriteXY( 48, 80,'THIS PRODUCTION PRESENTED AT');
 WriteXY(124, 98,'FLAG 2001');
 WriteXY( 32,120,'THE INTERNATIONAL SLEEPING EVENT');
 WriteXY( 84,130,'NO DEMOSHOW ALLOWED');
 VideoCopy;
 OwnDelay(303*6);
 FillChar(VirtScr^,64000,#0);
 VideoCopy;
 OwnDelay(303*1);

 ISS_StopTimer(teglalaptajmer);
 ISS_StopTimer(kockatajmer);
 ISS_StopTimer(delaypotlek);

 TextMode(CO80); { Kep kikapcs }
 WriteLn(#13,#10,' Bluebox:Second Childhood');
 WriteLn(' Flag2001 - Who needs demoscene anyway?'); { Tomket kabbe. }
 WriteLn(' No Window$, no demo..? :('); { Elmondjuk a velemenyunk jol. }
 Freemem(VirtScr,64000);

 While Keypressed Do Readkey;
End.
{ Signed: Spielberg/Bluebox, de ugyis letagadom }
