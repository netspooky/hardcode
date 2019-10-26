unit Startup;
interface
uses
   Objects,
   Ints,
   GRect, General,
   Fade, GraphFns, Backgnd, Windows,
   Common, Tables,
   Smooth, Scale;

procedure InitIntro;
procedure DoneIntro;
function  Stop     :Boolean;

const
   MsgCPU          :PChar =
   'At least an 80386 CPU is required'#13#10'$';

   MousePresent    :Boolean =          False;

var
   ShiftX          :Array [0..199] of ShortInt;
   ShiftY          :Array [0..319] of ShortInt;
   ShiftYOfs       :Array [0..319] of Integer;

procedure _Mouse;

const
   Mouse           :PGPoint=@_Mouse;

var
   MouseS          :PGPoint;

implementation
uses
   Morphing;

{$L mouse}
procedure _Mouse; external;

procedure CheckReq;
begin
   if Test8086<2 then
   begin
      asm
         mov  dx,word ptr MsgCPU
         mov  ah,9
         int  21h
      end;
      Halt;
   end;
end;

procedure InitVideo;
begin
   asm
      mov  ax,13h
      int  10h

      xor  bx,bx
      mov  cx,100h
      les  dx,Palette
      mov  ax,1012h
      int  10h

      mov  ax,3533h
      int  21h
      mov  ax,es
      or   ax,bx
      jz   @@NoMouse
      xor  ax,ax
      int  33h
      mov  MousePresent,ah
@@NoMouse:
   end;
end;

procedure InitMemory;
begin
   BackPtr:=HeapOrg;
   asm
      add  word ptr HeapOrg+2,1000h
   end;

   BufferPtr:=HeapOrg;
   asm
      add  word ptr HeapOrg+2,1000h
   end;

   FinalBuffer:=HeapOrg;
   asm
      add  word ptr HeapOrg+2,1000h
   end;

   MouseS:=HeapOrg;
   asm
      mov  ax,word ptr cs:_Mouse
      inc  ax
      mul  word ptr cs:_Mouse+2
      shr  ax,4
      add  word ptr HeapOrg+2,ax
   end;
end;

procedure InitMorph;
begin
   FillChar(ShiftX, SizeOf(ShiftX)+SizeOf(ShiftY), 0);
end;

procedure ScaleMouse(SizeX, SizeY      :Integer);
var
   NewSize         :TGPoint;
begin
   NewSize.X:=SizeX; NewSize.Y:=SizeY;
   ScaleImage(Mouse, MouseS, NewSize);
end;

procedure ShowTitle;
var
   SaveBuffer      :Pointer;
begin
   SaveBuffer:=BufferPtr; BufferPtr:=@VM;

   asm
      mov  dx,3C8h
      xor  ax,ax
      out  dx,al
      inc  dx
      mov  cx,768
@@Next:
      out  dx,al
      nop
      loop @@Next
   end;

   DrawFrame(160-87, 100-88, 2*87, 2*88, '');
   Bar(160-84, 100-85, 2*84+1, 2*85+1, 254);
   DrawWindow(160-80, 100-88+7, 2*80, 112, '');
   ScaleMouse(150, 105);
   Morph(160, 76, MouseS, PtrRec(BufferPtr).Seg);
   ScaleMouse(30, 20);
   Morph(151, 150, MouseS, PtrRec(BufferPtr).Seg);
   OutText(166, 147, 253, 'TRO');
   OutTextC(160, 170, 255, '(C) 1995 by Solar Designer');

   ShowPalette;
   BufferPtr:=SaveBuffer;
end;

procedure InitBackground;
var
   i               :Integer;
begin
   DrawBackground;
   for i:=0 to 127 do
   begin
      ScaleMouse(32+Random(128), 20+Random(80));
      PutBlock(Random(320-MouseS^.X), Random(200-MouseS^.Y), MouseS);
   end;
   OutTextC(160, 5, 255, '... MouseTRO ][ ... by Solar Designer ...');
end;

procedure InitIntro;
begin
   CheckReq;
   InitInts;
   InitVideo;
   Randomize;
   InitMemory;
   InitMorph;

   ShowTitle;
   LTimer:=Timer;

   CalcTables;

   InitBackground;
   Move(BufferPtr^, BackPtr^, 320*200);
   Move(BufferPtr^, FinalBuffer^, 320*200);

   ScaleMouse(74, 53);

   while Timer-LTimer<2*18 do;

   HidePalette;
   Move(FinalBuffer^, VM, 320*200);
   ShowPalette;
end;

procedure DoneIntro;
begin
   HidePalette;

   asm
      mov  ax,3
      int  10h
   end;

   DoneInts;
end;

function  Stop;
assembler;
asm
   mov  ah,1
   int  16h
   jz   @@NoKey
   xor  ax,ax
   int  16h
   cmp  al,27
   jne  @@NoKey
   ret
@@NoKey:
   mov  al,MousePresent
   or   al,al
   jz   @@NoMouse
   mov  ax,3
   int  33h
   mov  ax,bx
   and  al,2
@@NoMouse:
end;

end.
