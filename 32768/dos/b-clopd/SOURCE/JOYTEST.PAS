USES Crt,Joystick;
VAR X,Y:Word;
BEGIN
  REPEAT
    ClrScr;
    ReadJoyA(X,Y);
    WriteLn('        ',X);
    WriteLn('        ',Y);
    WriteLn('        ',ButtonA1);
    Delay(20);
  UNTIL KeyPressed;
  ReadKey;
END.