program SkuskaHry1;

uses graph,Crt;

const MaxN         = 10;
      MaxEdit      = 10;    { pocet tahov pre jedneho hraca pri Edit }
      MaxPlay      = 10;    { pocet tahov pre jedneho hraca pri Play }
      RandomMirrNum= 5;     { number of random mirrors }

      EditPhase    = 0;
      PlayPhase    = 1;
      EndPhase     = 2;
      Player1      = 0;
      Player2      = 1;

      Free         = 0;
      MainMirror   = 1;
      SecMirror    = 2;
      MirrorMask   = 3;

 { (from) 1 = up, 2 = right, 3 = down, 4 = left }
      Pl : array[0..1,1..4] of Word =
                     ( (4,8,16,32) , (64,128,256,512) );
      PlayerMask : array[0..1] of Word = (60,960);
      Pohyb : array[0..1,1..4] of Integer =
                     ( (0,-1,0,1) , (1,0,-1,0) );

      XX           = 150;
      YY           = 090;
      SIZ          = 24;
      SIP          = 12;

type  PHraciePole  = ^THraciePole;
      THraciePole  = array[0..MaxN+1,0..MaxN+1] of Word;

var   a            : PHraciePole;
      CurP         : Byte;          { prave hrajuci hrac  }
      CurT         : Byte;          { aktualne cislo tahu }
      CurGP        : Byte;          { aktualna faza hry   }
      x,y,z        : Integer;
      score        : array[0..1] of Integer;
      Games        : Integer;

procedure Inic;
var grDriver: Integer;
    grMode: Integer;
    ErrCode: Integer;
begin
 grDriver := Detect;
 InitGraph(grDriver, grMode,'');
 ErrCode := GraphResult;
 if ErrCode <> grOk then begin
  Writeln('Graphics error:', GraphErrorMsg(ErrCode));
  Halt(0);
 end;
 New(a);
 Fillchar(score, SizeOf(score),0);
 Randomize;
end;

procedure DeInic;
begin
 CloseGraph;
 Dispose(a);
end;

procedure ShowStatus;
var ss,s2 : string;
begin
 SetViewPort(0, 0, 639, YY-1, ClipOn);
 ClearViewPort;
 if (CurGP=EditPhase) then ss:='Edit phase - set up some mirror on plane.';
 if (CurGP=PlayPhase) then ss:='Play phase - launch the laser beam.';
 if (CurGP=EndPhase)  then ss:='Result:';
 MoveTo(130,0);
 OutText(ss);
 Str(CurT:2,ss);
 if (CurGP=EditPhase) then Str(MaxEdit:2,s2);
 if (CurGP=PlayPhase) then Str(MaxPlay:2,s2);
 ss:='Turn: ['+ss+'/'+s2+']';
 if (CurP=Player1) then ss:=ss+'                Player: 1'
                   else ss:=ss+'                Player: 2';
 MoveTo(135,20);
 if (CurGP<>EndPhase) then OutText(ss);
 Str(score[0]:5,ss); ss:='Player 1: '+ss; MoveTo(135,40); OutText(ss);
 Str(score[1]:5,ss); ss:='Player 2: '+ss; MoveTo(330,40); OutText(ss);
 Str(Games,ss); ss:='Games to play: '+ss;
 MoveTo(135,60); if (Games>0) then OutText(ss) else OutText('Final!');
 SetViewPort(0, 0, 639, 479, ClipOn);
end;

procedure DrawMainPlane;
var i,j   : Integer;
 procedure DrawPlayer(p:Integer);
 var k : Integer;
     b     : array[1..4] of Byte;
 begin
  FillChar(b,SizeOf(b),0);
{ (z) 1 = hore, 2 = pravo, 3 = dole, 4 = lavo }
  for k:=1 to 4 do
   if (a^[i,j] and Pl[p,k])>0 then b[k]:=1;
  if (b[1]=1) then Line(i*SIZ+XX+SIP,j*SIZ+YY,i*SIZ+SIP+XX,j*SIZ+SIP+YY);
  if (b[2]=1) then Line(i*SIZ+XX+SIP,j*SIZ+SIP+YY,i*SIZ+SIZ+XX,j*SIZ+SIP+YY);
  if (b[3]=1) then Line(i*SIZ+XX+SIP,j*SIZ+YY+SIP,i*SIZ+SIP+XX,j*SIZ+SIZ+YY);
  if (b[4]=1) then Line(i*SIZ+XX,j*SIZ+YY+SIP,i*SIZ+SIP+XX,j*SIZ+SIP+YY);
 end;
