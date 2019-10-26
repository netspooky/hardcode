program Superfast_compo;
uses crt;
const nstars=1000;

var
   tipo:word;
   pp,pp2:integer;
   bufscr:word;bufscrptr:pointer;
   x,y,z,a,b,c:word;
   cx,cy,cz,angle:integer;
   tempw:word;
   tempb:byte;
   tempi:integer;

   coorx:array[0..nstars+1] of integer;
   coory:array[0..nstars+1] of integer;
   coorz:array[0..nstars+1] of integer;
   tcoorx:array[0..nstars+1] of integer;
   tcoory:array[0..nstars+1] of integer;
   tcoorz:array[0..nstars+1] of integer;
   difx:array[0..nstars+1] of integer;
   dify:array[0..nstars+1] of integer;
   difz:array[0..nstars+1] of integer;
   seno:array[0..370] of integer;
   coseno:array[0..370] of integer;

procedure retrace; assembler;
asm
  mov dx,3dah
@vert1:
  in al,dx
  test al,8
  jz @vert1
@vert2:
  in al,dx
  test al,8
  jnz @vert2
end;

   procedure movedw(origen,destino:word);assembler;
   asm
        push ds
        mov cx,64000
        shr cx,2
        mov es,origen
        mov ds,destino
        xor di,di
   @gg:
        db 66h; mov ax,es:[di]
        db 66h; mov ds:[di],ax
        add di,4
        dec cx
        jnz @gg
        pop ds
   end;
   procedure refresh;assembler;
   asm
        push ds
        mov cx,64000
        shr cx,2
        mov es,bufscr
        mov ax,$a000
        mov ds,ax
        xor di,di
        db 66h; xor bx,bx
   @gg:
        db 66h; mov ax,es:[di]
        db 66h; mov es:[di],bx
        db 66h; mov ds:[di],ax
        add di,4
        dec cx
        jnz @gg
        pop ds
   end;

   procedure dibu3d;
   var dibuja:boolean;
   begin
      for c:=0 to nstars do begin
        cx:=coorx[c];
        cy:=coory[c];
        cz:=coorz[c]+256;
        dec(coorz[c]);

        if cz<>0 then
        begin
           x:=160+cx shl 8 div cz;
           y:=100+cy shl 8 div cz;
        end else begin
           x:=160+cx shl 8;
           y:=100+cy shl 8;
        end;

        dibuja:=false;
        if ((y<200) and (y>-1) and (x<320) and (x>-1)) then  dibuja:=true;

      if dibuja then mem[bufscr:y*320+x]:=255-(coorz[c]+400) shr 1
        else
        if ((coorz[c]<-400) or (not dibuja)) then begin
           case tipo of
               0: begin
           coorx[c]:=random(200)-100;
           coory[c]:=random(200)-100;
           coorz[c]:=random(100);
                  end;
               1: begin
           angle:=random(360);
           coorx[c]:=seno[angle] shr 3;
           coory[c]:=coseno[angle] shr 3;
           coorz[c]:=random(100);
                  end;
                2: begin
            inc(angle,2);if angle>360 then dec(angle,360);
           coorx[c]:=seno[angle] shr 3;
           coory[c]:=coseno[angle] shr 3;
           coorz[c]:=random(100);
                   end;
                3: begin
            inc(angle,2);if angle>360 then dec(angle,360);
           coorx[c]:=seno[angle] shr 3;
           coory[c]:=coseno[angle] shr 3;
           coorz[c]:=random(20)+80;
                   end;
                4: begin
            dec(angle,2);if angle<0 then inc(angle,360);
           coorx[c]:=seno[angle] shr 3;
           coory[c]:=coseno[angle] shr 3;
           coorz[c]:=random(20)+80;
                   end;
                5: begin
                y:=(random(20)+20);
                x:=(random(20)+20);
                if (random(2))=1 then x:=-x;
                if (random(2))=1 then y:=-y;
           coorx[c]:=x;
           coory[c]:=y;
           coorz[c]:=random(20)+80;
                   end;
                6: begin
                y:=(random(80)-40);
                x:=(random(20)+20);
                if (random(2))=1 then x:=-x;
           coorx[c]:=x;
           coory[c]:=y;
           coorz[c]:=random(20)+80;
                   end;
                7: begin
           coorx[c]:=random(200)-100;
           coory[c]:=random(200)-100;
           coorz[c]:=random(100);
                   end;
           end;
        end;
      end;
   end;

