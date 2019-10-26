{$G+}
{$DEFINE cesky}
{$DEFINE sejf}
{$DEFINE _soundblaster}
const
 sinB:array[0..255] of shortint=(0,3,6,9,12,16,19,22,25,28,31,34,37,40,43,46,
 49,52,54,57,60,63,66,68,71,73,76,78,81,83,86,88,
 90,92,94,96,98,100,102,104,106,108,109,111,112,114,115,116,
 118,119,120,121,122,123,123,124,125,125,126,126,126,127,127,127,
 127,127,127,127,126,126,125,125,124,124,123,122,121,120,119,118,
 117,116,114,113,112,110,108,107,105,103,101,99,97,95,93,91,
 89,87,84,82,80,77,75,72,69,67,64,61,59,56,53,50,
 47,44,41,39,36,32,29,26,23,20,17,14,11,8,5,2,
 -2,-5,-8,-11,-14,-17,-20,-23,-26,-29,-32,-36,-39,-41,-44,-47,
 -50,-53,-56,-59,-61,-64,-67,-69,-72,-75,-77,-80,-82,-84,-87,-89,
 -91,-93,-95,-97,-99,-101,-103,-105,-107,-108,-110,-112,-113,-114,-116,-117,
 -118,-119,-120,-121,-122,-123,-124,-124,-125,-125,-126,-126,-127,-127,-127,-127,
 -127,-127,-127,-126,-126,-126,-125,-125,-124,-123,-123,-122,-121,-120,-119,-118,
 -116,-115,-114,-112,-111,-109,-108,-106,-104,-102,-100,-98,-96,-94,-92,-90,
 -88,-86,-83,-81,-78,-76,-73,-71,-68,-66,-63,-60,-57,-54,-52,-49,
 -46,-43,-40,-37,-34,-31,-28,-25,-22,-19,-16,-12,-9,-6,-3,-1);
 _roztec:integer=64;
 _y:byte=46;
 _ko=256;
 _kr=64;
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
var
 scr:array[0..183,0..319] of byte;
 belt:array[0..15,0..327] of byte;
 _s,_o,tp,tf:word;
 tim:word;
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
FUNCTION  MinI(x,y:integer):integer;inline($58/$5b/$3b/$c3/$7e/$01/$93);{pop ax;pop bx;cmp ax,bx;jle +1;xchg ax,bx}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE pal(col,r,g,b:byte); assembler;
{Nastavi barve col RGB odstin}
asm   {pal}
 mov  dx,03C8h
 mov  al,col
 out  dx,al
 inc  dx
 mov  al,r
 out  dx,al
 mov  al,g
 out  dx,al
 mov  al,b
 out  dx,al
end;  {pal}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE Xchg(var a,b; bytes:word); assembler;
asm   {Xchg}
 push ds
 lds  si,a
 les  di,b
 mov  cx,bytes
@1:
 mov  al,es:[di]
 xchg al,[si]
 stosb
 inc  si
 loop @1
 pop  ds
end;  {Xchg}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
FUNCTION  Bounded(n,min,max:longint):longint; assembler;
asm   {Bounded}
 db  66h;mov ax,word ptr n
 db  66h;mov bx,word ptr min; db 66h;cmp ax,bx; jle @bx
 db  66h;mov bx,word ptr max; db 66h;cmp bx,ax; jle @bx
 mov dx,word ptr n+2
 jmp @end
@bx:
 mov ax,bx
 db  66h;shr bx,16
 mov dx,bx
@end:
end;  {Bounded}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE flip; assembler;
asm   {flip}
 mov  dx,03DAh
@1:
 in   al,dx
 test al,8
 jnz  @1
@2:
 in   al,dx
 test al,8
 jz   @2
 mov  dx,ds
 push 0A000h
 pop  es
 mov  di,16*320
 cli
 mov  si,offset scr
 mov  cx,320*184/4
 db   66h;rep  movsw
 mov  ds,dx
 sti
end;  {flip}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
Procedure Line(X1,Y1,X2,Y2:Integer; Col:Byte);
function sign(a:integer):integer; assembler;
asm
 mov  ax,a
 or   ax,ax
 jg   @g
 jl   @l
 jmp  @end
