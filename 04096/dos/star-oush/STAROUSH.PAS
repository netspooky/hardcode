{$G+}
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
 napis:array[0..39] of byte=(
 $7C,$66,$66,$66,$66,$66,$7C,$00,
 $3C,$66,$66,$66,$66,$66,$3C,$00,
 $63,$63,$63,$6B,$6B,$6B,$3E,$00,
 $66,$66,$76,$7E,$6E,$66,$66,$00,
 $7E,$18,$18,$18,$18,$18,$18,$00);
 _stars=$100;
type
 TStar=
  record
   r:word;
   fi:byte;
   fi2:byte;
  end;
var
 star:array[0.._stars-1] of TStar;
 i,j:word;
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
FUNCTION  MaxI(x,y:integer):integer;inline($58/$5b/$3b/$d8/$7e/$01/$93);{pop ax;pop bx;cmp bx,ax;jle +1;xchg ax,bx}
procedure moment; assembler;
asm   {moment}
 mov  dx,03DAh
@1:
 in   al,dx
 test al,8
 jz   @1
@2:
 in   al,dx
 test al,8
 jnz  @2
end;  {moment}
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
const
 RSeed:longint=0;
 RValue:longint=0;
PROCEDURE InitR16b; assembler;
asm   {initr16b}
 mov  ax,0040h
 mov  es,ax
 mov  ax,es:[006ch]
 mov  word ptr [RSeed],ax
 mov  ax,es:[006ch+2]
 mov  word ptr [RSeed+2],ax
end;  {initr16b}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
function r16b:word; assembler;
asm   {r16b}
 mov  bx,word ptr [RValue]
 mov  ax,word ptr [RSeed]
 rol  ax,3
 sub  ax,7
 xor  ax,bx
 mov  word ptr [RValue],ax
 mov  word ptr [RSeed],bx
end;  {r16b}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure xorQuad(x:word; y,w,h:byte; c:byte); assembler;
asm   {xorQuad}
 push 0A000h
 pop  es
 xor  al,al
 mov  ah,y
 mov  di,ax
 shr  ax,1
 shr  ax,1
 add  di,ax
 add  di,x
 mov  si,320
 xor  ah,ah
 mov  al,w
 sub  si,ax
 mov  al,c
 mov  ch,h
@1:
 mov  cl,w
@2:
 xor  es:[di],al
 inc  di
 dec  cl
 jnz  @2
 add  di,si
 dec  ch
 jnz  @1
end;  {xorQuad}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
const
 starenable:byte=1;
PROCEDURE ShowStar(star:TStar);
var
 x,y,a:integer;
begin {ShowStar}
 with star do
 begin
  a:=sinB[byte(fi2)]*r div 128;
  x:=160+sinB[byte(fi+$40)]*r div 128;
  y:=100+sinB[byte(fi)]*a div 128;
  if (x<0) or (x>294) or (y<0) or (y>199) then else
   begin
    word(a):=byte(y) shl 8+byte(y) shl 6+x;
    if (mem[SegA000:a]>0) and (mem[SegA000:a]<16) then else
     mem[SegA000:a]:=(24+sinB[byte(fi+fi2)] div 16)*starenable;
   end;
 end;
end;  {ShowStar}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure textdata; assembler;
asm   {textdata}
 db   00h
 dw   0401h
 db   '\Downtown production\'
 dw   0601h
 db   'brings a contribution\'
 dw   0801h
 db   'to FIASKO ''99 party\'
 dw   0A01h
 db   'in category\'
 dw   0C01h
 db   '4 kB intro.'
 db   00h
 dw   0601h
 db   'The 4 kB intro\'
 dw   0801h
 db   'called\\\'
 dw   0A01h
 db   'STAR\/'
 dw   0B04h
 db   '/OUSH'
 dw   0D01h
 db   '(party version)'
 db   00h
 dw   0601h
 db   'made in Harry\\\\'
 dw   060Dh
 db   ' '
 dw   060Ch
 db   ' '
 dw   060Bh
 db   ' '
 dw   060Ah
 db   ' '
 dw   0609h
 db   ' '
 dw   0609h
 db   'hurry\'
 dw   0801h
 db   'by Carlos /Downtown'
 dw   0A01h
 db   'on the 11th of August 1999\'
 dw   0D01h
 db   'STAR IT! / OUSH IT!'
 db   '',0,'$'
end;  {textdata}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
const
 tim:word=0;
 TDelay:word=0;
 TOfs:word=ofs(textdata);
procedure texttask; assembler;
asm   {texttask}
 mov  si,TOfs
 or   word ptr TDelay,0
 jz   @0
 dec  word ptr TDelay
 jmp  @end
@0:
 mov  dl,cs:[si]   {nacte nasledujici znak}
 inc  si
 or   dl,dl
 jnz  @1
 push 0A000h       {0 - smazani obrazovky}
 pop  es
 xor  ax,ax
 mov  di,ax
 mov  dl,200
@0a:
 mov  cx,148
 rep  stosw
 add  di,24
 dec  dl
 jnz  @0a
 jmp  @end
@1:
 cmp  dl,' '       {mensi nez 32 - (spolu s dalsim bytem) nastaveni pozice}
 jae  @2
 mov  dh,cs:[si]
 inc  si
 xor  bh,bh
 mov  ah,2
 int  10h
 jmp  @end
@2:
 cmp  dl,'$'       {'$' - konec textu, zacatek loopovani}
 jne  @3
 mov  si,offset textdata
 mov  TDelay,32
 jmp  @end
