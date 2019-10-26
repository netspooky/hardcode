{$A+,B-,D+,E+,F-,G+,I+,L+,N-,O-,P-,Q-,R-,S+,T-,V+,X+,Y+}
{$M 65500,0,655360}
USES Crt,Dos,ModiGraf,PCXVModi,Keyboard;
CONST StandardLoad='level4';
TYPE tVersion=ARRAY[1..4]OF Char;
CONST AktVersion:tVersion='IMG2';
TYPE tIMGHeader=RECORD
                  Version:tVersion;
                  XSize,YSize:LongInt;
                END;
CONST MaxLX=160;
      MaxLY=100;
      _MMX=100;
      _MMY=100;
      MusterAnz=55*4;
      MapOn:Boolean=False;
      MaxSprX=320;
      MaxSprY=200;
      MaxObjekte=100;
      ObjSprs=30;
      ObjSprName:ARRAY[1..ObjSprs]OF STRING=('KGENR',
                                             'KUGEL',
                                             'KGENL',
                                             'FGENL',
                                             'FGENR',
                                             'FEUER2',
                                             'ENGEL1',
                                             'SPIKER',
                                             'PAD',
                                             'Bridge',
                                             'Box',
                                             'bazzooka',
                                             'minigun',
                                             'shot1',
                                             'bumper',
                                             'start',
                                             'khead',
                                             'Medi',
                                             'sm_head',
                                             'sm_foot',
                                             'ballblas',
                                             'ende',
                                             'leben',
                                             'kugel',
                                             'rocket',
                                             'ma_head',
                                             'so_head',
                                             'ak_head',
                                             'urm_Head',
                                             'ballblas'
                                            );
      LESprs=4;
      LESprName:ARRAY[1..LESprs]OF STRING=('GRNDLIST',
                                           'OBJLIST',
                                           'Rahmen',
                                           'Muster'
                                                    );
      LevSprs=41;
      SprName:ARRAY[1..LevSprs]OF STRING=('smkraut1',
                                          'smkraut3',
                                          'smkraut2',
                                          's11',
                                          's1',
                                          's2',
                                          'sg1',
                                          'sg2',
                                          'sm2',
                                          'sm1',
                                          'sm1',
                                          'sm1',
                                          'sm1',
                                          'sm3',
                                          'sm3',
                                          'sm3',
                                          'sm3',
                                          'sm5',
                                          'sm5',
                                          'sm5',
                                          'sm5',
                                          'sm9',
                                          'sm10',
                                          'sm11',
                                          's33',
                                          's3',
                                          's4',
                                          'so1',
                                          'water',
                                          'water2',
                                          'sm12',
                                          'back1',
                                          'back1',
                                          'so2',
                                          'se1',
                                          'se2',
                                          'se3',
                                          'se4',
                                          's33',
                                          's3',
                                          's4'
                                         );
      _Unlimited=-1;
TYPE
     tMuster=ARRAY[0..399]OF Byte;
     tTestMuster=ARRAY[0..24]OF Byte;
     tLev=ARRAY[0..MaxLX*MaxLY-1]OF Byte;
     tLevM=ARRAY[0..MaxLX*MaxLY-1]OF Word;
     tLevel=RECORD
              LXS,LYS:LongInt;
              LevD:^tLev;
              LevM:^tLev;
            END;
     tSprDat=ARRAY[0..MaxSprX*MaxSprY-1]OF Byte;
     tSprite=RECORD
               XSize,YSize:LongInt;
               XMid,YMid:LongInt;
               Dat:^tSprDat;
             END;
     tObjekt=RECORD
               Typ:LongInt;
               XS,YS:Real;
               XX,YY:Real;
               Spr:^tSprite;
               Par:ARRAY[1..10]OF LongInt;
             END;
VAR Scrp,Screen:^tScreen;
    LSpr:ARRAY[1..LevSprs]OF tSprite;
    Lev:tLevel;
    Objekte:LongInt;
    Obj:ARRAY[1..MaxObjekte]OF tObjekt;
    ObjSpr:ARRAY[1..ObjSprs]OF tSprite;
    LESpr:ARRAY[1..LESprs]OF tSprite;
    MCol:ARRAY[0..63]OF Byte;
    Palette:PAL_ARRAY;
    MX,MY:Word;
    MK:Byte;
    WaitR:Boolean;
    ScrG,ScrO,ScrM,ScrX,ScrY,MAkX,MAkY,MakX2,MakY2:LongInt;
    P1,P2,X1,X2,Y1,Y2,X,Y,I,K,M:LongInt;
    AkO,AkList,AkG,AkG2,AkM:LongInt;
    Muster:ARRAY[0..MusterAnz-1]OF ^tMuster;
{    SMuster:^tLev;}
    TestMuster:tMuster;
    MConv:ARRAY[0..15,0..15]OF Byte;
    SMuster:^tLev;
    Dont:ARRAY[-1..5]OF RECORD X,Y:LongInt; END;
    Deep:LongInt;

{FUNCTION GetM(X,Y:LongInt):Boolean;
VAR By,Bi:LongInt;
BEGIN
  IF(X<0)OR(Y<0)OR(X>=Lev.LXS*5)OR(Y>=Lev.LYS*5)THEN EXit;
  By:=(Y*Lev.LXS*5+X)DIV 8;
  Bi:=(Y*Lev.LXS*5+X)MOD 8;
  GetM:=SMuster^[By] AND (1 SHL Bi)=(1 SHL Bi);
END;

PROCEDURE SetM(X,Y:LongInt;Bool:Boolean);
VAR By,Bi:LongInt;
BEGIN
  IF(X<0)OR(Y<0)OR(X>=Lev.LXS*5)OR(Y>=Lev.LYS*5)THEN EXit;
  By:=(Y*Lev.LXS*5+X)DIV 8;
  Bi:=(Y*Lev.LXS*5+X)MOD 8;
  IF Bool=True THEN SMuster^[By]:=SMuster^[By] OR (1 SHL Bi)
               ELSE SMuster^[By]:=SMuster^[By] AND (NOT(1 SHL Bi));
END;}

PROCEDURE TransP(P1:LongInt;VAR X,Y:LongInt);
BEGIN
  IF P1<5 THEN BEGIN
    X:=0;
    Y:=P1;
  END ELSE
  IF P1<9 THEN BEGIN
    X:=P1-4;
    Y:=4;
  END ELSE
  IF P1<13 THEN BEGIN
    X:=4;
    Y:=4-(P1-8);
  END ELSE
  BEGIN
    X:=4-(P1-12);
    Y:=0;
  END;
END;

PROCEDURE TransV(X,Y:LongInt;VAR P1:LongInt);
BEGIN
  IF(X=0)THEN P1:=Y ELSE
  IF(Y=4)THEN P1:=X+4 ELSE
  IF(X=4)THEN P1:=8+(4-Y) ELSE
  IF(Y=0)THEN P1:=12+(4-X) ELSE
END;

PROCEDURE GetPoints(X,Y:LongInt;VAR P1,P2:LongInt);
BEGIN
  P1:=SMuster^[Y*Lev.LXS+X] AND $0F;
  P2:=(SMuster^[Y*Lev.LXS+X] SHR 4) AND $0F;
END;

PROCEDURE SetPoints(X,Y:LongInt;P1,P2:LongInt);
BEGIN
  SMuster^[Y*Lev.LXS+X]:=P2 SHL 4 + P1;
  Lev.LevM^[Y*Lev.LXS+X]:=MConv[P1,P2];
