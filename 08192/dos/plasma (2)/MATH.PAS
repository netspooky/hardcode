{ Fast ? math library.                                                 }
{ Just faster than standard funtcions. Non-optimized.                  }
{                                                                      }
{                                               Spanish Lords  Feb 94  }

UNIT Math;

INTERFACE

var
  TblSinCos   : Array [0..360+90] of Integer;
  SquareTable : Array [0..640   ] of LongInt;

Function FSin (Ang:Word):Integer;
Function FCos (Ang:Word):Integer;
Function FSqrt(Min,Max:Word;Dato:LongInt):Word;

IMPLEMENTATION

var
  Cnt       : Word;


Function FSin (Ang:Word):Integer;

Begin
   If Ang>360 then Ang:=Ang mod 360;
   FSin:=TblSinCos[Ang];
End;

Function FCos (Ang:Word):Integer;

Begin
   If Ang>360 then Ang:=Ang mod 360;
   Inc (Ang,90);
   FCos:=TblSinCos[Ang];
End;

Function FSqrt(Min,Max:Word;Dato:LongInt):Word;

label vuelve,fin;

var
  Cursor : Word;
  AuxVal : LongInt;

begin
vuelve:
   asm
      mov  ax,Max
      add  ax,Min
      shr  ax,1
      mov  Cursor,ax
   end;
   AuxVal:=SquareTable[Cursor];
   If (AuxVal=Dato) or (Max=Min+1) then goto fin;
   If AuxVal>Dato then Max:=Cursor;
   If AuxVal<Dato then Min:=Cursor;
   goto vuelve;
fin:
   FSqrt:=Cursor;
end;

BEGIN
   For Cnt:=0 to 360+90 do TblSinCos[Cnt]:=Round(Sin(Cnt*PI/180)*256);
   For Cnt:=0 to 640    do SquareTable[Cnt]:=Sqr(Cnt);
END.