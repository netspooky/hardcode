program write_tables;
uses crt,dos;
var
i:word;
f:text;
alph:word;

begin
     clrscr;
     assign(f,'sine2.inc');
     rewrite(f);
     alph:=0;
     writeln(f,'sint:');
     for i:=0 to 255 do begin
         if alph=0 then write(f,'db ',round(sin(2*pi*i/255)*127))
         else write(f,',',round(sin(2*pi*i/255)*127));
         inc(alph);
         if alph=10 then begin
            writeln(f);
            alph:=0;
         end;
     end;
     close(f);

     clrscr;
{     assign(f,'color.inc');
     rewrite(f);
     alph:=0;
     writeln(f,'ft:');
     for i:=0 to 255 do begin
         if alph=0 then write(f,'db ',round(cos(2*pi*i/255)*127)+127)
         else write(f,',',round(cos(2*pi*i/255)*127)+127);
         inc(alph);
         if alph=10 then begin
            writeln(f);
            alph:=0;
         end;
     end;
     close(f);}

end.
