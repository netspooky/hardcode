{ Martin fractal program, by Alan Meiss

  Formula from "Dynamical Systems and Fractals",
   by Karl-Heinz Becker and Michael D”rfler,
   Cambridge University Press, 1990

  Written in Turbo Pascal 4.0, math chip recommended }

program martin_fractal;

uses graph, crt;

var xmax, ymax, t, tcmax, tc, clr, cx, cy, code:integer;
    sa,sav,sb,sc:real;
    ch:char;

{ Check command line parameter for specified loop limit. }

procedure getparam;

begin
   tcmax:=12;
   if paramcount>0 then begin
      val(paramstr(1),tcmax,code);
      end;
   tcmax:=abs(tcmax);
end;

{ Autodetect graphics hardware and initialize .bgi driver }

procedure init_graphics;

var aa,bb:integer;

begin
   randomize;
   detectgraph(aa,bb);
   initgraph(aa,bb,'');
   xmax:=getmaxx;
   ymax:=getmaxy;
   cx:=round(xmax/2.0);
   cy:=round(ymax/2.0);
end;

{ Return sign of x: -1, 0, or +1 }

function sign(x:real):integer;

begin
   sign:=0;
   if x<>0 then begin
      if x<0 then sign:=-1
      else sign:=1;
      end;
end;

{ Plot coordinate with real x,y values }

procedure plot(x,y:real;clr:integer);

begin
   putpixel(round(x)+cx,round(y)+cy,clr);
end;

{ Cycle a given fractal until a key is pressed,
   with a counter for incrementing display color.
  "a", "b", and "c" are random values constant for a
   given fractal, "s" is a scaling factor. }

procedure martin1(a,b,c,s:real);

var xold, yold, xnew, ynew:real;

begin
   xold:=0;
   yold:=0;
   clr:=9+round(int(random*7));
   t:=0;
   tc:=0;
   ch:='a';
   repeat
      plot(xold*s,yold*s,clr);
      xnew:=yold-sign(xold)*sqrt(abs(b*xold-c)); { <- This is it! These two }
      ynew:=a-xold;                              { <- lines generate the }
      xold:=xnew;                                {     entire fractal! }
      yold:=ynew;
      inc(t);
      if t>1000 then begin
         inc(tc);
         inc(clr);
         if clr>15 then clr:=9;
         t:=0;
         end;
   until keypressed or ((tc>(tcmax-1)) and (tcmax>0));
   cleardevice;
   if keypressed then ch:=readkey;
end;

{ Main loop. Cycle until ESC or Q is typed. }

begin
   getparam;
   init_graphics;
   repeat
      sa:=random*100.0-50.0;
      sb:=random*100.0-50.0;
      sc:=random*100.0-50.0;
      sav:=(abs(sa)+abs(sb)+abs(sc))/3.0;
      martin1(sa,sb,sc,6.0-abs(sav/10.0));
   until (ord(ch)=27) or (ch='q') or (ch='Q');
   textmode(3);
end.