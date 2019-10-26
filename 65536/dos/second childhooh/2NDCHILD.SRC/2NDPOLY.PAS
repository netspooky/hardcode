
{ Ezt itt eleg szar, de mentsegemre legyen mondva, hogy loptam. }

Type TVirtMem = array[0..63999]of Byte;

     TPoint = record
       xp,yp,z : Single
     end;
     PPoint = ^TPoint;

     BaseType = single;

var
 fpic:^TVirtMem;
 fpicp:^Byte;
 ZBuffer:array[0..63999]of BaseType;
 fZBp:^BaseType;

Procedure ClearZBuffer; assembler;

const data:single=10000000;
{$ASMMODE intel}
asm
         mov ecx,64000
         mov eax,Dword ptr [Data]
         lea edi,zbuffer
         cld
         rep stosd
end;


Procedure PoliFiller(p1,p2,p3:PPoint;Color:Byte;Kepernyocim:Pointer);

Const e0=1; e1=0;

var rr,rt:integer;
    rr1,rr2:integer;

    s21x,s23x,s31x:BaseType;
    s21y,s23y,s31y:BaseType;

    dm:array[0..199,0..1]of integer;
    dmZ:array[0..199,0..1]of single;
{}    st_ZB,ev_ZB:single;
    tempS:single;
    tpos:single;
{}
    tempp:PPoint;
{}

begin

 p1^.Yp:=p1^.Yp+0.01;
 p2^.Yp:=p2^.Yp+0.01;
 p3^.Yp:=p3^.Yp+0.01;

 p1^.Xp:=p1^.Xp+0.01;
 p2^.Xp:=p2^.Xp+0.01;
 p3^.Xp:=p3^.Xp+0.01;

 p1^.Z:=-p1^.Z;
 p2^.Z:=-p2^.Z;
 p3^.Z:=-p3^.Z;


 fpic:=kepernyocim;


 for rr:=0 to 199 do begin
  dm[rr,0]:=0; dm[rr,1]:=-1;
{}
  dmZ[rr,0]:=10000000; dmZ[rr,1]:=10000000;
{}
 end;

 if (p2^.Yp < p1^.Yp) and (p2^.Yp <= p3^.Yp) then begin

  Tempp:=p3; p3:=p1; p1:=p2; p2:=Tempp;

 end else begin
  if (p3^.Yp < p1^.Yp) and (p3^.Yp <= p2^.Yp) then begin

   Tempp:=p2; p2:=p1; p1:=p3; p3:=Tempp;

  end;
 end;

  s21x:=p2^.xp-p1^.xp; s21y:=p2^.yp-p1^.yp;
  s23x:=p2^.xp-p3^.xp; s23y:=p2^.yp-p3^.yp;
  s31x:=p3^.xp-p1^.xp; s31y:=p3^.yp-p1^.yp;

 if (s21y = 0.0) then s21y:=s21y+0.0001;

 if ((p2^.xp-(s23y/s21y*s21x)) < p3^.xp) then begin


   if s21y<>0 then begin

    for rr:=round(p1^.yp+0.5) to round(p2^.yp-0.5) do begin
     if (rr>=0) and (rr<=199) then begin
      temps:=rr-p1^.yp;
      dm[rr,e1]:=round(p1^.xp+(temps/s21y*s21x)+0.5);
      tpos:=temps/s21y;
      dmZ[rr,e1]:=   p1^.Z+(tpos*(p2^.Z-p1^.Z));
     end;
    end;
   end;

   if s31y<>0 then begin

    for rr:=round(p1^.yp+0.5) to round(p3^.yp-0.5) do begin
     if (rr>=0) and (rr<=199) then begin
      temps:=rr-p1^.yp;
      dm[rr,e0]:=round(p1^.xp+(temps/s31y*s31x)+0.5);
      tpos:=temps/s31y;
      dmZ[rr,e0]:=   p1^.Z+(tpos*(p3^.Z-p1^.Z));
     end;
    end;
   end;

   if s23y<>0 then begin
    if (p2^.yp < p3^.yp) then begin

     for rr:=round(p2^.yp+0.5) to round(p3^.yp-0.5) do begin
      if (rr>=0) and (rr<=199) then begin
       temps:=rr-p2^.yp;
       dm[rr,e1]:=round(p2^.xp+(temps/s23y*s23x)+0.5);
       tpos:=temps/s23y;
       dmZ[rr,e1]:=   p2^.Z+(tpos*(p2^.Z-p3^.Z));
      end;
     end;

    end else begin { >= }

     for rr:=round(p3^.yp+0.5) to round(p2^.yp-0.5) do begin
      if (rr>=0) and (rr<=199) then begin
       temps:=rr-p3^.yp;
       dm[rr,e0]:=round(p3^.xp+(temps/s23y*s23x)-0.5);
       tpos:=temps/s23y;
       dmZ[rr,e0]:=   p3^.Z+(tpos*(p2^.Z-p3^.Z));
      end;
     end;
    end;
   end;


  {}rr1:=round(p1^.yp+0.5);
  if rr1<0 then rr1:=0;
  {}if s23y<0 then rr2:=round(p3^.yp-0.5) else rr2:=round(p2^.yp-0.5);
  if rr2>199 then rr2:=199;


   for rr:=rr1 to rr2 do begin

    st_ZB:=dmZ[rr,0];
    ev_ZB:=(dmZ[rr,1]-dmZ[rr,0]+0.01)/(dm[rr,1]-dm[rr,0]+0.01);

    if dm[rr,0]<0 then begin
     st_ZB:=st_ZB-ev_ZB*dm[rr,0];
     dm[rr,0]:=0;
    end;

    if dm[rr,1]>319 then dm[rr,1]:=319;
    fpicp:=@fpic^[rr*320+dm[rr,0]];
    fZBp :=@ZBuffer[rr*320+dm[rr,0]];

    for rt:=dm[rr,0] to dm[rr,1] do begin

     if ((fZBp^){ZBuffer[rr*320+rt]} > st_ZB) then begin

      fpicp^:=Color;

      fZBp^{ZBuffer[rr*320+rt]}:=st_ZB;

     end;

     inc(fpicp);
     inc(fZBp);
     st_ZB:=st_ZB+ev_ZB;

    end;

  end;
 end;
end;









