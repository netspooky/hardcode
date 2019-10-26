program JoyDemo;

{
Copyright (c) 1989 David B. Howorth

Last revised May 9, 1989.  Requires Turbo Pascal 5.0.

This program demonstrates the procedures and functions in JOYSTICK.TPU.
NOTE that before this demonstration can work JOYSTICK.TPU must be compiled
to disk from the accompanying file JOYSTICK.PAS.

Permission is granted to distribute this file and the accompanying files
(JOYSTICK.PAS and JOYSTICK.DOC) provided (1) all three files are distributed
together and (2) no fee is charged.

Permission is granted to include compiled versions of the routines in these
files in any program, commercial or noncommercial, provided only that if the
program is distributed, whether commercially or noncommercially, a copy
(including any documentation) be sent to the author.  My address is
99 Lincoln Pl., Brooklyn, NY 11217.
}

Uses Dos, Crt, Joystick;

const
  header = '                         JOYSTICK DEMONSTRATION NUMBER ';
  footer ='                   Press a joystick button to end demonstration.';
  DemoChar = #22;

type
  CursorType = (none,normal,fat);

var
  InitX, InitY : word;
  { These variables are initialized at start up to get the coordinates of
    Joystick A when it is centered.  If Joystick A is not centered at
    start up, Demo3 may not work correctly. }

  NumberOfSticks : byte;

  Reg : Registers;

  CursorStartLine, CursorEndLine : byte;

{--------------------------------------}

procedure GetCursorData;
begin
  Reg.ah := $0F;
  intr($10,Reg);
  Reg.ah := $03;
  intr($10,Reg);
  CursorStartLine := Reg.ch;
  CursorEndLine := Reg.cl;
end;

{--------------------------------------}

procedure SetCursor(c : CursorType);
begin
  case c of
    none : Reg.ch := $20;
    normal : Reg.ch := CursorStartLine;
    fat : Reg.ch := 0;
  end;
  Reg.cl := CursorEndLine;
  Reg.ah := 1;
  intr($10,Reg);
end;

{--------------------------------------}

procedure DrawBox(x1,y1,x2,y2 : integer);
var
  i : byte;