END;

PROCEDURE RoundIt;
VAR X,Y,X1,X2,NP,Y1,Y2,P1,P2,PT1,PT2,I,K,M:LongInt;
    NewM:^tLev;

PROCEDURE SetN(X,Y,P1,P2:LongInt);
VAR I,K,M:LongInt;
    Temp:^tLev;
BEGIN
  Temp:=@(SMuster^);
  SMuster:=@(NewM^);
  SetPoints(X,Y,P1,P2);
  SMuster:=@(Temp^);
END;

BEGIN
{  New(NewM);
  FOR I:=0 TO Lev.LXS*Lev.LYS-1 DO NewM^[I]:=SMuster^[I];
  FOR Y:=1 TO Lev.LYS-2 DO BEGIN
    FOR X:=1 TO Lev.LXS-2 DO BEGIN
      GetPoints(X,Y,P1,P2);
      TransP(P1,X1,Y1);
      IF X1=0 THEN BEGIN
        GetPoints(X-1,Y,PT1,PT2);
        TransP(PT2,X2,Y2);
        IF X2=4 THEN BEGIN
          M:=(Y1+Y2)DIV 2;
          TransV(X2,M,NP);
          SetN(X-1,Y,PT1,NP);
          TransV(X1,M,NP);
          SetN(X,Y,NP,P2);
        END;
      END;
      IF Y1=0 THEN BEGIN
        GetPoints(X,Y-1,PT1,PT2);
        TransP(PT2,X2,Y2);
        IF Y2=4 THEN BEGIN
          M:=(X1+X2)DIV 2;
          TransV(X2,M,NP);
          SetN(X-1,Y,PT1,NP);
          TransV(X1,M,NP);
          SetN(X,Y,NP,P2);
        END;
      END;
    END;
  END;
  FOR I:=0 TO Lev.LXS*Lev.LYS-1 DO SMuster^[I]:=NewM^[I];
  DisPose(NewM);}
END;

FUNCTION GetNearest(R,G,B:Byte):Byte;
VAR I,K,M,Abw,MinA,MC:Word;
BEGIN
  MinA:=768;
  FOR I:=1 TO 254 DO BEGIN
    Abw:=Abs(R-Palette[I][0])+Abs(G-Palette[I][1])+Abs(B-Palette[I][2]);
    IF Abw<MinA THEN BEGIN
      MC:=I;
      MinA:=Abw;
    END;
  END;
  GetNearest:=MC;
END;

PROCEDURE CreateObj(X,Y,_Typ:LongInt);
VAR I,K,M:LongInt;
BEGIN
  IF Objekte<MaxObjekte THEN BEGIN
    Inc(Objekte);
    WITH Obj[Objekte] DO BEGIN
      XX:=X;
      YY:=Y;
      XS:=0;
      YS:=0;
      FOR I:=1 TO 10 DO
        Par[I]:=0;
      Typ:=_Typ;
      CASE TYP OF
        2:BEGIN
            Par[1]:=_Unlimited;
          END;
      END;
    END;
  END;
END;

PROCEDURE DelObj(N:LongInt);
VAR I,K,M:LongInt;
BEGIN
  IF(N<1)OR(N>Objekte)THEN Exit;
  IF Objekte>1 THEN BEGIN
    Obj[N]:=Obj[Objekte];
    Dec(Objekte);
  END ELSE BEGIN
    Objekte:=0;
  END;
END;

PROCEDURE PutTSpr(X,Y:LongInt;Spr:tSprite);
VAR I,K,M,N:LongInt;
    AX,AY,XN,YN:LongInt;
    B:Byte;
BEGIN
WITH Spr DO BEGIN
  X:=X-XMid-ScrX*20;
  Y:=Y-YMid-ScrY*20;
  M:=Y*320+X;
  FOR K:=0 TO YSize-1 DO BEGIN
    IF(Y+K>=0)AND(Y+K<158)THEN BEGIn
          AY:=K-YMid;
          FOR I:=0 TO XSize-1 DO IF(X+I>=0)AND(X+I<320)THEN BEGIN
            AX:=I-XMid;
            XN:=I;
            YN:=K;
            IF(XN>=0)AND(XN<XSize)AND(YN>=0)AND(YN<YSize)
              THEN B:=Spr.Dat^[YN*XSize+XN]
              ELSE B:=0;
            IF B<>0 THEN Scrp^[M+I]:=B;
          END;
    END;
    Inc(M,320);
  END;
END;
END;


PROCEDURE PutSpr(X,Y:LongInt;Spr:tSprite);
VAR I,K,M:LongInt;
BEGIN
  WITH Spr DO BEGIN
    FOR I:=0 TO YSize-1 DO IF I+Y<200 THEN
      Move(Dat^[I*XSize],Scrp^[(Y+I)*320+X],XSize);
  END;
END;

PROCEDURE PutMSpr(X,Y:LongInt;Spr:tSprite;Muster:tMuster);
VAR I,K,M:LongInt;
BEGIN
  WITH Spr DO BEGIN
   FOR K:=0 TO YSize-1 DO
    FOR I:=0 TO XSize-1 DO
      IF Muster[K*20+I]<>0 THEN
        Scrp^[(Y+K)*320+X+I]:=Dat^[K*20+I];
  END;
END;

PROCEDURE GetMousePos;
BEGIN
  ASM
    mov ax,3;
    mov bx,0;
    int $33;
    mov [MK],bl
    mov [MX],cx
    mov [MY],dx
  END;
  MX:=MX SHR 1;
  IF MX<1 THEN MX:=1;
  IF MX>318 THEN MX:=318;
  IF MY<1 THEN MY:=1;
  IF MY>198 THEN MY:=198;
END;

PROCEDURE Mirror(Sou,Des:tSprite);
VAR I,K,M:LongInt;
BEGIN
WITH Sou DO
  FOR I:=0 TO XSize-1 DO
    FOR K:=0 TO YSize-1 DO BEGIN
      Des.Dat^[K*20+I]:=Sou.Dat^[K*20+19-I];
    END;
END;

PROCEDURE RotSpriteTo(Sou,Des:tSprite);
VAR I,K,M:LongInt;
BEGIN
  FOR K:=0 TO 19 DO
    FOR I:=0 TO 19 DO
      Des.Dat^[I*20+19-K]:=Sou.Dat^[K*20+I];
END;

PROCEDURE LoadSprites;
VAR I,K,M:LongInt;
    F:FILE;
    Head:tIMGHeader;
