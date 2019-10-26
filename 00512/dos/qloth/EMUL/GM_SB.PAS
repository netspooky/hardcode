{ Софтина основана на SBI-плеере из SWAG            }
{ Использование: заменяете в своей программе все    }
{ out dx,al, имеющие отношение к midi, на int 3     }
{ и запускаете gm_sb ваша_программа                 }
{ Примечание: высота нот произвольная - исправляйте }
{ сами. Пока не поддерживаются ударники.            }

{$M 8192,0,0}
{$N-}
uses Crt,Dos;
const InsReg : array[0..10] of Word =
  ($23,$20,$43,$40,$63,$60,$83,$80,$C0,$E3,$E0);
const ChannelShift : array[0..8] of Word =
  ($00,$01,$02,$08,$09,$0A,$10,$11,$12);
{   Channel        1   2   3   4   5   6   7   8   9}
{   Operator 1    00  01  02  08  09  0A  10  11  12}
{   Operator 2    03  04  05  0B  0C  0D  13  14  15}

const FNum:array[0..11] of Word=
          ($16B,$181,$198,$1B0,$1CA,$1E5,
           $202,$220,$241,$263,$287,$2AE);


{
Bytes A0-B8 - Octave / F-Number / Key-On

        7     6     5     4     3     2     1     0
     +-----+-----+-----+-----+-----+-----+-----+-----+
     |        F-Number (least significant byte)      |  (A0-A8)
     |                                               |
     +-----+-----+-----+-----+-----+-----+-----+-----+

        7     6     5     4     3     2     1     0
     +-----+-----+-----+-----+-----+-----+-----+-----+
     |  Unused   | Key |    Octave       | F-Number  |  (B0-B8)
     |           | On  |                 | most sig. |
     +-----+-----+-----+-----+-----+-----+-----+-----+

          bit   5  - Channel is voiced when set, silent when clear.
          bits 4-2 - Octave (0-7).  0 is lowest, 7 is highest.
          bits 1-0 - Most significant bits of F-number.

     In octave 4, the F-number values for the chromatic scale and their
     corresponding frequencies would be:

        F Number     Frequency     Note
           16B          277.2       C#
           181          293.7       D
           198          311.1       D#
           1B0          329.6       E
           1CA          349.2       F
           1E5          370.0       F#
           202          392.0       G
           220          415.3       G#
           241          440.0       A
           263          466.2       A#
           287          493.9       B
           2AE          523.3       C
}

var
  CH: Char;
  IsSBI: boolean;
  SBIName: string;

var BufS: array[0..8,0..15] of Char; {9 channels x 16 byte}


procedure Bit;
begin
  Delay(1); {something fancier was suggested, but this works fine}
end;

function CheckSoundCard: Boolean;
var Temp, Temp2: Byte;
begin
  port[$388]:=$4; repeat until Port[$22E] > 127;
  port[$389]:=$60; repeat until Port[$22E] > 127;
  port[$389]:=$80; repeat until Port[$22E] > 127;
  Temp:=port[$388];
  port[$388]:=$2; repeat until Port[$22E] > 127;
  port[$389]:=$FF; repeat until Port[$22E] > 127;
  port[$388]:=$4; repeat until Port[$22E] > 127;
  port[$389]:=$21; repeat until Port[$22E] > 127;
  Delay(1);
  Temp2:=port[$388];
  port[$388]:=$4; repeat until Port[$22E] > 127;
  port[$389]:=$60; repeat until Port[$22E] > 127;
  port[$389]:=$80; repeat until Port[$22E] > 127;
  If ((temp and $E0)=$00) and ((temp2 and $E0)=$c0) then
    CheckSoundCard:=True else CheckSoundCard:=False;
end;
procedure ClearCard;
var CP: byte;
begin
  For CP:=0 to 255 do begin
    port[$388]:=CP;
    port[$389]:=0;
  end;
end;
procedure Sounder(A,B: byte);
begin
  port[$388]:=A; Bit;
  port[$389]:=B; Bit;
end;

procedure SetInstr(Channel,Instr:Byte);
var S:string;
    F:file;
begin
  S:='midi000.ins';
  S[5]:=Char($30+(Instr div 100) mod 10);
  S[6]:=Char($30+(Instr div 10) mod 10);
  S[7]:=Char($30+(Instr div 1) mod 10);
  Assign(F, S);
  ReSet(F, 1);
  BlockRead(F,BufS[Channel],SizeOf(BufS[Channel]));
  Close(F);
end;

procedure PlayNote(Channel,Note,Volume:Byte);
var F,O,N,I:Word;
begin
  O:=Note div 12;
  N:=Note mod 12;
  F:=FNum[N] + O*$400+$2000;
  SoundER($B0+Channel,0);
  for I:=1 to 11 do
    SoundER(InsReg[I]+ChannelShift[Channel],
            Ord(BufS[Channel,I]));
  SoundER($A0+Channel,Lo(F));
  SoundER($B0+Channel,Hi(F));
end;

procedure Out(Flags, CS, IP, AX, BX, CX, DX, Si, DI, DS, ES, BP: Word); interrupt;
{в основной проге вместо out dx,al - int3}
const State:Byte=0;
      C:Byte=0;
      N:Byte=0;
      V:Byte=0;
begin
  if DX=$330 then begin
    case State of
      0: begin
        if (AX and $F0)=$90 then begin
           C:=AX and $0F;
           State:=1;
        end;
        if (AX and $F0)=$C0 then begin
           C:=AX and $0F;
           State:=3;
        end;
      end;
      1: begin {note_on,note}
        N:=Lo(AX);
        State:=2;
      end;
      2: begin {note_on,volume}
        V:=Lo(AX);
        PlayNote(C,N,V);
        State:=0;
      end;
      3: begin {set_instr,instr}
        N:=Lo(AX);
        SetInstr(C,N+1);
        State:=0;
      end;
    end;
  end;
end;

(* debug only - убрать 'interrupt' у процедуры out
procedure WGM(X:Byte);
begin
  Out(0, 0, 0, X, 0, 0, $330, 0, 0, 0, 0, 0);{ interrupt;}
end;
*)

var Int3Save : Pointer;

begin
{  if not CheckSoundCard then begin
    WriteLn('Soundcard not detected!');
    halt(1);
  end;}

  ClearCard;
  SwapVectors;
  GetIntVec(3,Int3Save);
  SetIntVec(3,Addr(Out));
  Exec(GetEnv('COMSPEC'), '/C '+ParamStr(1));
  SetIntVec(3,Int3Save);
  SwapVectors;

(*
  WGM($C0+0); WGM(1); { SetInstr(0,1); }
  WGM($C0+1); WGM(14); { SetInstr(1,14); }
  WGM($90+0); WGM($37); WGM(127); { SetNoteOn(0,$37+B[I*2],127);{}
  Delay(300);
  WGM($90+1); WGM($37); WGM(127); { SetNoteOn(0,$37+B[I*2],127);{}
  Delay(900);
*)

(*
  SetInstr(0,3);
  PlayNote(0,48,127);
  Delay(50);
  PlayNote(1,48,127);
  Delay(50);
  PlayNote(2,48,127);
{  for I:=0 to 10 do SoundER(InsReg[I],Ord(Buf[I]));
  SoundER($A0,$58);
  SoundER($B0,$31);}
*)
  ClearCard;
end.