@g:
 mov  ax,1
 jmp  @end
@l:
 mov  ax,-1
@end:
end;
Var i,s,d1x,d1y,d2x,d2y,u,v,m,n:Integer;
Begin
 u:=x2-x1;
 v:=y2-y1;
 d1x:=Sign(u);
 d1y:=Sign(v);
 d2x:=Sign(u);
 d2y:=0;
 m:=Abs(u);
 n:=Abs(v);
 If Not(M>N) Then
  Begin
   d2x:=0;
   d2y:=Sign(v);
   m:=Abs(v);
   n:=Abs(u);
  End;
 s:=m ShR 1;
 For i:=0 To M Do
  Begin
   scr[y1,x1]:=Col;
   Asm
    mov ax,n
    add s,ax         {s := s + n;}
    mov ax,s
    cmp ax,m
    jb @elseif       {IF not (s<m) THEN BEGIN}
    mov ax,m
    sub s,ax         {s := s - m;}
    mov ax,d1x
    add x1,ax         {x1:= x1 + d1x;}
    mov ax,d1y
    add y1,ax         {y1 := y1 + d1y;}
    jmp @endif       {end}
   @elseif:            {ELSE BEGIN}
    mov ax,d2x
    add x1,ax         {x1 := x1 + d2x;}
    mov ax,d2y
    add y1,ax         {y1 := y1 + d2y;}
   @endif:             {END;}
   End;
  End;
End;
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
function barvu(barva:byte):byte;
begin {barvu}
 case barva of
 $00..$3F: barvu:=24-((barva and $3F) div 10);
 $40..$7F: barvu:=16+(barva and $3F) shr 3;
 $80..$BF: barvu:=24+(barva and $3F) shr 3;
 $C0..$FF: barvu:=31-(barva and $3F) shr 3;
 end;
end;  {barvu}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure textdata; assembler;
asm
 {$IFDEF cesky}
 db   ' Zdravim. Patrick0 uvadi intro -KROUCHLE-. Toto intro dokladuje prislovi: NENI DULEZITE ZVITEZIT, '
 db   'ale ZUCASTNIT SE. Ti, co ihned neutekli maji celkem vydrz. Dekuji. PODPORUJTE CESKOU DEMOSCENU '
 db   'a UNDERGROUND a uvidite vice inter, jako je tohle....'
 db   0
 {$ELSE}
 db   ' Greetz. Patrick0 presents intro -SPHUBE-. This intro backs a preverb: IT''S NOT IMPORTANT TO WIN '
 db   'but TO TAKE PART. Those who didn''t run away are quite rigid:) Thanx. Support czech scene'
 db   '&underground and you''ll see many other this-like intros....'
 db   0
 {$ENDIF}
end;
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure zobrazbelt; assembler;
asm   {zobrazbelt}
 push 0A000h
 pop  es
 mov  si,offset belt
 xor  di,di
 mov  bl,16
@ForY:
 mov  cx,80
 db   66h;rep  movsw
 add  si,8
 dec  bl
 jnz  @ForY
end;  {zobrazbelt}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure pridejpismeno;
var i,j:byte;
begin {pridejpismeno}
 for j:=0 to 15 do
  for i:=0 to 7 do
  if mem[_s:_o+mem[CSeg:tp] shl 4+j] and ($80 shr i)<>0
  then belt[j,320+i]:=100+port[$40] and 3
  else belt[j,320+i]:=20+port[$40] and 3;
end;  {pridejpismeno}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure posunbelt; assembler;
asm   {posunbelt}
 push ds
 pop  es
 mov  si,offset belt
 mov  di,si
 inc  si
 mov  cx,16*328-1
 rep  movsb
end;  {posunbelt}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure pistext; assembler;
asm   {pistext}
 mov  bx,tp
 mov  al,cs:[bx]
 or   al,al
 jnz  @0
 call pridejpismeno
 jmp  @1
@0:
 inc  tf
 and  tf,7
 jnz  @1
 call pridejpismeno
 inc  tp
@1:
 call posunbelt
@2:
 call zobrazbelt
