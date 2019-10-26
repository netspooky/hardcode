unit TxtWin;
interface
uses
   Strings,
   General,
   Common, Tables, GraphFns,
   Windows;

const
   MaxTextTime =   20;

type
   TStrArray =     Array [0..0] of PChar;

   TTextWindow =
   object(TWindow)
      Text         :^TStrArray;
      TextCount,
      TextPos      :Integer;
      TextTime     :Word;

      constructor Init(Ax, Ay, Aw, Ah  :Integer;
                       const ATitle    :String;
                       var AText       :Array of PChar);

      procedure Draw; virtual;
   end;

implementation
uses
   Copy;

constructor TTextWindow.Init;
begin
   if Initialized then Exit;
   Inherited Init(Ax, Ay, Aw, Ah, ATitle, nil, CopyArea);
   Text:=@AText; TextCount:=High(AText);
end;

procedure TTextWindow.Draw;
var
   SaveBuffer      :Pointer;
   TextLine, CurY  :Integer;
   Color           :Byte;
begin
   if not Initialized then Exit;

   SaveBuffer:=BufferPtr; BufferPtr:=FinalBuffer;
   DrawWindow(x, y, w, h, Title^);

   if Timer-TextTime>MaxTextTime then
   begin
      TextTime:=Timer; Inc(TextPos);
   end;

   CurY:=y+20;
   for TextLine:=0 to TextCount do
   if TextLine<TextPos then
   begin
      if TextLine+1<TextPos
      then Color:=63
      else Color:=Max(Min((Timer-TextTime)*63 div MaxTextTime, 63), C2G[cBack]);
      OutTextC(x+w shr 1, CurY, G2C[Color], StrPas(Text^[TextLine]));
      Inc(CurY, 8);
   end;

   BufferPtr:=SaveBuffer;
end;

end.
