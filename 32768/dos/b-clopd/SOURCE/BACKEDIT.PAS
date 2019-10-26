USES Crt,Dos,ModiGraf;
TYPE tVersion=ARRAY[1..4]OF Char;
CONST AktVersion:tVersion='IMG2';
TYPE tHeader=RECORD
              Version:tVersion;
              XSize,YSize:LongInt;
            END;
     tSprite=ARRAY[0..399]OF Byte;

CONST BackPics=3*4+2;
      XS=40;
      YS=40;

VAR I,K,M:LongInt;
    Spr:ARRAY[1..BackPics]OF tSprite;
    Back:ARRAY[0..XS*YS-1]OF Byte;

PROCEDURE Load(Sprite:tSprite;ST:STRING);
VAR F:FILE;
    I,K,M:LongInt;
    Header:tHeader;
BEGIN
  Assign(F,St);
  ReSet(F,1);
  BlockRead(F,Header,SizeOf(THeader));
  BlockRead(F,Sprite,400);
  Close(F);
END;

PROCEDURE RotSpriteTo(VAR Sou,Des:tSprite);
VAR I,K,M:LongInt;
BEGIN
  FOR K:=0 TO 19 DO
    FOR I:=0 TO 19 DO
      Des[I*20+19-K]:=Sou[K*20+I];
END;

BEGIN
  FOR I:=1 TO BackPics DO BEGIN
    IF I IN [2,5,8] THEN BEGIN
      FOR M:=I TO I+2 DO
        RotSpriteTo(Spr[M-1],Spr[M]);
      Inc(I,2);
    END ELSE BEGIN
      CASE I OF
        1:Load(Spr[I],'DATA\BACK1.IMG');
        5:Load(Spr[I],'DATA\BACK2.IMG');
        9:Load(Spr[I],'DATA\BACK3.IMG');
        12:Load(Spr[I],'DATA\BACK4.IMG');
        13:Load(Spr[I],'DATA\BACK5.IMG');
      END;
    END;
  END;
  Init(19);
  ReadKey;
  GFXClose;
END.