procedure dibuja;
var dibuja:boolean;
begin
      for c:=0 to nstars do begin
        cx:=tcoorx[c];
        cy:=tcoory[c];
        cz:=tcoorz[c]+256;

        if cz<>0 then
        begin
           x:=160+cx shl 8 div cz;
           y:=100+cy shl 8 div cz;
        end else begin
           x:=160+cx shl 8;
           y:=100+cy shl 8;
        end;

        dibuja:=false;
        if ((y<200) and (y>-1) and (x<320) and (x>-1)) then  dibuja:=true;

      if dibuja then mem[bufscr:y*320+x]:=255-(tcoorz[c]+400) shr 1
     end;
end;
   procedure low;assembler;
   asm
      push ds
      mov es,bufscr
      xor di,di
      mov cx,64000
@ff:
      mov al,es:[di]
{      or al,al
      jz @sf
      dec al}
      shr al,1
      mov es:[di],al
@sf:
      add di,1
      dec cx
      jnz @ff


      pop ds
   end;

   procedure setp(color,red,green,blue:byte);
   begin
        port[$3c8]:=color;
        port[$3c9]:=red;
        port[$3c9]:=green;
        port[$3c9]:=blue;
   end;
{--------------------------------------------------------------------}
   begin
   getmem(bufscrptr,65000);
   bufscr:=seg(bufscrptr^);
   fillchar(bufscrptr^,65000,0);
   randomize;
   for x:=0 to 370 do seno[x]:=round(sin(x*3.1416/180)*256);
   for x:=0 to 370 do coseno[x]:=round(cos(x*3.1416/180)*256);
   asm
      mov ax,13h
      int 10h
   end;

   for x:=0 to 255 do setp(x,x shr 2,x shr 2,x shr 2);
   for y:=0 to 10 do for x:=0 to 255 do mem[$a000:y*320+x]:=x;


   for x:=0 to nstars do begin
       coorx[x]:=random(200)-100;
       coory[x]:=random(200)-100;
       coorz[x]:=random(100);
   end;
   angle:=60;

   for pp:=0 to 7 do
   for pp2:=0 to 500 do begin
   tipo:=pp;
   dibu3d;
   refresh;
   end;

   for x:=0 to 260 do seno[x]:=round(sin(x*3.1416/128)*256);
   for x:=0 to 260 do coseno[x]:=round(cos(x*3.1416/128)*256);

     for c:=0 to nstars do begin
         y:=random(x div 10)+ x div 30+ 7;
       tcoorx[c]:=(coseno[c and 255]*y)div 256;
       tcoory[c]:=c div 10 - 60;
       tcoorz[c]:=((seno[c and 255]*y)div 256);
     end;

   for c:=0 to nstars do begin
       difx[c]:=round(((tcoorx[c]-coorx[c])/ 100)*128);
       dify[c]:=round(((tcoory[c]-coory[c])/ 100)*128);
       difz[c]:=round(((tcoorz[c]-coorz[c])/ 100)*128);
   end;

   for pp:=0 to 100 do begin
     for c:=0 to nstars do begin
       tcoorx[c]:=coorx[c]+(difx[c]*pp)div 128;
       tcoory[c]:=coory[c]+(dify[c]*pp)div 128;
       tcoorz[c]:=coorz[c]+(difz[c]*pp)div 128;
     end;
     dibuja;
     refresh;
     delay(5);
   end;

   delay(200);

   for pp:=0 to 200 do begin
     for c:=0 to nstars do begin
       dec(tcoorz[c]);
     end;
     dibuja;
     refresh;
     delay(5);
   end;

   fillchar(bufscrptr^,65000,255);
   movedw(bufscr,$a000);
   for y:=0 to 63 do
       begin
       retrace;
       setp(255,63-y,63-y,63-y);
       delay(10);
       end;

   asm
      mov ax,3h
      int 10h
   end;
   freemem(bufscrptr,65000);
   writeln('A Fast Code Intro by Lord Matrix at Queimada Party `96...');
   writeln('Thanks to Fog, Geiger, Black Sound, Fly, The Vaw and Tyxop.');
   writeln('Greets to the cool people at Queimada Party and R34.DEMOS');
   end.
{--------------------------------------------------------------------}