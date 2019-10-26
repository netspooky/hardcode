unit Modigraf;   {Mit init(19); inizialisieren}
interface
uses dos;
type
     TScreen=Array[0..64004] OF Byte;
     pal_array = array [0..255, 0..2] of byte;
     TLookUp=ARRAY[0..255] OF Byte;
var
    I,K:Integer;
    m:longint;
procedure init(index:byte);
procedure gfxclose;
procedure palset(e,r,g,b:byte);
procedure palget(VAR e,r,g,b:byte);
PROCEDURE LoadPaletteFile(VAR Palette:PAL_ARRAY;Fi:STRING);
PROCEDURE Setpalette(VAR Pal:Pal_Array);  {Eine Åbergebene Palette setzen}
PROCEDURE Getpalette(VAR Pal:Pal_Array);  {Eine Åbergebene Palette setzen}
PROCEDURE WaitRetrace;
FUNCTION Retrace:Boolean;
FUNCTION ToStr(I:LongInt):STRING;
FUNCTION GFXMode:Byte;

implementation

FUNCTION ToStr(I:LongInt):STRING;
VAR St:STRING;
BEGIN
  Str(I,St);
  ToStr:=St;
END;

PROCEDURE WaitRetrace;ASSEMBLER;
ASM
  mov dx,3dah
@wait1:
  in al,dx
  test al,08h
  jnz @wait1
@wait2:
  in al,dx
  test al,08h
  jz @wait2
END;

FUNCTION Retrace:Boolean;ASSEMBLER;
ASM
  mov dx,3dah
  in al,dx
  test al,08h
  jz @nichtret
  mov al,1
  jmp @end
 @nichtret:
  mov al,0
 @end:
END;

PROCEDURE Setpalette(VAR Pal:Pal_Array);  {Eine Åbergebene Palette setzen}
VAR I:Byte;
BEGIN
  FOR I:=0 TO 255 DO Palset(I,Pal[I,0],Pal[I,1],Pal[I,2]);
END;
PROCEDURE Getpalette(VAR Pal:Pal_Array);  {Eine Åbergebene Palette setzen}
VAR I:Byte;
BEGIN
  FOR I:=0 TO 255 DO PalGet(I,Pal[I,0],Pal[I,1],Pal[I,2]);
END;

procedure init(index:byte);assembler;
asm
mov ah,0
mov al,index
int 10h;
end;

FUNCTION GFXMode:Byte;ASSEMBLER;
ASM
  mov ah,0Fh
  int 10h
END;

procedure gfxclose; begin Init(3) end;

procedure palset(e,r,g,b:byte);
begin
port[$3c8]:=e;
port[$3c9]:=r;
port[$3c9]:=g;
port[$3c9]:=b;
end;

procedure palget(VAR e,r,g,b:byte);
begin
port[$3c7]:=e;
R:=port[$3c9];
G:=port[$3c9];
B:=port[$3c9];
end;

PROCEDURE LoadPaletteFile(VAR Palette:PAL_ARRAY;Fi:STRING);
VAR F:FILE;
BEGIN
  Assign(F,Fi);
  ReSet(F,1);
  BlockRead(F,Palette,768);
  Close(F);
END;

begin
end.
