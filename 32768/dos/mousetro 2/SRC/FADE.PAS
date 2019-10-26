{$R-,S-,Q-}
unit Fade;
interface
uses
   Tables;

const
   LevelCnt =      32;

procedure HidePalette;
procedure ShowPalette;

implementation

procedure SetPalette(var Palette       :TPalette);
assembler;
asm
   mov  dx,3DAh
@@w8:
   in   al,dx
   test al,8
   jz   @@w8

   push ds
   lds  si,Palette

   cli
   mov  dx,3C8h
   xor  ax,ax
   out  dx,al
   inc  dx

   cld
   mov  cx,256*3
@@Next:
   lodsb
   out  dx,al
   nop
   loop @@Next
   sti

   pop  ds
end;

procedure SlowChange(Increase          :Boolean);
var
   CPalette        :TPalette;
   Level           :Integer;

procedure CalcPalette;
var
   C, P            :Integer;
begin
   if Level<>LevelCnt then
   for C:=0 to 255 do
   for P:=0 to 2 do CPalette[C, P]:=Palette^[C, P]*Level div LevelCnt
   else CPalette:=Palette^;

   SetPalette(CPalette);
end;

begin
   CPalette:=Palette^;

   if Increase then
   for Level:=0 to LevelCnt do CalcPalette
   else
   for Level:=LevelCnt-1 downto 0 do CalcPalette;
end;

procedure HidePalette;
begin
   SlowChange(False);
end;

procedure ShowPalette;
begin
   SlowChange(True);
end;

end.
