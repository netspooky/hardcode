unit GraphFns;
interface
uses
   Common, Font;

procedure Bar    (x, y, w, h, c        :Integer);

procedure Rectangle(x, y, w, h, c      :Integer);

procedure OutChar(x, y, w, c           :Integer;
                  CharData             :Pointer);

procedure OutText(x, y, c              :Integer;
                  const Text           :String);

procedure OutTextC(x, y, c             :Integer;
                   const Text          :String);

function  TextWidth(const Text         :String)  :Integer;

procedure GetImage(x, y, w, h          :Integer;
                   Image               :Pointer);

procedure PutImage(x, y                :Integer;
                   Image               :Pointer);

procedure PutBlock(x, y                :Integer;
                   Image               :Pointer);

implementation

{$L graphfns}
procedure Bar; external;
procedure OutChar; external;
procedure GetImage; external;
procedure PutImage; external;
procedure PutBlock; external;

procedure Rectangle;
begin
   Bar(x, y, w, 1, c);
   Bar(x+w, y, 1, h+1, c);
   Bar(x, y+h, w, 1, c);
   Bar(x, y, 1, h, c);
end;

procedure OutText;
var
   i, w            :Integer;
   Ofs             :Word;
begin
   for i:=1 to Length(Text) do
   if Text[i]=' ' then Inc(x, SpaceWidth) else
   begin
      Ofs:=FontOfs^[Text[i]];
      w:=FontData^[Ofs];
      OutChar(x, y, w, c, @(FontData^[Ofs+1]));
      Inc(x, w+1);
   end;
end;

procedure OutTextC;
begin
   OutText(x-TextWidth(Text) shr 1, y-3, c, Text);
end;

function  TextWidth;
var
   i, w            :Integer;
begin
   w:=0;
   for i:=1 to Length(Text) do
   if Text[i]=' ' then Inc(w, SpaceWidth) else
   begin
      Inc(w, FontData^[FontOfs^[Text[i]]]);
      if i<>Length(Text) then Inc(w);
   end;
   TextWidth:=w;
end;

end.
