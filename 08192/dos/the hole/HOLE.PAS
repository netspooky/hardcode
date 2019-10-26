{                       T H E   H O L E . v 1.0                              }
{                                                                            }
{ The first version coded by Spanish Lords in Feb 95 for RASANTE filling hole}
{ This release is for public domain, but really I comment this code for      }
{ Eduard S…nchez Palaz¢n, he asked me for the hole in BUTIFARRA 3 (April 95) }
{ Eduard:                                                                    }
{     þ Here is the code you can see is NOT 3D , only 2D, :)                 }
{     þ It is totally coment, too much I think.                              }
{     þ One kiss for Aitak ;-)                                               }
{                                                                            }
{ I studied the original code from Bas van Gaalen, Holland, PD.- Greetings.- }
{                                                                            }
{                                                   <çom / Spanish Lords     }
{ If you want to contact with us e-mail us:                pedro@cedex.es    }
{ We need artist and musicians, coders are welcome too. ;-)                  }
{$R-,Q-}
Program The_Hole;

Uses Crt;

Const
  IncAng      =       6;{ Steps in angle for drawing each circle.}
  XMov        =       4;{ Moving constans.}
  YMov        =       5;

var
  SinTable    : array[0..449] of integer; { Sinus Table. 499=359+90 cos(í)=sin(í+90)}
  SinMov      : array[0..255] of integer; { Sinus table for movement.}
  CosMov      : array[0..255] of integer; { Cosinus table for movement.}
  Buffer      : pointer;                  { Here we will write.}
  BufferSeg   : word;
  IncLong     : byte;                     { Inc in distance between two circles.}
{ þ Do you need any comment of this procedure? }
{ þ Yes ?                                      }
{ þ Then, you are a lamer, dont read any more. }
Procedure SetColor(Col,R,G,B:Byte); assembler;
Asm
  cli
  mov dx,03C8H
  mov al,Col
  out dx,al
  inc dx
  mov al,r
  out dx,al
  mov al,g
  out dx,al
  mov al,b
  out dx,al
  sti
End;
{ Make a degradated for the hole in colors 16..32.}
{ The init R,G,B are the most dark color.         }
Procedure MakeDegradated (InitR,InitG,InitB:Byte);
Var
  CntColor : Byte;
  Procedure MyDec (Var Val:Byte;Inc:Byte);Begin If Val>Inc then Dec (Val,Inc) else Val:=0;End;
Begin
  For CntColor:=32 downto 16 do
    Begin
      SetColor (CntColor,InitR,InitG,InitB);
      MyDec (InitR,4);
      MyDec (InitG,4);
      MyDec (InitB,4);
    End;
End;
{ Clear the buffer where we will write the hole.}
Procedure ClearBuffer; assembler;
Asm
  mov ax,BufferSeg
  mov es,ax
  xor di,di
  xor ax,ax
  mov cx,32000
  rep stosw
End;
{ Put in A000h the buffer where we are painting pixels.}
{ þ In RASANTE HOLE all of this is XMode, QUICK!       }
Procedure PutBuffer; assembler;
Asm
  push ds
  mov ax,0A000h
  mov es,ax
  mov ax,BufferSeg
  mov ds,ax
  xor si,si
  xor di,di
  mov cx,32000
  rep movsw
  pop ds
End;
{ I hope everybody know what it is this. }
Procedure CalcTables;
Var
  Cnt : Word;
Begin
{ Precalcualted values for movement.}
{ If you want do not precalculated them, you have time for playing with this }
{ values. Ok ? make a beatiful key-controlled hole! :)                       }
  For Cnt:=0 to 255 do
    Begin
      SinMov[Cnt]:=round(sin(pi*Cnt/128)*20);
      CosMov[Cnt]:=round(cos(pi*Cnt/128)*80);
    End;
{ Precalculated sinus table. Only one table. I remember you: cos(í)=sin(í+90)}
{ The values are between -127 , 127 = 2^7                                    }
{                        sal Var,7 for mul                                   }
{                        sar Var,7 for div  (High speed.)                    }
  For Cnt:=0 to 449 do SinTable[Cnt]:=round(sin(2*pi*Cnt/360)*128);
End;

{ Draw a point in Buffer.                              }
{   þ The middle of the screen = (160,100)             }
{   þ Center & Radius of Circle that we are drawing.   }
{   þ Angle                                            }
{   þ Color                                            }
{ This procedure uses parametrics formules of a circle:}
{   x = XCenter + Radius * Cos (í)                     }
{   y = YCenter + Radius * Sin (í)    í î [0..359ø]    }
Procedure DrawPoint(XCenter,YCenter,Radius,Angle:word;Color:byte);
Var
  X,Y:word;
Begin
  X:=(Radius*SinTable[90+Angle]);
  asm sar x,7 end;
  X:=160+XCenter+X;
  Y:=(Radius*SinTable[Angle]);
  asm sar y,7 end;
  Y:=100+YCenter+Y;
  if (X<320) and (Y<200) then
{ This is probably the most quick form for putting a pixel.}
    Asm
      mov  ax,BufferSeg
      mov  es,ax
      mov  al,Color
      mov  bx,X
      mov  dx,Y
      xchg dh,dl
      mov  di,dx
      shr  di,1
      shr  di,1
      add  di,dx
      add  di,bx
      mov  es:[di],al
    End;
End;

{ The MEOLLO. -.Spanish expresion ;-) }
Procedure TheHole;
Const
  x  : Word =    0;
  y  : Word =    0;
Var
  CntAng    : Word;
  CntLong   : Word;
  Color     : Byte;
Begin
  Repeat
{ Wait for vertical retrace.}
    while (port[$3da] and 8) <> 0 do;
    while (port[$3da] and 8) = 0 do;
    Color:=19;
    IncLong:=2;
    CntLong:=10;
    Repeat
    { Draw a circle.}
      CntAng:=0;
      Repeat
        DrawPoint(CosMov[(x+(200-CntLong)) mod 255],SinMov[(y+(200-CntLong)) mod 255],CntLong,CntAng,Color);
{ [ No move ] comment -^                     }
{        DrawPoint(x,y,CntLong,CntAng,Color);}
        Inc(CntAng,IncAng);
      Until CntAng>=360;
    { Ok the circle is drawing.}
    { Another circle, another colour, until CntLong 220 :) }
      inc(CntLong,IncLong);
      if (CntLong mod 3)=0 then
        begin
          inc(IncLong);
          inc(Color);
          if Color>31 then Color:=31;
        end;
    Until CntLong>=220;
{ Moving, if no move the circles, NO MOVE.}
    x:=XMov+x mod 255;
    y:=YMov+y mod 255;
{ [ No move ] comment -^ You willl see the hole move NOTHING }
{    x:=0; y:=0;}
    PutBuffer;
    ClearBuffer;
  until keypressed;
End;
{ Main.}
BEGIN
{ Put MCGA On.}
  asm
    mov ax,13h
    int 10h
  end;
{ Memory for Buffer, If I have 64000 bytes Pascal give me a complete segment.}
{ Offset =0; but you can do it with less memory, using Memory unit and       }
{ MemAllocSeg Ok Eduard? ;-)                                                 }
  GetMem(Buffer,64000);
  BufferSeg:=seg(Buffer^);
  ClearBuffer;
  CalcTables;
  MakeDegradated (50,50,64);
  TheHole;
{ Remember Freemem.:) }
  Freemem(Buffer,64000);
  Textmode(lastmode);
end.
