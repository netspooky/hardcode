
program rask_fastintro;
uses crt,dos;
var
 x,y:word;

begin
textmode(co80+font8x8);
textattr := 15;
writeln('  xxxx   xx xx  xxx  xx x    xx    ');
textattr := 7;
writeln('  xx xx  xx xx xx    xx x   xx     ');
textattr := 8;
writeln('  xxxxx  xx xx  xxx  xxxx  xxxx    ');
writeln('  xx  xx xx xx    xx xx x  xx xx   ');
writeln('  xxxxxx  xxx   xxx  xx x   xxx    ');
writeln('                                   ');
delay(1500);
textattr := cyan;
writeln ('Kom til bushparty og bli drita full');
writeln;
delay(1500);
textattr := cyan+8;
writeln ('24/6 - 27/6  1999');
writeln;
delay(1500);
writeln;
textattr := cyan;
writeln ('Ja. Kjekt.');
delay(1500);
writeln;
for x := 0 to 3000 do
 begin
  y := y + round(1500*sin(x*x));
  sound (y xor x);
  delay(1);
 end;

textattr := 15;
writeln;
writeln;
writeln;
writeln;
writeln ('Code by Piffi');
writeln ('Music by Piffi');
writeln ('Bush6 ascii logo by Piffi');
writeln ('Stem p† rectum cauda for faen =) ');
writeln;
writeln ('Ja fint.');
nosound;

end.