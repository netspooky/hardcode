USES Crt;
CONST
      DaLevel='DATA\intro.LVL';
      DaOutLevel='DATA\Opt.LVL';
      MaxLX=160;
      MaxLY=100;
      MaxObjekte=100;
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
     tObjekt=RECORD
               Typ:LongInt;
               XS,YS:Real;
               XX,YY:Real;
               Spr:Pointer;
               Par:ARRAY[1..10]OF LongInt;
             END;
VAR Lev:tLevel;
    Objekte:LongInt;
    Obj:ARRAY[1..MaxObjekte]OF tObjekt;



PROCEDURE SaveLevel_NOW(St:STRING);
VAR F:FILE;
    I,K,M,P,BW:LongInt;
    A,B,BI,BC:Byte;

BEGIN
  Assign(F,ST);
  ReWrite(F,1);
  BlockWrite(F,Lev,SizeOf(Lev)-4);
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
    Inc(P);
  END;
  BlockWrite(F,A,1);
  BlockWrite(F,B,1);{}

  BlockWrite(F,Objekte,4);
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
    B:=Typ;
    BlockWrite(F,B,1);
    BlockWrite(F,XX,SizeOf(Real));
    BlockWrite(F,YY,SizeOf(Real));
    B:=Par[1];
    BlockWrite(F,B,1);
  END;
  ClosE(F);
END;


PROCEDURE LoadLevel_NOW(St:STRING);
VAR F:FILE;
    BR,P1,P2,I,K,M,P:LongInt;
    A,B,BI,BC:Byte;
BEGIN
  Assign(F,ST);
  ReSet(F,1);
  BlockRead(F,Lev,SizeOf(Lev)-4);
  GetMem(Lev.LevD,Lev.LXS*Lev.LYS);
  GetMem(Lev.LevM,Lev.LXS*Lev.LYS);

  BI:=7;
  P:=0;
  BR:=0;
  WHILE P<Lev.LXS*Lev.LYS DO BEGIN
    BlockRead(F,A,1);
    BlockRead(F,B,1);{}
    FillChar(Lev.LevD^[P],A,B);
    Inc(P,A);
  END;
  BlockRead(F,Objekte,4);
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
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

FUNCTION NothingInLine(L:LongInt):Boolean;
VAR I,K,M:LongInt;
BEGIN
  NothingInLine:=True;
  WITH Lev DO BEGIN
    FOR I:=0 TO LXS-1 DO
      IF LevD^[L*LXS+I]<>0 THEN NothingInLine:=False;
  END;
END;

FUNCTION NothingInRow(L:LongInt):Boolean;
VAR I,K,M:LongInt;
BEGIN
  NothingInRow:=True;
  WITH Lev DO BEGIN
    FOR K:=0 TO LYS-1 DO
      IF LevD^[K*LXS+L]<>0 THEN NothingInRow:=False;
  END;
END;

PROCEDURE DelLine(L:LongInt);
VAR I,K,M,LP:LongInt;
    TLevD:^tLev;
BEGIN
  WITH Lev DO BEGIN
    GetMem(TLevD,LXS*LYS);
    Move(LevD^,TLevD^,LXS*LYS);
    FreeMem(LevD,LXS*LYS);
    GetMem(LevD,LXS*(LYS-1));
    LP:=0;
    FOR K:=0 TO LYS-2 DO BEGIN
      IF K=L THEN Inc(LP);
      FOR I:=0 TO LXS-1 DO BEGIN
        LevD^[K*LXS+I]:=TLevD^[LP*LXS+I];
      END;
      Inc(LP);
    END;
    FreeMem(TLevD,LXS*LYS);
    Dec(LYS);
  END;
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
    IF YY/20>=L THEN YY:=YY-20;
  END;
END;

PROCEDURE DelRow(L:LongInt);
VAR I,K,M,LP:LongInt;
    TLevD:^tLev;
BEGIN
  WITH Lev DO BEGIN
    GetMem(TLevD,LXS*LYS);
    Move(LevD^,TLevD^,LXS*LYS);
    FreeMem(LevD,LXS*LYS);
    GetMem(LevD,(LXS-1)*LYS);
    FOR K:=0 TO LYS-1 DO BEGIN
      LP:=0;
      FOR I:=0 TO LXS-2 DO BEGIN
        IF I=L THEN Inc(LP);
        LevD^[K*(LXS-1)+I]:=TLevD^[K*LXS+LP];
        Inc(LP);
      END;
    END;
    FreeMem(TLevD,LXS*LYS);
    Dec(LXS);
  END;
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
    IF XX/20>=L THEN XX:=XX-20;
  END;
END;

PROCEDURE InsRow(L:LongInt);
VAR I,K,M,LP:LongInt;
    TLevD:^tLev;
BEGIN
  WITH Lev DO BEGIN
    GetMem(TLevD,LXS*LYS);
    Move(LevD^,TLevD^,LXS*LYS);
    FreeMem(LevD,LXS*LYS);
    GetMem(LevD,(LXS+1)*LYS);
    FOR K:=0 TO LYS-1 DO BEGIN
      LP:=0;
      FOR I:=0 TO LXS DO BEGIN
        IF I=L THEN Dec(LP);
        LevD^[K*(LXS+1)+I]:=TLevD^[K*LXS+LP];
        Inc(LP);
      END;
    END;
    FreeMem(TLevD,LXS*LYS);
    Inc(LXS);
  END;
  FOR I:=1 TO Objekte DO WITH Obj[I] DO BEGIN
    IF XX/20>=L THEN XX:=XX+20;
  END;
END;

PROCEDURE OptLevel;
VAR I,K,M:LongInt;
BEGIN
  WHILE NothingInLine(0) DO DelLine(0);
  WHILE NothingInLine(Lev.LYS-1) DO DelLine(Lev.LYS-1);
  WHILE NothingInRow(0) DO DelRow(0);
  WHILE NothingInRow(Lev.LXS-1) DO DelRow(Lev.LXS-1);
  FOR I:=1 TO 21 DO InsRow(Lev.LXS-35);
END;

BEGIN
  ClrScr;
  LoadLevel_NOW(DaLevel);
  WITH Lev DO
    WriteLn('InLevel : ',LXS,' x ',LYS);
  ReadKey;
  OptLevel;
  WITH Lev DO
    WriteLn('OutLevel : ',LXS,' x ',LYS);
  ReadKey;
  SaveLevel_NOW(DaOutLevel);
END.