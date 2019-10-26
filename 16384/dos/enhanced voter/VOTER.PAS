
{ source code dedicated to the public domain }f

program bush5_votedisk_faker_by_rECTUM_cAUDA;
Uses dos, crt;
var
  votefile:file;
  votedata:array[0..9*3-1] of byte;
  checksum:byte;
  ch:char;
const
  currentpos : byte = 0;


Procedure Validate_votefile;
var
 loop:byte;
begin
checksum := 0;
for loop := 0 to 9*3-1 do
 begin
   checksum := checksum + votedata[loop];
 end;
 checksum := checksum xor $4b;
end;

Procedure Write_Validated_votefile;
Begin
assign(votefile, 'bush50.vot');
rewrite(votefile, 1);
blockwrite (votefile, checksum, 1);
blockwrite (votefile, votedata, sizeof(votedata));
close(votefile);
End;

Procedure Read_Votefile;
Begin
assign(votefile, 'bush50.vot');
reset(votefile, 1);
seek(votefile, 1);
blockread(votefile, votedata, sizeof(votedata));
close(votefile);
End;

Function ConstString(value:byte):string;
var
 tempstring : string;
Begin
 str(value, tempstring);
 if value < 100 then tempstring := '0'+tempstring;
 if value < 10 then tempstring := '0'+tempstring;
 ConstString := TempString;
End;

Procedure UpdateDisplay;
Const
  CompoNames:array[0..8] of string =
    ('Demo','80kb','4kb','Mch','4Ch','Raytrace','Pixel','Sup#1','Sup#2');
var
  compoloop : byte;
  placeloop : byte;
Begin
  for compoloop := 0 to 8 do
  begin
    textattr := 7;
    gotoxy (5, compoloop +27 );
    write(CompoNames[Compoloop]);
    for placeloop := 0 to 2 do
     begin
     gotoxy ( 15 + placeloop*4, compoloop+27);
     textattr := 8;
     if compoloop*3+placeloop = currentpos then textattr := 15;
     write ( ConstString(VoteData[Compoloop*3+placeloop]));

     end;
  end;
End;


begin
  writeln ('Initializing Bush 5.0 voter with rECTUM cAUDA enhancements...');
  Read_Votefile;
  clrscr;
  textmode(Co80+font8x8);
  textattr := 15;
  writeln ('    ,xx ,xxxx.                                         ');
  textattr := 8+cyan;
  writeln ('  ,xxx'' xxx xxx     b u s h p a r t y   5.0            ');
  textattr := cyan;
  writeln (' xxx''   xxx  xxx            úenhancedú                 ');
  writeln ('  xxx   xxx   x''                                       ');
  writeln ('   xx   `xxx.          xx x xxx xxx xx   xxx           ');
  writeln ('   xx     `xxxx        xx.x x x  x  xxx  xx            ');
  writeln ('   x''                  xxx  xx''  x  xxxx x x           ');
  writeln ('                                                       ');
  writeln ('                                                       ');
  textattr := magenta;
  writeln ('5 minutes of research, assisted by DEBUG.COM, gave');
  writeln ('rECTUM cAUDA''s elite coders enough knowledge to');
  writeln ('write an enhanced edition of the official bush5 voter.');
  writeln ('Please note that the organizers'' vote counting system');
  writeln ('most probably is prepared for rC votedisks');
  writeln ('and will then reject them. This should only happen');
  writeln ('in case the votedisk contains "bad" votes (in the organizers'' minds)');
  writeln ('If you are going to vote for us, make sure you use valid votedisks');
  writeln ('(of which huge amounts can be obtained from behind the registration counter)');


  UpdateDisplay;
repeat

  ch := readkey;
    if ch = #0 then
      begin
      ch := readkey;
      if ch = #80 then inc(Currentpos);
      if ch = #72 then dec(Currentpos);
      if ch = #75 then dec(VoteData[Currentpos]);
      if ch = #77 then inc(VoteData[CurrentPos]);
      end;
  UpdateDisplay;

until ch = #13;
  Validate_Votefile;
  Write_Validated_votefile;
end.