@3:
end;  {pistext}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
{$IFDEF soundblaster}
const
 sbOn:boolean    =false;
 dspBase         =$220;
 dspReset        =dspBase+$6;
 dspReadData     =dspBase+$A;
 dspWriteData    =dspBase+$C;
 dspWriteStatus  =dspBase+$C;
 dspDataAvailable=dspBase+$E;
FUNCTION sbResetDSP:boolean; assembler;
asm   {sbResetDSP}
 mov  al,1
 mov  dx,dspReset
 out  dx,al
 mov  cx,0FFFFh
 db   66h;rep xchg ax,ax
 mov  al,0
 out  dx,al
 mov  cx,0FFFFh
 db   66h;rep xchg ax,ax
 mov  dx,dspDataAvailable
 in   al,dx
 test al,80h
 jz   @ne
 mov  dx,dspReadData
 in   al,dx
 cmp  al,0AAh
 jne  @ne
 mov  al,true
 jmp  @end
@ne:
 mov  al,false
@end:
end;  {sbResetDSP}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE sbWriteDSP(value:byte); assembler;
asm   {sbWriteDSP}
 mov  dx,dspWriteStatus
@1:
 {$IFDEF sejf}
 in   al,60h
 dec  al
 jz   @2
 {$ENDIF}
 in   al,dx
 test al,80h
 jnz  @1
{$IFDEF sejf}
@2:
{$ENDIF}
 mov  dx,dspWriteData
 mov  al,value
 out  dx,al
end;  {sbWriteDSP}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE sbPlayBack(sound:pointer; Size:word; frequency:word);
var
 TimeConstant:word;
 Page:word;
 Ofset:word;
begin {sbPlayBack}
 if (Size<1) or (sound=nil) or (frequency and $F000=0) then exit else dec(Size);
 sbWriteDSP($D1);
 Ofset:=seg(sound^) shl 4+ofs(sound^);
 page:=(seg(sound^)+ofs(sound^) shr 4) shr 12;
 port[$0A]:=5;
 port[$0C]:=0;
 port[$0B]:=$49;
 port[$02]:=lo(Ofset);
 port[$02]:=hi(Ofset);
 port[$83]:=page;
 port[$03]:=lo(Size);
 port[$03]:=hi(Size);
 port[$0A]:=1;
 TimeConstant:=256-1000000 div frequency;
 sbWriteDSP($40);
 sbWriteDSP(TimeConstant);
 sbWriteDSP($14);
 sbWriteDSP(lo(Size));
 sbWriteDSP(hi(Size));
end;  {sbPlayBack}
{$ENDIF}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
const
 _ra:array[0..18] of byte=(
 5,25,36,43,47,51,54,55,57,58,55,50,41,32,23,14,9,5,2);
{ 5,27,39,47,52,56,59,61,63,64,63,61,59,56,52,47,39,27,5);}
var
 i,j,k,l,m,n,c,minpos:byte;
 ns:shortint;
 s:array[0..7] of
  record
   n,c:byte;
  end;
