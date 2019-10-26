{ hi you pas-progger...this is mr.x of hASH.X and tECHN0 aRTS...
  i released this code to the public because i thought that you
  can learn something from it...this is an easy code...so if ya
  like to make a bbstro comme ca (french ??? (: )...change the code like you
  want it...and if you improve it...pump it on my bbs x-zone...
  mhhh.....greets oh yes...to klump for some help in the past...
  and to plasmoid of deep who progged the nice fatchat...thnx...
  yes thats all...have a nice time...
  
  p.s.
  the files "ansi.ans and ansi.obj are just the gfx...
  u don't need ansi.ans but u have to make ya own ansi.obj
  with thedraw or something like that....

 }



{$L ansi.obj}
uses crt,dos;

procedure write_line(tstr : string);

  var
    i : integer;

    procedure write_char(char1 : char);

    begin
      delay(60 + random(75));
      write(char1);
     sound(150);
    delay(10);
    nosound;
    end;

  begin
    for i := 1 to length(tstr) do
      begin
        if random(50) = 0 then
          begin
            write_char(chr(random(26)+65));
            delay(100 + random(100));
            write_char(#8);
           end;
        write_char(tstr[i]);
      end;
    writeln;
  end;

 procedure ImageData; external;
 procedure ImageData_Width; external;
 procedure ImageData_Depth; external;
 procedure ImageData_Length; external;

procedure displayxzone;
	 type ScreenType = array [0..3999] of Byte;
	 var Screen : ScreenType absolute $B800:0000;
	     X,Offset : Integer;

	 const
	   ImageDataPtr : ^ScreenType = @ImageData;
	   ImageDataWidthPtr : ^Integer = @ImageData_Width;
	   ImageDataDepthPtr : ^Integer = @ImageData_Depth;
	   ImageDataLengthPtr : ^Integer = @ImageData_Length;

	 begin
	   Offset := 001;     {den bildblock ersetzen...?}

	   for X := 0 to ImageDataDepthPtr^-1 do
	     Move (ImageDataPtr^[1+X*ImageDataWidthPtr^*2],
		   Screen[X*160+Offset],ImageDataWidthPtr^*2);
	 end;


  begin
  textcolor(lightblue);
  clrscr;
  displayxzone ;
  gotoxy(1,18);
  write_line('            - hASH.X WHQ - tECHN0 aRTS WHQ - RONNY SKRZEBA DiST -');
  write_line('                 - 1.7 GiGZ HD WiTH PcB.JPG.PROGGER STuFF -');
  write_line('                           - [NODE1:030/382-4782] -');
  write_line('                     -  FROM 21:00 to 7:00 WiTH 33.6oo  -');
  write_line('                     - [NODE2:FOLLOWS WiTH 28.8oo SOON] -');
  write_line('                     - okay now u can press ya key,hehe -');
  repeat until keypressed;
 end.