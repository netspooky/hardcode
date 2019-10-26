Uses Crt,OpGr;   {Demo program by OP Software Studio  1995.09.09.   16:31}

Const

   palrot_speed = 5;

   X            : Word = 0;
   Y            : Word = 0;
   palx         : integer = palrot_speed;

Var Pal                       : Array[0..767] of byte;
    RGBr                      : Array[0..2] of byte;
    xx,j,i,l                  : integer;
    r,g,b,aa,bb,cc            : byte;
    colors                    : Array[0..764] of byte;
    xi,yi,dx,dy               : integer;
    kep                       : array[1..25,1..80,1..2] of char absolute $b800:0;

Procedure Palanim;
Begin
  move(Pal,RGBr,3);
  move(Pal[3],Pal,759);
  move(RGBr,Pal[759],3);
  asm
    cld
    mov  dx,03c8h
    mov  al,1
    out  dx,al
    lea  si,Pal
    mov  cx,253*3
    inc  dx
    rep outsb
  end;
End;

Procedure ShowPal; Assembler;
Asm
  mov  bx,X
  mov  cl,bl
  shr  bx,2
  mov  ax,160
  mul  Y
  add  bx,ax
  mov  dx,03d4h
  mov  al,0ch
  mov  ah,bh
  out  dx,ax
  inc  al
  mov  ah,bl
  out  dx,ax
  and  cl,3
  shl  cl,1
  mov  dx,03dah
@wait:
  in   al,dx
  and  al,8
  jz   @wait
  mov  dl,0c0h
  mov  al,13h
  out  dx,al
  mov  al,cl
  out  dx,al
  mov  al,020h
  out  dx,al
  dec  palx
  jnz  @exit
  mov  palx,palrot_speed
  Call Palanim
@exit:
End;

Procedure RGBsin(l:byte);
var r,g,b:byte;
Begin
  j:=0;
  for i:=1 to l do
  Begin
    r:=32+round(30*sin(  i*pi*2/l )); pal[j]:=r;
    g:=32+round(30*cos(  i*pi*2/l )); pal[j+1]:=g;
    b:=32+round(30*sin( -i*pi*2/l )); pal[j+2]:=b;
    SetRGBreg(i,r,g,b);
    inc(j,3);
  End;
End;

Procedure Fade;
begin
  TextColor(0);
  ClrScr;
  SetRGBreg(1,0,0,0);
  TextColor(1);
  GotoXY(35,13);
  Writeln('by OP Master');
  GotoXY(1,1);
  TextColor(0);
  for i:=0 to 63 do
  begin
    Delay(20);
    SetRGBreg(1,i,i,i);
  end;
  Delay(700);
  for i:=63 downto 0 do
  begin
    Delay(20);
    SetRGBreg(1,i,i,i);
  end;
end;

Procedure Mindegy; {Ezt a rutint ¡rta : Pak¢ G‚za}
begin
  for aa:=1 to 24 do
   for bb:=24 downto 1 do
    for cc:=1 to 80 do
    begin
      if kep[bb+1,cc,1]=' ' then
      begin
        kep[bb+1,cc,1]:=kep[bb,cc,1];
        kep[bb+1,cc,2]:=kep[bb,cc,2];
        kep[bb,cc,1]:=' ';
        kep[bb,cc,2]:=#7;
      end;
    end;
end;

Begin
  Mindegy;
  Delay(500);
  asm
    mov ax,0013h
    int 10h
  end;
  RGBsin(255);
  OutStrXY(0,0,'     ');{Ett”l az utas¡t st¢l lesz a program m‚rete 10 Kbyte}
  dx:=1;
  dy:=1;
  xi:=1;
  yi:=1;
  repeat
    ShowPal;
    Box(xi,yi,xi+10,yi+10,0);
    inc(xi,dx);
    inc(yi,dy);
    if xi=309 then dx:=-dx;
    if yi=190 then dy:=-dy;
    if xi=1 then dx:=-dx;
    if yi=1 then dy:=-dy;
    Box(xi,yi,xi+10,yi+10,l-4);
    ink:=120;
    OutStrXY(90,95,'OP Software Studio');
  until keypressed;
  Box(xi,yi,xi+10,yi+10,0);
  ink:=120;
  OutStrXY(90,95,'OP Software Studio');
  for i:=0 to 90 do
  begin
    Delay(20);
    ScrollLf(90,95,180,105);
    ScrollRg(181,95,250,105);
  end;
  TextMode(3);
  Fade;
  TextMode(3);
End.