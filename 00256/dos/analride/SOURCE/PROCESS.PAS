{ old^shitty, but works... }
{ neon / the machines }

var fi : file;

procedure Copyright;
begin
 asm mov ax, 03h
     int 10h
 end;
 writeln;
 writeln(' COM file PostProcessor v.1.0');
 writeln(' by neon / the machines');
end;

procedure CheckParam;
begin
 if paramcount<>1 then
 begin
  copyright;
  writeln(' þ pleez write phile name...');
  halt(0);
 end;
end;

procedure CutZeroes;
var b   : byte;
    pos : longint;
    i   : longint;

label _exit, _loop;

begin
 i:=0;
 assign(fi, paramstr(1));
 reset(fi, 1);
 pos:=filesize(fi);
 _loop:
  seek(fi, pos-1);
  blockread(fi, b, 1);
  if b<>0 then goto _exit;
  dec(pos);
  inc(i);
  goto _loop;
 _exit:
 truncate(fi);
 close(fi);
 writeln(' þ Cutted ', i,' zeros from file: ', paramstr(1));
end;

begin
 CheckParam;
 Copyright;
 CutZeroes;
end.