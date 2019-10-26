{$G+,A+,R-,S-,I-,N-,E-,X+,V-}
{$M 8192,0,65536}
{$L MUSIC}

Program FatalVision_Intro;

{ FatalVision intro                         }
{ Programmed by BoRZoM on 13/06/94          }
{ Using VECTOR/MODE-X/SOUND units by BoRZoM }
{ Graphics is Generated using BoRZoM's code }
{ ----------------------------------------- }
{ Greetingz goes to MathMaster              }

Uses DOS, CRT, MODEX, VECTOR, STOOL, PICTURE;

Type
  FontType = Array [0..255, 0..7] of Byte;

Const
  VecPts   = 8;                          { Simple 8-point cube }
  NoVGA    : String = 'Sorry, VGA adapter required.';
  Credits  : String = 'Intro designed/coded by [BoRZoM/Trouble Makers]';
  SoundCard: String = 'Adlib or compatible card detected!';
  Scroller : String =
             'Hi! Well, here is another idiotic intro, '+
             'for FatalVision coded by BoRZoM/FatalVision. Just '+
             'wanted to say "Hi!", and dont forget us! Greetz '+
             'to: Trouble Makers team, Matt Prichard... '+
             'SEPULTURA RULES! '+
             'Later on dudez...                                 ';
  Vectors  : Array [1..4] of Array [1..8] of Point3D = (
   ((x:-50;y:-50;z:-50),  { Cube }
    (x: 50;y:-50;z:-50),
    (x: 50;y:-50;z: 50),
    (x:-50;y:-50;z: 50),
    (x:-50;y: 50;z:-50),
    (x: 50;y: 50;z:-50),
    (x: 50;y: 50;z: 50),
    (x:-50;y: 50;z: 50)),

   ((x: 50;y:-50;z:-50), { Something weird }
    (x: 50;y:-50;z: 50),
    (x:-50;y:-50;z: 50),
    (x:-50;y:-50;z:-50),
    (x:-50;y: 50;z:-50),
    (x: 50;y: 50;z:-50),
    (x: 50;y: 50;z: 50),
    (x:-50;y: 50;z: 50)),

   ((x:-50;y:-50;z:-50), { Pyramid }
    (x: 50;y:-50;z:-50),
    (x: 50;y:-50;z: 50),
    (x:-50;y:-50;z: 50),
    (x: 00;y: 50;z: 00),
    (x: 00;y: 50;z: 00),
    (x: 00;y: 50;z: 00),
    (x: 00;y: 50;z: 00)),

   ((x:-30;y:-70;z: 00), { Line }
    (x:-30;y:-70;z: 00),
    (x: 30;y: 70;z: 00),
    (x: 30;y: 70;z: 00),
    (x: 00;y: 00;z: 00),
    (x: 00;y: 00;z: 00),
    (x: 00;y: 00;z: 00),
    (x: 00;y: 00;z: 00)));

  VectorLines : Array [1..12, 1..2] of Byte = (
    (1, 2), (2, 3), (3, 4), (4, 1),
    (5, 6), (6, 7), (7, 8), (8, 5),
    (1, 5), (2, 6), (3, 7),
    (4, 8));

Var
  X,  Y,  Z,
  RX, RY, RZ,
  XX, YY, ZZ,
  VX, VY, VXI,
  VYI        : Integer;
  NewVector,
  TempVector : Array [1..VecPts] of Point3D;
  Palette1,
  Palette2   : Array [0..767] of Byte;
  TextBitmap : Array [0..7, 0..79] of Byte;
  SinTable   : Array [0..255] of ShortInt;
  CharTable  : ^FontType;
  CurPOS     : 0..7;
  CurPAGE    : 0..3;
  CurSIN,
  OldSIN,
  CurSIZ,
  CurCHR     : Word;
  VGA        : Boolean;
  Old9       : Pointer;
  Wrd        : Word;
  Adlib      : Boolean;

procedure Music; external;

procedure Getfont; assembler;            { Returns address of 8x8 font }
asm                                      { into CharTable pointer      }
  mov  ax, 1130h
  mov  bh, 1
  int  10h
  mov  word(CharTable+2),es
  mov  word(CharTable),bp
end;

procedure Nothing; interrupt;            { new keyboard interrupt      }
begin
  asm
    push 40h
    pop  es
    xor  al, al
    mov  es:[17h], al
    pushf
    call old9
  end;
end;

Begin
  asm
    mov  Vga, 1
    mov  ax, 1a00h
    int  10h
    cmp  al, 1ah
    je   @ok
    mov  Vga, 0
    @ok:
  end;
  if not Vga then begin                  { adapter is VGA?          }
    writeln (NoVGA);                     { no, print error message  }
    halt;                                { and exit to dos          }
  end;
  Adlib := AdlibPresent;
  If Adlib then begin
    writeln (SoundCard);
    hsc_init;
    hsc_set (@Music);
    hsc_play (false);
    delay (2000);
  end;
  for x := 1 to 25 do begin              { Fadeout the text screen  }
    move (mem [$B800:0], mem [$B800:160], 160*24);
    fillchar (mem [$B800:0], 160, 0);
    repeat until port [$3da] and 8 = 8;
    repeat until port [$3da] and 8 = 0;
  end;
  InitTables;                            { initialize vector tables }
  InitModeX (m320x200, 320, 200, 4);     { Enter 320x200x256x4 mode }
  move (MyPal^, Palette1, 768);
  fillchar (TextBitmap, sizeof (TextBitmap), 0);
  fillchar (Palette2, 768, 0);
  for x := 0 to 255 do SinTable [x] := round (sin (x*2*pi/256)*48)+60;
  Getfont;
  CurPOS := 0;
  CurSIN := $FE;
  CurCHR := 1;
  CurPAGE := 0;
  rx := 0;   { x,y,z rotation angles }
  ry := 45;
  rz := 90;
  vx := 0;
  vy := 0;
  vxi := 2;
  vyi := 2;
  getintvec (9, Old9);
  setintvec (9, @Nothing);
  port [$3c8] := 0;
  for x := 0 to 767 do port [$3c9] := 0; { Clear palette            }
  for x := 3 downto 0 do begin
    set_active_page(x);
    draw_Bitmap (MyPic^, 0, 0, 320, 200);  { Draw picture on screen   }
  end;
  for x := 0 to 63 do begin              { Fade in palette          }
    port [$3c8] := 0;
    For y := 0 to 767 do begin
      If Palette2 [y] < Palette1 [y] then Inc (Palette2 [y]);
      port [$3c9] := Palette2 [y];
    end;
    repeat until port [$3da] and 8 = 8;
  end;
  Randomize;
  port [$3c8] := 255;
  port [$3c9] := 63; port [$3c9] := 63; port [$3c9] := 63;
  port [$3c8] := 254;
  port [$3c9] := 43; port [$3c9] := 63; port [$3c9] := 43;
  port [$3c8] := 253;
  port [$3c9] := Random(63); port [$3c9] := Random(63); port [$3c9] := Random(63);
  port [$3c7] := 0;
  for x := 0 to 767 do Palette2 [x] := Port [$3c9];

  repeat
    { first, process scroller ... }
    for x := 0 to 7 do move (TextBitmap [x, 1], TextBitmap [x, 0], 79);
    for x := 0 to 7 do
      if (CharTable^ [ord (Scroller [curCHR]), x] shl curPOS) and 128 <> 0
        then TextBitmap [x, 79] := 1 else TextBitmap [x, 79] := 0;
    inc (CurPOS);
    OldSIN := CurSIN;
    CurSIN := (CurSIN - 1) and $FF;
    if CurPOS = 8 then begin
      CurPOS := 0;
      inc (CurCHR);
      if CurCHR > length (Scroller) then CurCHR := 1;
    end;
    { second, process vector coordinates... }
    rx := (rx + 3) mod 360;     {+2}
    ry := (ry + 4) mod 360;     {+1}
    rz := (rz + 358) mod 360;   {-1}
    CurSIZ := (CurSIZ + 1) mod 256;
    PVal := Round (Sin (CurSIZ*2*pi/256)*80)*2;
    Rotate (Vectors [1], TempVector, rx, ry, rz, VecPts);
    PerspectiveMUL (TempVector, NewVector, VecPts);
    vx := vx + vxi;
    vy := vy + vyi;
    if (vy = 56) or (vy = -56) then vyi := -vyi;
    if (vx = 110) or (vx = -110) then vxi := -vxi;
    { third, print the scroller ... }
    Set_Active_Page ((CurPage+1) mod 3);
    for x := 0 to 7 do for y := 1 to 79 do begin
      yy := x*4 + SinTable [(y+CurSIN) and $FF];
      xx := y*4;
      zz := TextBitmap [x, y]+254;
      if zz = 255 then begin
        Set_Point (xx, yy, 255);
        Set_Point (xx-1, yy, 254);
        Set_Point (xx+1, yy, 254);
        Set_Point (xx, yy-1, 254);
        Set_Point (xx, yy+1, 254);
      end;
    end;
    { fourth, print the vector... }
    for x := 1 to 12 do
      draw_line (
      vx+NewVector [VectorLines [x, 1]].x, vy+NewVector [VectorLines [x, 1]].y,
      vx+NewVector [VectorLines [x, 2]].x, vy+NewVector [VectorLines [x, 2]].y,
        253);

    Set_Display_Page ((CurPage+1) mod 3);
    Set_Active_Page (CurPage);
    { fifth, Restore background }
    Copy_Bitmap (3, 0, 0, 319, 199, CurPage, 0, 0);
    CurPage := (CurPage + 1) mod 3;
  until port [$60] = 1;                  { repeat until ESCape pressed }
  for x := 0 to 63 do begin              { Fade out palette            }
    port [$3c8] := 0;
    For y := 0 to 767 do begin
      If Palette2 [y] > 0 then Dec (Palette2 [y]);
      port [$3c9] := Palette2 [y];
    end;
    repeat until port [$3da] and 8 = 8;
  end;
  asm                                    { set back 80x25x16 text mode }
    mov  ax, 3
    int  10h
  end;
  if Adlib then begin
    hsc_stop;
    hsc_deinit;
  end;
  writeln (Credits);                     { write the credits           }
  setintvec (9, Old9);                   { restore back keyboard int.  }
End.