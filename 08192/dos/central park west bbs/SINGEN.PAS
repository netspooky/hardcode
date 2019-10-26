var x:integer;
    c:byte;

    sint:array[0..511] of byte;
    sint2:array[0..511] of byte;
    redt:array[0..255] of byte;

    f:file;

begin
   c:=0;
   repeat
     redt[c]:=c;
     redt[127-c]:=c;
     redt[128+c]:=c;
     redt[255-c]:=c;
     inc(c);
   until (c=64);

   x:=0;
   repeat
     sint[x]:=round(128+(127.5*cos(x*pi/255*2)));
     sint2[x]:=round(128+({127.5}5.640267929*sqrt(x)*sin(x*pi/255*2)));
     inc(x);
   until (x=512);

   assign(f,'s1');
   rewrite(f,1);
   blockwrite(f,sint,sizeof(sint));
   close(f);
   assign(f,'s2');
   rewrite(f,1);
   blockwrite(f,sint2,sizeof(sint2));
   close(f);
   assign(f,'rt');
   rewrite(f,1);
   blockwrite(f,redt,sizeof(redt));
   close(f);
end.