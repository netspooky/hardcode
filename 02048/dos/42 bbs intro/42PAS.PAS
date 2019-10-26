

var i,j:word;
ctr:word;
a,b,c,
firstchar,
k,l,m:byte;
x,y: word;
jdir:byte;
randseed:word;
var fofs,fseg:word;

const

scrollstr:string =
'LBA WHQ... Sysop: Maniac/LBA... No doors... No Lamers... Thousands of messages...  1,000,000,000 byte file area...   '+
'Fidonet 3:771/42... ';




_4points: array [0..3,0..1] of byte =
((20,30),(20,0),(0,20),(30,20));


_2points: array [0..4,0..1] of byte =
((0,5),(15,0),(20,10),(0,28),(20,28));


procedure putpixel(x,y:word; c:byte); assembler;
  asm
  mov es, sega000
  mov ax,[y]
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,[x]
  mov al,[c]
  stosb
  end;

procedure putpixel0(x,y:word; c:byte); assembler;
  asm
  mov es, sega000
  mov ax,[y]
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,[x]
  mov al,[c]
  mov dl, [es:di]
  cmp dl, 0
  jnz @@end

  stosb
@@end:
  end;

procedure putpixela(x,y:word; c:byte); assembler;
  asm
  mov es, sega000
  mov ax,[y]
  shl ax,5
  mov di,ax
  add di, 64000
  shl ax,2
  add di,ax
  add di,[x]
  mov al,[c]
  stosb
  end;


procedure writetxt(x,y:integer; txt:string;color:byte);
var i,j,k:byte;
begin
  for i:=1 to length(txt) do for j:=0 to 7 do for k:=0 to 7 do
    if ((mem[fseg:fofs+ord(txt[i])*8+j] shl k) and 128) <> 0 then begin
      if j+y < 200 then
      if j+y >= 0 then
      if (i*8)+x+k < 320 then
      if (i*8)+x+k >= 0 then
      putpixel((i*8)+x+k,(y+j),color-j-k);
    end else       if j+y >= 0 then
      if j+y < 200 then
putpixel((i*8)+x+k,(y+j),0);
end;

procedure writetxt0(x,y:integer; txt:string;color:byte);
var i,j,k:byte;
begin
  for i:=1 to length(txt) do for j:=0 to 7 do for k:=0 to 7 do
    if ((mem[fseg:fofs+ord(txt[i])*8+j] shl k) and 128) <> 0 then begin
      if (i*16-16)+x+k*2 < 320 then
      if (i*16-16)+x+k*2 >= 0 then
      putpixel((i*16-16)+x+k*2,(y+j*2),color);
    end else
      if (i*16-16)+x+k*2 < 320 then
      if (i*16-16)+x+k*2 >= 0 then
      putpixel((i*16-16)+x+k*2,(y+j*2),

      mem[sega000:64000+(j*160+k+(x div 2)+(i*8))]


      )

  end;

procedure rand;
var a: word;
begin
randseed:= random(65535);
asm
mov ax, randseed;
mov bx, 12345
xor ax, bx
rol ax, 2
ror bx, 30
xor ax, bx

mov randseed, ax

mov a, ax
end;
a:= a mod 3;
asm
mov ax, a
end;
end;


procedure setpal(c,r,g,b:byte); assembler;
asm
  mov dx,3c8h
  mov al,[c]
  out dx,al
  inc dx
  mov al,[r]
  out dx,al
  mov al,[g]
  out dx,al
  mov al,[b]
  out dx,al
end;


begin
randomize;
randseed:= random(65535);
asm
mov ax, 013h
int 10h;
  mov ax,1130h
  mov bh,3
  int 10h
  mov fseg,es
  mov fofs,bp
end;


x:=_2points[0,0];
y:=_2points[0,1];

    m:=24;
    jdir:= 1;
for i:= 1 to 4 do
    begin
    repeat
    if x < _2points[i,0] then inc(x);
    if y < _2points[i,1] then inc(y);
    if x > _2points[i,0] then dec(x);
    if y > _2points[i,1] then dec(y);
    m:= m+jdir;
    dec(m);
    if m >= 28 then jdir:= 0;
    if m <= 24 then jdir:= 2;
    if x <> _2points[i,0] then
       begin
       putpixel(x+165,y+14,(m-4));
       putpixel(x+165,y+16,(m-4));
       end;

    if y <> _2points[i,1] then
       begin
       putpixel(x+164,y+15,(m-4));
       putpixel(x+166,y+15,(m-4));
       end;

    putpixel(x+165,y+15,m);
    until (y = _2points[i,1]) and (x = _2points[i,0]);
    end;

