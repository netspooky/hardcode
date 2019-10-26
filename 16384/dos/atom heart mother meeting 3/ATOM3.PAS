uses crt;

var ztart:word;

var dezine:word;

    pallo_on:boolean;
    taustamode:byte;
    dezignpaletti:boolean;

type sgreentype=array[0..63999] of byte;

var  sgreenptr:^sgreentype;

const skroltxt:string =

      '                                                 '+
      'seuraava efekti kuvaa maailman kolmea peruselementtia  '+
      '   vihrea kuin nurmi  sininen kuin taivas  keltainen kuin maa  '+
      '         paamarani on taydellyys           ';

const fontti:array[0..26,0..5,0..5] of byte =

(

((0,0,0,0,0,0),
 (0,0,0,0,0,0),
 (0,0,0,0,0,0),
 (0,0,0,0,0,0),
 (0,0,0,0,0,0),
 (0,0,0,0,0,0)),


((0,1,1,1,1,0),
 (1,0,0,1,1,0),
 (1,0,0,1,1,0),
 (1,1,1,1,1,0),
 (1,0,0,1,1,0),
 (1,0,0,1,1,0)),

((1,1,1,1,0,0),
 (1,1,0,1,1,0),
 (0,1,1,1,0,0),
 (0,1,0,1,1,0),
 (0,1,0,1,1,0),
 (0,1,1,1,1,0)),

((0,0,1,1,1,0),
 (0,1,0,1,1,0),
 (1,1,0,0,0,0),
 (1,1,0,0,0,0),
 (1,1,0,0,1,0),
 (0,1,1,1,1,0)),

((1,1,1,1,0,0),
 (1,1,0,1,1,0),
 (1,0,0,1,1,0),
 (1,0,1,1,1,0),
 (1,0,1,1,1,0),
 (1,1,1,1,0,0)),

((1,1,1,1,0,0),
 (1,0,0,0,0,0),
 (1,1,1,1,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,0,0),
 (1,1,1,1,1,0)),

((1,1,1,1,1,0),
 (1,1,0,0,1,0),
 (1,1,1,0,0,0),
 (1,1,0,0,0,0),
 (1,1,0,0,0,0),
 (1,1,1,0,0,0)),

((0,1,1,1,1,0),
 (1,1,0,0,0,0),
 (1,0,0,0,0,0),
 (1,0,0,1,1,0),
 (1,1,0,0,1,0),
 (1,1,1,1,1,0)),

((1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,1,1,1,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0)),

((0,0,1,1,1,0),
 (0,0,0,0,0,0),
 (0,0,1,1,1,0),
 (0,0,1,1,1,0),
 (0,0,1,1,1,0),
 (0,0,1,1,1,0)),

((0,0,0,1,1,0),
 (0,0,0,1,1,0),
 (0,0,0,1,1,0),
 (0,0,0,1,1,0),
 (0,0,0,1,1,0),
 (1,1,1,1,1,0)),

((1,0,0,0,1,0),
 (1,0,0,1,0,0),
 (1,1,1,1,0,0),
 (1,1,1,1,0,0),
 (1,0,0,1,0,0),
 (1,0,0,1,1,0)),

((1,1,1,0,0,0),
 (1,1,1,0,0,0),
 (1,1,1,0,0,0),
 (1,1,1,0,0,0),
 (1,1,1,0,0,0),
 (1,1,1,1,1,0)),

((1,1,0,0,1,0),
 (1,1,0,0,1,0),
 (1,0,1,1,1,0),
 (1,0,1,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0)) ,

((1,1,1,0,0,0),
 (1,0,1,1,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0))  ,

((0,0,1,1,0,0),
 (0,1,1,1,1,0),
 (0,1,0,0,1,0),
 (0,1,0,0,1,0),
 (0,1,1,1,1,0),
 (0,0,1,1,0,0))   ,

((0,0,1,1,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,1,1,1,1,0),
 (1,0,0,0,0,0),
 (1,0,0,0,0,0))    ,

((1,1,1,1,1,0),
 (1,0,0,0,1,0),
 (1,0,0,1,1,0),
 (1,1,1,1,1,0),
 (0,0,0,0,1,0),
 (0,0,0,0,1,0))     ,

((1,1,1,1,1,0),
 (1,0,0,0,1,0),
 (1,1,1,1,1,0),
 (1,0,1,0,0,0),
 (1,0,1,0,0,0),
 (1,0,0,1,1,0))      ,

((1,1,1,1,0,0),
 (1,0,0,0,0,0),
 (1,1,1,1,1,0),
 (0,0,0,0,1,0),
 (0,0,0,0,1,0),
 (0,0,0,1,1,0))       ,

((0,0,1,0,0,0),
 (1,1,1,1,1,0),
 (0,0,1,0,0,0),
 (0,0,1,0,0,0),
 (0,0,1,0,0,0),
 (0,0,1,0,0,0))        ,

((1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (0,1,1,1,1,0))         ,

((1,0,0,0,1,0),
 (0,1,0,0,1,0),
 (0,0,1,0,1,0),
 (0,0,0,1,1,0),
 (0,0,0,0,1,0),
 (0,0,0,0,1,0))           ,

((1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,1,0,1,0),
 (1,1,1,1,1,0),
 (1,1,1,1,1,0),
 (1,0,0,0,1,0)),


((1,0,0,0,0,1),
 (0,1,0,0,1,0),
 (0,0,1,1,0,0),
 (0,0,1,1,0,0),
 (0,1,0,0,1,0),
 (1,0,0,0,0,1))             ,

((1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (1,0,0,0,1,0),
 (0,1,1,1,1,0),
 (0,0,0,0,1,0),
 (1,1,1,1,1,0))              ,

((1,1,1,1,1,0),
 (0,0,0,1,0,0),
 (0,0,1,0,0,0),
 (0,1,0,0,0,0),
 (1,0,0,0,0,0),
 (1,1,1,1,1,0))

 );


var sini:array[0..255] of integer;

var frame:integer;

var phgz:array[-49..49,-49..49] of integer;

const numztr=300;

var ztary,ztarr,ztara:array[0..numztr] of integer;

procedure genztarz;
var l:integer;
begin
     for l:=0 to numztr do begin
         ztary[l]:=random(50)-25;
         ztarr[l]:=random(256);
         ztara[l]:=random(50);
     end;
end;

procedure filopali(t:integer);
var l,r,g,b:integer;
begin
     port[$3c8]:=0;
     for l:=0 to 255 do begin
     r:=0;g:=0;b:=0;
         if (l and 1)=1 then b:=b+16;
         if (l and 2)=2 then g:=g+16;
         if (l and 4)=4 then r:=r+16;
         if (l and 8)=8 then begin b:=b+8;g:=g+8;r:=r+8;end;
         if (l and 16)=16 then b:=b+32;
         if (l and 32)=32 then g:=g+32;
         if (l and 64)=64 then r:=r+32;
         if (l and 128)=128 then begin b:=b+16;g:=g+16;r:=r+16;end;
         r:=r div 4;
         g:=g div 4;
         b:=b div 4;

         port[$3c9]:=r;
         port[$3c9]:=g;
         port[$3c9]:=b;
     end;
     (*
     63 do begin
         port[$3c9]:=l;
         port[$3c9]:=0;
         port[$3c9]:=0;
     end;
     for l:=0 to 63 do begin
         port[$3c9]:=0;
         port[$3c9]:=l;
         port[$3c9]:=0;
     end;
     for l:=0 to 63 do begin
         port[$3c9]:=0;
         port[$3c9]:=0;
         port[$3c9]:=l;
     end;*)
end;

procedure filosofy(t:integer);
var x,y:integer;
    oso,jojo,joojo:word;
    koluy,kolu,koluq,kolustep,kolustepstep:integer;
begin
     oso:=0;

     kolu:=t;
     kolustep:=(abs(sini[(t) and 255])+50);
     kolustepstep:=(abs(sini[(50+(t*2)) and 255])+10);
     joojo:=sini[(t+77) and 255] and 255;
     jojo:=sini[(t*4+32) and 255];

     for y:=0 to 199 do begin
     kolu:=koluy;
     for x:=0 to 319 do begin
         koluq:=(kolu or jojo) and joojo;
         if koluq<>255 then sgreenptr^[oso]:=koluq;
         inc(kolu,kolustep);
         inc(oso);
     end;
     koluy:=koluy+kolustep;
     if ((y+t) and 15)=0 then begin
        joojo:=sini[(t+y*26) and 255];
        jojo:=sini[((t+y)*4+32) and 255];end;

     kolustep:=kolustep+kolustepstep;
     end;
end;

procedure rotodrawztr(ang:integer);
var l,x,y,z:integer;
begin
     for l:=0 to numztr do begin
         y:=ztary[l];
         x:=(sini[ (ang+ztara[l]) and 255 ]*ztarr[l]) div 256;
         z:=(sini[ (64+ang+ztara[l]) and 255 ]*ztarr[l]) div 256;
         z:=z+200;
         x:=(x*256) div z;
         y:=(y*256) div z;
         x:=x+160;
         y:=y+100;
         sgreenptr^[y*320+x]:=255;
     end;
end;

procedure makephongtab;
var x,y:integer;
    z2:integer;
begin
     for x:=-49 to 49 do
     for y:=-49 to 49 do begin          (* x2+y2+z2=r2
                                           z2 = r2-x2-y2 *)
     z2:=50*50-x*x-y*y;
     if z2<0 then phgz[x,y]:=255
             else phgz[x,y]:=trunc(sqrt(z2));
     end;
end;

procedure phongball(xo,yo:integer);
var x,y:integer;
    lx,ly,lz:integer;
    kros:integer;
begin

(*lx:=random(50)-30;
     ly:=random(50)-20;
     lz:=random(50)-25;*)

     lx:=(sini[(frame*9) and 255]*30) div 256;
     ly:=(sini[(64+(frame*14)) and 255]*30) div 256;
     lz:=phgz[lx,ly];

     for x:=-49 to 49 do
     for y:=-49 to 49 do begin
         if phgz[x,y]<>255 then begin
         kros:=(x*lx+y*ly+phgz[x,y]*lz) div 10;
         kros:=kros+50;
         if kros<0 then kros:=0;
         if kros>255 then kros:=255;
         sgreenptr^[(y+yo)*320+(x+xo)]:=kros;
         end;
     end;
end;

procedure makesintab;
var l:integer;
begin
     for l:=0 to 255 do
         sini[l]:=trunc(sin((l*2*3.1415926)/256)*256);
end;

procedure kakka(t:integer);
var x,y,a:integer;
    hii,hiistep,doublehiistep:integer;
    hii2,hii2step:integer;
    cex,cey:integer;
begin
     hiistep:=sini[(t*3) and 255];
     doublehiistep:=hiistep*2;
     hii2step:=sini[((t*3)+64) and 255];

     cex:=160+(sini[(t*8) and 255]*30) div 256;
     cey:=100+(sini[((t*8)+50) and 255]*30) div 256;

     hii2:=-cey*hii2step-cex*hiistep;
     a:=0;
     for y:=0 to 199 do begin
         hii:=hii2;
     for x:=0 to 319 do begin
         sgreenptr^[a]:=hi(hii);
         inc(hii,hiistep);
         inc(a);
     end;
         hii2:=hii2+hii2step;
     end;
end;

procedure pallase(t,r,g,b:integer);
var l,rr,gg,bb:integer;
begin
     port[$3c8]:=1;
     for l:=0 to 253 do begin
         rr:=(((l+t*abs(l-128)) div 256)*r) div 256;
         port[$3c9]:=rr;
         gg:=(((l+t*abs(l-128)) div 256)*g) div 256;
         port[$3c9]:=gg;
         bb:=(((l+t*abs(l-128)) div 256)*b) div 256;
         port[$3c9]:=bb;
     end;

     port[$3c9]:=(255-rr) and 255;
     port[$3c9]:=(255-gg) and 255;
     port[$3c9]:=(255-bb) and 255;
end;

procedure elechar(x,y:integer; t:char);
var xl,yl:byte;
    oso:word;
    q:integer;
begin
     oso:=y*320+x;
     q:=ord(t)-64;
     for xl:=0 to 5 do begin
     for yl:=0 to 5 do begin
         if fontti[q,xl,yl]=1 then
            sgreenptr^[oso]:=255;
         inc(oso);
     end;
         inc(oso,320-6);
     end;
end;

procedure skrolly(t:integer);
var physx:integer;
    khar,kharx:integer;
    l:integer;
begin
     physx:=t*6;
     khar:=physx div 10;
     kharx:=physx mod 10;
     for l:=1 to 32 do
          elechar(l*10-kharx,170+(sini[( (physx+l*10)+t*10) and 255] div 16),

                   chr(64+(ord( skroltxt[khar+l] ) and 31))

                   );
end;


procedure eletext(yy:integer; t:string);
var x,y:integer;
var l:integer;
    lg:integer;
begin
     lg:=abs((frame and 31)-16);

     x:=160-(lg*length(t)) div 2;
     for l:=0 to length(t) do begin
         y:=yy+sini[((l*5)+frame*13) and 255] div 8;
         elechar(x,y,t[l]);
         x:=x+lg;
     end;
end;

begin

     new(sgreenptr);

     makesintab;
     makephongtab;
     genztarz;

     asm
         mov ax,13h
         int 10h
     end;

     (*
     for frame:=0 to 30000 do mem[$a000:frame]:=frame and 255;

     repeat until keypressed;
     *)

     ztart:=memw[0:1132];
     frame:=0;

     repeat

          frame:=(frame*7+(memw[0:1132]-ztart))div 8;

          (*inc(frame);*)

          case taustamode of
               0: begin

          if not dezignpaletti then begin
          kakka(frame*3);
          pallase(frame,abs(64-(frame and 63))*2,
                        abs(64-((frame*3) and 63)),
                        abs(64-(frame and 63)) div 2) end else

          begin

          kakka(frame*8);

          pallase(frame*2,abs(64-(frame*7)) and 63,
                          abs(64-(frame*11)) and 63,
                          abs(64-(frame*15)) and 63);

          end;end;


               1: begin
               filosofy(frame);
               filopali(frame);end;

          end;


          dezignpaletti:=false;

          dezine:=frame;

          if (dezine<650) or (dezine>710)
                          then taustamode:=0
                          else taustamode:=1;

          if (dezine>110) and (dezine<40) then rotodrawztr(frame*5);

          if (dezine>=10) and (frame<80) then eletext(60,'ONLY');
          if (dezine>=30) and (frame<90) then eletext(80,'LAMERZ');
          if (dezine>=50) and (frame<100) then eletext(100,'MAKE@IT');
          if (dezine>=70) and (frame<110) then eletext(120,'POSSIBLE');

          pallo_on:=false;
          if ((dezine>=100) and (frame<190)) then begin
             pallo_on:=true;
             if (dezine and 7)=0 then dezignpaletti:=true;
          end;

          if (dezine>190) and (frame<200) then
                          if ((dezine and 2)=0) then begin
                             pallo_on:=true;
                             dezignpaletti:=true; end;
          if (dezine>200) and (frame<220) then
                          if ((dezine and 4)=0) then pallo_on:=true
                                                else dezignpaletti:=true;
          if (dezine>290) and (dezine<300) and ((dezine and 1)=0) then
                          begin pallo_on:=true; dezignpaletti:=true;end;
          (*if (dezine>=300) then pallo_on:=true;*)

          if pallo_on
           then
             phongball(160+(sini[frame*19 and 255]*40) div 256,
                       100+((sini[(frame*19+64) and 255]*40) div 256));



          if (dezine>=200) and (dezine<260) then eletext(50,'ATOM');
          if (dezine>=205) and (dezine<265) then eletext(70,'MEETING');
          if (dezine>=210) and (dezine<270) then eletext(90,'PART@III');
          if (dezine>=215) and (dezine<275) then eletext(130,'DA@INTRO');

(*          if (dezine>=280) and (dezine<300) then eletext(50,' *)

          if (dezine>300) and (dezine<600) then skrolly(frame-300);


          if (dezine>=750) and (dezine<850) then eletext(50,'GREETINGS TO');
          if (dezine>=770) and (dezine<860) then eletext(80,'LUNA');
          if (dezine>=775) and (dezine<870) then eletext(100,'AND');
          if (dezine>=780) and (dezine<880) then eletext(120,'BELLA');


          repeat until (port[$3da] and 8)=0;

          move(sgreenptr^,mem[$a000:0000],64000);

     until (keypressed) or (dezine>900);

     asm
         mov ax,3
         xor bx,bx
         int 10h
     end;

     writeln('cREDiTS:');
     writeln('mAiN cODE bY ViZNUT');
     writeln('aDDiTIONAL cODiNG / oPTiMIZATiON bY 216');
     writeln('oRiGINAL fALCON vERSiON oF dA PHiLOsOPHY eFFECT bY ViZNUT & TWN');

end.