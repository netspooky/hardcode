USES DataFile,DataFil2;
VAR I,K,M:LongInt;
BEGIN
  M:=3;
  K:=2;
  IF M<K THEN BEGIN
    PlDat;
    MidiDat;
    OtherDat;
    PaletteDat;
    BackGroundDat;
    ObjDat;
  END;
END.