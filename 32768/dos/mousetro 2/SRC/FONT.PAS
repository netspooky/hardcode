unit Font;
interface

const
   SpaceWidth =    5;

procedure _FontData;
procedure _FontOfs;

type
   TFontData =     Array [0..MaxInt] of Byte;
   TFontOfs =      Array [#33..#127] of Word;

const
   FontData        :^TFontData=@_FontData;
   FontOfs         :^TFontOfs=@_FontOfs;

implementation

{$L fontdata}
procedure _FontData; external;
{$L fontofs}
procedure _FontOfs; external;

end.