begin
  gotoxy(x1,y1);
  write(#218);
  for i := x1 + 1 to x2 - 1 do write(#196);
  write(#191);
  for i := y1 + 1 to y2 - 1 do
  begin
    gotoxy(x1,i);
    write(#179);
    gotoxy(x2,i);
    write(#179);
  end;
  gotoxy(x1,y2);
  write(#192);
  for i := x1 + 1 to x2 - 1 do write(#196);
  write(#217);
end;

{--------------------------------------}

procedure Demo1;
var  ch : char;
begin
  clrscr;
  writeln(header,'1');
  gotoxy(1,7);
  writeln
  ('This is just a test of the function JoystickPresent, which indicates,');
  writeln('as you might guess, whether a joystick is present.');
  writeln;
  if JoystickPresent
    then writeln('You have one.')
    else writeln('You don''t have one attached.');
  writeln;
  writeln;
  write('Caveat:  See section F.2. of JOYSTICK.DOC.');
  gotoxy(14,23);
  write('How many joysticks do you have installed?  ');
  repeat
    ch := readkey;
  until ch in ['0'..'2'];
  NumberOfSticks := ord(ch) - 48;
end;

{--------------------------------------}

procedure Demo2;

{ This demonstates both ReadJoy, which reads the joystick X and Y coordinates
  and the functions ButtonA1, etc., which read the 4 joystick buttons.
  Outputs raw data to the screen. }

const
  line1a = 'JOYSTICK A';
  line1b = '                                 JOYSTICK B';
  line2a = 'X-Axis  Y-Axis  Button 1  Button 2';
  line2b = '         X-Axis  Y-Axis  Button 1  Button 2';

type
  StatusStringType = string[3];

var
  JoyAX, JoyAY, JoyBX, JoyBY : word;
  line : string;
  ch : char;

{-------}

  function ButtonStatusSt(b : boolean) : StatusStringType;
  begin
    if b then ButtonStatusSt := 'IN' else ButtonStatusSt := 'OUT';
  end;

{-------}

begin
  clrscr;
  SetCursor(none);
  writeln(header,'2');
  writeln;
  writeln('                        (Joystick input shown as raw data)');
  if (NumberOfSticks = 2)
    then line := line1a + line1b
    else line := line1a;
  gotoxy(40 - (length(line) div 2),7);
  writeln(line);
  if (NumberOfSticks = 2)
    then line := line2a + line2b
    else line := line2a;
  gotoxy(40 - (length(line) div 2),8);
  write(line);
  gotoxy(24,23);
  write('To go on to next demo, press a key.');

  repeat
    ReadJoyA(JoyAX,JoyAY);
    if (NumberOfSticks = 2)
      then gotoxy(1,9)
      else gotoxy(22,9);
    write(JoyAX:5,JoyAY:8,
          ButtonStatusSt(ButtonA1):9,ButtonStatusSt(ButtonA2):10);
    if (NumberOfSticks = 2)
      then begin
             ReadJoyB(JoyBX,JoyBY);
             write(JoyBX:16,JoyBY:8,
                   ButtonStatusSt(ButtonB1):9,ButtonStatusSt(ButtonB2):10);
           end;
  until keypressed;
  while keypressed do ch := readkey;  { clear key buffer }
end; { Demo2 }

{--------------------------------------}

procedure Demo3;
  { Shows how to use the joystick as a DIRECTION indicator. }

var
  JoyX, JoyY       : word;
  ScreenX, ScreenY : byte;

begin
  clrscr;
  SetCursor(none);
  writeln(header,'3');
  writeln;
  writeln('                        (Joystick as direction indicator)');
  gotoxy(1,25);
  write(footer);
  DrawBox(1,5,80,24);
  ScreenX := 40;                  { Initial coordinates of character }
  ScreenY := 14;                  { in center of the box.            }

  repeat
    gotoxy(ScreenX,ScreenY);
    write(' ');                       { erase previous character }
    ReadJoyA(JoyX,JoyY);
    if JoyX > InitX + (InitX div 5)
      then inc(ScreenX)
      else if JoyX < InitX - (InitX div 5)
             then dec(ScreenX);
    if JoyY > InitY + (InitY div 5)
      then inc(ScreenY)
      else if JoyY < InitY - (InitY div 5)
             then dec(ScreenY);

{ If all you are interested in is what direction the joystick has been moved,
  all you need to do is compare the current position with the initial
  position calibrated by the program.  If you want your program to be
  relatively portable, you ought to make the comparison in as relative terms
  as possible, i.e., use something like 'if JoyX > InitX + (InitX div 5)',
  rather than something like 'if JoyX > InitX + 10'.  It's possible the
  latter expression won't work effectively with some makes of joystick or at
  the speed of some chips.                                                  }

    if ScreenX > 79 then ScreenX := 79;        { make sure      }
    if ScreenX < 2 then ScreenX := 2;          { the character  }
    if ScreenY > 23 then ScreenY := 23;        { doesn't get    }
    if ScreenY < 6 then ScreenY := 6;          { out of the box }
    gotoxy(ScreenX,ScreenY);
    write(DemoChar);
    delay(30);                         { slow things down a bit }
  until ButtonA1 or ButtonA2;
  repeat until not (ButtonA1 or ButtonA2); { wait till button no longer in }
end; { Demo3 }

{--------------------------------------}

procedure Demo4;
{ Shows how to use the joystick as a POSITION indicator. }

var
  LowX,      { Minimum and          }
  LowY,      { maximum joystick     }
  HighX,     { coordinates,read     }
  HighY,     { once, at calibration.}

  JoyX,      { Current joystick coordinates, }
  JoyY       { read repeatedly.              }

             : word;

  ScreenX,   { Screen coordinates of cursor, }
  ScreenY,   { derived from JoyX and JoyY.   }
  OldScreenX,
  OldScreenY : byte;

begin
  clrscr;
  writeln(header,'4');
  writeln;
  writeln('                         (Joystick as position indicator)');
  gotoxy(1,7);
  writeln('You may want to try this demo with the joystick unlocked.');

  { Calibrate joystick: }
  gotoxy(1,9);
  repeat
   writeln
   ('Move joystick to upper-left corner and press one of its buttons.');
   repeat until ButtonA1 or ButtonA2;
   ReadJoyA(LowX,LowY);
   repeat until not (ButtonA1 or ButtonA2); { wait till button no longer in }
   writeln
   ('Move joystick to lower-right corner and press one of its buttons.');
   repeat until ButtonA1 or ButtonA2;
   ReadJoyA(HighX,HighY);
   repeat until not (ButtonA1 or ButtonA2); { wait till button no longer in }
   if (LowX >= HighX) or (LowY >= HighY)
     then begin
            writeln;
            writeln('You did not calibrate correctly.  Please recalibrate.');
            writeln;
          end;
  until (LowX < HighX) and (LowY < HighY);
  clrscr;
  SetCursor(none);
  DrawBox(1,1,80,24);
  gotoxy(1,25);
  write(footer);
  OldScreenX := 100; OldScreenY := 100; { so first erasure will be ignored }
  repeat
    ReadJoyA(JoyX,JoyY);

    if JoyX < LowX then JoyX := LowX;  { If joystick was not at extreme     }
    if JoyX > HighX then JoyX := HighX;{ positions during calibration,      }
    if JoyY < LowY then JoyY := LowY;  { screen coordinates may lie off-    }
    if JoyY > HighY then JoyY := HighY;{ screen.  These statements fix that.}

    ScreenX := (((JoyX - LowX + 1) * 77) div (HighX - LowX)) + 2;
    ScreenY := (((JoyY - LowY + 1) * 21) div (HighY - LowY)) + 2;
    { The above formulas simply calculate a position on the screen for the
      cursor. }

    if (OldScreenX <> ScreenX) or (OldScreenY <> ScreenY)
      then begin
             gotoxy(OldScreenX,OldScreenY);write(' ');
             gotoxy(ScreenX,ScreenY);write(DemoChar);
             OldScreenX := ScreenX; OldScreenY := ScreenY;
           end;
    gotoxy(1,1);  { <-- Don't know why, but this seems to make this demo a }
                  {     little less fluttery.  Should be unneccessary with }
                  {     programs that do more than this one.               }
  until ButtonA1 or ButtonA2;
end; { Demo4 }

begin { main program }
  ReadJoyA(InitX,InitY);
  { Calibrate joystick.  These values will be used as the base values for
    Demo3.  The demo assumes that at startup Joystick A will be centered.
    If it is not, Demo3 will probably not work correctly. }
  GetCursorData;
  Demo1;
  if (NumberOfSticks = 0) then halt;
  Demo2;
  Demo3;
  Demo4;
  clrscr;
  SetCursor(normal);
end.