BEGIN
  FOR I:=1 TO LevSprs DO BEGIN
    Assign(F,'DATA\'+SprName[I]+'.IMG');
    ReSet(F,1);
    BlockRead(F,Head,SizeOf(Head));
    WITH LSpr[I] DO BEGIN
      XSize:=Head.XSize;
      YSize:=Head.YSize;
      XMid:=XSize DIV 2;YMid:=YSize DIV 2;
      GetMem(Dat,XSize*YSize);
      BlockRead(F,Dat^,XSize*YSize);
    END;
    Close(F);
  END;
  FOR I:=11 TO 13 DO
    RotSpriteTo(LSpr[I-1],LSpr[I]);
  FOR I:=15 TO 17 DO
    RotSpriteTo(LSpr[I-1],LSpr[I]);
  FOR I:=19 TO 21 DO
    RotSpriteTo(LSpr[I-1],LSpr[I]);
  Mirror(LSpr[32],LSpr[33]);
  FOR I:=1 TO LESprs DO BEGIN
    Assign(F,'DATA\'+LESprName[I]+'.IMG');
    ReSet(F,1);
    BlockRead(F,Head,SizeOf(Head));
    WITH LESpr[I] DO BEGIN
      XSize:=Head.XSize;
      YSize:=Head.YSize;
      XMid:=XSize DIV 2;YMid:=YSize DIV 2;
      GetMem(Dat,XSize*YSize);
      BlockRead(F,Dat^,XSize*YSize);
    END;
    Close(F);
  END;
  FOR I:=1 TO ObjSprs DO BEGIN
    Assign(F,'DATA\'+ObjSprName[I]+'.IMG');
    ReSet(F,1);
    BlockRead(F,Head,SizeOf(Head));
    WITH ObjSpr[I] DO BEGIN
      XSize:=Head.XSize;
      YSize:=Head.YSize;
      XMid:=XSize DIV 2;YMid:=YSize DIV 2;
      GetMem(Dat,XSize*YSize);
      BlockRead(F,Dat^,XSize*YSize);
    END;
    Close(F);
  END;
END;

FUNCTION GetClosestObj:LongInt;
VAR BestA,BestO,I,K,M:LongInt;
BEGIN
  IF Objekte=0 THEN BEGIN
    GetClosestObj:=0;
    Exit;
  END;
  BestA:=MaxLongInt;
  BestO:=1;
  FOR I:=1 TO Objekte DO BEGIN
    M:=Round(Sqr(MX+ScrX*20-Obj[I].XX)+Sqr(MY+ScrY*20-Obj[I].YY));
    IF M<BestA THEN BEGIN
      BestA:=M;
      BestO:=I;
    END;
  END;
  GetClosestObj:=BestO;
END;

{FUNCTION GetNum(X,Y:LongInt):LongInt;
VAR I,K,M:LongInt;
BEGIN
  M:=0;
  FOR K:=4 DOWNTO 0 DO
    FOR I:=4 DOWNTO 0 DO BEGIN
      M:=M SHL 1;
      IF GetM(X*5+I,Y*5+K) THEN Inc(M);
    END;
  GetNum:=M;
END;}

{PROCEDURE SetMuster(X,Y:LongInt);
VAR I,K,M,A,W,B,BW:LongInt;
BEGIN
  BW:=MaxLongInt;
  B:=0;
  FOR M:=0 TO 99 DO BEGIN
    W:=0;
    FOR K:=0 TO 4 DO
      FOR I:=0 TO 4 DO BEGIN
        IF GetM(X*5+I,Y*5+K) THEN Inc(W,16-TestMuster[M][K*5+I])
                             ELSE Inc(W,TestMuster[M][K*5+I]);
      END;
    IF W<BW THEN BEGIN
      B:=M;
      BW:=W;
    END;
  END;
  Lev.LevM^[Y*Lev.LXS+X]:=B;
END;

PROCEDURE CalcBestMuster;
VAR X,Y,I,K,M,A,W,B,BW:LongInt;
BEGIN
  FOR M:=0 TO 99 DO BEGIN
    FOR I:=0 TO 4 DO
      FOR K:=0 TO 4 DO BEGIN
        A:=0;
        FOR X:=0 TO 3 DO
          FOR Y:=0 TO 3 DO
            IF Muster[M]^[(K*4+Y)*20+I*4+X]<>0 THEN Inc(A);
        TestMuster[M][K*5+I]:=A;
      END;
  END;
END;

PROCEDURE ConvertMuster;
VAR I,K,M,N:LongInt;
BEGIN
  WITH Lev DO BEGIN
    FOR K:=0 TO LYS-1 DO
      FOR I:=0 TO LXS-1 DO BEGIN
        SetMuster(I,K);
{        N:=GetNum(I,K);
        IF N=0 THEN LevD^[K*LXS+I]:=0 ELSE LevM^[K*LXS+I]:=MConv[N];}
{      END;
  END;
END;}

FUNCTION OverPoss:Boolean;
BEGIN
 IF(MAkX2 MOD 5=0)OR(MakX2 MOD 5=4)OR
   (MAkY2 MOD 5=0)OR(MakY2 MOD 5=4) THEN OverPoss:=True ELSE OverPoss:=False;
END;

PROCEDURE SetDaPoint(X,Y,NP:LongInt);
VAR I,K,M,NX,NY,P1,P2,X1,Y1,X2,Y2:LongInt;
BEGIN
  IF(X<0)OR(Y<0)OR(X>=Lev.LXS)OR(Y>=Lev.LYS) THEN Exit;
  IF Deep>0 THEN BEGIN
    FOR I:=1 TO Deep DO IF(Dont[I].X=X)AND(Dont[I].Y=Y) THEN Exit;
  END;
  Inc(Deep);
  Dont[Deep].X:=X;
  Dont[Deep].Y:=Y;

  GetPoints(X,Y,P1,P2);
  TransP(P1,X1,Y1);
  TransP(P2,X2,Y2);
  TransP(NP,NX,NY);
  IF (Sqr(NX-X1)+Sqr(NY-Y1))<(Sqr(NX-X2)+Sqr(NY-Y2))
    THEN SetPoints(X,Y,NP,P2)
    ELSE SetPoints(X,Y,P1,NP);

  IF Deep=0 THEN Exit;

  IF NX=0 THEN BEGIN
    TransV(4,NY,M);
    GetPoints(X-1,Y,P1,P2);
    IF(P1+P2<>0) THEN
      SetDaPoint(X-1,Y,M);
  END;
  IF NX=4 THEN BEGIN
    TransV(0,NY,M);
    GetPoints(X+1,Y,P1,P2);
    IF(P1+P2<>0) THEN
      SetDaPoint(X+1,Y,M);
  END;
  IF NY=0 THEN BEGIN
    TransV(NX,4,M);
    GetPoints(X,Y-1,P1,P2);
    IF(P1+P2<>0) THEN
      SetDaPoint(X,Y-1,M);
  END;
  IF NY=4 THEN BEGIN
    TransV(NX,0,M);
    GetPoints(X,Y+1,P1,P2);
    IF(P1+P2<>0) THEN
      SetDaPoint(X,Y+1,M);
  END;
  Dec(Deep);
END;

PROCEDURE MouseStuff;
VAR I,K,M,P1,P2,NP,X1,X2,Y1,Y2,NX,NY:LongInt;
BEGIN
    GetMousePos;
    FillChar(Scrp^[MY*320+MX-1],3,14);
    Scrp^[(MY-1)*320+MX]:=14;
    Scrp^[(MY+1)*320+MX]:=14;
    MAkX:=MX DIV 20;
    MAkY:=MY DIV 20;
    MAkX2:=MX DIV 4;
    MAkY2:=MY DIV 4;
    IF MK=1 THEN BEGIN
      IF AkList=1 THEN BEGIN
        IF(MAkY<8)THEN BEGIN
          Lev.LevD^[(MAkY+ScrY)*Lev.LXS+MAkX+ScrX]:=AkG;
          GetPoints(MAkX+ScrX,MakY+ScrY,P1,P2);
          IF P1+P2=0 THEN
            SetPoints(MAkX+ScrX,MakY+ScrY,0,12);
        END;
      END;
      IF AkList=3 THEN BEGIN
        IF(MAkY<8)AND(OverPoss)THEN BEGIN
          NX:=MakX2 MOD 5;
          NY:=MakY2 MOD 5;
          TransV(NX,NY,NP);
          Deep:=-1;
          IF Key[56] THEN Deep:=0;
          SetDaPoint(MAkX+ScrX,MakY+ScrY,NP);
{          GetPoints(MAkX+ScrX,MakY+ScrY,P1,P2);
          TransP(P1,X1,Y1);
          TransP(P2,X2,Y2);
          IF (Sqr(NX-X1)+Sqr(NY-Y1))<(Sqr(NX-X2)+Sqr(NY-Y2))
            THEN SetPoints(MAkX+ScrX,MAkY+ScrY,NP,P2)
            ELSE SetPoints(MAkX+ScrX,MAkY+ScrY,P1,NP);}
        END;
{          Lev.LevM^[(MAkY+ScrY)*Lev.LXS+MAkX+ScrX]:=AkM-1;}
      END;
      IF(MAkY=8)THEN BEGIN
        IF MakX=0 THEN BEGIN AkList:=1;{ConvertMuster;{}END;
        IF MakX=1 THEN BEGIN AkList:=2;{ConvertMuster;{}END;
        IF MakX=2 THEN AkList:=3;
      END;
      IF AkList=1 THEN BEGIN
        IF(MAkY=9)AND(MAkX>0)AND(MAkX-1<=13)THEN AkG:=MAkX-1+ScrG;
        IF(MAkY=9)AND(MAkX=0)AND(ScrG>0)THEN Dec(ScrG);
        IF(MAkY=9)AND(MAkX=15)AND(ScrG<LevSprS-13)THEN Inc(ScrG);
      END ELSE
      IF(AkList=2)THEN BEGIN
        IF(NOT WaitR)AND(MAkY<8) THEN CreateObj(MX+ScrX*20,MY+ScrY*20,AkO);
        IF(MAkY=9)AND(MAkX>0)AND(MAkX-1<=13)THEN AkO:=MAkX+ScrO;
        IF(MAkY=9)AND(MAkX=0)AND(ScrO>0)THEN Dec(ScrO);
        IF(MAkY=9)AND(MAkX=15)AND(ScrO<ObjSprs-14)THEN Inc(ScrO);
      END;
      IF(AkList=3)THEN BEGIN
        IF(MAkY=9)AND(MAkX>0)AND(MAkX-1<=13)THEN AkM:=MAkX+ScrM;
        IF(MAkY=9)AND(MAkX=0)AND(ScrM>0)THEN Dec(ScrM);
        IF(MAkY=9)AND(MAkX=15)AND(ScrM<MusterAnz-14)THEN Inc(ScrM);
      END;
      WaitR:=True;
    END;
    IF MK=2 THEN BEGIN
      IF AkList=1 THEN BEGIN
        IF(MAkY<8)THEN BEGIN
          Lev.LevD^[(MAkY+ScrY)*Lev.LXS+MAkX+ScrX]:=AkG2;
          SetPoints(MAkX+ScrX,MakY+ScrY,0,0);
        END;
        IF(MAkY=9)AND(MAkX>0)AND(MAkX-1<=13)THEN AkG2:=MAkX-1+ScrG;
      END ELSE
      IF AkList=2 THEN BEGIN
        IF(NOT WaitR)AND(MAkY<8) THEN DelObj(GetClosestObj);
      END;
      IF AkList=3 THEN BEGIN
        IF MAkY<8 THEN
          SetPoints(MAkX+ScrX,MakY+ScrY,0,0);
      END;
      WaitR:=True;
    END;
    IF MK=0 THEN WaitR:=False;
    M:=50;
    IF(MX=1)AND(ScrX>0)THEN BEGIN Dec(ScrX);Delay(M);END;
    IF(MX=318)AND(ScrX+16<Lev.LXS)THEN BEGIN Inc(ScrX);Delay(M);END;
    IF(MY=1)AND(ScrY>0)THEN BEGIN Dec(ScrY);Delay(M);END;
    IF(MY=198)AND(ScrY+8<Lev.LYS)THEN BEGIN Inc(ScrY);Delay(M);END;
END;

PROCEDURE DrawXAt(X,Y,Col:LongInt);
VAR I:LongInt;
BEGIN
    FOR I:=4 TO 15 DO BEGIN
      Scrp^[(Y-10+I)*320+X-10+I]:=Col;
      Scrp^[(Y-10+I)*320+X+9-I]:=Col;
    END;
END;

PROCEDURE DrawStuff;
VAR I,K,M,N,S,P1,P2,X1,Y1,X2,Y2:LongInt;
BEGIN

    PutSpr(0,160,LESpr[1]);
    PutSpr(20,160,LESpr[2]);
    PutSpr(40,160,LESpr[4]);

    {Level malen}
IF AkList=3 THEN BEGIN
    FOR K:=0 TO 7 DO BEGIN
      FOR I:=0 TO 15 DO BEGIN
        GetPoints(I+ScrX,K+ScrY,P1,P2);
       IF(P1+P2<>0)THEN BEGIN
        N:=MConv[P1,P2];
        FOR M:=0 TO 19 DO
          Move(Muster[N]^[M*20],Scrp^[(K*20+M)*320+I*20],20);
        TransP(P1,X1,Y1);X1:=X1*4;Y1:=Y1*4;
        TransP(P2,X2,Y2);X2:=X2*4;Y2:=Y2*4;
        IF(I=MakX)AND(K=MakY)THEN BEGIN
          Scrp^[(K*20+Y1+2)*320+I*20+X1+2]:=11;
          Scrp^[(K*20+Y2+2)*320+I*20+X2+2]:=11;
        END ELSE BEGIN
          Scrp^[(K*20+Y1+2)*320+I*20+X1+2]:=13;
          Scrp^[(K*20+Y2+2)*320+I*20+X2+2]:=13;
        END;
       END;
      END;
    END;
{    FOR K:=0 TO 8*5-1 DO BEGIN
      FOR I:=0 TO 16*5-1 DO BEGIN
        IF GetM(I+ScrX*5,K+ScrY*5) THEN BEGIN
          FOR M:=0 TO 3 DO
            FillChar(Scrp^[(K*4+M)*320+I*4],4,12);
        END;
      END;
    END;}
END ELSE
    FOR K:=0 TO 7 DO BEGIN
      FOR I:=0 TO 15 DO BEGIN
        M:=Lev.LevD^[(K+ScrY)*Lev.LXS+I+ScrX];
        N:=Lev.LevM^[(K+ScrY)*Lev.LXS+I+ScrX];
        IF M<>0 THEN PutMSpr(I*20,K*20,LSpr[M],Muster[N]^);
      END;
    END;
    FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
      PutTSpr(Round(XX),Round(YY),ObjSpr[Typ]);
    END;
    IF(AkList=2)AND(Objekte>0)THEN BEGIN
      M:=GetClosestObj;
      PutTSpr(Round(Obj[M].XX),Round(Obj[M].YY),LESpr[3]);
    END;

    FOR I:=-5 TO 5 DO BEGIN
      FillChar(Scrp^[(190+I)*320+5+Abs(I)],10-Abs(I),15);
      FillChar(Scrp^[(190+I)*320+305],10-Abs(I),15);
    END;

    IF AkList=1 THEN BEGIN
      FOR I:=0 TO LevSprs DO IF(I-ScrG>=0)AND(I-ScrG<14)AND(I<>0)THEN
        PutSpr((I-ScrG+1)*20,180,LSpr[I]);
      IF(AkG2-ScrG>=0)AND(AkG2-ScrG<14)THEN
        DrawXAt((AkG2+1-ScrG)*20+10,190,7);
      IF(AkG-ScrG>=0)AND(AkG-ScrG<14)THEN
        DrawXAt((AkG+1-ScrG)*20+10,190,15);
    END ELSE

    IF AkList=2 THEN BEGIN
      FOR I:=1 TO ObjSprs DO IF(I-ScrO>0)AND(I-ScrO<=14)AND(I<>0)THEN
        PutSpr((I-ScrO)*20,180,ObjSpr[I]);
      IF(AkO-ScrO>0)AND(AkO-ScrO<=14)THEN
        DrawXAt((AkO-ScrO)*20+10,190,15);
    END;

    IF AkList=3 THEN BEGIN
      FOR I:=1 TO MusterAnz DO IF(I-ScrM>0)AND(I-ScrM<=14)THEN
        FOR K:=0 TO 19 DO Move(Muster[I-1]^[K*20],Scrp^[(180+K)*320+(I-ScrM)*20],20);
      IF(AkM-ScrM>0)AND(AkM-ScrM<=14)THEN
        DrawXAt((AkM-ScrM)*20+10,190,13);
    END;


    FillChar(Scrp^[158*320],320,8);
    FillChar(Scrp^[159*320],320,7);
    FillChar(Scrp^[160*320],320,8);

    IF(AkList IN [1])OR(MAkY>7)THEN BEGIN
      FillChar(Scrp^[MAkY*20*320+MAkX*20],20,15);
      FillChar(Scrp^[(MAkY*20+19)*320+MAkX*20],20,15);
      FOR I:=0 TO 19 DO BEGIN
        Scrp^[(MAkY*20+I)*320+MAkX*20]:=15;
        Scrp^[(MAkY*20+I)*320+MAkX*20+19]:=15;
      END;
    END ELSE
    IF(AkList IN [3])OR(MAkY>7)THEN BEGIN
      FillChar(Scrp^[MAkY*20*320+MAkX*20],20,15);
      FillChar(Scrp^[(MAkY*20+19)*320+MAkX*20],20,15);
      FOR I:=0 TO 19 DO BEGIN
        Scrp^[(MAkY*20+I)*320+MAkX*20]:=15;
        Scrp^[(MAkY*20+I)*320+MAkX*20+19]:=15;
      END;
      IF OverPoss THEN BEGIN
        FillChar(Scrp^[MAkY2*4*320+MAkX2*4],4,13);
        FillChar(Scrp^[(MAkY2*4+3)*320+MAkX2*4],4,13);
        FOR I:=0 TO 3 DO BEGIN
          Scrp^[(MAkY2*4+I)*320+MAkX2*4]:=13;
          Scrp^[(MAkY2*4+I)*320+MAkX2*4+3]:=13;
        END;
      END;
    END ELSE
    IF(AkList=2)AND(MAkY<8)THEN BEGIN
      PutTSpr(MX+ScrX*20,MY+ScrY*20,ObjSpr[AkO]);
    END;
END;

PROCEDURE CreateLev(VAR Lev:tLevel;LX,LY:LongInt);
VAR I,K,M:LongInt;
BEGIN
  WITH Lev DO BEGIN
    LXS:=LX;
    LYS:=LY;
    GetMem(LevD,LXS*LYS);
    GetMem(LevM,LXS*LYS);
    FOR K:=0 TO LYS-1 DO
      FOR I:=0 TO LXS-1 DO BEGIN
        LevD^[K*LXS+I]:=0;
        LevM^[K*LXS+I]:=0;
      END;
  END;
  FOR I:=0 TO Lev.LXS-1 DO
    FOR K:=0 TO Lev.LYS-1 DO
      SetPoints(I,K,0,0);
{  FillChar(SMuster^,Lev.LXS*Lev.LYS*4,0);}
END;

PROCEDURE SaveLevel_NOW(St:STRING);
VAR F:FILE;
    I,K,M,P,BW:LongInt;
    A,B,BI,BC:Byte;

PROCEDURE AddBit(B:Byte);
BEGIN
  BC:=BC OR (B SHL BI);
  Inc(BI);
  IF BI=8 THEN BEGIN
    BlockWrite(F,BC,1);
    Inc(BW);
    BC:=0;
    BI:=0;
  END;
END;

PROCEDURE AddByte(B:Byte);
VAR I:LongInt;
BEGIN
{  TextMode(3);
  WriteLn('Adding ',B);
  IF ReadKey=#27 THEN Halt(0);}
  FOR I:=0 TO 5 DO
    AddBit((B AND (1 SHL I))SHR I);
END;

PROCEDURE WriteIt(A,B:Byte);
BEGIN
    IF(A=1)AND((B SHR 4)AND 3<>3) THEN BEGIN
      AddByte(B);
    END ELSE BEGIN
      AddByte(A OR (3 SHL 4));
      AddByte(B);
    END;
END;

PROCEDURE AddIt(C:Byte);
BEGIN
  IF(C=B)AND(A<15) THEN Inc(A)
    ELSE BEGIN
      WriteIt(A,B);
      A:=1;
      B:=C;
    END;
END;

BEGIN
  Assign(F,ST);
  ReWrite(F,1);
  BlockWrite(F,Lev,SizeOf(Lev)-4);
{  BlockWrite(F,Lev.LevD^,Lev.LXS*Lev.LYS);
  BlockWrite(F,Lev.LevM^,Lev.LXS*Lev.LYS);}
  P:=1;
  A:=1;
  B:=Lev.LevD^[0];
  BI:=0;
  BC:=0;
  BW:=0;
  WHILE P<Lev.LXS*Lev.LYS DO BEGIN
    IF(Lev.LevD^[P]=B)AND(A<255) THEN Inc(A)
      ELSE BEGIN
        BlockWrite(F,A,1);
        BlockWrite(F,B,1);
        A:=1;
        B:=Lev.LevD^[P];
      END;
{    AddIt(Lev.LevD^[P]);}
    Inc(P);
  END;
{  WriteIt(A,B);
  IF BI<>0 THEN BEGIN
    BlockWrite(F,BC,1);
{    Inc(BW);}
{  END;}
{  TextMode(3);
  WriteLn('Bytes Written : ',BW);
  ReadKey;}
  BlockWrite(F,A,1);
  BlockWrite(F,B,1);{}

{  P:=1;
  A:=1;
  B:=Lev.LevM^[0];
  WHILE P<Lev.LXS*Lev.LYS DO BEGIN
    IF(Lev.LevM^[P]=B)AND(A<255) THEN Inc(A)
      ELSE BEGIN
        BlockWrite(F,A,1);
        BlockWrite(F,B,1);
        A:=1;
        B:=Lev.LevM^[P];
      END;
    Inc(P);
  END;
  BlockWrite(F,A,1);
  BlockWrite(F,B,1);}


  BlockWrite(F,Objekte,4);
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
{    BlockWrite(F,Obj[I],SizeOf(tObjekt));}
    B:=Typ;
    BlockWrite(F,B,1);
    BlockWrite(F,XX,SizeOf(Real));
    BlockWrite(F,YY,SizeOf(Real));
    B:=Par[1];
    BlockWrite(F,B,1);
  END;
  ClosE(F);
END;

PROCEDURE GetPForM(M:LongInt;VAR P1,P2:LongInt);
VAR I,K,N:LongInt;
BEGIN
  P1:=0;
  P2:=0;
  FOR I:=0 TO 15 DO
    FOR K:=0 TO 15 DO
      IF(MConv[I,K]=M)THEN BEGIN
        P1:=I;
        P2:=K;
      END;
END;


PROCEDURE LoadLevel_NOW(St:STRING);
VAR F:FILE;
    BR,P1,P2,I,K,M,P:LongInt;
    A,B,BI,BC:Byte;

FUNCTION GetBit:Byte;
BEGIN
  Inc(BI);
  IF Bi=8 THEN BEGIN
    BlockRead(F,BC,1);
    Inc(BR);
    BI:=0;
  END;
  GetBit:=(BC AND (1 SHL BI))SHR BI;
END;

FUNCTION GetByte:Byte;
VAR B:BytE;
    I:LongInt;
BEGIN
  B:=0;
  FOR I:=0 TO 5 DO
    B:=B OR (GetBit SHL I);
  GetByte:=B;
{  TextMode(3);
  WriteLn('Reading ',B);
  IF ReadKey=#27 THEN Halt(0);}
END;

BEGIN
  WITH Lev DO BEGIN
    FreeMem(LevD,LXS*LYS);
    FreeMem(LevM,LXS*LYS);
  END;
  Assign(F,ST);
  ReSet(F,1);
  BlockRead(F,Lev,SizeOf(Lev)-4);
  GetMem(Lev.LevD,Lev.LXS*Lev.LYS);
  GetMem(Lev.LevM,Lev.LXS*Lev.LYS);

{  BlockRead(F,Lev.LevD^,Lev.LXS*Lev.LYS);
  BlockRead(F,Lev.LevM^,Lev.LXS*Lev.LYS);}

  BI:=7;
  P:=0;
  BR:=0;
  WHILE P<Lev.LXS*Lev.LYS DO BEGIN
    BlockRead(F,A,1);
    BlockRead(F,B,1);{}
{    A:=1;
    B:=GetByte;
    IF(B SHR 4) AND 3=3 THEN BEGIN
      A:=B AND (1+2+4+8);
      B:=GetByte;
    END;
{    A:=GetByte;
    B:=GetByte;{}
    FillChar(Lev.LevD^[P],A,B);
    Inc(P,A);
  END;
{  TextMode(3);
  WriteLn('Bytes read ',BR);
  ReadKey;}
{  P:=0;
  WHILE P<Lev.LXS*Lev.LYS DO BEGIN
    BlockRead(F,A,1);
    BlockRead(F,B,1);
    FillChar(Lev.LevM^[P],A,B);
    Inc(P,A);
  END;}
  FOR I:=0 TO Lev.LXS-1 DO BEGIN
    FOR K:=0 TO Lev.LYS-1 DO BEGIN
      SetPoints(I,K,0,12);
    END;
  END;

  BlockRead(F,Objekte,4);
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
{    BlockRead(F,Obj[I],SizeOf(tObjekt));}
    FillChar(Obj[I],SizeOf(tObjekt),0);
    BlockRead(F,B,1);
    Typ:=B;
    BlockRead(F,XX,SizeOf(Real));
    BlockRead(F,YY,SizeOf(Real));
    BlockRead(F,B,1);
    Par[1]:=B;
  END;
  ClosE(F);
END;

PROCEDURE DrawDir;
VAR SR:SearchRec;
    I,K,M:LongInt;
BEGIN
  FindFirst('*.lvl',ANYFILE,SR);
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

PROCEDURE SaveLevel;
VAR FName:STRING;
BEGIN
  TextMode(3);
  ChDir('DATA');
  DoneKeyBoard;
  DrawDir;
  REPEAT
    WriteLn('<- SAVE Level ->');
    Write('Filename (8Bst ohne .lvl) : ');
    ReadLn(FName);
  UNTIL (Pos('.',FName)=0)AND(Length(FName)>0)AND(Length(FName)<9);
  SaveLevel_NOW(FName+'.lvl');
  InitKeyBoard;
  Init(19);
  SetPalette(Palette);
  ChDir('..');
END;

PROCEDURE LoadLevel;
VAR FName:STRING;
BEGIN
  TextMode(3);
  ChDir('DATA');
  DoneKeyBoard;
  DrawDir;
  REPEAT
    WriteLn('<- LOAD Level ->');
    Write('Filename (8Bst ohne .lvl) : ');
    ReadLn(FName);
  UNTIL (Pos('.',FName)=0)AND(Length(FName)>0)AND(Length(FName)<9);
  LoadLevel_NOW(FName+'.lvl');
  InitKeyBoard;
  Init(19);
  SetPalette(Palette);
  ChDir('..');
END;

PROCEDURE EditAkObj;
BEGIN
  TextMode(3);
  DoneKeyBoard;
  CASE Obj[GetClosestObj].Typ OF
    4:BEGIN
         WriteLn('--- Feuer ---');
         WriteLn;
         Write('Welche Gradzahl (?objlist.txt?) (Now : ',Obj[GetClosestObj].Par[1],') : ');
         ReadLn(Obj[GetClosestObj].Par[1]);
       END;
    11:BEGIN
         WriteLn('--- BOX ---');
         WriteLn;
         Write('Was soll entstehen (?objlist.txt?) (Now : ',Obj[GetClosestObj].Par[1],') : ');
         ReadLn(Obj[GetClosestObj].Par[1]);
       END;
    22:BEGIN
         WriteLn('--- LevelEnde ---');
         WriteLn;
         Write('N„chstes Level (Now : ',Obj[GetClosestObj].Par[1],') : ');
         ReadLn(Obj[GetClosestObj].Par[1]);
       END;
  END;
  InitKeyBoard;
  Init(19);
  SetPalette(Palette);
END;

PROCEDURE DrawMap;
VAR MMX,MMY,C,A,X,Y,X2,Y2,EX,EY,I,K,M:LongInt;
    AX,AY,StepX,StepY:Real;
BEGIN
  IF Lev.LXS>Lev.LYS THEN BEGIN
    MMX:=_MMX;
    MMY:=Round(_MMY*(Lev.LYS/Lev.LXS));
  END ELSE BEGIN
    MMY:=_MMY;
    MMX:=Round(_MMX*(Lev.LXS/Lev.LYS));
  END;
  EX:=318-MMX;
  EY:=1+MMY;
  FillChar(Scrp^[EX],MMX+2,15);
  FillChar(Scrp^[EY*320+EX],MMX+2,15);
  FOR I:=0 TO EY DO BEGIN
    Scrp^[I*320+EX]:=15;
    Scrp^[I*320+319]:=15;
  END;
  AY:=0;
  StepX:=(Lev.LXS-1)/MMX;
  StepY:=(Lev.LYS-1)/MMY;
  FOR K:=0 TO MMY-1 DO BEGIN
    AX:=0;
    FOR I:=0 TO MMX-1 DO BEGIN
      A:=0;
      C:=0;
      FOR Y:=Trunc(AY) TO Trunc(AY+StepY) dO BEGIN
        FOR X:=Trunc(AX) TO Trunc(AX+StepX) DO BEGIN
          IF Lev.LevD^[Y*Lev.LXS+X]<>0 THEN Inc(C);
          Inc(A);
        END;
      END;
      C:=(C*63) DIV A;
      Scrp^[(1+K)*320+EX+1+I]:=MCol[C];
      AX:=AX+StepX;
    END;
    AY:=AY+StepY;
  END;
  X:=(ScrX*MMX) DIV Lev.LXS;
  Y:=(ScrY*MMY) DIV Lev.LYS;
  X2:=((ScrX+15)*MMX) DIV Lev.LXS;
  Y2:=((ScrY+7)*MMY) DIV Lev.LYS;
  FOR K:=Y TO Y2 DO BEGIN
    FOR I:=X TO X2 DO IF (I=X)OR(I=X2)OR(K=Y)OR(K=Y2) THEN BEGIN
      Scrp^[(K+1)*320+EX+1+I]:=13;
    END;
  END;
END;

PROCEDURE CreateDaLevel;
VAR Ch:Char;
    I,K,M,X,Y:LongInt;
BEGIN
  TextMode(3);
  DoneKeyBoard;
  WriteLn(' ---- NEW Level ---- ');
  WriteLn;
  Write('Sicher (J/N) ? ');
  REPEAT
    Ch:=UpCase(ReadKey);
  UNTIL Ch IN ['J','N'];
  WriteLn(Ch);
  IF Ch='J' THEN BEGIN
    WITH Lev DO BEGIN
      FreeMem(LevD,LXS*LYS);
      FreeMem(LevM,LXS*LYS);
    END;
    WHILE Objekte>0 DO DelObj(1);
    REPEAT
      Write('Level XSize (Max ',MaxLX,') : ');
      ReadLn(X);
    UNTIL (X>=16)AND(X<=MaxLX);
    REPEAT
      Write('Level YSize (Max ',MaxLY,') : ');
      ReadLn(Y);
    UNTIL (Y>=10)AND(Y<=MaxLY);
    CreateLev(Lev,X,Y);
  END;
  InitKeyBoard;
  Init(19);
  SetPalette(Palette);
END;

PROCEDURE FillLevel;
VAR X1,X2,Y1,Y2,Is,Fill:LongInt;
    Is2,Fill2:Boolean;

PROCEDURE FillIt(X,Y:LongInt);
VAR P1,P2:LongInt;
BEGIN
  IF SPtr<1000 THEN Exit;
  IF(X>=0)AND(X<Lev.LXS)AND(Y>=0)AND(Y<Lev.LYS)AND(Lev.LevD^[(Y)*Lev.LXS+X]=Is)THEN BEGIN
    Lev.LevD^[(Y)*Lev.LXS+X]:=Fill;
    GetPoints(X,Y,P1,P2);
    IF P1+P2=0 THEN
      SetPoints(X,Y,0,12);
    IF Fill=0 THEN
      SetPoints(X,Y,0,0);
    FillIt(X-1,Y);
    FillIt(X+1,Y);
    FillIt(X,Y-1);
    FillIt(X,Y+1);
  END;
END;

PROCEDURE FillIt2(X,Y:LongInt);
BEGIN
  IF SPtr<1000 THEN Exit;
{  IF(X>=0)AND(X<Lev.LXS*5)AND(Y>=0)AND(Y<Lev.LYS*5)AND(GetM(X,Y)=Is2)THEN BEGIN
    IF(X<X1)THEN X1:=X;
    IF(X>X2)THEN X2:=X;
    IF(Y<Y1)THEN Y1:=Y;
    IF(Y>Y2)THEN Y2:=Y;
    SetM(X,Y,Fill2);
    FillIt2(X-1,Y);
    FillIt2(X+1,Y);
    FillIt2(X,Y-1);
    FillIt2(X,Y+1);
  END;}
END;

BEGIN
  IF(AkList=1)AND(MAkY<=7)THEN BEGIN
    Is:=Lev.LevD^[(MAkY+ScrY)*Lev.LXS+MAkX+ScrX];
    Fill:=AkG;
    IF Is=Fill THEN Exit;
    FillIt(MakX+ScrX,MakY+ScrY);
  END;
  IF(AkList=3)AND(MAkY<=7)THEN BEGIN
    X1:=MakX2+ScrX*5;X2:=X1;
    Y1:=MakY2+ScrY*5;Y2:=Y1;
{    Is2:=GetM(MAkX2+ScrX*5,MAkY2+ScrY*5);}
    Fill2:=True;
    IF Is2=Fill2 THEN Exit;
    FillIt2(MakX2+ScrX*5,MakY2+ScrY*5);
{    FOR K:=Y1 DIV 5 TO Y2 DIV 5 DO
      FOR I:=X1 DIV 5 TO X2 DIV 5 DO
        SetMuster(I,K);}
  END;
END;

PROCEDURE RotateAndCreate(Sou,Des:LongInt);
VAR I,K,M:LongInt;
BEGIN
  New(Muster[Des]);
  FOR K:=0 TO 19 DO
    FOR I:=0 TO 19 DO
      Muster[Des]^[I*20+19-K]:=Muster[Sou]^[K*20+I];
END;

PROCEDURE CreateMuster;
VAR R,RStep,S1,S2,I,K,M,X1,X2,Y1,Y2,X,Y:LongInt;
BEGIN
S1:=0;
S2:=0;
FOR M:=0 TO 54 DO BEGIN
  New(Muster[M]);
  FillChar(Muster[M]^,400,0);
  Y1:=S1*5;
  IF S2<4 THEN BEGIN
    X2:=(S2+1)*5;
    Y2:=0;
  END ELSE
  IF S2<8 THEN BEGIN
    X2:=20;
    Y2:=(S2-3)*5;
  END ELSE BEGIN
    X2:=(11-S2)*5;
    Y2:=20;
  END;
  R:=0;
  FOR X:=0 TO X2-1 DO BEGIN
    R:=R+(LongInt(Random(3))-1);
    R:=0;
    FOR Y:=19 DOWNTO (R DIV 3+Y1+((Y2-Y1)*X)DIV (X2-1)) DO IF(Y>=0)AND(Y<20)THEN
      Muster[M]^[Y*20+X]:=7;
  END;
  IF S2<4 THEN BEGIN
    FOR X:=X2 TO 19 DO
      FOR Y:=0 TO 19 DO
        Muster[M]^[Y*20+X]:=7;
  END;
  Inc(S2);
  IF S2=11 THEN BEGIN Inc(S1);S2:=0; END;
END;
FOR M:=1 TO 3 DO
  FOR K:=0 TO 54 DO RotateAndCreate((M-1)*55+K,M*55+K);
FillChar(Muster[1]^,400,15);
FillChar(Muster[0]^,400,0);
END;

FUNCTION BestMuster:LongInt;
VAR I,K,M,A,W,B,BW:LongInt;
BEGIN
  BW:=MaxLongInt;
  B:=0;
  FOR M:=0 TO MusterAnz-1 DO BEGIN
    W:=0;
    FOR K:=0 TO 19 DO
      FOR I:=0 TO 19 DO BEGIN
        IF(Muster[M]^[(K)*20+I]<>0)XOR(TestMuster[K*20+I]<>0)THEN Inc(W);
      END;
    IF W<BW THEN BEGIN
      B:=M;
      BW:=W;
    END;
  END;
  BestMuster:=B;
END;

PROCEDURE CalcMConv;
VAR I,K,M,N,S,P1,P2,X1,X2,Y1,Y2:LongInt;
BEGIN
  FOR I:=0 TO 15 DO
    FOR K:=0 TO 15 DO
      MConv[I,K]:=55;
  M:=0;
FOR N:=0 TO 3 DO BEGIN
  FOR I:=0 TO 4 DO BEGIN
    FOR K:=15 DOWNTO 5 DO BEGIN
      MConv[(32-N*4+I)MOD 16,(32-N*4+K)MOD 16]:=M;
{      Init(19);
      FOR S:=0 TO 19 DO
        Move(Muster[M]^[S*20],Screen^[S*320],20);

      TransP((32-N*4+I)MOD 16,X1,Y1);
      TransP((32-N*4+K)MOD 16,X2,Y2);
      Screen^[(Y1*5+2)*320+X1*5+2]:=13;
      Screen^[(Y2*5+2)*320+X2*5+2]:=13;

      IF ReadKey=#27 THEN Halt(0);}
      Inc(M);
    END;
  END;
END;
{  FOR P1:=0 TO 15 DO
    FOR P2:=0 TO 15 DO BEGIN
      FillChar(TestMuster,400,0);
      TransP(P1,X1,Y1);X1:=X1*5;Y1:=Y1*5;
      TransP(P2,X2,Y2);X2:=X2*5;Y2:=Y2*5;
        IF X2>X1 THEN BEGIN
          FOR M:=0 TO X1-1 DO BEGIN
            N:=Y1;FOR S:=N TO 19 DO TestMuster[S*20+M]:=7;
          END;
          FOR M:=X1 TO X2-1 DO BEGIN
            N:=Y1+(Y2-Y1)*(M-X1) DIV (X2-X1-1);
            FOR S:=N TO 19 DO TestMuster[S*20+M]:=7;
          END;
          FOR M:=X2 TO 19 DO BEGIN
            N:=Y2;FOR S:=N TO 19 DO TestMuster[S*20+M]:=7;
          END;
        END ELSE BEGIN
          M:=X1;X1:=X2;X2:=M;
          M:=Y1;Y1:=Y2;Y2:=M;
          FOR M:=0 TO X1-1 DO BEGIN
            N:=Y1;FOR S:=N-1 DOWNTO 0 DO TestMuster[S*20+M]:=7;
          END;
          FOR M:=X1 TO X2-1 DO BEGIN
            N:=Y1+(Y2-Y1)*(M-X1) DIV (X2-X1-1);
            FOR S:=N-1 DOWNTO 0 DO TestMuster[S*20+M]:=7;
          END;
          FOR M:=X2 TO 19 DO BEGIN
            N:=Y2;FOR S:=N-1 DOWNTO 0 DO TestMuster[S*20+M]:=7;
          END;
        END;
     MConv[P1,P2]:=BestMuster;
     Init(19);
     FOR I:=0 TO 19 DO
       Move(TestMuster[I*20],Screen^[I*320],20);

     FOR I:=0 TO 19 DO
       Move(Muster[MConv[P1,P2]]^[I*20],Screen^[I*320+30],20);
     IF ReadKey=#27 THEN Halt(0);
  END;}
END;

BEGIN
  CreateMuster;
  GetMem(SMuster,MaxLX*MaxLY*4);
  CreateLev(Lev,10,10);
  Screen:=PTR($A000,0);
  CalcMConv;
{  CalcBestMuster;}
{  FOR M:=0 TO 31 DO BEGIN
    Init(19);
    I:=M;
    X:=0;
    Y:=0;
    REPEAT
      TestMuster[Y*5+X]:=(I AND 1=1);
      IF TestMuster[Y*5+X] THEN
        FOR K:=0 TO 3 DO FillChar(Screen^[(Y*4+K)*320+X*4],4,15);
      I:=I SHR 1;
      Inc(X);
      IF X=5 THEN BEGIN
        X:=0;
        Inc(Y);
      END;
    UNTIL Y=5;
    MConv[M]:=BestMuster;
    FOR K:=0 TO 19 DO
      FOR I:=0 TO 19 DO
        IF Muster[MConv[M]]^[K*20+I]<>0 THEN Screen^[(30+K)*320+I]:=15;
    ReadKey;
  END;}
  New(Scrp);
  Screen:=PTR($A000,0);
  LoadPCX(Screen^,Palette,'DATA.SAV\0492.PCX',0);
  Init(19);
  SetPalette(Palette);
  FOR I:=0 TO 63 DO MCol[I]:=GetNearest(I,I,I);
  LoadSprites;
  InitKeyboard;
  AkList:=1;
  AkG:=1;
  AkG2:=0;
  AkM:=1;
  AkO:=1;
  ScrX:=0;
  ScrY:=0;
  ScrG:=0;
  ScrM:=0;
  LoadLevel_NOW('DATA\'+StandardLoad+'.lvl');{}
{  CreateLev(Lev,50,30);{}
  WaitR:=False;
  REPEAT
    FillChar(Scrp^,64000,0);
    DrawStuff;
    MouseStuff;
    IF MapOn THEN DrawMap;
    IF KeyPr(15) THEN MapOn:=NOT MapOn;
    IF KeyPr(57) THEN IF (AkList=2) THEN EditAkObj
                 ELSE IF (AkList=3) THEN BEGIN
                   GetPoints(MAkX+ScrX,MakY+ScrY,I,K);
                   IF I+K=0
                     THEN SetPoints(MAkX+ScrX,MakY+ScrY,0,12)
                     ELSE SetPoints(MAkX+ScrX,MakY+ScrY,K,I);
                 END;
    IF KeyPr(59) THEN CreateDaLevel;
    IF KeyPr(60) THEN SaveLevel;
    IF KeyPr(61) THEN LoadLevel;
    IF KeyPr(33) THEN FillLevel;
    IF KeyPr(2) THEN AkList:=1;
    IF KeyPr(3) THEN AkList:=2;
    IF KeyPr(4) THEN AkList:=3;
    IF KeyPr(19) THEN BEGIN
      GetPoints(MAkX+ScrX,MakY+ScrY,I,K);
      SetPoints(MAkX+ScrX,MakY+ScrY,(I+4)MOD 16,(K+4)MOD 16)
    END;
    If Key[29] AND Key[56] THEN BEGIN
      IF KeyPr(77) THEN BEGIN
        FOR I:=Lev.LXS-1 DOWNTO 1 DO
          FOR K:=0 TO Lev.LYS-1 DO BEGIN
            Lev.LevD^[K*Lev.LXS+I]:=Lev.LevD^[K*Lev.LXS+I-1];
            Lev.LevM^[K*Lev.LXS+I]:=Lev.LevM^[K*Lev.LXS+I-1];
            Deep:=-1;
            GetPoints(I-1,K,P1,P2);
            SetPoints(I,K,P1,P2);
          END;
      END;
    END;
{    IF KeyPr(28) THEN BEGIN
      TextMode(3);
      WriteLn(GetNum(0,0));
      Halt(0);
    END;}
    IF (KeyPr(49))AND(AkList=1)AND(MAkY<=7)THEN AkG:=Lev.LevD^[(MAkY+ScrY)*Lev.LXS+MAkX+ScrX];
    IF KeyPr(88) THEN LoadLevel_NOW('DATA\'+StandardLoad+'.lvl');
    Move(Scrp^,Screen^,64000);
  UNTIL KeyPr(1);
  DoneKeyBoard;
  GFXClose;
  WriteLn(Lev.LXS,'x',Lev.LYS);
END.