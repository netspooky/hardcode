program make_a_raw_asm_dump;

var
  f      : text;
  c      : word;
  inf    : file of byte;
  b      : byte;

begin
  if paramcount<1 then exit;
  assign(inf,paramstr(1));
  reset(inf);
  assign(f,'endansi.raw');
  rewrite(f);
  writeln(f,'endansi label byte');
  while not eof(inf) do begin
    read(inf,b);
    write(f,'db ');
    writeln(f,b);
  end;
  close(f);
  close(inf);
end.
