USES Crt,ModiGraf;
TYPE tMuster=ARRAY[0..399]OF Byte;
VAR I,K,M:LongInt;
    Muster:ARRAY[0..99]OF ^tMuster;
    Screen:^tScreen;

PROCEDURE RotateAndCreate(Sou,Des:LongInt);
VAR I,K,M:LongInt;
BEGIN
  New(Muster[Des]);
  FOR K:=0 TO 19 DO
    FOR I:=0 TO 19 DO
      Muster[Des]^[I*20+19-K]:=Muster[Sou]^[K*20+I];
END;

PROCEDURE CreateMuster;
VAR R,RStep,S1,S2,I,K,M,X1,X2,X,Y:LongInt;
BEGIN
S1:=0;
S2:=0;
FOR M:=0 TO 24 DO BEGIN
  New(Muster[M]);
  FillChar(Muster[M]^,400,0);
  X1:=S1*5;
  X2:=S2*5;
  R:=0;
  FOR X:=0 TO 19 DO BEGIN
    R:=R+(LongInt(Random(3))-1);
    FOR Y:=19 DOWNTO (R DIV 3+X1+((X2-X1)*X)DIV 19) DO IF(Y>=0)AND(Y<20)THEN
      Muster[M]^[Y*20+X]:=15;
  END;
  Inc(S2);
  IF S2=5 THEN BEGIN Inc(S1);S2:=0; END;
END;
FOR M:=1 TO 3 DO
  FOR K:=0 TO 24 DO BEGIN
    RotateAndCreate((M-1)*25+K,M*25+K);
    FillChar(Screen^,64000,0);
    FOR I:=0 TO 19 DO Move(Muster[M*25+K]^[I*20],Screen^[I*320],20);
    IF ReadKey=#27 THEN Halt(0);
  END;
END;

BEGIN
  Randomize;
  Init(19);
  Screen:=PTR($A000,0);
  CreateMuster;
  TextMode(3);
END.