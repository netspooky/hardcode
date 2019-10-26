var
 ar:array[0..255]of byte;
 f:file;
 a,b:word;

begin
 assign(f,paramstr(1));
 reset(f,1);
 seek(f,62);
 blockread(f,ar,256);
 a:=0;
 for b:=0 to 255 do
 begin 
  if (b and 3<>3)then
  begin 
   ar[a]:=ar[b];
   inc(a);
  end;
 end;
 close(f);
 assign(f,paramstr(2));
 rewrite(f,1);
 blockwrite(f,ar,192);
 close(f);
end.
