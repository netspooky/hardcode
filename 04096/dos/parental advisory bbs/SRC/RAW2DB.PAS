program raw2db;
var
f:file;
f2:text;
c:char;
begin
assign(f,'x1');
reset(f,1);
assign(f2,'output');
rewrite(f2);
write(f2,'String        db ');
repeat
BlockRead(f,c,1);
write(f2,ord(c),',');
until eof(f);
close(f);
close(f2);
end.