begin
 asm
  mov  ax,13h
  int  10h
  mov  ax,1130h
  mov  bh,06h
  int  10h
  mov  _s,es
  mov  _o,bp
  mov  ax,offset textdata
  mov  tp,ax
  mov  tf,7
 end;
 fillchar(belt,sizeof(belt),0);
 for i:=0 to 15 do pal(i+32,0,i shl 2,0);
 tim:=0; {$IFDEF soundblaster}sbOn:=sbResetDSP;{$ENDIF}
 repeat
  for i:=0 to 255 do
   begin
    pistext;
    {seradi barvy}
    for k:=0 to 7 do
     with s[k] do
     begin
      n:=k;
      c:=barvu(byte(sinB[i]+k*$40+$A0));
     end;
    for m:=0 to 6 do
     begin
      minpos:=m;
      for k:=m+1 to 7 do
       if s[k].c>s[minpos].c then minpos:=k;
      xchg(s[m],s[minpos],2);
     end;
    inc(tim);
    {$IFDEF soundblaster}
    if tim and 15=0 then
     sbPlayBack(@sinB,256,$800+random($2000));
    {$ENDIF}
    if byte(tim)=192 then
     begin
      ns:=_ra[0];
      move(_ra[1],_ra[0],sizeof(_ra)-1);
      _ra[sizeof(_ra)-1]:=ns;
     end;
    ns:=(sinB[byte(tim)] div 2)*tim shr 12;
    _roztec:=$60+sinB[byte(tim shl 1+$80)] div 6;
    _y:=$40+sinB[byte(tim)] div 48;
    for j:=1 downto 0 do {pro dve barvy (seda a potom cerna pro smazani)}
     begin
      for k:=7 downto 0 do {pro segmenty}
       for l:=0 to 18 do {pro podstavy}
        begin
         line(sinB[byte(sinB[i]+64+s[k].n*$20)]*_ra[l] div $80+_ko
         ,_y+l*_roztec div 32+sinB[byte(sinB[i]+s[k].n*$20)]*_ra[l] div ($100+sinB[byte(tim shr 1)])
         ,sinB[byte(sinB[i]+64+(s[k].n+1) and 7*$20)]*_ra[l] div $80+_ko
         ,_y+l*_roztec div 32+sinB[byte(sinB[i]+(s[k].n+1) and 7*$20)]*_ra[l] div ($100+sinB[byte(tim shr 1)])
         ,barvu(byte(sinB[i]+k*$20+$A0))*j);
         if l<>18 then
          line(sinB[byte(sinB[i]+64+s[k].n*$20)]*_ra[l] div $80+_ko
          ,_y+l*_roztec div 32+sinB[byte(sinB[i]+s[k].n*$20)]*_ra[l] div ($100+sinB[byte(tim shr 1)])
          ,sinB[byte(sinB[i]+64+s[k].n*$20)]*_ra[(l+1) mod 19] div $80+_ko
          ,_y+(l+1)*_roztec div 32+sinB[byte(sinB[i]+s[k].n*$20)]*_ra[(l+1) mod 19] div ($100+sinB[byte(tim shr 1)])
          ,barvu(byte(sinB[i]+k*$20+$A0))*j);
        end;
      for k:=7 downto 0 do {pro ctyri steny}
       for l:=0 to 1 do {pro dve podstavy}
        begin
         line(sinB[byte(sinB[i]+64+l*(-ns)+s[k].n*$20)]*50 div $80+_kr
         ,_y+l*$40+sinB[byte(sinB[i]+l*(-ns)+s[k].n*$20)]*20 div $80
         ,sinB[byte(sinB[i]+64+l*(-ns)+(s[k].n+1) and 7*$20)]*50 div $80+_kr
         ,_y+l*$40+sinB[byte(sinB[i]+l*(-ns)+(s[k].n+1) and 7*$20)]*20 div $80
         ,barvu(byte(sinB[i]+k*$40+$A0))*j);
         if l=0 then
          for n:=0 to $3F do
           scr[_y+l*70+sinB[byte(sinB[i]-n*ns shr 6+s[k].n*$20)]*20 div $80+n
           ,sinB[byte(sinB[i]-n*ns shr 6+64+s[k].n*$20)]*50 div $80+_kr]:=barvu(sinB[i]+s[k].n*$40+$70)*j;
        end;
      for l:=0 to 7 do
       for k:=0 to 2 do
        begin
         fillchar(scr[32+l shl 4+k,160-abs(sinB[byte(i+l shl 5)]) div 4]
         ,abs(sinB[byte(i+l shl 5)]) div 2,(32+abs(sinB[byte(i+l shl 5)]) div 8)*j);
         fillchar(scr[32+l shl 4+k,160-abs(sinB[byte(i+l shl 5)]) div 4]
         ,2,26*j);
         fillchar(scr[32+l shl 4+k,160-abs(sinB[byte(i+l shl 5)]) div 4+abs(sinB[byte(i+l shl 5)]) div 2-2],2,26*j);
        end;
      if j=1 then flip;
     end;
    if port[$60]=1 then break;
   end;
 until port[$60]=1;
 asm
  xor  ah,ah
  int  16h
  mov  ax,3
  int  10h
 end;
end.