begin
 ClearViewPort;
 for i:=1 to MaxN do
  for j:=1 to MaxN do begin
   Line(i*SIZ+XX,j*SIZ+YY,i*SIZ+SIZ+XX,j*SIZ+YY);
   Line(i*SIZ+XX,j*SIZ+YY,i*SIZ+XX,j*SIZ+SIZ+YY);
   SetColor(11);
   if (a^[i,j] and MainMirror)>0 then begin
    Line(i*SIZ+XX+1,j*SIZ+YY+1,i*SIZ+SIZ+XX-1,j*SIZ+SIZ+YY-1);
   end;
   if (a^[i,j] and SecMirror)>0 then begin
    Line(i*SIZ+XX+1,j*SIZ+SIZ+YY-1,i*SIZ+SIZ+XX-1,j*SIZ+YY+1);
   end;
   SetColor(10);
   DrawPlayer(Player1);
   SetColor(12);
   DrawPlayer(Player2);
   SetColor(15);
  end;
 Line(11*SIZ+XX,YY+SIZ,11*SIZ+XX,11*SIZ+YY);
 Line(XX+SIZ,11*SIZ+YY,11*SIZ+XX,11*SIZ+YY);
 SetColor(11);
 MoveTo(20,400); OutText('Masters of Deflektor - 2 players game by Mr.PED/7GODS demo group (c) 1997');
 MoveTo(20,410); OutText('Thanks goes to Costa Panai for original "Deflektor" game (ZX Spectrum)');
 MoveTo(20,420); OutText('(do you remember ? I did change this action game to slow mind battle :)');
 SetColor(10);
 MoveTo(20,430); OutText('Controls: K=end');
 MoveTo(20,440); OutText('  - Edit Phase: O,P,Q,A movement  1 = "\" mirror,  2 = "/" mirror');
 MoveTo(20,450); OutText('  - Edit Phase: O,P     movement  SPACE = launch');
 MoveTo(20,460); SetColor(1); OutText('school exams suxxxx...');
 SetColor(15);
end;

procedure Kurzor;
var i : Integer;
begin
 SetColor(1);
 for i:=0 to (SIZ-1) do
  Line(x*SIZ+XX,y*SIZ+YY+i,x*SIZ+SIZ+XX-1,y*SIZ+YY+i);
 SetColor(15);
end;

procedure Kurzor2;
var i : Integer;
begin
 if (z<=10)             then begin y:=0; x:=z; end;
 if (z>=11) and (z<=20) then begin y:=z-10; x:=11; end;
 if (z>=21) and (z<=30) then begin y:=11; x:=31-z; end;
 if (z>=31)             then begin y:=41-z; x:=0; end;
 Kurzor;
end;

procedure EditPlane;
 procedure AskForMirror;
 var cc : char;
 begin
  SetWriteMode(XORPut);        { XOR mode }
  repeat
   Kurzor; cc:=ReadKey; Kurzor;
   if (cc='o') and (x>1) then Dec(x);
   if (cc='p') and (x<MaxN) then Inc(x);
   if (cc='q') and (y>1) then Dec(y);
   if (cc='a') and (y<MaxN) then Inc(y);
   if (cc='k') then Halt(0);
  until ((a^[x,y] and MirrorMask)=0) and
        ((cc='1') or (cc='2'));
  if cc='1' then a^[x,y]:=a^[x,y]+1
            else a^[x,y]:=a^[x,y]+2;
  SetWriteMode(NormalPut);     { Normal mode for rectangle }
  DrawMainPlane;
 end;
begin
 FillChar(a^, SizeOf(THraciePole), 0);
 for z:=1 to RandomMirrNum do begin
  repeat
   x:=1+Random(MaxN);
   y:=1+Random(MaxN);
  until (a^[x,y]=0);
  a^[x,y]:=1+Random(2);
 end;
 x:=1; y:=1;
 DrawMainPlane;
 CurT:=0; CurGP:=EditPhase;
 while (CurT<MaxEdit) do begin
  Inc(CurT);
  CurP:=1-CurP;
  ShowStatus;
  AskForMirror;
  CurP:=1-CurP;
  ShowStatus;
  AskForMirror;
 end;
end;

procedure LaunchBeam;   { z,x,y, CurP }
var oo: Word;
    pp,p2 : Byte;