x:=_4points[0,0];
y:=_4points[0,1];

    m:=24;
    jdir:= 1;
for i:= 1 to 3 do
    begin
    repeat
    if x < _4points[i,0] then inc(x);
    if y < _4points[i,1] then inc(y);
    if x > _4points[i,0] then dec(x);
    if y > _4points[i,1] then dec(y);
    m:= m+jdir;
    dec(m);
    if m >= 28 then jdir:= 0;
    if m <= 24 then jdir:= 2;
    if x <> _4points[i,0] then
       begin
       putpixel(x+135,y+14,(m-4));
       putpixel(x+135,y+16,(m-4));
       end;

    if y <> _4points[i,1] then
       begin
       putpixel(x+134,y+15,(m-4));
       putpixel(x+136,y+15,(m-4));
       end;

    putpixel(x+135,y+15,m);
    until (y = _4points[i,1]) and (x = _4points[i,0]);
    end;



writetxt(60,0,'This file was stolen from',31);

writetxt(100,50,'The coding bbs',60);

writetxt(105,60,'+644 568-6697',60);






for x:=0 to 319 do
for y:=121 downto 80 do
begin
putpixel(x,y,20);
if (x+y) mod 2 = 0 then
if y mod 2 = 0 then
if random(5) <>0 then
putpixel(x,y,14);

if random (10) = 0 then y:=80;
end;




for x:=0 to 319 do
for y:=122 to 139 do
putpixel(x,y,20);

for x:=0 to 160 do
for y:=0 to 8 do
begin
putpixela(x, y,20);
if random(5) <> 0 then
begin
putpixel(x*2-1 ,122 + y * 2,14);
putpixela(x, y,14);
end;
end;

ctr:=0;
firstchar:=1;

repeat
inc (ctr);
if firstchar >219 then
   begin
   firstchar:=1;
   ctr:=1;
   end;

if ctr*2 > 339+firstchar*16 then inc (firstchar);

for i:=0 to 20 do
writetxt0(319-ctr*2+(i+firstchar)*16,122,scrollstr[i+firstchar],9);




inc(k);
k:=k mod 16+16;
j:=0;

asm
mov es, sega000
mov di,0
mov ax,0
mov cx,25600

@@l1:
mov dl,[es:di]
cmp dl, 16
ja @@nostos
stosb
jmp @@stosed
@@nostos:
inc di;
@@stosed:
loop @@l1
end;










  asm
mov j, 0
mov i, 0
@@leftlightiloop:

  mov bx, 3
  call rand
  add j, ax
  dec j

  mov es, sega000
  mov ax,30
  add ax, j
  dec ax
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,141
  sub di, i

  sub di, 321
  mov al, 9
  mov dl, [es:di]
  cmp dl, 0
  jnz @@llend2
  stosb
@@llend2:
  add di, 639
  mov dl, [es:di]
  cmp dl, 0
  jnz @@llend3
  stosb
@@llend3:
  sub di, 321
  mov al, 11
  mov dl, [es:di]
  cmp dl, 0
  jnz @@llend1
  stosb
@@llend1:
inc i
cmp i, 140
jnz @@leftlightiloop

  end;

  asm
mov j, 0
mov i, 0
@@rightlightiloop:

  mov bx, 3
  call rand
  add j, ax
  dec j

  mov es, sega000
  mov ax,30
  add ax, j
  dec ax
  shl ax,6
  mov di,ax
  shl ax,2
  add di,ax
  add di,184
  add di, i

  sub di, 321
  mov al, 9
  mov dl, [es:di]
  cmp dl, 0
  jnz @@rlend2
  stosb
@@rlend2:
  add di, 639
  mov dl, [es:di]
  cmp dl, 0
  jnz @@rlend3
  stosb
@@rlend3:
  sub di, 321
  mov al, 11
  mov dl, [es:di]
  cmp dl, 0
  jnz @@rlend1
  stosb
@@rlend1:
inc i
cmp i, 137
jnz @@rightlightiloop

  end;


until port [$60] < 128;



asm
mov ax, 03h
int 10h;
end;


writeln('42 - The coding bbs +644 568-6697');

end.