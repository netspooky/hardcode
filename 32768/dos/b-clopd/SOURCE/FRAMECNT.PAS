UNIT FrameCnt;
INTERFACE
USES Dos;
TYPE TFrameRate=RECORD
                  OldSec,NewSec:Word;
                  FCnt:Word;
                END;
VAR Frame:TFrameRate;
    Frames,HighestF:LongInt;
    H,M,HS:Word;

PROCEDURE FrameRate(Tick,FPS:LongInt);

IMPLEMENTATION

PROCEDURE FrameRate(Tick,FPS:LongInt);
BEGIN
  WITH Frame DO BEGIN
    OldSec:=NewSec;
    NewSec:=Tick DIV FpS;
    IF OldSec=NewSec THEN Inc(FCnt) ELSE BEGIN
      Frames:=FCnt;
      IF FCnt>HighestF THEN HighestF:=FCnt;
      FCnt:=0;
    END;
  END;
END;

BEGIN
  Frames:=0;
  HighestF:=0;
END.