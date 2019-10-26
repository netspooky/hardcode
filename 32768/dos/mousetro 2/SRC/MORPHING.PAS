unit Morphing;
interface
uses
   Common, GRect, Startup;

const
   MSX = 2;
   MSY = 2;

procedure Morph(x, y                   :Word;
                Image                  :PGPoint;
                Target                 :Word);

procedure MorphStep(Image              :PGPoint);

implementation

{$L morphing}
procedure Morph; external;

var
   i               :Integer;
   NewShift        :ShortInt;

function  RndShift :ShortInt;
const
   Nx =  5;
   Ns    :Array [0..1] of Byte =
   (Nx, 97);
   N     :Byte =   Nx;
   E     :LongInt= 0;
var
   M               :ShortInt;
begin
   if (i=1) and (Random(30)=0) then N:=Ns[Random(High(Ns)+1)];
   M:=N shr 1;
   if N=Nx then
   begin
      RndShift:=(Random(Nx)-M) div M;
      E:=0;
   end else
   begin
      RndShift:=(E mod LongInt(N)-M) div (M shr 1 +1);
      Inc(E);
   end;
end;

procedure MorphStep;
begin
   for i:=1 to Image^.Y do
   begin
      NewShift:=ShiftX[i-1]+RndShift;
      if NewShift<ShiftX[i]-MSX then NewShift:=ShiftX[i]-MSX;
      if NewShift>ShiftX[i]+MSX then NewShift:=ShiftX[i]+MSX;
      ShiftX[i]:=NewShift;
   end;

   for i:=1 to Image^.X do
   begin
      NewShift:=ShiftY[i-1]+RndShift;
      if NewShift<ShiftY[i]-MSY then NewShift:=ShiftY[i]-MSY;
      if NewShift>ShiftY[i]+MSY then NewShift:=ShiftY[i]+MSY;
      ShiftY[i]:=NewShift;
      ShiftYOfs[i]:=ShiftY[i]*320;
   end;
end;

end.