begin
 a^[x,y]:=1;            { odtial uz isiel luc }
 pp:=CurP;
 if (z<=10)             then oo:=1; { odkial ide luc }
 if (z>=11) and (z<=20) then oo:=2;
 if (z>=21) and (z<=30) then oo:=3;
 if (z>=31)             then oo:=4;
{ teraz ma v x,y predosle policko, pp ma current owner, oo ma curr. smer }
 repeat { az kym nevyleti von z plochy }
  x:=x+Pohyb[0,oo];
  y:=y+Pohyb[1,oo];
  Inc(score[pp]);
  if (a^[x,y] and MirrorMask)=0 then begin  { nie je zrkadlo, mohol krizit }
   p2:=pp;
   if (pp=CurP) then begin { ma svoj luc, cize cudzi meni ! }
    pp:=1-pp;
    if (a^[x,y] and PlayerMask[pp])=0 then pp:=1-pp;
   end else begin          { nema svoj luc, tak lub. meni ! }
    if (a^[x,y] and PlayerMask[0])<>0 then pp:=1-pp
    else if (a^[x,y] and PlayerMask[1])<>0 then pp:=1-pp;
   end;
   if oo>2 then oo:=oo-2 else oo:=oo+2;
   a^[x,y]:=a^[x,y] or Pl[pp,oo];
   if oo>2 then oo:=oo-2 else oo:=oo+2;
   a^[x,y]:=a^[x,y] or Pl[p2,oo];
  end else begin                            { je zrkadlo, zmen smer }
   a^[x,y]:=a^[x,y] or Pl[pp,oo];
{ (z) 1 = hore, 2 = pravo, 3 = dole, 4 = lavo }
   if (a^[x,y] and SecMirror)=0 then oo:=5-oo { main }
   else begin                                 { secondary }
    if (oo mod 2)=0 then oo:=oo-1 else oo:=oo+1;
   end;
   if oo>2 then oo:=oo-2 else oo:=oo+2;
   a^[x,y]:=a^[x,y] or Pl[pp,oo];
   if oo>2 then oo:=oo-2 else oo:=oo+2;
  end;
 until (x=0) or (y=0) or (x=MaxN+1) or (y=MaxN+1);
 Inc(score[pp]);
 a^[x,y]:=1;            { a sem dosiel luc }
 DrawMainPlane;         { vykresli ho }
end;

procedure PlayPlane;
 procedure AskForBeam;
 var cc : char;
     bb : byte;
 begin
  SetWriteMode(XORPut);        { XOR mode for rectangle }
  repeat
   Kurzor2; cc:=ReadKey; Kurzor2;
   if (cc='o') then Dec(z);
   if (z=0) then z:=MaxN*4;
   if (cc='p') then Inc(z);
   if (z=MaxN*4+1) then z:=1;
   if (cc='k') then Halt(0);
  until (cc=' ') and (a^[x,y]=0);
  SetWriteMode(NormalPut);     { Normal mode for rectangle }
  LaunchBeam;
 end;
begin
 z:=1; CurT:=0; CurGP:=PlayPhase;
 while (CurT<MaxPlay) do begin
  Inc(CurT);
  CurP:=1-CurP;
  ShowStatus;
  AskForBeam;
  CurP:=1-CurP;
  ShowStatus;
  AskForBeam;
 end;
end;

begin
 Writeln(' "Masters of Deflektor" - 2 players game by Mr.PED/7GODS demo group (c) 1997');
 Writeln(' Thanks goes to Costa Panai for original "Deflektor" game (ZX Spectrum)');
 Writeln;
 Writeln(' Rules of game: there is Edit phase, when both players are placing one mirror');
 Writeln(' on the plane until all mirrors are placed. There are two types of mirror.');
 Writeln('   There are already some random mirrors. (symetric play doesn''t end with draw)');
 Writeln('   Than starts the Play Phase. Same player is beginning, like in Edit phase.');
 Writeln(' The player is choosing the square, from where he will launch his laser beam');
 Writeln(' trough the plane. This square and the "finish" square is no more accepted as');
 Writeln(' a launching square in next turns.');
 Writeln;
 Writeln('   The beam is reflecting in mirrors.');
 Writeln('   If beam hits some other beam, than:');
 Writeln('   - if it was beam of the player, which is on the turn, than beam');
 Writeln('     gets always his launcher color.');
 Writeln('   - if it was beam of the other player, than color of this beam changes.');
 Writeln('     (if it hits two times other player beam, than it has again "own" color)');
 Writeln;
 Writeln('   Score: one point is added for each square the beam hits + 2 bonus points !');
 Writeln(' for reaching border of plane. The point is added to player with same color,');
 Writeln(' like the beam has at the beginning of square (+ at the end).');
 Writeln('   First turn is doing always other player, so I recommend to enter not odd');
 Writeln(' number of games (to keep both players start same number of games)');
 Writeln;
 Write('Enter number of games: '); Readln(Games);
 CurP:=Player2;
 Inic;
 while (Games<>0) do begin
  EditPlane;
  PlayPlane;
  Dec(Games);
  CurGP:=EndPhase; ShowStatus;
  CurP:=1-CurP;
  asm
   xor ax,ax
   int 16h
  end;
 end;
 DeInic;
end.