@3:
 cmp  dl,'\'       {'\' - znamena, aby vypis malou chvili pockal}
 jne  @4
 mov  TDelay,64
 jmp  @end
@4:
 cmp  dl,''       {'' - znamena, aby vypis dlouhou chvili pockal}
 jne  @5
 mov  TDelay,200h
 jmp  @end
@5:
 mov  ah,2         {normalni znak, ktery bude zobrazen}
 int  21h
 mov  TDelay,6
 cmp  dl,' '
 jne  @end
 add  TDelay,6
@end:
 mov  TOfs,si
end;  {texttask}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
begin
 asm
  mov  ax,13h
  int  10h
  call InitR16b
 end;
 pal(7,0,32,63);
 for i:=0 to _stars-1 do
  with star[i] do
  begin
   r:=16+r16b mod 84;
   fi:=r16b and $FF;
   fi2:=56+r16b and 15;
  end;
 for j:=0 to 63 do
  for i:=0 to 7 do
   xorquad(295+i shl 1+i,3+j shl 1+j+byte(j>31),3,3,172*byte(napis[j mod 40+byte(j>=40) shl 3] and ($80 shr i)<>0));
 xorquad(295,98,25,97,172);
 repeat
  starenable:=1;
  for i:=0 to _stars-1 do
   with star[i] do showstar(star[i]);
  moment;
  starenable:=0;
  inc(tim);
  for i:=0 to _stars-1 do
   with star[i] do
   begin
    showstar(star[i]);
    case tim of
    $0000..$00FF:
     begin
      if i=tim then
       begin
        r:=32+r16b mod 96;
        fi2:=64;
       end;
      dec(fi);
     end;
    $0100..$01FF:
     begin
      if i=tim-$0100 then
       begin
        fi2:=fi2-40+r16b mod 80;
        r:=96;
       end;
      dec(fi);
      dec(fi2);
     end;
    $0200..$02FF:
     begin
      if i=tim-$0200 then
       begin
        r:=i shr 1; if r=0 then inc(r);
        fi:=i shr 1+r16b and 1;
        fi2:=i shr 4+r16b mod r;
       end;
      dec(fi);
      dec(fi2);
     end;
    $0300..$03FF:
     begin
      if i=tim-$0300 then
       begin
        fi:=i shr 1+r16b mod r;
        fi2:=i shr 4+r16b and 1;
       end;
      dec(fi);
      dec(fi2);
     end;
    $0400..$04FF:
     begin
      if i=tim-$0400 then
       fi2:=i shr 4+fi shr (3-(tim-$400) shr 6)+r16b and 1;
      dec(fi);
      dec(fi2);
     end;
    $0500..$05FF:
     begin
      if i=tim-$0500 then
       fi2:=i shr 4+fi shl ((tim-$500) shr 6)+r16b and 1;
      dec(fi);
      dec(fi2);
     end;
    $0600..$07FF:
     begin
      if (i<$0700) and (i=tim-$0600) then
       begin
        fi2:=i shr 2+r16b mod r;
        fi:=i shr 2+fi2+r16b and 1;
       end;
      if i<$0700 then
       begin
        dec(fi);
        r:=(r+byte(tim and 3=0)) and 127;
        if r=0 then inc(r);
       end;
      dec(fi2);
     end;
    $0800..$08FF:
     begin
      dec(fi2);
      r:=(r+1) and 127;
      if r=0 then inc(r);
     end;
    $0900..$09FF:
     begin
      if i=tim-$0900 then
       begin
        fi:=i shr 2+fi2+r16b and 1;
        fi2:=i shr 2+r16b mod r;
       end;
      dec(fi2,byte(tim and 7=0));
      dec(fi);
     end;
    $0A00..$0AFF:
     begin
      dec(fi2);
      r:=(r+byte(tim and 1=0)) and 127;
     end;
    $0B00..$0BFF:
     begin
      if i=tim-$0B00 then
       begin
        r:=i shr 1;
        fi:=i shr 1;
        fi2:=64;
       end;
      dec(fi);
     end;
    $0C00..$0CFF:
     begin
      if i=tim-$0C00 then
       begin
        r:=96;
        fi:=r16b and $FF;
        fi2:=r16b and $FF;
       end;
      dec(fi);
      dec(fi2);
     end;
    $0D00..$0DFF:
     begin
      if i=tim-$0D00 then r:=r16b and $FF;
      r:=(r+1) mod 200;
     end;
    $0E00..$0EFF:
     begin
      if i=tim-$0E00 then r:=r16b and $FF;
      r:=(r+1) mod 200;
      inc(fi);
      inc(fi2);
     end;
    else
     begin
      inc(fi);
      dec(fi2);
     end;
    end; {/case}
    tim:=tim and $0FFF;
   end; {/with}
  texttask;
 until port[$60]=1;
 for j:=0 to 63 do
  begin
   for i:=0 to 15 do
    pal(i+16,maxI(0,2+i shl 2-j),maxI(0,2+i shl 2-j),maxI(0,2+i shl 2-j));
   pal(7,0,maxI(0,32-j),63-j);
   moment;
  end;
 asm
  xor  ah,ah
  int  16h
  mov  ax,3
  int  10h
  jmp  @end
 @bye:
  db   'STAR/',10,8,8,'/OUSH',13,10,'STAR IT!, OUSH IT!',13,10,36
 @end:
  push cs
  pop  ds
  mov  dx,offset @bye
  mov  ah,9
  int  21h
 end;
end.