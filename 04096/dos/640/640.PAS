{$G+}
{$DEFINE soundblaster}
{$DEFINE sejf}
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
 koule:array[0..181] of byte=( {14x13}
 $00,$00,$00,$13,$13,$13,$14,$14,$14,$14,$00,$00,$00,$00,$00,$00,
 $13,$13,$14,$15,$16,$18,$19,$1A,$18,$15,$00,$00,$00,$13,$13,$14,
 $15,$16,$18,$1A,$1B,$1F,$1D,$19,$15,$00,$13,$13,$14,$14,$15,$17,
 $18,$1A,$1B,$1D,$1C,$1A,$17,$13,$13,$13,$14,$14,$16,$17,$18,$1A,
 $1A,$1B,$1A,$19,$17,$14,$13,$13,$14,$14,$16,$17,$18,$19,$19,$19,
 $19,$18,$16,$14,$13,$13,$14,$14,$15,$16,$17,$18,$18,$18,$18,$17,
 $16,$14,$13,$13,$14,$14,$15,$16,$16,$17,$17,$17,$17,$16,$15,$13,
 $13,$13,$13,$14,$14,$15,$15,$16,$16,$16,$16,$15,$14,$13,$13,$13,
 $13,$13,$14,$14,$14,$14,$15,$14,$14,$14,$13,$00,$00,$13,$13,$13,
 $13,$14,$14,$14,$14,$14,$13,$13,$13,$00,$00,$00,$13,$13,$13,$13,
 $13,$13,$13,$13,$13,$13,$00,$00,$00,$00,$00,$00,$13,$13,$13,$13,
 $13,$13,$00,$00,$00,$00);
 n1:string[37]='"640 kV should be enough for..‚ gh!"$';
 n2:string[11]='Bill Gates$';
 _amp=10;
var
 i,direct:byte;
{$IFDEF brejk} ctrlbreak:pointer; {$ENDIF}
 scr:array[0..159,0..319] of byte;
 tim:word;
 smp:array[0..1999] of byte;
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
procedure myExitProc; far; assembler;
asm   {myExitProc}
 {$IFDEF brejk}
 lds  dx,ctrlbreak
 mov  ax,2523h
 int  21h
 {$ENDIF}
 mov  ah,4Ch
 int  21h
end;  {myExitProc}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
FUNCTION  MinW(x,y:word):word;inline($58/$5b/$3b/$c3/$72/$01/$93);{pop ax;pop bx;cmp ax,bx;jb +1;xchg ax,bx}
FUNCTION  Bounded(n,min,max:longint):longint; assembler;
asm {Bounded}
 db   66h;mov ax,word ptr n
 db   66h;mov bx,word ptr min
 db   66h;cmp ax,bx; jle @bx
 db   66h;mov bx,word ptr max
 db   66h;cmp bx,ax; jle @bx
 mov  dx,word ptr n+2
 jmp  @end
@bx:
 mov  ax,bx
 db   66h;shr bx,16
 mov  dx,bx
@end:
end;  {Bounded}
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
PROCEDURE decscreen; assembler;
asm   {decscreen}
 mov  si,offset scr
 mov  cx,320*160
@1:
 cmp  byte ptr ds:[si],0C0h
 jb   @2
 dec  byte ptr ds:[si]
 dec  byte ptr ds:[si]
@2:
 inc  si
 dec  cx
 jnz  @1
end;  {decscreen}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE FillChar(var d; cnt:word; b:byte);assembler;
{Vyplni promennou zadanym bytem. Pouziva zarovnavani a StoSD}
asm   {FillChar}
 push es
 cmp  cnt,0
 je   @end
 cld
 les  di,d
 mov  cx,cnt
 mov  al,b
 mov  ah,al
 push ax
 push ax
 db   66h;pop  ax
 test cx,1
 jz   @1
 stosb
@1:
 test cx,2
 jz   @2
 stosw
@2:
 shr  cx,1
 shr  cx,1
 db   66h;rep  stosw
@end:
 pop  es
end;  {FillChar}
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
 mov  di,40*320
 cli
 mov  si,offset scr
 mov  cx,320*160/4
 db   66h;rep  movsw
 mov  ds,dx
 sti
end;  {flip}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
{$IFDEF soundblaster}
var
 sbOn:boolean;
 dspReset:word;
 dspReadData:word;
 dspWriteData:word;
 dspWriteStatus:word;
 dspDataAvailable:word;
