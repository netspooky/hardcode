{16K Intro by Cooler/Psycho (cooler@tut.by, 2:450/164.5)}
{Specially for Millennium'1901 Party (Minsk, Belarus)}
{$A+,B-,D+,E-,F+,G+,I+,L+,N+,O-,P+,Q-,R-,S+,T-,V+,X+,Y+}
{$M 16384,152288,260000}
{DEFINE DEBUG}
program Intro;
uses gp15;
type
 buffer=array[0..199,0..319] of byte;
 TTextBuf=array[0..127,0..127] of byte;
 T3DPoint=record
  x,y,z:shortint;
  color:byte;
 end;
 TFace=record
  v1,v2,v3:integer;
  color:byte;
  z:shortint;
 end;
const
 BaseVertices:array[0..3] of T3DPoint=(
  (x:80;y:80;z:80;color:200),
  (x:-80;y:-80;z:80;color:200),
  (x:-80;y:80;z:-80;color:200),
  (x:80;y:-80;z:-80;color:200));
 BaseFigure:array[0..3] of TFace=(
  (v1:0;v2:3;v3:1;color:200;z:0),
  (v1:0;v2:1;v3:2;color:180;z:0),
  (v1:0;v2:2;v3:3;color:160;z:0),
  (v1:1;v2:3;v3:2;color:140;z:0));
 LogoVertices:array[0..37] of t3dPoint=(
  (x:-68;y:20;z:0;color:255),
  (x:-72;y:-4;z:0;color:255),
  (x:-60;y:-20;z:0;color:255),
  (x:-52;y:-16;z:0;color:255),
  (x:-52;y:0;z:0;color:255),
  (x:-48;y:-4;z:0;color:255),
  (x:-20;y:-24;z:0;color:255),

  (x:-56;y:20;z:0;color:255),
  (x:-56;y:8;z:0;color:255),
  (x:-32;y:-16;z:0;color:255),
  (x:-20;y:-20;z:0;color:255),
  (x:-20;y:0;z:0;color:255),
  (x:-20;y:8;z:0;color:255),

  (x:-20;y:20;z:0;color:255),
  (x:-16;y:20;z:0;color:255),
  (x:-16;y:-16;z:0;color:255),
  (x:-8;y:-20;z:0;color:255),
  (x:4;y:20;z:0;color:255),
  (x:12;y:16;z:0;color:255),
  (x:12;y:-20;z:0;color:255),
  (x:16;y:0;z:0;color:255),
  (x:24;y:-20;z:0;color:255),
  (x:24;y:20;z:0;color:255),

  (x:23;y:-12;z:0;color:255),
  (x:23;y:12;z:0;color:255),
  (x:28;y:-18;z:0;color:255),
  (x:28;y:18;z:0;color:255),
  (x:32;y:-20;z:0;color:255),
  (x:32;y:20;z:0;color:255),
  (x:40;y:-16;z:0;color:255),
  (x:40;y:16;z:0;color:255),

  (x:48;y:16;z:0;color:255),
  (x:56;y:20;z:0;color:255),
  (x:56;y:8;z:0;color:255),
  (x:44;y:-20;z:0;color:255),
  (x:52;y:-20;z:0;color:255),
  (x:68;y:-20;z:0;color:255),
  (x:20;y:28;z:0;color:255));

 LogoData:array[0..17] of TFace=(
  (v1:1;v2:5;v3:4;color:0;z:0),
  (v1:0;v2:2;v3:3;color:0;z:0),
  (v1:3;v2:2;v3:6;color:0;z:0),
  (v1:7;v2:9;v3:10;color:0;z:0),
  (v1:9;v2:10;v3:13;color:0;z:0),
  (v1:8;v2:11;v3:12;color:0;z:0),

  (v1:14;v2:15;v3:16;color:0;z:0),
  (v1:17;v2:15;v3:16;color:0;z:0),
  (v1:17;v2:16;v3:18;color:0;z:0),
  (v1:17;v2:19;v3:18;color:0;z:0),
  (v1:20;v2:21;v3:22;color:0;z:0),
  (v1:21;v2:27;v3:23;color:0;z:0),
  (v1:22;v2:24;v3:28;color:0;z:0),
  (v1:25;v2:27;v3:29;color:0;z:0),
  (v1:26;v2:30;v3:28;color:0;z:0),
  (v1:37;v2:31;v3:32;color:0;z:0),
  (v1:33;v2:34;v3:35;color:0;z:0),
  (v1:31;v2:36;v3:32;color:0;z:0));

 ClipX1:integer=0;
 ClipX2:integer=319;
 ClipY1:integer=0;
 ClipY2:integer=199;
 FirstPartSize:word=765;
 DeltaZ:integer=4096;

var
 Palette:array[0..255,0..2] of byte;
 WiredFont:array[0..127,0..31] of longint;
 Texture:^TTextBuf;
 br1,br2,sat1,sat2:byte;
 dbuf,oldbuf:^buffer;
 vseg:word;
 i,j:integer;
 frame:integer;
 sintab:array[0..255] of shortint;
 vertices,scene:array[0..1023] of T3DPoint;
 matrix:array[0..2,0..2] of integer;
 origin:word;
 color:byte;
 TempBuf:array[0..2] of longint;
 faces:array[0..1023] of TFace;
 BeatFunc,TimeFunc,skip:integer;
 sqrtab:array[0..4095] of byte;
 blob:^TTextBuf;
 EscFlag:boolean;

procedure ModSamples; external; {$L music\samples.obj }
procedure ModPatterns; external; {$L music\patterns.obj }
procedure InitSinTab; external; {$L sintable.obj }

function Time:integer;
 begin
  TimeFunc:=GP.vars^[PlayingPattern]*64+GP.vars^[PatternRow]-64;
  Time:=TimeFunc;
 end;
procedure DoBeat(value,start,step:integer);
 begin
  if skip>0 then begin
   dec(skip);
   exit;
  end;
  if GP.vars^[PatternRow] mod step=start then begin
   BeatFunc:=value; skip:=2;
  end;
 end;
function ExSin(x:integer):longint;
 begin
  ExSin:=sintab[(x div 4) and 255]*(4-x and 3)+
         sintab[(x div 4+1) and 255]*(x and 3);
 end;
procedure GenMatrix(a,b,c:integer);
type
 TMatrix=array[0..2,0..2] of longint;
var
 asin,acos:integer;
 m1,m2:TMatrix;
procedure Mult(var m1,m2:TMatrix);
 var
  i,j,k:integer;
  m3:TMatrix;
 begin
  for i:=0 to 2 do
   for j:=0 to 2 do begin
    m3[i,j]:=0;
    for k:=0 to 2 do m3[i,j]:=m3[i,j]+m1[i,k]*m2[k,j];
   end;
  move(m3,m1,sizeof(TMatrix));
  fillchar(m2,sizeof(TMatrix),0);
 end;
begin
 fillchar(m2,sizeof(TMatrix)*2,0);
 acos:=sintab[(a+64) and 255];
 asin:=sintab[a and 255];
 M1[0,0]:=acos;
 M1[0,1]:=-asin;
 M1[1,0]:=asin;
 M1[1,1]:=acos;
 M1[2,2]:=64;
 acos:=sintab[(b+64) and 255];
 asin:=sintab[b and 255];
 M2[0,0]:=acos;
 M2[0,2]:=-asin;
 M2[2,0]:=asin;
 M2[2,2]:=acos;
 M2[1,1]:=64;
 Mult(M1,M2);
 acos:=sintab[(c+64) and 255];
 asin:=sintab[c and 255];
 M2[1,1]:=acos;
 M2[1,2]:=-asin;
 M2[2,1]:=asin;
 M2[2,2]:=acos;
 M2[0,0]:=64;
 Mult(M1,M2);
 for i:=0 to 2 do
  for j:=0 to 2 do
   matrix[i,j]:=m1[i,j] div 128;
end;

procedure Project(cnt:integer);
 var
  i,j,k:integer;
  o:word;
 begin
  for i:=0 to cnt-1 do begin
   for j:=0 to 2 do begin
    TempBuf[j]:=0;
    o:=ofs(vertices[i]);
    for k:=0 to 2 do begin
     TempBuf[j]:=TempBuf[j]+shortint(mem[dseg:o])*longint(matrix[j,k]);
     inc(o);
    end;
   end;
   scene[i].z:=TempBuf[2] div 2048;
   TempBuf[2]:=TempBuf[2] div 64+DeltaZ;
   scene[i].x:=8*TempBuf[0] div (7*TempBuf[2]);
   scene[i].y:=TempBuf[1] div (TempBuf[2]);
   scene[i].color:=vertices[i].color;
  end;
 end;
procedure Triangle(p1,p2,p3:integer);
 var
  v1,v2,v3,y,y1:integer;
  x1,x2,dx1,dx2:integer;
  c1,c2,dc1,dc2:integer;
  xl,xr,cl,cr,dc:integer;
  vc1,vc2,vc3:integer;
  l,i:integer;
  o:word;
 begin
  if scene[p1].y<scene[p2].y then v1:=p1 else v1:=p2;
  if scene[p3].y<scene[v1].y then v1:=p3;
  if scene[p1].y>scene[p2].y then v2:=p1 else v2:=p2;
  if scene[p3].y>scene[v2].y then v2:=p3;
  if (v1<>p1) and (v2<>p1) then v3:=p1;
  if (v1<>p2) and (v2<>p2) then v3:=p2;
  if (v1<>p3) and (v2<>p3) then v3:=p3;

  y1:=scene[v1].y;
  vc1:=scene[v1].color;
  vc2:=scene[v2].color;
  vc3:=scene[v3].color;
  if scene[v1].y=scene[v3].y then begin
   x1:=scene[v1].x*256;
   x2:=scene[v3].x*256;
   l:=scene[v2].y-y1;
   if l=0 then exit;
   dx1:=(scene[v2].x-scene[v1].x)*256 div l;
   dx2:=(scene[v2].x-scene[v3].x)*256 div l;
   c1:=vc1*256;
   c2:=vc3*256;
   dc1:=(vc2-vc1)*256 div l;
   dc2:=(vc2-vc3)*256 div l;
  end else begin
   if y1>=CLipY1 then mem[vseg:origin+320*y1+scene[v1].x]:=vc1;
   x1:=scene[v1].x*256;
   x2:=x1;
   dx1:=(scene[v2].x-scene[v1].x)*256 div (scene[v2].y-y1);
   dx2:=(scene[v3].x-scene[v1].x)*256 div (scene[v3].y-y1);
   c1:=vc1*256;
   c2:=c1;
   dc1:=(vc2-vc1)*256 div (scene[v2].y-y1);
   dc2:=(vc3-vc1)*256 div (scene[v3].y-y1);
   inc(y1);
   x1:=x1+dx1; x2:=x2+dx2;
   c1:=c1+dc1; c2:=c2+dc2;
  end;
  for y:=y1 to scene[v2].y-1 do begin
   if (y>=clipy1) and (y<=Clipy2) then begin
    {Нарисовать спан}
    if x1<x2 then begin
     asm
      mov ax,x1
      add ax,255
      sar ax,8
      mov xl,ax
      mov ax,x2
      add ax,128
      sar ax,8
      mov xr,ax
     end;
     cl:=c1;
     cr:=c2;
    end else begin
     asm
      mov ax,x2
      add ax,255
      sar ax,8
      mov xl,ax
      mov ax,x1
      add ax,128
      sar ax,8
      mov xr,ax
     end;
     cl:=c2;
     cr:=c1;
    end;
    if xr>xl then dc:=(cr-cl) div (xr-xl);
    if xl<ClipX1 then begin cl:=cl+dc*(ClipX1-xl); xl:=ClipX1; end;
    if xr>ClipX2 then begin
      xr:=ClipX2; end;
    o:=origin+y*320+xl;
    for i:=xl to xr do begin
     mem[vseg:o]:=cl shr 8;
     cl:=cl+dc;
     inc(o);
    end;
   end;
   if y=scene[v3].y then begin
    dx2:=(scene[v2].x-scene[v3].x)*256 div (scene[v2].y-scene[v3].y);
    dc2:=(vc2-vc3)*256 div (scene[v2].y-scene[v3].y);
   end;
   x1:=x1+dx1; x2:=x2+dx2;
   c1:=c1+dc1; c2:=c2+dc2;
  end;
 end;

procedure DrawScene(vert,fac,x,y:integer);
type
 TOrder=array[0..1023] of integer;
var
 i,j,n1,n2,c,cnt,m:integer;
 ord1,ord2:^TOrder;
 p:pointer;
 v1x,v1y,v1z,v2x,v2y,v2z,vx,vy,vz:integer;
begin
 origin:=x+320*y;
 ClipX1:=-x+2; CLipX2:=319-x-2;
 ClipY1:=-y+2; ClipY2:=199-y-2;
 new(ord1); new(ord2);
 Project(vert);
 cnt:=0;
 { Вычислить среднее Z }
 for i:=0 to Fac-1 do with faces[i] do begin
  faces[i].z:=(integer(scene[v1].z)+
               integer(scene[v2].z)+
               integer(scene[v3].z)) div 3;
  v1x:=scene[v1].x-scene[v2].x;
  v1y:=scene[v1].y-scene[v2].y;
  v2x:=scene[v1].x-scene[v3].x;
  v2y:=scene[v1].y-scene[v3].y;
  if (v1x*v2y-v2x*v1y>0) then begin
   ord1^[cnt]:=i;
   inc(cnt);
  end;
 end;
 { Сортировка (за линейное время) }
 m:=1;
 for i:=0 to 7 do begin
  c:=0;
  for j:=0 to cnt-1 do
   if (faces[ord1^[j]].z xor $80) and m=0 then inc(c);
  n1:=0; n2:=c;
  for j:=0 to cnt-1 do
   if (faces[ord1^[j]].z xor $80) and m=0 then begin
    ord2^[n1]:=ord1^[j];
    inc(n1);
   end else begin
    ord2^[n2]:=ord1^[j];
    inc(n2);
   end;
  m:=m*2;
  p:=ord1; ord1:=ord2; ord2:=p;
 end;
 { Нарисовать от дальних к ближним }
 for i:=cnt-1 downto 0 do with faces[ord1^[i]] do begin
  if color<>0 then begin
   scene[v1].color:=color;
   scene[v2].color:=color;
   scene[v3].color:=color;
  end;
  Triangle(v1,v2,v3);
 end;
 dispose(ord1); dispose(ord2);
end;

procedure SetPalette; assembler;
 asm
    xor ax,ax
    mov dx,3c8h
    out dx,al
    inc dx
    mov cx,FirstPartSize
    mov si,offset palette
@01:mov al,[si]
    mov ah,127
    sub ah,al
    mov al,sat1
    mul ah
    shl ax,2
    lodsb
    add al,ah
    mul br1
    mov al,ah
    cmp al,3fh
    jbe @03
    mov al,3fh
@03:
    out dx,al
    loop @01
    mov cx,768
    sub cx,FirstPartSize
@02:mov al,[si]
    mov ah,127
    sub ah,al
    mov al,sat1
    mul ah
    shl ax,2
    lodsb
    add al,ah
    mul br2
    mov al,ah
    cmp al,3fh
    jbe @04
    mov al,3fh
@04:
    out dx,al
    loop @02
 end;

procedure VSync; assembler;
 asm
     mov dx,3dah
@01: in al,dx
     test al,8
     jz @01
 end;

procedure SetRgb(n,r,g,b:byte); assembler;
asm
 mov dx,3c8h
 mov al,n
 out dx,al
 inc dx
 mov al,r
 out dx,al
 mov al,g
 out dx,al
 mov al,b
 out dx,al
end;

procedure PrintChar(c:char;o:word;color,color2:byte); assembler;
asm
   mov si,offset WiredFont
   mov al,c
   mov ah,128
   mul ah
   add si,ax
   mov di,o
   mov es,vseg
   mov dx,32
   mov bl,color
   mov bh,color2
@01:
   push dx
   lodsw
   mov dx,ax
   lodsw
   mov cx,16
@02:
   rcr ax,1
   jnc @03
   mov byte ptr es:[di],bh
@03:
   rcr dx,1
   jnc @04
   mov es:[di],bl
@04:

   inc di
   loop @02
   add di,320-16
   pop dx
   dec dx
   jnz @01
end;


function IsEsc:boolean; assembler;
 asm
  mov al,escflag
  or al,al
  jnz @01
  xor ax,ax
  in al,60h
  cmp al,1
  je @01
  xor ax,ax
@01:mov escflag,al
 end;

procedure ClearBuf; assembler;
asm
 push vseg
 pop es
 mov cx,32000
 xor ax,ax
 xor di,di
 rep stosw
end;
procedure FlipToScreen;
 begin
 asm
  mov ax,7
  mul BeatFunc
  shr ax,3
  mov BeatFunc,ax

  push ds
  push 0a000h
  pop es
  mov ax,vseg
  mov ds,ax
  mov cx,16000
  xor si,si
  mov di,si
  db 66h; rep movsw
  pop ds
  {$IFDEF DEBUG}
  xor di,di
@01:
  mov es:[di],cl
  inc di
  cmp cl,255
  jne @02
  add di,64
@02:
  inc cx
  cmp ch,16
  jb @01
  {$ENDIF}
 end;
 {$IFDEF DEBUG}
  vseg:=segA000;
  PrintChar(chr(48+time mod 10),51240,0,254);
  PrintChar(chr(48+(time div 10) mod 10),51220,0,254);
  PrintChar(chr(48+(time div 100) mod 10),51200,0,254);
  vseg:=seg(dbuf^);
 {$ENDIF}
 end;

procedure Blur1; assembler;
 asm
   push ds
   mov ax,vseg
   mov ds,ax
   mov es,ax
   mov di,320
   mov cx,63360
   xor bx,bx
@01:
   xor ax,ax
   mov bl,[di-1]
   add ax,bx
   mov bl,[di+1]
   add ax,bx
   mov bl,[di-320]
   add ax,bx
   mov bl,[di+320]
   add ax,bx
   shr ax,2
   stosb
   dec cx
   jnz @01
   pop ds
 end;
procedure Blur16K(s,len:word); assembler;
 asm
     push ds
     mov ds,s
     xor si,si
     mov di,len
     dec di
     mov bx,len
     shl bx,1
     dec bx
     mov cx,16384
     xor dx,dx
@inner:
     xor ax,ax
     mov dl,[si]
     add si,di
     add ax,dx
     and si,3fffh
     mov dl,[si]
     add si,2
     add ax,dx
     and si,3fffh
     mov dl,[si]
     add si,di
     add ax,dx
     and si,3fffh
     mov dl,[si]
     sub si,bx
     add ax,dx
     and si,3fffh
     shr ax,2
     mov [si],al
     dec cx
     jnz @inner
     pop ds
 end;
procedure FireBlur; assembler;
asm
   push ds
   mov ax,vseg
   mov ds,ax
   mov es,ax
   xor di,di
   mov cx,63360
   xor bx,bx
@01:
   xor ax,ax
   mov bl,[di]
   add ax,bx
   mov bl,[di+319]
   add ax,bx
   mov bl,[di+320]
   add ax,bx
   mov bl,[di+321]
   add ax,bx
   shr ax,2
   or al,al
   jz @02
   dec al
@02:
   stosb
   dec cx
   jnz @01
   pop ds
end;

procedure PrintString(st:string;x,y:integer;color,color2:byte;fl:boolean);
var
 i:integer;
 o,addo:word;
begin
 o:=y*320+x;
 for i:=1 to length(st) do begin
  if fl then addo:=random(3)+320*random(3) else addo:=0;
  PrintChar(st[i],o+addo,color,color2);
  inc(o,18);
 end;
end;
function Sat(b,min,max:integer):integer;
 begin
  Sat:=b;
  if b>max then Sat:=max;
  if b<min then Sat:=min;
 end;
function Pike(x,arg,a,b,c:integer):integer;
begin
 if x<arg then Pike:=a+(b-a)*x div arg
  else Pike:=b+(c-b)*(x-arg) div (256-arg);
end;

procedure Initialize;
 const
  dirtab:array[0..7,0..1] of shortint=
    ((0,1),(1,1),(1,0),(1,-1),(0,-1),(-1,-1),(-1,0),(-1,1));
  Diver:word=128;
 var
  i,j,c:integer;
  s,o,w:word;
  b,x,y:byte;
  p:pointer;
 begin
  new(dbuf);
  new(oldbuf);
  new(Texture);
  new(blob);
  getmem(p,16384);
  SampleMemBuf:=seg(p^);
  vseg:=seg(dbuf^);
  j:=0;
  for i:=0 to 4095 do begin
   if sqr(j)<i then inc(j);
   sqrtab[i]:=j;
  end;
  for i:=0 to 127 do
   for j:=0 to 127 do
    blob^[i,j]:=Sat(32-sqrtab[Sat(sqr(64-i)+sqr(64-j),0,4095)],0,32);
  { Генерация шрифта }
  asm
   push bp
   mov ax,1130h
   mov bh,6
   int 10h
   mov ax,bp
   pop bp
   mov si,ax
   mov b,128
   mov di,offset WiredFont
@NextChar:
   xor dx,dx
   xor bx,bx
   mov ch,16
@NextLine:
   mov al,es:[si]
   inc si
   mov cl,8
@Expand:
   shr bx,2
   rcl al,1
   jnc @Skip
   or bx,0c000h
@Skip:
   dec cl
   jnz @Expand
   shl bx,1
   push ax
   mov ax,bx
   xor ax,dx
   mov [di],ax
   mov ax,bx
   and ax,dx
   mov [di+2],ax
   mov dx,bx
   shl dx,1
   mov ax,bx
   xor ax,dx
   mov [di+4],ax
   mov ax,bx
   and ax,dx
   mov [di+6],ax
   add di,8
   pop ax
   dec ch
   jnz @NextLine

   dec b
   jnz @NextChar
  end;
  {Заполним таблицу синусов }
  InitSinTab;
  RandSeed:=10001;
  { Генерация текстуры }
  fillchar(texture^,16384,0);
  for i:=1 to 25 do begin
   x:=random(256); y:=random(256);
   c:=random(8);
   for j:=1 to 2000 do begin
    inc(Texture^[x shr 1,y shr 1],4);
    x:=x+dirtab[c,0];
    y:=y+dirtab[c,1];
    if j and 1=0 then
     c:=(c-1+random(3)) and 7;
   end;
  end;
  randomize;
  asm
   mov ax,13h
   int 10h
  end;
 end;

procedure Part1;
 var
  i,j,x,y,lx,ly:integer;
  s,o:word;
 begin
  for i:=0 to 255 do begin
   palette[i,0]:=Pike(i,128,0,64,64);
   palette[i,1]:=Pike(i,128,0,127,64);
   palette[i,2]:=Pike(i,192,0,127,32);
  end;
  ClearBuf;
  s:=seg(OldBuf^); o:=0;
  for i:=0 to 99 do
   for j:=0 to 319 do begin
    lx:=(160-j);
    ly:=(100-i);
    x:=lx div 16+random(3)-1+ly div 32;
    y:=ly div 16+random(3)-1-lx div 32;
    memw[s:o]:=y*320+x;
    o:=o+2;
   end;
  palette[255,0]:=120;
  palette[255,1]:=120;
  palette[255,2]:=0;
{  br1:=120; br2:=120;} br1:=0;
  repeat
   DoBeat(30,7,16);
   DoBeat(30,9,16);
   if (time<10) and (br1<110) then inc(br1,10);
   if (time>60) and (br1>0) then dec(br1,2);
{   br1:=Sat(frame,0,110)+BeatFunc;}
   br2:=br1;
   sat1:=BeatFunc div 8;
   inc(br1,BeatFunc);
   SetPalette;
   dec(br1,BeatFunc);
   for i:=1 to 100 do begin
    o:=random(63679); s:=seg(dbuf^);
    mem[s:o]:=240;
    mem[s:o+1]:=240;
    mem[s:o+320]:=240;
    mem[s:o+321]:=240;
   end;
   asm
    push ds
    mov ax,word ptr OldBuf+2
    mov es,ax
    mov ax,word ptr dbuf+2
    mov ds,ax
    mov cx,32000
    xor si,si
    xor di,di
@01:xor ax,ax
    mov al,[si]
    shr al,1
    mov bx,es:[di]
    mov ah,[si+bx]
    shr ah,1
    add al,ah
    mov [si],al
    xor ax,ax
    not si
    not bx
    mov al,[si+64000]
    shr al,1
    mov ah,[64000+si+bx]
    shr ah,1
    add al,ah
    mov [64000+si],al
    not si
    not bx
    inc si
    add di,2
    dec cx
    jnz @01
    pop ds
   end;
   Blur1;

   VSync;
   FlipToScreen;
   vseg:=segA000;
   case (time-7) div 16 of
    0:PrintString('THE PSYCHO TEAM',24,84,255,180,false);
    1:PrintString('presents',84,84,255,180,false);
    2:begin
       PrintString('specially for',40,32,250,180,false);
       PrintString('MILLENNIUM',32,84,255,180,false);
       PrintString('DEMOPARTY',120,120,255,180,false);
      end;
    3:PrintString('16K INTRO',80,84,255,180,false);
   end;
   vseg:=seg(dbuf^);
{   inc(frame);}
  until IsEsc or (TimeFunc>64);
 end;

procedure Part2(mode:integer);
 type
  TParticle=record
   cx,cy:integer;
   dx,dy:integer;
   life:integer;
  end;
 var
  i,j,x,y:integer;
  particles:array[0..1023] of TParticle;
  count:integer;
  timer:longint;
 begin
  for i:=0 to 255 do begin
   palette[i,0]:=Sat(i,0,127);
   palette[i,1]:=Sat(i-48,0,120);
   palette[i,2]:=Pike(i,32,0,32,0)+Pike(i,128,0,0,200);
  end;
  move(BaseVertices,vertices,sizeof(BaseVertices));
  move(BaseFigure,faces,sizeof(BaseFigure));
  ClearBuf;
  FlipToScreen;
  br1:=0; br2:=0; sat1:=0;
  count:=0; frame:=-2000; timer:=time;
  repeat
   if time=992 then frame:=0;
   if (time-timer<5) and (br1<120) then inc(br1,4);
   if (time>1078) and (sat1<60) then
     inc(sat1,1);
   x:=160+sintab[(frame div 3) and $FF];
   y:=80-sintab[(frame+60) and $FF] div 2;
   if frame<0 then
   for i:=1 to 3 do begin
    with particles[count] do begin
     cx:=x shl 5+random(100); cy:=y shl 5+random(100);
     dx:=-16383+random(32767);
     dy:=-16383+random(32767);
     life:=10+random(400);
    end;
    inc(count);
   end else begin
    DeltaZ:=$3a00;
    GenMatrix(frame,frame*2,frame*4);
    DrawScene(4,4,320-frame div 2+sintab[(frame+40) and 255],100+sintab[frame and 255]);
   end;
   i:=0;
   repeat
    with particles[i] do begin
     dec(life);
     if life<=0 then begin
      particles[i]:=particles[count-1];
      dec(count);
     end else begin
      dbuf^[cy shr 5,cx shr 5]:=64+life div 2;
      cx:=cx+dx div 256; cy:=cy+dy div 256;
      dy:=dy+256;
      dx:=dx-dx div 64;
      dy:=dy-dy div 64;
      if (cx<100) or (cx>10200) then dx:=-dx;
      if (cy>6200) then dy:=-dy;
      inc(i);
     end;
    end;
   until (i>=count);
   SetPalette;
   FireBlur;
   vsync;
   FlipToScreen;
   inc(frame);
  until (isEsc) or (time>1087);
 end;

procedure Part10;
 var
  i,asin,acos:integer;
  u,v:word;
  timer:longint;
 begin
  for i:=0 to 255 do begin
   palette[i,0]:=(i div 2) and 127;
   palette[i,1]:=(i) and 127;
   palette[i,2]:=(i*2) and 127;
  end;
  br1:=0;  frame:=0; timer:=time; sat1:=0;
  repeat
   if (time-timer<20) and (br1<100) then inc(br1,5);
   if (time-timer>58) and (br1<100) then dec(br1,5);
   SetPalette;
   asin:=ExSin(frame);
   acos:=ExSin(frame+256);
   asm
    mov ax,vseg
    mov es,ax
    mov ch,100
    xor dx,dx
    xor bx,bx
    xor di,di
    mov si,319
@01:push dx
    push bx
    mov cl,160
@02:mov al,bh
    xor al,dh
    shr al,2
    mov es:[di],al
{    add al,40h}
    mov es:[si],al
    not di
    add al,40h
    not si
    mov es:[64000+di],al
{    add al,40h}
    mov es:[64000+si],al
    not di
    not si
    inc di
    dec si
    add bx,acos
    inc di
    dec si
    add dx,asin
    dec cl
    jnz @02
    pop bx
    pop dx
    add bx,asin
    sub dx,acos
    add di,320
    add si,960
    dec ch
    jnz @01
   end;
   PrintString('And now',96,70,255,254,false);
   PrintString('some greetz...',32,100,255,254,false);
   VSync;
   FlipToScreen;
   inc(frame);
  until (IsEsc) or ((time mod 64=30) and (frame>100));
 end;

procedure Part11;
 var
  i,j,asin,acos,k:integer;
  u,v:word;
  timer:longint;
 type
  sstr=string[12];
 const
  greets:array[0..11] of sstr=(
    'Accept Corp.',
    'ANTARES',
    'FENOMEN',
    'FREEART',
    'FishBone',
    'Infinite',
    'MonSteR',
    'SkyProject',
    'Perforation',
    'PHG',
    'PROXiUM',
    'T-Rex');
 begin
  for i:=0 to 255 do begin
   palette[i,0]:=Sat(i-128,0,127){Pike(i,4,0,80,0)};
   palette[i,1]:=Pike(i,160,20,120,120);
   palette[i,2]:=Pike(i,64,0,100,60);
  end;
  br1:=0; frame:=0; timer:=time;
  repeat
   DoBeat(24,0,8);
   if (time mod 64<5) and (br1<100) then inc(br1,5);
   if (time mod 64>60) and (br1>0) then dec(br1,5);
   br2:=br1; Sat1:=beatFunc;
   SetPalette;
   case time div 64 of
    12:begin
{        fillchar(dbuf^,64000,255);}
        asin:=ExSin(frame);
        acos:=ExSin(frame+256);
        asm
         mov ax,vseg
         mov es,ax
         xor di,di
         mov cx,32000
         mov ax,0ffffh
         rep stosw
         mov ch,200
         xor dx,dx
         xor bx,bx
         xor di,di
         mov si,319
@01:     push dx
         push bx
         mov i,320
@02:     mov al,bh
         xor al,dh
         and es:[di],al
         and es:[si],al
         not di
         not si
         and es:[64000+di],al
         and es:[64000+si],al
         not di
         not si
         inc di
         dec si
         add bx,acos
         add dx,asin
         dec i
         jnz @02
         pop bx
         pop dx
         add bx,asin
         sub dx,acos
         add si,640
         dec ch
         jnz @01
        end;
       end;
    11:begin
{        fillchar(dbuf^,64000,0);}
        asin:=ExSin(frame);
        acos:=ExSin(frame+256);
        asm
         mov ax,vseg
         mov es,ax
         xor di,di
         mov cx,32000
         xor ax,ax
         rep stosw
         mov ch,200
         xor dx,dx
         xor bx,bx
         xor di,di
         mov si,319
@01:     push dx
         push bx
         mov i,320
@02:     mov al,bh
         xor al,dh
         shr al,1
         xor es:[di],al
         xor es:[si],al
         not di
         not si
         xor es:[64000+di],al
         xor es:[64000+si],al
         not di
         not si
         inc di
         dec si
         add bx,acos
         add dx,asin
         dec i
         jnz @02
         pop bx
         pop dx
         add bx,asin
         sub dx,acos
         add si,640
         dec ch
         jnz @01
        end;
       end;
    13:begin
{        fillchar(dbuf^,64000,0);}
        asin:=ExSin(frame);
        acos:=ExSin(frame+256);
        asm
         mov ax,vseg
         mov es,ax
         xor di,di
         mov cx,32000
         xor ax,ax
         rep stosw
         mov ch,200
         xor dx,dx
         xor bx,bx
         xor di,di
         mov si,319
@01:     push dx
         push bx
         mov i,320
@02:     mov al,bh
         xor al,dh
         shr al,3
         add es:[di],al
         add es:[si],al
         not di
         not si
         add es:[64000+di],al
         add es:[64000+si],al
         not di
         not si
         inc di
         dec si
         add bx,acos
         add dx,asin
         dec i
         jnz @02
         pop bx
         pop dx
         add bx,asin
         sub dx,acos
         add si,640
         dec ch
         jnz @01
        end;
       end;
   end;
   for i:=0 to 3 do begin
    if ((time-i*8) mod 64) and 32=0 then begin
     k:=(time div 64-11)*4;
     j:=160-length(greets[i+k])*9{+sintab[(frame*4+i*16) and 255] div 3};
     PrintString(greets[i+k],j,i*40+24,96,255+i*32-(time mod 64)*4,true);
    end;
   end;
   VSync;
   FlipToScreen;
   inc(frame);
  until IsEsc or ((time>895) and (frame>100));
 end;

procedure PartTitle;
var
 i,j,dz:integer;
 b:byte;
begin
  for i:=0 to 255 do begin
   palette[i,0]:=Sat(i-160,0,127);
   palette[i,1]:=Sat(i,0,127);
   palette[i,2]:=Sat(i-48,0,127);
  end;
  move(LogoVertices,vertices,sizeof(LogoVertices));
  move(LogoData,Faces,sizeof(LogoData));
  {br1:=100; br2:=100;} frame:=0;
{  sat1:=60;}
  DeltaZ:=13500; dz:=155;
  repeat
   br1:=Sat(frame*2,0,120);
   sat1:=Sat((frame-140)*3,0,60);
   SetPalette;
   asm
    push ds
    mov ax,vseg
    mov es,ax
    mov ax,word ptr Texture+2
    mov ds,ax
    xor di,di
    xor dx,dx
@01:mov cx,320
@02:mov bh,dl
    mov bl,cl
    shl bl,1
    shr bx,1
    and bx,3fffh
    mov al,[bx]
    shl al,1
    mov es:[di],al
    inc di
    loop @02
    inc dx
    cmp dx,200
    jne @01
    pop ds
   end;
   GenMatrix(Sat(frame*2-20,0,250),0,-10);
   Dec(DeltaZ,dz);
   if dz>0 then dec(dz);
   Project(38);
   for i:=0 to 37 do
    vertices[i].color:=scene[i].y*3 div 2+160;
   DrawScene(38,18,160,100);
   VSync;
   FlipToScreen;
   inc(frame);
  until IsEsc or (frame>160);

   for i:=0 to 255 do begin
    palette[i,0]:=Sat(i-128,0,100);
    palette[i,1]:=Pike(i,64,0,100,0);
    palette[i,2]:=Sat(i-48,0,127);
   end;
  ClearBuf;
  DrawScene(38,18,160,100);
  for i:=1 to 4 do blur1;
  DrawScene(38,18,160,100);
  blur1; blur1;
  for i:=0 to 199 do
   for j:=0 to 319 do begin
    b:=dbuf^[i,j];
    if b<12 then dbuf^[i,j]:=Texture^[i and 127,j and 127] else
    if b<24 then dbuf^[i,j]:=60-(b-16)*(b-16) else
    if b>64 then dbuf^[i,j]:=180-(sintab[(j*3+i*2) and 255]-
                                  sintab[i*5 and 255]-
                                  sintab[(i*4-j*7) and 255]) div 3
    else dbuf^[i,j]:=0;

   end;
  FlipToScreen;
  Frame:=0;
  repeat
   DoBeat(24,4,8);
   br1:=120-Sat(frame-160,0,120);
   sat1:=Sat(60-frame*3,0,60)+BeatFunc;
   SetPalette;
   VSync;
   FlipToScreen;
   inc(frame);
  until IsEsc or (Time>=127);
end;

procedure Part5;
var
 i,j,k,w:integer;
 pos,wid,spd:array[0..15] of integer;
 TitlePos:integer;
 fn,timer,ddz:integer;
begin
  for i:=0 to 255 do begin
   palette[i,0]:=Sat(i-128,0,100);
   palette[i,1]:=Sat(i-32,0,120);
   palette[i,2]:=Sat(i+32,0,120);
  end;
 for i:=0 to 15 do begin
  pos[i]:=random(1000);
  wid[i]:=8+random(32);
  spd[i]:=1+random(3);
  if i>7 then spd[i]:=-spd[i];
 end;
 frame:=0; ddz:=1024; DeltaZ:=21000;
 timer:=time; br1:=0;
 repeat
  DoBeat(800,4,8);
  { TODO: }
  if (time-timer<10) and (br1<120) then inc(br1,5);
  if (time-timer>125) and (br1>0) then dec(br1,5);
  sat1:=BeatFunc div 48;
{  br1:=120;}
  ClearBuf;
  for i:=0 to 15 do begin
   k:=pos[i] div 4;
   w:=wid[i];
   for j:=k to k+w do
    if (j>=0) and (j<200) then
    asm
     mov ax,j
     mov dx,320
     mul dx
     mov si,ax
     mov cx,320

     push ds
     mov ax,word ptr dbuf+2
     mov ds,ax
     mov ax,i
     shr al,3
     add al,20
@01: add [si],al
     inc si
     dec cx
     jnz @01
     pop ds
    end;
   pos[i]:=(pos[i]+spd[i]) and 1023;
  end;
{  DeltaZ:=4000;}
  if (GP.Vars^[PatternRow]<60) and (ddz>0) then begin
   dec(DeltaZ,ddz); dec(ddz,32);
  end;
  if (GP.Vars^[PatternRow]>60) and (ddz<1024) then begin
   inc(ddz,32);
   inc(DeltaZ,ddz);
  end;
  dec(DeltaZ,BeatFunc);
  GenMatrix(frame,frame div 2,frame*3 div 2);
  i:=0;
  repeat
   if Time-Timer<64 then begin
    vertices[0].x:=sintab[(i*8) and 255] div 2;
    vertices[0].y:=sintab[(i*8+64) and 255] div 2;
    vertices[0].z:=i div 2-80;
   end else begin
    j:=100+sintab[(i*6+i*2) and 255] div 3;
    vertices[0].x:=j*sintab[(i) and 255] div 128;
    vertices[0].y:=j*sintab[(i*3+64) and 255] div 128;
    vertices[0].z:=j-100{sintab[(i*2+i*4) and 255] div 2};
   end;
   Project(1);
   inc(i); scene[1]:=scene[0];
   if Time-Timer<64 then begin
    vertices[0].x:=sintab[(i*8) and 255] div 2;
    vertices[0].y:=sintab[(i*8+64) and 255] div 2;
    vertices[0].z:=i div 2-80;
   end else begin
    j:=100+sintab[(i*6+i*2) and 255] div 3;
    vertices[0].x:=j*sintab[(i) and 255] div 128;
    vertices[0].y:=j*sintab[(i*3+64) and 255] div 128;
    vertices[0].z:=j-100{sintab[(i*2+i*4) and 255] div 2};
   end;
   Project(1);
   for j:=0 to 7 do
    dbuf^[100+(scene[0].y*j+scene[1].y*(8-j)) div 8,
          160+(scene[0].x*j+scene[1].x*(8-j)) div 8]:=140-scene[0].z;
  until i>320;
  inc(DeltaZ,BeatFunc);
  TitlePos:=Sat(frame*2-64,0,200)-Sat(frame*2-1600,0,200);
  if TitlePos>0 then
   for i:=0 to 31 do begin
    w:=TitlePos-i*i div 16;
    if w>0 then
    asm
     mov ax,i
     mov dx,320
     mul dx
     mov si,ax
     mov cx,w
     push ds
     mov ax,word ptr dbuf+2
     mov ds,ax
@01: mov al,[si]
     shr al,1
     add al,96
     mov [si],al
     not si
     mov al,[64000+si]
     shr al,1
     add al,96
     mov [64000+si],al
     not si
     inc si
     dec cx
     jnz @01
     pop ds
    end;
   end;
  SetPalette;
  if (frame>154) and (frame<460) then begin
    PrintString('CODE:',32,2,0,224,false);
    PrintString('COOLER',192,172,0,224,false);
  end;
  if (frame>480) and (frame<800) then begin
    PrintString('MUSIC:',24,2,0,224,false);
    PrintString('DJ MoHaX',170,172,0,224,false);
  end;
  blur1;
  VSync;
  FlipToScreen;
  inc(frame);
 until IsEsc or ((time mod 128=127) and (frame>100));
end;

procedure GenWheel(r,n:integer);
var
 i,j:integer;
begin
 vertices[0].x:=0;
 vertices[0].y:=0;
 vertices[0].z:=0;
 for i:=1 to n+1 do begin
  j:=i*256 div n;
  vertices[i].x:=(sintab[(j+64) and 255])*r div 80;
  vertices[i].y:=(sintab[(j) and 255])*r div 80;
  vertices[i].z:=0;
  j:=j-2+4*(i and 1);
  vertices[i+n+1].x:=(sintab[(j+64) and 255])*r div 64;
  vertices[i+n+1].y:=(sintab[(j) and 255])*r div 64;
  vertices[i+n+1].z:=0;
 end;
 for i:=0 to n-1 do begin
  faces[i].v1:=0;
  faces[i].v3:=i+2;
  faces[i].v2:=i+1;
  faces[i].color:=16;
  if i and 1=0 then begin
   faces[i+n].v1:=n+i+3;
   faces[i+n].v3:=n+i+2;
   faces[i+n].v2:=i+1;
   faces[i+n].color:=16;
   faces[i+1+n].v1:=n+i+3;
   faces[i+1+n].v3:=i+1;
   faces[i+1+n].v2:=i+2;
   faces[i+1+n].color:=16;
  end;
 end;
end;

procedure Part4;
var
 i,j,x,y,u,v,delta,dd:integer;
 buf:^TTextBuf;
 timer:longint;
begin
 new(buf);
 for i:=0 to 255 do begin
  palette[i,0]:=Sat(120-i,24,120);
  palette[i,1]:=Sat(100-i,32,120);
  palette[i,2]:=Sat(i-128,0,120);
 end;
 frame:=0; delta:=150; br1:=0; timer:=time; sat1:=0;
 repeat
{  DoBeat(12,0,8);}
  if (time-timer<20) and (br1<120) then inc(br1,5);
  if (time-timer>120) and (br1>0) then dec(br1,3);
  SetPalette;
  ClearBuf;

  DeltaZ:=4096;
  GenMatrix(frame*4 div 3,0,0);
  GenWheel(100,24);
  DrawScene(50,48,100,120);

  GenMatrix(frame+10,0,0);
  GenWheel(120,32);
  DrawScene(66,64,224,150);

  GenMatrix(-frame*2+5,0,0);
  GenWheel(64,16);
  DrawScene(34,32,170,80);

  GenMatrix(-frame*8 div 3+5,0,0);
  GenWheel(45,12);
  DrawScene(26,24,40,160);

{  GenMatrix(-frame*8 div 3+5,0,0);
  GenWheel(45,12);
  DrawScene(26,24,40,160);}

  DeltaZ:=7200;
{  GenMatrix(frame,frame,frame div 2);}
  GenMatrix(frame div 3,frame,frame div 2);
  move(baseVertices,vertices,sizeof(basevertices));
  move(basefigure,faces,sizeof(basefigure));
  for i:=0 to 3 do begin
   vertices[i].color:=160+i*30;
   if frame<450 then faces[i].color:=175+i*20
   else faces[i].color:=0;
  end;
  DrawScene(4,4,160,100+(128-(3*frame div 5) and 255-sintab[(3*frame div 5) and 255]));

  VSync;
  FlipToScreen;
  inc(frame);
 until IsEsc or ((time mod 128=125) and (frame>100));
end;

procedure Part4a;
var
 i,j,x,y,u,v,delta,dd,vcnt,fcnt:integer;
 koef,pos,timer:longint;
 mas:array[0..199] of integer;

const
 a:array[0..5] of shortint=(1,1,5,11,6,-2);
 b:array[0..5] of shortint=(-1,3,2,7,13,-8);
 c:array[0..5] of shortint=(3,0,-1,2,3,0);

function Func(a,b:integer):integer;
 var
  p:integer;
 begin
  if frame<256 then p:=48 else p:=176+frame div 2;
  if (a<4) and (b<4) then func:=64+sintab[p and 255] div 3 else
    func:=64+sintab[(p+64) and 255] div 3;
 end;

begin
 for i:=0 to 255 do begin
  palette[i,0]:=Pike(i,128,0,60,100);
  palette[i,1]:=Pike(i,96,90,0,110);
  palette[i,2]:=Pike(i,48,40,60,0);
 end;
 FirstPartSize:=384;
 fillchar(palette,3,0);
 frame:=0; delta:=150; br1:=0; br2:=0; timer:=time;
 repeat
  DoBeat(20,0,4);
  if (time-timer<50) and (br1<120) then inc(br1,2);
  if (time-timer>110) and (br1>0) then dec(br1,1);
  if (time-timer<50) and (br2<120) then inc(br2,4);
  if (time-timer>120) and (br2>0) then dec(br2,4);
  inc(br1,BeatFunc);
  SetPalette;
  dec(br1,BeatFunc);
{  ClearBuf;}
  fillchar(mas,sizeof(mas),0);
  for i:=0 to 15 do begin
   j:=i*64-frame and 255;
   if (j>=0) and (j<256) then begin
    koef:=4096*ExSin(j) div ExSin(j+256);
    pos:=koef*4; y:=199; u:=i+1;
    repeat
     x:=pos div 4096;
     if x>319 then x:=319;
     if x<mas[y] then break;
     fillchar(dbuf^[y,mas[y]],x-mas[y]+1,(i shl 5) and 63);
     mas[y]:=x;
     pos:=pos+koef;
     dec(y);
    until (y<0);
   end;
  end;
  for i:=0 to 199 do
   if mas[i]<319 then fillchar(dbuf^[i,mas[i]],320-mas[i],(u shl 5) and 63);
  for i:=0 to 4 do begin
   j:=frame*c[i];
   u:=a[i]; v:=b[i];
  asm
   mov ax,vseg
   mov es,ax
   mov si,offset sintab
   xor di,di
   mov bx,j
   mov dx,200
@01:
   mov cx,320
   push bx
@02:
   and bx,0ffh
   mov al,[si+bx]
   add al,80
   shr al,3
   add bx,v
   add es:[di],al

   inc di
   loop @02
   pop bx
   add bx,u
   dec dx
   jnz @01
  end;
  end;

  DeltaZ:=$1800;
  GenMatrix(frame div 3,frame,frame div 2);
  move(baseVertices,vertices,sizeof(basevertices));
  move(basefigure,faces,sizeof(basefigure));
  for i:=0 to 3 do begin
   vertices[i].color:=255;
  end;

  vcnt:=4; fcnt:=4;
  for i:=0 to 3 do with faces[i] do begin
   vertices[vcnt].x:=(vertices[v1].x+vertices[v2].x)*func(v1,v2) div 128;
   vertices[vcnt].y:=(vertices[v1].y+vertices[v2].y)*func(v1,v2) div 128;
   vertices[vcnt].z:=(vertices[v1].z+vertices[v2].z)*func(v1,v2) div 128;
{   vertices[vcnt].color:=(vertices[v1].color+vertices[v2].color)*func2(v1,v2) div 128;}

   vertices[vcnt+1].x:=(vertices[v1].x+vertices[v3].x)*func(v1,v3) div 128;
   vertices[vcnt+1].y:=(vertices[v1].y+vertices[v3].y)*func(v1,v3) div 128;
   vertices[vcnt+1].z:=(vertices[v1].z+vertices[v3].z)*func(v1,v3) div 128;
{   vertices[vcnt+1].color:=(vertices[v1].color+vertices[v3].color)*func2(v1,v3) div 128;}

   vertices[vcnt+2].x:=(vertices[v3].x+vertices[v2].x)*func(v3,v2) div 128;
   vertices[vcnt+2].y:=(vertices[v3].y+vertices[v2].y)*func(v3,v2) div 128;
   vertices[vcnt+2].z:=(vertices[v3].z+vertices[v2].z)*func(v3,v2) div 128;
{   vertices[vcnt+2].color:=(vertices[v3].color+vertices[v2].color)*func2(v3,v2) div 128;}

   faces[fcnt].v1:=v1;
   faces[fcnt].v2:=vcnt;
   faces[fcnt].v3:=vcnt+1;
   faces[fcnt].color:=0;

   faces[fcnt+1].v1:=v2;
   faces[fcnt+1].v2:=vcnt+2;
   faces[fcnt+1].v3:=vcnt;
   faces[fcnt+1].color:=0;

   faces[fcnt+2].v1:=v3;
   faces[fcnt+2].v2:=vcnt+1;
   faces[fcnt+2].v3:=vcnt+2;
   faces[fcnt+2].color:=0;

   v1:=vcnt; v2:=vcnt+2; v3:=vcnt+1; color:=0;

   inc(fcnt,3); inc(vcnt,3);
  end;

  for i:=0 to 15 do with faces[i] do begin
   vertices[vcnt].x:=(vertices[v1].x+vertices[v2].x)*func(v1,v2) div 128;
   vertices[vcnt].y:=(vertices[v1].y+vertices[v2].y)*func(v1,v2) div 128;
   vertices[vcnt].z:=(vertices[v1].z+vertices[v2].z)*func(v1,v2) div 128;
{   vertices[vcnt].color:=(vertices[v1].color+vertices[v2].color)*func2(v1,v2) div 128;}

   vertices[vcnt+1].x:=(vertices[v1].x+vertices[v3].x)*func(v1,v3) div 128;
   vertices[vcnt+1].y:=(vertices[v1].y+vertices[v3].y)*func(v1,v3) div 128;
   vertices[vcnt+1].z:=(vertices[v1].z+vertices[v3].z)*func(v1,v3) div 128;
{   vertices[vcnt+1].color:=(vertices[v1].color+vertices[v3].color)*func2(v1,v3) div 128;}

   vertices[vcnt+2].x:=(vertices[v3].x+vertices[v2].x)*func(v3,v2) div 128;
   vertices[vcnt+2].y:=(vertices[v3].y+vertices[v2].y)*func(v3,v2) div 128;
   vertices[vcnt+2].z:=(vertices[v3].z+vertices[v2].z)*func(v3,v2) div 128;
{   vertices[vcnt+2].color:=(vertices[v3].color+vertices[v2].color)*func2(v3,v2) div 128;}

   faces[fcnt].v1:=v1;
   faces[fcnt].v2:=vcnt;
   faces[fcnt].v3:=vcnt+1;
   faces[fcnt].color:=0;

   faces[fcnt+1].v1:=v2;
   faces[fcnt+1].v2:=vcnt+2;
   faces[fcnt+1].v3:=vcnt;
   faces[fcnt+1].color:=0;

   faces[fcnt+2].v1:=v3;
   faces[fcnt+2].v2:=vcnt+1;
   faces[fcnt+2].v3:=vcnt+2;
   faces[fcnt+2].color:=0;

   v1:=vcnt; v2:=vcnt+2; v3:=vcnt+1; color:=0;

   inc(fcnt,3); inc(vcnt,3);
  end;
  for i:=0 to vcnt-1 do
   vertices[i].color:=191-(sintab[vertices[i].z and 255]{-sintab[vertices[i].x and 255]});
  DrawScene(vcnt,fcnt,160,100);
  if Time and 4<>0 then
   PrintString('VOTE!',224,172,192+BeatFunc,240+BeatFunc,false);

  VSync;
  FlipToScreen;
  inc(frame);
 until IsEsc or ((time mod 128=125) and (frame>100));
 FirstPartSize:=765;
end;

procedure Part6;
 var
  i,j,cu,cv,cx,cy:integer;
  x1,y1,x2,y2,ddx,ddy,x,y:longint;
  v:byte;
  timer:longint;
 begin
  for i:=0 to 255 do begin
   palette[i,0]:=Sat(i-64,0,100);
   palette[i,1]:=Sat(i,0,100);
   palette[i,2]:=Sat(i-32,0,120);
  end;
  frame:=0; timer:=time; br1:=0;
  repeat
   DoBeat(16,4,8);
   if (time-timer<10) and (br1<150) then inc(br1,5);
   if (time-timer>124) and (br1>0) then dec(br1,5);
   br2:=br1;
   Sat1:=BeatFunc;
   SetPalette;
{   ClearBuf;}
   for i:=0 to 99 do begin
    x1:=65536*ExSin(frame+256) div (i+2);
    y1:=65536*ExSin(frame) div (i+2);
    x2:=y1; y2:=-x1;
    ddx:=(x2-x1) div 320;
    ddy:=(y2-y1) div 320;
    x:=x1; y:=y1;
    if i<48 then v:=sqr(48-i) div 16 else v:=0;
    asm
     mov ax,vseg
     mov es,ax
     mov ax,i
     mov cx,320
     mul cx
     mov di,31680
     mov si,32000
     sub di,ax
     add si,ax
     db 66h; mov bx,word ptr x
     db 66h; mov dx,word ptr y

@01: db 66h; mov ax,dx
     db 66h; xor ax,bx
     db 66h; shr ax,2
     shr ah,2
     sub ah,v
     jb @02
@03: mov es:[di],ah
     mov es:[si],ah
     db 66h; add bx,word ptr ddx
     db 66h; add dx,word ptr ddy

     inc di
     inc si
     dec cx
     jnz @01
     jmp @04
@02: mov ah,0
     jmp @03
@04:
    end;
   end;
   for i:=0 to 9 do begin
    cx:=96+sintab[(frame+i*24) and 255] div 2+sintab[(i*16+frame div 3) and 255] div 2;
    cy:=32+sintab[(frame*2+100+i*20) and 255] div 4;
    j:=cy*320+cx;
    asm
     mov di,j
     mov ax,vseg
     mov es,ax
     push ds
     mov si,word ptr blob
     mov ax,word ptr blob+2
     mov ds,ax
     mov dx,128
@01: mov cx,128
     push di
@02: lodsb
     shl al,1
     mov ah,es:[di]
     add ah,al
     jnc @03
     mov ah,255
@03: mov es:[di],ah
     inc di
     dec cx
     jnz @02
     pop di
     add di,320
     dec dx
     jnz @01
     pop ds
    end;
   end;
   vsync;
   FlipToScreen;
   inc(frame);
  until IsEsc or ((time mod 128=127) and (frame>100));
 end;

procedure FinalPart;
 var
  i,j:integer;
 begin
  for i:=0 to 255 do begin
   palette[i,0]:=Sat(i-160,0,127);
   palette[i,1]:=Sat(i,0,127);
   palette[i,2]:=Sat(i-48,0,127);
  end;
   asm
    push ds
    mov ax,vseg
    mov es,ax
    mov ax,word ptr Texture+2
    mov ds,ax
    xor di,di
    xor dx,dx
@01:mov cx,320
@02:mov bh,dl
    mov bl,cl
    shl bl,1
    shr bx,1
    and bx,3fffh
    mov al,[bx]
    shl al,1
    mov es:[di],al
    inc di
    loop @02
    inc dx
    cmp dx,200
    jne @01
    pop ds
   end;
  PrintString('PASCAL -',64,64,192,96,false);
  PrintString('RULEZ!',128,96,192,96,false);
  PrintString('(The End)',80,160,192,64,false);
  frame:=0;
  repeat
   if frame=192 then begin
     GP_KillModule;
     GP_ResetGUS;
   end;
   sat1:=Sat(60-frame*2,0,60);
   br1:=Sat(400-frame,0,100);
   SetPalette;
   vsync;
   FlipToScreen;
   inc(frame);
  until IsEsc or (br1=0);

 end;

begin
 Initialize;

 GP_ResetGUS;
 GP_LoadModule(seg(ModSamples),ofs(ModPatterns),ofs(ModSamples));
 GP_StartPlaying;

 Part1;
 PartTitle;
 Part6;
 Part5;
 Part4;
 Part4a;
 Part10;
 Part11;
 Part2(1);

 FinalPart;

 GP_KillModule;
 GP_ResetGUS;

 asm
  mov ax,3h
  int 10h
 end;
end.