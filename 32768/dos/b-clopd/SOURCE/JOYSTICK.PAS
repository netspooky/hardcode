unit Joystick;

{
Copyright (c) 1989 David B. Howorth

Last revised May 9, 1989.  Requires Turbo Pascal 5.0.

This file, when compiled to disk, creates JOYSTICK.TPU, a Turbo Pascal unit
containing all necessary routines for joystick control.  The routines can
be demonstrated by running the accompanying program JOYDEMO (after first
compiling JOYSTICK.PAS to disk).

For further information see the accompanying file, JOYSTICK.DOC.

Permission is granted to distribute this file and the accompanying files
(JOYDEMO.PAS and JOYSTICK.DOC) provided (1) all three files are distributed
together and (2) no fee is charged.

Permission is granted to include compiled versions of the routines in these
files in any program, commercial or noncommercial, provided only that if the
program is distributed, whether commercially or noncommercially, a copy
(including any documentation) be sent to the author.  My address is
99 Lincoln Pl., Brooklyn, NY 11217.
}

interface

procedure ReadJoyA(var XAxis, YAxis : word);
{ Reads the X and Y coordinates of Joystick A. }

procedure ReadJoyB(var XAxis, YAxis : word);
{ Reads the X and Y coordinates of Joystick B. }

function ButtonA1 : boolean;
function ButtonA2 : boolean;
function ButtonB1 : boolean;
function ButtonB2 : boolean;
{ These four functions return the status (true = in; false = out) of each
  of the buttons on joystick A and B.  On most models, Button #1 is the
  top button. }

function JoystickPresent : boolean;
{ This function indicates whether a joystick is installed. }

implementation

uses Dos;

type
  ReadJoyProc = procedure(a,b : byte;var c,d : word);
  ButtonFunc = function(a : byte) : boolean;

var
  ReadJoy : ReadJoyProc;
  Button : ButtonFunc;
  Reg : Registers;

{----------------------------- private routines ----------------------------}

function NewBIOS : boolean;
var
  DecadeChar : char absolute $F000:$FFFB;
  YearChar : char absolute $F000:$FFFC;
begin
  NewBIOS := (DecadeChar in ['9','0']) {an optimistic view of software life}
    or ((DecadeChar = '8') and (YearChar in ['4'..'9']));
end;

{$F+}

procedure OldReadJoy(xbit,ybit : byte; var XAxis, YAxis : word);
begin
inline(
  $BA/$01/$02/    {mov  dx, 201h      ;load dx with joystick port address   }
  $C4/$BE/>XAxis/ {les  di, XAxis[bp] ;load es with segment and di w/offset }
  $8A/$66/<xbit/  {mov  ah, xbit[bp]  ;set appropriate bit in ah            }
  $E8/$0C/$00/    {call SUBR                                                }
  $C4/$BE/>YAxis/ {les  di, YAxis[bp]                                       }
  $8A/$66/<ybit/  {mov  ah, ybit[bp]  ;set appropriate bit in ah            }
  $E8/$02/$00/    {call SUBR                                                }
  $EB/$1D/        {jump short END     ;we're done!                          }
                  {SUBR:              ;first wait, if necessary, until      }
                  {                   ; relevant bit is 0:                  }
  $B9/$FF/$FF/    {       mov  cx, 0ffffh ;fill cx to the brim              }
  $EC/            {WAIT:  in   al, dx     ;get input from port 201h         }
  $84/$E0/        {       test al, ah     ;is the relevant bit 0 yet?       }
  $E0/$FB/        {       loopne WAIT     ;if not, go back to wait          }

  $B9/$FF/$FF/    {       mov  cx, 0ffffh ;fill cx to the brim again        }
  $FA/            {       cli             ;disable interrupts               }
  $EE/            {       out  dx, al     ;'nudge' port 201h                }
  $EC/            {AGAIN: in   al, dx     ;get input from port 201h         }
  $84/$E0/        {       test al, ah     ;is the relevant bit 0 yet?       }
  $E0/$FB/        {       loopne AGAIN    ;if not, go back to AGAIN         }
  $FB/            {       sti             ;reenable interrupts              }
  $F7/$D9/        {       neg  cx         ;negative cx                      }
  $81/$C1/$FF/$FF/{       add  cx, 0ffffh ;add 0ffffh back to value in cx   }
  $26/            {       es:             ;segment override                 }
  $89/$0D/        {       mov  [di], cx   ;store value of cx in location    }
                  {                       ; of relevant variable            }
  $C3);           {       ret                                               }
                  {END:                                                     }
end; { OldReadJoy }

procedure NewReadJoy(which, meaningless : byte; var XAxis, YAxis : word);
begin
  Reg.ah := $84;
  Reg.dx := 1;
  intr($15,Reg);
  if (which = 1)
    then begin
           XAxis := Reg.ax;
           YAxis := Reg.bx;
         end
    else begin
           XAxis := Reg.cx;
           YAxis := Reg.dx;
         end;
end;

function OldButton(mask : byte) : boolean;
begin OldButton := ((port[$201] and mask) = 0); end;

function NewButton(mask : byte) : boolean;
begin
  Reg.ah := $84;
  Reg.dx := 0;
  intr($15,Reg);
  NewButton := ((Reg.al and mask) = 0);
end;

{$F-}

{----------------------------- public routines -----------------------------}

procedure ReadJoyA(var XAxis, YAxis : word);
begin ReadJoy(1,2,XAxis, YAxis); end;

procedure ReadJoyB(var XAxis, YAxis : word);
begin ReadJoy(4,8,XAxis, YAxis); end;

function ButtonA1 : boolean;
begin ButtonA1 := Button($10); end;

function ButtonA2 : boolean;
begin ButtonA2 := Button($20); end;

function ButtonB1 : boolean;
begin ButtonB1 := Button($40); end;

function ButtonB2 : boolean;
begin ButtonB2 := Button($80); end;

function JoystickPresent : boolean;
begin
  intr($11,Reg);
  JoystickPresent := ((Reg.ax and $1000) <> 0);
end;

{------------------------------ initialization -----------------------------}

begin
  if NewBIOS
    then begin                         { use BIOS routines }
           ReadJoy := NewReadJoy;
           Button := NewButton;
         end
    else begin                         { use work-around routines }
           ReadJoy := OldReadJoy;
           Button := OldButton;
         end;
end.