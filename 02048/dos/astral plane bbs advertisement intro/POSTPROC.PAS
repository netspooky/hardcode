
  (* special post processing utility for COM-files, cuts the unused
     zeros from the end, JHH/93 *)

  type
    a = array [1..65535] of byte;
  var
    f : file;
    b : ^a;
    l : word;
    s : word;

  procedure xHalt (msg: string);
  begin
    write (msg);
    halt;
  end;

  begin
    if ParamCount <> 1 then xHalt ('usage: POSTPROC <com-file>');
    if MaxAvail < 65535 then xHalt ('out of memory!');
    GetMem (b, 65535);
    assign (f, ParamStr (1));
    {$I-}
    reset (f, 1);
    if ioResult <> 0 then xHalt ('usage: POSTPROC <com-file>');
    write ('reading..');
    blockread (f, b^, 65535, l);
    close (f);
    write (' processing..');
    s := l;
    while b^[s] = 00 do  dec (s);
    rewrite (f, 1);
    write (' writing..');
    blockwrite (f, b^, s);
    close (f);
    write (' total: ', s, ' bytes.');
  end.
