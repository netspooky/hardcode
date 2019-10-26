unit Tables;
{$G+,R-,S-,Q-}
interface
uses
   General;

const
   cRGB =          5;
   dRGB =          (1 shl cRGB)-1;
   sRGB =          1;
   xRGB =          (1 shl sRGB) shr 1;
   mDiff =         3;
   dC =            2;
   cSqrt =         155;

type
   TPalette =      Array [0..255, 0..2] of Byte;
   TRPalette =     Array [0..2, 0..255] of Byte;
   TRGB2C =        Array [0..dRGB, 0..dRGB, 0..dRGB] of Byte;

var
   RGB2C           :^TRGB2C;
   C2G, C2GC       :Array [0..255] of Byte;
   G2C             :Array [0..63] of Byte;
   PaletteR        :TRPalette;
   EdgeSqrt        :Array [0..cSqrt-1] of Byte;

procedure _Palette;
procedure _EdgeSqrt;

const
   Palette         :^TPalette=@_Palette;

procedure CalcTables;

implementation

{$L palette}
procedure _Palette; external;
{$L sqrt}
procedure _EdgeSqrt; external;

procedure CalcTables;
var
   LastG           :Byte;
   i               :Integer;

   R, G, B,
   Rc, Gc, Bc,
   C               :Byte;
   d, Cd           :Integer;
   PP              :TPalette;
   PPx             :Array [0..255] of Byte;
   PPc             :Integer;
begin
{ Color -> Gray }
   FillChar(G2C, SizeOf(G2C), 255);
   for i:=Low(C2G) to High(C2G) do
   begin
      PaletteR[0, i]:=Palette^[i, 0];
      PaletteR[1, i]:=Palette^[i, 1];
      PaletteR[2, i]:=Palette^[i, 2];

      C2G[i]:=(Palette^[i, 0]+Palette^[i, 1]+Palette^[i, 2]) div 3;
      if (Abs(Palette^[i, 0]-Palette^[i, 1])<=dC) and
         (Abs(Palette^[i, 1]-Palette^[i, 2])<=dC) then G2C[C2G[i]]:=i;
   end;

{ Gray -> Color }
   i:=Low(G2C); while G2C[i]=255 do Inc(i); LastG:=G2C[i];
   for i:=Low(G2C) to High(G2C) do
   if G2C[i]=255 then G2C[i]:=LastG else LastG:=G2C[i];

{ Color -> GrayColor }
   for i:=Low(C2GC) to High(C2GC) do
      C2GC[i]:=G2C[C2G[i]];

{ 24bit -> 8bit}
   RGB2C:=HeapOrg;
   asm
      add  word ptr HeapOrg+2,(dRGB+1)*(dRGB+1)*(dRGB+1)/16
   end;

   for R:=0 to dRGB do
   begin
      Rc:=R shl sRGB;

      PPc:=0;
      for C:=0 to 255 do
      if Abs(Palette^[C, 0]-Rc)<mDiff then
      begin
         PP[PPc]:=Palette^[C]; PPx[PPc]:=C;
         Inc(PPc);
      end;

{ Uncomment when adjusting mDiff: }
{     if PPc=0 then RunError(200);}

      for G:=0 to dRGB do
      begin
         Gc:=G shl sRGB;

         for B:=0 to dRGB do
         begin
            Bc:=B shl sRGB;

            asm
               push ds
               push ss
               pop  ds

               mov  dx,MaxInt

               mov  si,offset PP
               mov  cx,PPc

@@NextColor:
               mov  al,byte ptr [bp+si]
               sub  al,Rc
               imul al
               cmp  ax,dx
               jae  @@BadColor
               mov  di,ax
               mov  al,byte ptr [bp+si+1]
               sub  al,Gc
               imul al
               add  di,ax
               cmp  di,dx
               jae  @@BadColor
               mov  al,byte ptr [bp+si+2]
               sub  al,Bc
               imul al
               add  ax,di

               cmp  ax,dx
               jae  @@BadColor
               mov  bx,cx
               mov  dx,ax
@@BadColor:

               add  si,3
               loop @@NextColor

               mov  ax,PPc
               sub  ax,bx
               lea  bx,[bp+offset PPx]
               xlat
               mov  C,al

               pop  ds
            end;
            RGB2C^[R, G, B]:=C;
         end;
      end;
   end;

   asm
      cld
      push ds
      pop  es
      mov  di,offset EdgeSqrt
      mov  si,offset _EdgeSqrt

      mov  bx,offset G2C

      mov  cx,cSqrt
@@NextColor:
      mov  al,cs:[si]
      xlat
      stosb
      inc  si
      loop @@NextColor
   end;
end;

end.
