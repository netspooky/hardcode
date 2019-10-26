unit PCXVModi;

{R-}    {Range checking off}
{B-}    {Boolean complete evaluation off}
{S-}    {Stack checking off}
{I-}    {I/O checking on}
{N-}    {No numeric coprocessor}
interface

uses
  Dos, ModiGraf;

const
   MAX_WIDTH = 4000;                  { max. Grî·e PCX-Bild }
   COMPRESS_NUM = $C0;                { Maske Kompressbyte  }
   MAX_BLOCK = 4096;                  { Puffergrî·e         }

   mcga=$13;

type
   block_array = array [0..MAX_BLOCK] of byte;
   line_array = array [0..MAX_WIDTH] of byte;
   name = string [80];

   pcx_header = record
    Signatur: byte;     { immer 10 fÅr PCX Files        }
    Version: byte;      { 2 - (alt) PCX - ohne Palette  }
                        { 3 - ohne Palette              }
                        { 4 - MS Windows - ohne Palette }
                        { 5 - mit Palette               }
    Encoding: byte;     { 1 PCX Komprimierung 0 keine   }
    Bits_per_pixel: byte; { Bits pro Pixel - 1, 2 4, 8  }

    Xmin: integer;      { Bildabmessungen               }
    Ymin: integer;
    Xmax: integer;
    Ymax: integer;

    Hdpi: integer;      { Bildauflîsung (dots per inch) }
    Vdpi: integer;      { 300 ist default               }

    ColorMap: array [0..15, 0..2] of byte;
                        { RGB Palette fÅr 16 Farben     }
    Reserved: byte;     { wird auf 0 gesetzt            }
    Nplanes: byte;      { Zahl der Planes               }

    Bytes_per_line_per_plane: integer; { Byte pro Zeile }
    PaletteInfo: integer;  { 1 oder 2                   }

    HscreenSize: integer;   { fÅr Paintbrush IV Plus    }
    VscreenSize: integer;   { "                         }

    Dummy: array [74..127] of byte; { FÅllbytes         }
   end;

var
   I:Word;
   FileName: Name;          { Filename PCX File         }
   Handle: file;            { Filehandle                }

   RawData: ^block_array;              { 4k Daten Puffer }
   PHeader: pcx_header;                { PCX File Header }
   Palette256: pal_array;   { Palette mit 256 Farben    }
   PCXline: ^line_array;     { Puffer unkomprimierte Daten }

   Ymax: integer;           { Maximum Y Wert Bild       }
   NextByte: integer;       { Index in Puffer (ReadByte)}
   Index: integer;          { PCXline Index             }
   Data: byte;              { PCX Rohdaten compressed   }

   PictureMode: integer;    { Graphik Mode              }
   Mode : integer;          { Option Mode               }

   Reg: Registers;          { Register fÅr Int 10 calls }

   j: Integer;              { Hilfsvariable             }


procedure loadpcx(var buf:Tscreen;var palette:pal_array;st:string;SetPal:Byte);
procedure Savepcx(var buf:Tscreen;palette:pal_array;st:string;XS,YS:Word);
implementation

procedure Savepcx(var buf:Tscreen;palette:pal_array;st:string;XS,YS:Word);
VAR F,FT:FILE;
    Count,Color,B,B2,OL,OC:Byte;
    Posi:LongInt;
    I,K,M:Word;
BEGIN
WITH PHeader DO BEGIN
  Assign(F,'svertrag.pcx');
  ReSet(F,1);
  BlockRead(F,PHeader,128);
  Close(F);
  Assign(FT,'SHIT\cross1.pc~');
  ReSet(FT,1);
  Seek(FT,128);
  Assign(F,St);
  ReWrite(F,1);
    BlockWrite(F,PHeader,128);
    Posi:=FilePos(F);
    Color:=Buf[0];
    Count:=0;
{    FOR I:=1 TO 63999 DO BEGIN}
    FOR K:=0 TO YS-1 DO BEGIN
     FOR M:=0 TO XS-1 DO BEGIN
      I:=K*320+M;
      OC:=Color;
      IF Buf[I]=Color THEN
       IF Count<62 THEN Inc(Count)
       ELSE BEGIN
        Inc(Count);
        Count:=Count OR $C0; {Obere2 Bits setzen}
        BlockWrite(F,Count,1);
        BlockWrite(F,Color,1);
        OL:=Count AND $3F;
        Count:=0;
      END ELSE BEGIN
        IF (Count>1)OR(Color AND $C0 <> 0) THEN BEGIN
          Count:=Count OR $C0; {Count codieren Obere2 Bits setzen}
          BlockWrite(F,Count,1);
          BlockWrite(F,Color,1);
          OL:=Count AND $3F;
          Count:=1;
        END ELSE BEGIN
          BlockWrite(F,Color,1);
          OL:=Count;
          Count:=1;
        END;
        Color:=Buf[I];
      END;
      IF (FilePos(F)<>Posi)AND(ST='SHIT\cross1.PCX') THEN BEGIN
        IF FilePos(F)-Posi=2 THEN BlockRead(FT,B2,1);
        BlockRead(FT,B,1);
        WriteLn('My : Color : ',OC,'  Length : ',OL);
        IF FilePos(F)-Posi=2 THEN WriteLn('Color : ',B,'  Length : ',B2 AND $3F,'  Orig : ',B2)
        ELSE WriteLn('Color : ',B);
{        ReadKey;}
        Posi:=FilePos(F);
      END;
    END;
    Count:=Count OR $C0; {Obere2 Bits setzen}
    BlockWrite(F,Count,1);
    BlockWrite(F,Color,1);
  END;
  Count:=12;
  BlockWrite(F,Count,1);
  FOR I:=0 TO 255 DO FOR K:=0 TO 2 DO Palette[I][K]:=Palette[I][K] SHL 2;
  BlockWrite(F,Palette,768);
  Close(FT);
  Close(F);
END;
END;

procedure loadpcx(var buf:tscreen;var palette:pal_array;st:string;SetPal:Byte);

procedure VideoMode (n: integer);


begin
{  asm mov ax,19; int 16; end;}
end;  { VideoMode }


procedure EntireVGApalette;

var
   i: integer;

begin
 for i := 0 to 255 do
  begin                        { R, G, B mu· 0..63 sein }
   Palette256 [i, 0]   := Palette256 [i, 0]   shr 2;
   Palette256 [i, 1] := Palette256 [i, 1] shr 2;
   Palette256 [i, 2]  := Palette256 [i, 2]  shr 2;
  end;
IF SetPal=1 THEN SetPalette(Palette256);
palette:=palette256;
end;  { EntireVGApalette }

procedure SetPalette;
begin
 case PictureMode of
   MCGA: EntireVGApalette;
 end;
end;  { SetPalette }

procedure Read256palette;

var
   signatur: byte;

begin

 seek (Handle, FileSize (Handle) - 769);
 BlockRead (Handle, signatur, 1);       { lese 1. Byte       }

 if signatur <> 12 then                 { keine Palette ...  }
  exit;
 BlockRead (Handle, Palette, 3*256); { lese Palette       }
 Palette256:=Palette;

 seek (Handle, 128);              { Lesezeiger auf Bilddaten }

end;  { Read256palette }

procedure ReadHeader;

label WrongFormat;

begin
{I-}
BlockRead (Handle, PHeader, 128);   { lese 128 Byte PCX Header }
                                       { Ist es ein PCX File? }
IF (PHeader.Signatur <> 10) or (PHeader.Encoding <> 1) then
 begin
  close (Handle);
  Writeln ('Keine gÅltige PCX-Datei');
  halt;
 end;


IF (PHeader.Nplanes = 4) and (PHeader.Bits_per_pixel = 1) then
 begin
  IF (PHeader.Ymax - PHeader.Ymin) <= 349 then
   begin
    Ymax := 349;
   end
  ELSE
   begin
    Ymax := 479;
   end;
 end
ELSE
 IF (PHeader.Nplanes = 1) then
  begin
   Ymax := 199;

   IF (PHeader.Bits_per_pixel = 1) then
   ELSE
    IF (PHeader.Bits_per_pixel = 2) then
    ELSE
     IF (PHeader.Bits_per_pixel = 8) then
      begin
       PictureMode := MCGA;
       IF PHeader.Version = 5 then   { 256 Farben }
        Read256palette;
      end
     ELSE
      goto WrongFormat;
  end
ELSE
 begin
WrongFormat:
  close (Handle);
  Writeln ('PCX File besitzt ein falsches Format');
  Writeln ('Es mu· ein CGA, EGA, VGA, oder MCGA Bild sein');
  halt;
 end;

Index := 0;
NextByte := MAX_BLOCK;               { Puffer als leer definieren }

end;  { ReadHeader }

procedure ReadByte;

var
   NumBlocksRead: integer;

begin
 if NextByte = MAX_BLOCK then   { Pufferende erreicht ? }
  begin
   {I-}
   BlockRead (Handle, RawData^, MAX_BLOCK, NumBlocksRead);
   {I+}
   IF IOResult <> 0 THEN
    begin
     Writeln ('Fehler beim Lesen der PCX-Daten');
     Close (handle);
     halt;
    end;
   NextByte := 0;               { Zeiger auf Pufferanf. }
  end;

 data := RawData ^[NextByte];     { lese nÑchstes Byte   }
 inc (NextByte);                 { Zeiger auf NextByte++}
end;  { ReadByte }


procedure Read_PCX_Line;
var
   count: integer;
   bytes_per_line: integer;

begin

bytes_per_line := PHeader.Bytes_per_line_per_plane * PHeader.Nplanes;
index := 0;                              { reset Zeiger       }

while (Index < bytes_per_line) do        { lese 1 Datenzeile  }
 begin
   ReadByte;                             { hole Byte aus Puffer}

   if (data and $C0) = compress_num then { komprimiert ?      }
    begin
     count := data and $3F;              { ZÑhler berechnen   }
     ReadByte;                           { Datenbyte holen    }
     FillChar (PCXline ^[Index], count, data);  { Byte kopieren}
     inc (Index, count);                 { Index += count     }
    end
   else
    begin                                { kein Wiederholbyte }
     PCXline ^[Index] := data;            { lese Datenbyte     }
     inc (Index);                        { Index++            }
    end;
 end;

 Index := 0;                             { reset Zeiger       }

end;  { Read_PCX_Line }

procedure ShowMCGA;

var
   l,k, kmax: integer;
   m:longint;

begin
 kmax := Ymax;
 if PHeader.Ymax < kmax then        { max. bis Bilduntergrenze }
   kmax := PHeader.ymax;

 for k := PHeader.Ymin to kmax do
  begin
   Read_PCX_Line;
   l := PHeader.XMax - PHeader.Xmin+1;          { anzugeigende Bytes       }
   if l > 320 then
    l := 320;                               { max. Bildschirmbreite    }
  Move (PCXline ^[0],buf[(k * 320)], l);

 end;
end;   { ShowMCGA }

Function OPEN (Var handle : file; Filename: name) : boolean;

begin
  Assign(handle,Filename);             {* setze Filename     *}
  {I-}                                {* Errorcheck off     *}
  Reset(handle,1);                     {* open file          *}
  {I+}                                {* Errorcheck on      *}
  IF IOResult=0 THEN ELSE;
  if IOResult=0 then BEGIN
   open := True;
  END
  else
   open := False;
end;

begin

 FOR I:=0 TO 65535 DO Buf[I]:=0;
 New(RawData);              { 4k Daten Puffer }
{ New(Header);                { PCX File Header }
 New(PCXline);     { Puffer unkomprimierte Daten }
 Filename := '';                    {* Clear Variable       *}
 Mode     := 0;

   filename:=st;
 IF NOT open (Handle, Filename) THEN
  begin
   Writeln ('Datei nicht vorhanden');
   halt;
  end;

 ReadHeader;                            { lese den PCX Header    }

 IF Mode <> 0 THEN
  PictureMode := Mode;                 { Mode per Eingabe setzen }

 VideoMode (PictureMode);               { aktiviere Graphik Mode }
 if PHeader.Version = 5 THEN
   SetPalette;                          { 256 Farben             }

 case PictureMode of
  MCGA: ShowMCGA;
  else
 end;

 close (Handle);


{For I:=0 TO 199 DO Buf[I*320+319]:=0;}
 DisPose(RawData);              { 4k Daten Puffer }
{ DisPose(Header);                { PCX File Header }
 DisPose(PCXline);     { Puffer unkomprimierte Daten }

end;  { PCXVIEW }
begin
end.
