{ Использование: заменяете в своей программе все    }
{ out dx,al, имеющие отношение к midi, на int 3     }
{ и запускаете gm_spk ваша_программа                }
{ Примечание: высота нот произвольная - исправляйте }
{ сами. Пока не поддерживаются ударники.            }
{$M 8192,0,0}
{$N-}
uses Crt,Dos;

const FNum:array[0..11] of Word=
          ($16B,$181,$198,$1B0,$1CA,$1E5,
           $202,$220,$241,$263,$287,$2AE);

var BufS: array[0..8,0..15] of Char; {9 channels x 16 byte}


procedure Bit;
begin
  Delay(1); {something fancier was suggested, but this works fine}
end;

function CheckSoundCard: Boolean;
begin
  CheckSoundCard:=True;
end;

procedure ClearCard;
begin
  NoSound;
end;

procedure SetInstr(Channel,Instr:Byte);
begin
end;

procedure PlayNote(Channel,Note,Volume:Byte);
var F,O,N,I:Word;
begin
  O:=Note div 12;
  N:=Note mod 12;
  F:=round(20*exp(Note*ln(2)/12));
  Sound(F);
  Delay(20);
  NoSound;
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

  ClearCard;
end.