FUNCTION sbResetDSP(base:word):boolean; assembler;
asm   {sbResetDSP}
 mov  ax,base
 mov  dspReset,ax
 mov  dspReadData,ax
 mov  dspWriteData,ax
 mov  dspWriteStatus,ax
 mov  dspDataAvailable,ax
 add  dspReset,6
 add  dspReadData,0Ah
 add  dspWriteData,0Ch
 add  dspWriteStatus,0Ch
 add  dspDataAvailable,0Eh
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
PROCEDURE sbSpeakersOn; assembler;
asm   {sbSpeakersOn}
 mov  dx,dspWriteStatus
@1:
 in   al,dx
 test al,80h
 jnz  @1
 mov  dx,dspWriteData
 mov  al,0D1h
 out  dx,al
end;  {sbSpeakersOn}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
PROCEDURE sbPlayBack(sound:pointer; Size:word; frequency:word);
var
 TimeConstant:word;
 Page:word;
 Ofset:word;
begin {sbPlayBack}
 if (Size<1) or (sound=nil) or (frequency and $F000=0) then exit else dec(Size);
 sbSpeakersOn;
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
procedure discharge(x1,y1,x2,y2:byte);
var y3:byte;
begin {discharge}
 if x2-x1<1+random(2) then exit;
 memW[DSeg:ofs(scr)+y1 shl 8+y1 shl 6+x1+$20]:=direct shl 8+direct;
 memW[DSeg:ofs(scr)+y2 shl 8+y2 shl 6+x2+$20]:=direct shl 8+direct;
 y3:=(y1+y2) shr 1+random((x2-x1) shr 2)-random((x2-x1) shr 2);
 discharge(x1,y1,(x1+x2) shr 1,y3);
 discharge((x1+x2) shr 1,y3,x2,y2);
end;  {discharge}
{ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß}
begin
 ExitProc:=@myExitProc;
 asm
  {$IFDEF brejk}
  mov  ax,3523h
  int  21h
  mov  word ptr ctrlbreak+2,es
  mov  word ptr ctrlbreak,bx
  push ds
  mov  ax,2523h
  push cs
  pop  ds
  mov  dx,offset myExitProc
  int  21h
  pop  ds
  {$ENDIF}
  mov  ax,13h
  int  10h
 end;
 for i:=0 to 63 do pal($C0+i,i,MinW(i+i shr 1,63),MinW(i shl 2,63));
 for i:=$BE to $BF do pal(i,0,0,0);
 for i:=0 to 12 do
  begin
   move(koule[i*14],scr[73+i,17],14);
   move(koule[i*14],scr[73+i,289],14);
  end;
 for tim:=85 to 159 do
  for i:=0 to 7 do
   begin
    scr[tim,20+i]:=18+i-4*byte(i=7);
    scr[tim,292+i]:=18+i-4*byte(i=7);
   end;
 for tim:=0 to sizeof(smp)-1 do smp[tim]:=$80+random(_amp)-random(_amp);
 tim:=192;
 {$IFDEF soundblaster}
 sbOn:=sbResetDSP($220) or sbResetDSP($240);
 {$ENDIF}
 repeat
  discharge(0,80,255,80);
  decscreen;
  flip; inc(tim);
  direct:=sinB[byte(tim)] div 4+$E0;
  {$IFDEF soundblaster}
  if sbOn and (random(byte(direct-$E0))<24) and (tim and 3=0) then
   sbPlayBack(@smp,sizeof(smp),34560);
  {$ENDIF}
  if tim>=1024 then
   asm
    mov  dx,0002h
    mov  bh,0
    mov  ah,2
    int  10h
    mov  dx,offset n1+1
    mov  ah,9
    int  21h
    mov  dx,011Ah
    mov  bh,0
    mov  ah,2
    int  10h
    mov  dx,offset n2+1
    mov  ah,9
    int  21h
   end;
 until port[$60]=1;
 for direct:=0 to 63 do
  begin
   for i:=0 to 63 do pal($C0+i,bounded(i-direct,0,63),bounded(i+i shr 1-direct,0,63),bounded(i shl 2-direct,0,63));
   for i:=0 to 15 do pal($10+i,bounded(i shl 2-4-direct,0,63),bounded(i shl 2-4-direct,0,63),bounded(i shl 2-4-direct,0,63));
   pal(7,42-direct*2 div 3,42-direct*2 div 3,42-direct*2 div 3);
   flip;
  end;
end.

"640 kV should be enough for.."
                     Bill Gates