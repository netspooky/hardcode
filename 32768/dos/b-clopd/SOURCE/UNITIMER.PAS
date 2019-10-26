UNIT UniTimer;

INTERFACE

USES Dos;
VAR OldInt8:Pointer;
    L:LongInt;

PROCEDURE InstallTimer(Proc:Pointer;FpS:Real);
PROCEDURE RestoreTimer;

IMPLEMENTATION

PROCEDURE InstallTimer(Proc:Pointer;FpS:Real);
BEGIN
  ASM cli END;
  IF FpS<>0 THEN L := Round(1193180/FpS) ELSE L:=0;
  Port[$43] := $36;
  Port[$40] := Lo(L);
  Port[$40] := Hi(L);
  GetIntVec(8,OldInt8);
  SetIntVec(8,Proc);
  ASM sti END;
END;

PROCEDURE RestoreTimer;
BEGIN
  ASM cli END;
  Port[$43] := $36;
  Port[$40] := 0;
  Port[$40] := 0;
  SetIntVec(8,OldInt8);
  ASM sti END;
END;

BEGIN
END.