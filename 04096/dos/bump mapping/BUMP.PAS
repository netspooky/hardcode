program bump_mapping;
type tomb=array[0..64000] of byte;
type tomb2=array[0..64000] of shortint;
var bumpmap:text;
    bump:^tomb;
    bumpx:^tomb2;
    kep:^tomb;
    ch1,ch2:char;
    a,b,w1,w2,z,curtext:byte;
    x:integer;
    y:shortint;
    s,co,fontseg,fontoffset:word;
    light:array[0..100,0..100] of byte;
const
     txt:array[0..2, 0..3] of string[30]=
    (('*********************',
      'Gargaj/ömlaÅt Design',
      'presents:',
      '*********************'),
     ('BöMP MéPPING',
      'A 4K in TURBO PASCAL!',
      'Made for the',
      'Conference 7007 party'),
     ('Group greets go to:',
      '-------------------',
      'AstroideA/Digital Dynamite',
      'Exceed/Mandula/United Force'));
      {----^----^----^----^----^----^}
      {----5---10---15---20---25---30}
    PL=64;
    SL=64;

procedure setpal(c,r,g,b : byte); assembler;
asm
 mov dx,03c8h;
 mov al,c;
 out dx,al;
 inc dx;
 mov al,r
 out dx,al;
 mov al,g;
 out dx,al;
 mov al,b;
 out dx,al
end;

procedure calclight;
var r,dx,dy:shortint;
    a,b,c:byte;
const cx=50;cy=50;
begin
fillchar(light,sizeof(light),0);
for a:=0 to 50 do
begin
 c:=(50-a);
 r:=a;
 dx:=r;
 dy:=0;
 repeat
 if r<=sqr(dy) then
 begin
  dx:=dx-1;
  r:=2*dx+1;
 end;
 light[cx+dx,cy+dy]:=c;
 light[cx-dx,cy+dy]:=c;
 light[cx+dx,cy-dy]:=c;
 light[cx-dx,cy-dy]:=c;
 light[cx+dy,cy+dx]:=c;
 light[cx-dy,cy+dx]:=c;
 light[cx+dy,cy-dx]:=c;
 light[cx-dy,cy-dx]:=c;
 inc(dy);
 until dy>=dx;
end;
for b:=2 to 100 do
 for a:=2 to 100 do
  if light[a,b]=0 then light[a,b]:=(light[a-1,b]+light[a+1,b]) div 2;
end;

procedure getfont; assembler;
asm { gets 8x16 font }
 mov ax,1130h;
 mov bh,6;
 int 10h;
 mov fontseg,es;
 mov fontoffset,bp;
end;

procedure settext(x:byte);
var a,b,c,d,c1,c2:byte;
    s:word;
begin
for s:=0 to 64000 do bump^[s]:=0;
for c:=0 to 3 do
begin
 c1:=(320-length(txt[x,c])*8) div 2;
 c2:=(200-4*16) div 2+c*16;
 if txt[x,c]<>'' then
 begin
  for a:=1 to length(txt[x,c]) do
  begin
   for d:=0 to 15 do
   for b:=0 to 7 do
    bump^[(c2+d)*320+c1+(a*8)+(7-b)]:=((mem[fontseg:fontoffset+byte(txt[x,c][a])*16+d] shr b) and 1);
  end;
 end;
end;
for s:=0 to 64000 do bumpx^[s]:=(bump^[s]-bump^[s+1])*8;
end;

procedure exitme;
begin
asm
 mov ax,3h
 int 10h
end;
dispose(kep);
dispose(bump);
dispose(bumpx);
halt;
end;

BEGIN
y:=1;
x:=1;
z:=0;
new(bump);
if bump=nil then exitme;
new(bumpx);
if bumpx=nil then exitme;
new(kep);
if kep=nil then exitme;
getfont;
calclight;
curtext:=0;
settext(0);
asm
 mov ax,13h
 int 10h
end;

repeat

(*
case z of
 0:for a:=0 to 255 do setpal(a,0      ,a shr 2,0      );
 1:for a:=0 to 255 do setpal(a,0      ,a shr 2,a shr 2);
 2:for a:=0 to 255 do setpal(a,a shr 2,0      ,a shr 2);
 3:for a:=0 to 255 do setpal(a,a shr 2,a shr 2,0      );
 4:for a:=0 to 255 do setpal(a,0      ,0      ,0      );
 5:for a:=0 to 255 do setpal(a,a shr 2,0      ,0      );
end;
*)

for a:=0 to 255 do
begin
 w1:=trunc((a shr 2)*(x/200));
 w2:=trunc((a shr 2)*((200-x)/200));
 case z of
  0:setpal(a,0      ,a shr 2,w1);
  1:setpal(a,w2     ,w1     ,a shr 2);
  2:setpal(a,a shr 2,w1     ,w2);
  3:setpal(a,w1     ,a shr 2,0);
  4:setpal(a,w1     ,w2     ,0);
  5:setpal(a,w1     ,0      ,0);
 end;
end;



for b:=0 to 99 do
 for a:=0 to 99 do
 begin
  co:=(x+a)+(50+b)*320;
  if light[a,b]>1 then
   kep^[co]:=abs(bumpx^[co]+(light[a,b]))*4;
 end;

move(kep^,mem[$a000:0],64000);
fillchar(kep^,64000,0);

inc(x,y);
if (x>=200) or (x<=0) then
begin
 y:=-y;
 inc(z);
 if x<=0 then
 begin
  inc(curtext);
  if (curtext=3) or (port[$60]=1) then exitme;
 end;
 settext(curtext);
end;

until port[$60]=1;
exitme;
END.