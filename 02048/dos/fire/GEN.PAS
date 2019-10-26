USES crt,dos;

VAR source,dest:string;


function Exist(FileName: String): Boolean;
{ Boolean function that returns True if the file exists;otherwise,
 it returns False. Closes the file if it exists. }
var
 F: file;
begin
 {$I-}
 Assign(F, FileName);
 FileMode := 0;  { Set file access to read only }
 Reset(F);
 Close(F);
 {$I+}
 Exist := (IOResult = 0) and (FileName <> '');
end;

Procedure GetNames;
BEGIN
  writeln;
  writeln ('Conversion from binary to db...');
  writeln;
  Write ('Enter name of binary file --> ');
  Readln (source);
  if not exist (source) then BEGIN
    Writeln (source,' not found! Exiting ...');
    writeln;
    halt;
  END;
  Write ('Enter name of desination text file --> ');
  Readln (dest);
  writeln;
  writeln ('Working ...');
END;

Procedure Convert;
VAR f:text;
    f2:file;
    loop1,loop2,loop3:integer;
    no:byte;
    msg:string;
    dir:dirstr;
    name:namestr;
    ext:extstr;
BEGIN
  assign (f2,source);
  reset (f2,1);
  assign (f,dest);
  rewrite (f);

  fsplit (dest, dir, name, ext);
  while length (name)<8 do name:=name+' ';

  write (f,name,'  db ');
  loop1:=0;
  loop3:=filesize (f2);
  loop2:=0;
  While not EOF (f2) do BEGIN
    blockread (f2,no,1);
    str (no:3,msg);
    write (f,msg);
    inc (loop1);
    inc (loop2);
    gotoxy (1,wherey);
    write (loop2,'/',loop3);
    if (loop1=16) and (not (eof(f2))) then BEGIN
      loop1:=0;
      writeln(f);
      write (f,'          db ');
    END else
    if not (eof(f2)) then write (f,',');
  END;

  close (f);
  close (f2);
  writeln;

  writeln ('Done.');
END;


BEGIN
  Getnames;
  Convert;
END.