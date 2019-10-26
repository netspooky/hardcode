USES Crt;
VAR I:LongINT;
BEGIN
  I:=0;
  REPEAT
    WriteLn(I,' -> ',Chr(I));
    Inc(I);
  UNTIL ReadKey=#27;
END.