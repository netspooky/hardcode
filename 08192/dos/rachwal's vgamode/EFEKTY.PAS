uses VGA13H,CRT;
var Pal : PaletaVGA;
    I   : Integer;
    Txt : String[80];
    E   : Byte;
    Ch  : Char;

begin
     for i:=0 to 63 do begin
          Pal[i].R:=255;
          Pal[i].G:=i;
          Pal[i].B:=0;
     end;
     for i:=64 to 127 do begin
          Pal[i].R:=255;
          Pal[i].G:=63-i;
          Pal[i].B:=0;
     end;
     for i:=128 to 191 do begin
          Pal[i].R:=255;
          Pal[i].G:=i;
          Pal[i].B:=0;
     end;
     for i:=192 to 255 do begin
          Pal[i].R:=255;
          Pal[i].G:=63-i;
          Pal[i].B:=0;
     end;
     InicjujVGA;
     UstawPalete(Pal,0,255);
     e:=1;
     KwadratPelny(0,0,MaxX,MaxY-20,e);
     VGAText(1,MaxY-17,1,'Rachwal''s VGAMode - 9 roznych efektow',3);
     PiszTextVGA(0,24,'Nacisnij klawisz - zmienisz efekt...',233,TRUE);
     repeat
          Rotacja(Pal,0,255,TRUE);
          if KeyPressed then begin
               ch:=readkey;
               Inc(e);
               KwadratPelny(0,0,MaxX,MaxY-20,e);
               if e = 9 then e:=0;
          end;
     until ch=#27;
     ZamknijVGA;
end.