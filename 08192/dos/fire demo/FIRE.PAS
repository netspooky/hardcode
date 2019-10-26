Program FireDemo;
Uses Crt;
Var
   i,x,y : Integer;
   FirePos : Array[1..319,1..199] of Byte;
   FireDiv : Real;
BEGIN { Main }
   { Randomizing Š Fire routine :) }
   Randomize;

   { Set MCGA mode 13 }
   asm
      mov     ax,0013h
      int     10h
   End;

   { Changing palette colors }
   For i := 1 to 5 do
   Begin
        Port[$3c8] := i; { Set Color attribute to change. }
        { Set RGB }
        Port[$3c9] := i*11; Port[$3c9] := i*3; Port[$3c9] := 0;
   End;
   For i := 6 to 12 do
   Begin
        Port[$3c8] := i; { Color attribute to change. }
        { Set RGB }
        Port[$3c9] := i*5; Port[$3c9] := i*5; Port[$3c9] := 0;
   End;

   { Calculating 1st 2 rows of the fire routine. }

   { Start of Routine }
   While not KeyPressed do
   Begin { while loop }
      For y := 199 to 200 do
      Begin { y }
            For x := 15 to 300 do FirePos[x,y] := Random(8) + 5;
      End;

      For y := 199 downto 130 do
      Begin { y }
            For x := 10 to 305 do
            begin { x }
                  i := Random(5) + 1;
                  Case i of
                       1: FirePos[x,y] := FirePos[x-1,y+1];
                       2: FirePos[x,y] := FirePos[x+1,y+1];
                       3: FirePos[x,y] := FirePos[x,y+1];
                       4: FirePos[x,y] := FirePos[x,y];
                       ELSE
                       begin { else }
                             FireDiv := Int((FirePos[x+1,y] + FirePos[x-1,y] + FirePos[x,y+1] ) / 3.1) ;
                             FirePos[x,y] := Round(FireDiv);
                       end; { else }
                  end; { case }
                  Mem [$a000:x+(y*320)]:=FirePos[x,y];
            end; { x }
      end; { y }
   End; { While loop }

   { Set Text mode 3}
   asm
        mov     ax,0003h
        int     10h
   End;
   WriteLn('written by ® F…¤T“M €…T ¯ of < swDeMo > GRouP');
END. { Main }

