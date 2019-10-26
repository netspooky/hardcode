{
      3D flatshaded tunnel

      By Peter Gordon
      (pete@shagged.org)

      Written in a dull afternoon spent
      at my parents house (hence for DOS
      and not Amiga :)

      Enjoy!
}

uses crt;

{ Types for double buffering variables }
type
  Virtualscreen = Array[1..64000] of byte;
  Virscr = ^VirtualScreen;

const TPOLYS = 11;             { Number of polygon rings to draw }
                               { Reduce this to make the horizon nearer }
                               { (for slow computers) }
      TSPACE = 32;             { Z-axis space between polygon rings }
      TANG   = 0.78539816339;  { Angle between polygon rings (octagons) }
                               { If you want something other than       }
                               { octagons, change the draw_tunnel loop  }
                               { accordingly and recalculate this. The  }
                               { formula is:                            }
                               {   TANG = (2*pi)/NUM_OF_EDGES           }
      TSIZE  = 20;             { Size of the tunnel }
                               { (don't go smaller than 16) }
      TWIST  = 0.2;            { Twistyness }
      SPIN   = -0.04;          { Spinning tunnel speed }
                               { Spinning it really fast (-1.83) looks }
                               { cool :) }
      CAMSPEED = 4;            { The speed at which we fly }
                               { TSPACE must be a multiple of CAMSPEED }
                               { unless you want jerky camera movement }
                               { Cant be negative; the tunnel will     }
                               { disappear into the distance :)        }

      XMAX  = 50;              { Amount that the tunnel "sways" left/right }
      YMAX  = 50;              { Amount that the tunnel "sways" up/down }
      PPREC = 12;              { Fixed point math precision (32-PPREC).PPREC }

var zpos:array[0..TPOLYS] of integer; { Z positions of all tunnel segments }
                                      { This is ALWAYS depth sorted }
    xoff:array[0..TPOLYS] of longint; { X positions of all tunnel segments }
    yoff:array[0..TPOLYS] of longint; { Y positions of all tunnel segments }
    ang:array[0..TPOLYS] of real;     { Angle of all tunnel segments }
    px:array[0..2] of longint;        { Dumb way to pass vars to the poly- }
    py:array[0..2] of longint;        { filling routine }
    sprc:longint;                     { basically gets set to 1<<PPREC }

    camx,camy,camxd,camyd:longint;    { Camera position and deltas }
    spina:real;                       { Current angle of spin for tunnel }

    scr2 : virscr;             { Double buffering vars }
    vaddr : word;

var nang:real;                 { Angles and offsets for the next }
    nxo:real;                  { tunnel segment to appear on the }
    nyo:real;                  { horizon }

{ Waits for vertical retrace }
{ Thanks to "Telemachos" for the routine }
PROCEDURE WaitRetrace;
Assembler;
label l1,l2;

asm
 mov dx,3DAh
l1:
  in al,dx
  and al,08h
  jnz l1
l2:
  in al,dx
  and al,08h
  jz l2
END;

{ Flips buffers (actually just copies...) }
{ once again, thanks "Telemachos" }
Procedure FlipScreen(source, dest : word);
Assembler; {386 only}
asm
  mov     dx, ds
  mov     ax, [dest]
  mov     es, ax
  mov     ax, [source]
  mov     ds, ax
  xor     si, si
  xor     di, di
  mov     cx, 16000
  db      $66
  rep     movsw
  mov     ds,dx    {mov's are faster than push / pops }
end;

{ Clear a 320x200 byte buffer }
{ (thanks Telemachos :) }
Procedure Clear (Col : Byte;where:word); Assembler;
asm
  mov     cx, 32000;
  mov     ax,where
  mov     es,ax
  xor     di,di
  mov     al,[col]
  mov     ah,al
  rep     stosw
END;

{ Set up double buffering }
{ (thanks Telemachos) }
PROCEDURE SetUpVirtual(VAR screenname:virscr;VAR add : word);
BEGIN
  GetMem (Screenname,64000);
  add := seg (Screenname^);
  clear(0,add);
END;

{ and shut it down... }
PROCEDURE ShutDown(Screenname:virscr);
BEGIN
  FreeMem (Screenname,64000);
END;

{ Initialise tunnel variables }
{ (this calculates a tunnel to draw for the first }
{ TSPACE frames }
procedure init_tunnel;
var n:integer;
begin
  nang := 0;
  nxo  := 0;
  nyo  := 0;
  for n := TPOLYS downto 0 do
  begin
    zpos[ n ] := ( TPOLYS-n ) * TSPACE;      { Fill in z positions }
    xoff[ n ] := round( sin( nxo ) * XMAX ); { Sway left/right }
    yoff[ n ] := round( cos( nyo ) * YMAX ); { Sway up/down }
    ang[ n ] := nang;                        { Rotate the tunnel }
    nang := nang + TWIST;
    nxo  := nxo  + 0.2;
    nyo  := nyo  + 0.25;
  end;

  { Calculate the camera start position }
  { (make sure we're inside the tunnel) }
  camx := xoff[TPOLYS] shl 8;
  camy := yoff[TPOLYS] shl 8;

  { Calculate the deltas for the camera }
  { (this is so it can smoothly follow the tunnel) }
  camxd := ((xoff[TPOLYS-1] shl 8) - camx) div (TSPACE div CAMSPEED);
  camyd := ((yoff[TPOLYS-1] shl 8) - camy) div (TSPACE div CAMSPEED);

  spina := 0;

end;

{ Display a horizontal line of solid colour }
{ very quickly. Thanks again to "Telemachos" for this }
Procedure HorLine(Xbegin, Xend,Ypos : integer;color : byte;where : word);
Assembler;
asm
 mov cx,[Xend]
 inc cx
 sub cx,[Xbegin]   {cx = length of line - used for counter }
                   {note, I assume that Xbegin < Xend - the poly routine}
                   {will take care of that...}
 mov ax,[ypos]
 shl ax,8
 mov di,ax
 shr ax,2
 add di,ax
 add di,[Xbegin]   {di = Ypos * 320 + Xbegin - offset for our line}
 mov es,[where]    {where to draw..}

 mov al,[color]
 rep stosb         {I draw byte by byte - slower than drawing a word at a}
                   {time but it is because of the changes we are going to}
                   {make to this routine when glenzing/gouraud/texturemapping}
end;

{ My ultra-lame polygon filler }
procedure fillpoly( col:integer; where:word );
var p1,p2,p3,t:integer;
    cx1,cx2,cy,dx1,dx2,ty:longint;
    dcx1,dcx2:longint;

label p3long, p2long;

begin
  { Make sure we're not asked to draw a flat poly }
  if( py[0] = py[1] ) and ( py[0] = py[2] ) then exit;
  if( px[0] = px[1] ) and ( px[0] = px[2] ) then exit;

  { Don't even need to calculate these }
  if(( px[0] < 0 ) and ( px[1] < 0 ) and (px[2] < 0 )) then exit;
  if(( px[0] > 319 ) and ( px[1] > 319 ) and (px[2] > 319 )) then exit;

  p1 := 0;
  p2 := 1;
  p3 := 2;

  { First we need to sort the polygon coordinates }
  { so that p1 <= p2 <= p3. The reason we passed  }
  { an array of coordinates instead of just the   }
  { actual screen coords is that we can swap the  }
  { order by chaging the index variables instead  }
  { of having to swap x AND y for every swap      }

  if( py[p1] > py[p2] ) then
  begin
    p1 := 1;
    p2 := 0;
  end;

  { now py[p1] <= py[p2] }
  if( py[p2] > py[p3] ) then
  begin
    p3 := p2;
    p2 := 2;
  end;

  { now py[p1] <= py[p2] and py[p2] <= py[p3] }
  { but p2 might have just been swapped, so }
  { py[p1] could NOW be > py[p2] }
  if( py[p1] > py[p2] ) then
  begin
    t  := p1;
    p1 := p2;
    p2 := t;
  end;

  { Don't even need to calculate these }
  if( py[p1] > 199 ) then exit;
  if( py[p3] < 0 ) then exit;

  { Now we draw all the scanlines from py[p1]    }
  { to py[p2] (provided that they are not equal. }

  { is there a first section to draw? }
  if( py[p2] > py[p1] ) then
  begin
    cx1 := px[p1] shl PPREC;  { left x counter }
    cx2 := cx1;               { right x counter }
    cy  := py[p1];            { y counter }

    { Yes, so draw it. Calculate if left or right side is longest }

    { special cases }
    if(( px[p1] > px[p2] ) and ( px[p1] > px[p3] )) then
    begin

      dx1 := ((px[p2] shl PPREC) - cx1 ) div (py[p2]-cy); { left delta }
      dx2 := ((px[p3] shl PPREC) - cx1 ) div (py[p3]-cy); { right delta }

      if( dx1 < dx2 ) then goto p3long;

      { Already calced, so just swap them }
      dcx1 := dx1;
      dx1  := dx2;
      dx2  := dcx1;

      goto p2long;
    end;

    if(( px[p1] < px[p2] ) and ( px[p1] < px[p3] )) then
    begin

      dx1 := ((px[p2] shl PPREC) - cx1 ) div (py[p2]-cy); { left delta }
      dx2 := ((px[p3] shl PPREC) - cx1 ) div (py[p3]-cy); { right delta }

      if( dx1 < dx2 ) then goto p3long;

      { Already calced, so just swap them }
      dcx1 := dx1;
      dx1  := dx2;
      dx2  := dcx1;

      goto p2long;
    end;

    if( px[p2] < px[p3] ) then
    begin

      { right side is longest, calculate delta }
      dx1 := ((px[p2] shl PPREC) - cx1 ) div (py[p2]-cy); { left delta }
      dx2 := ((px[p3] shl PPREC) - cx1 ) div (py[p3]-cy); { right delta }

p3long:

      { Skip anything off the top of the screen (if possible) }
      if( cy < 0 ) then
      begin
        if ( py[p2] >= 0 ) then
        begin
          cx1 := cx1 + (dx1*-cy);
          cx2 := cx2 + (dx2*-cy);
          cy := 0;
        end else begin
          cx1 := cx1 + (dx1*(py[p2]-cy));
          cx2 := cx2 + (dx2*(py[p2]-cy));
          cy := py[p2];
        end;
      end;

      { Skip anything off the bottom of the screen }
      if( py[p2] > 200 ) then
      begin
        py[p2] := 200;
        py[p3] := 200;
      end;

      while( cy < py[p2] ) do
      begin
        if( cy>= 0 ) then
        begin
          dcx1 := cx1 div sprc;
          dcx2 := cx2 div sprc;
          if(( dcx1 < 0 ) and ( dcx2 < 0 ) = false ) then
          begin
            if(( dcx1 > 319 ) and ( dcx2 > 319 ) = false ) then
            begin
              if( dcx1 < 0 )   then dcx1 := 0;
              if( dcx1 > 319 ) then dcx1 := 319;
              if( dcx2 < 0 )   then dcx2 := 0;
              if( dcx2 > 319 ) then dcx2 := 319;
              HorLine( dcx1, dcx2, cy, col, where );
            end;
          end;
        end;
        cx1 := cx1 + dx1;
        cx2 := cx2 + dx2;
        Inc( cy );
      end;

      { now recalculate dx1, if there is a second part }
      if( py[p3] > cy ) then
      begin
        cx1 := px[p2] shl PPREC;
        dx1 := ((px[p3] shl PPREC) - cx1 ) div (py[p3]-cy);
      end;

    end else begin

      { left side is longest, or there is no second part }
      dx1 := ((px[p3] shl PPREC) - cx1 ) div (py[p3]-cy); { left delta }
      dx2 := ((px[p2] shl PPREC) - cx1 ) div (py[p2]-cy); { right delta }

p2long:
      { Skip anything off the top of the screen (if possible) }
      if( cy < 0 ) then
      begin
        if ( py[p2] >= 0 ) then
        begin
          cx1 := cx1 + (dx1*-cy);
          cx2 := cx2 + (dx2*-cy);
          cy := 0;
        end else begin
          cx1 := cx1 + (dx1*(py[p2]-cy));
          cx2 := cx2 + (dx2*(py[p2]-cy));
          cy := py[p2];
        end;
      end;

      { Skip anything off the bottom of the screen }
      if( py[p2] > 200 ) then
      begin
        py[p2] := 200;
        py[p3] := 200;
      end;

      while( cy < py[p2] ) do
      begin
        if( cy >= 0 ) then
        begin
          dcx1 := cx1 div sprc;
          dcx2 := cx2 div sprc;
          if(( dcx1 < 0 ) and ( dcx2 < 0 ) = false ) then
          begin
            if(( dcx1 > 319 ) and ( dcx2 > 319 ) = false ) then
            begin
              if( dcx1 < 0 )   then dcx1 := 0;
              if( dcx1 > 319 ) then dcx1 := 319;
              if( dcx2 < 0 )   then dcx2 := 0;
              if( dcx2 > 319 ) then dcx2 := 319;
              HorLine( dcx1, dcx2, cy, col, where );
            end;
          end;
        end;
        cx1 := cx1 + dx1;
        cx2 := cx2 + dx2;
        Inc( cy );
      end;

      { now recalculate dx2, if there is a second part }
      if( py[p3] > cy ) then
      begin
        cx2 := px[p2] shl PPREC;
        dx2 := ((px[p3] shl PPREC) - cx2 ) div (py[p3]-cy);
      end;

    end;

  end else begin
    { No, its 0 pixels high, so initialise counters for second part }
    { if there is one... }
    if( py[p3] > py[p2] ) then
    begin
      if( px[p1] < px[p2] ) then
      begin
        cx1 := px[p1] shl PPREC;
        cx2 := px[p2] shl PPREC;
        dx1 := ((px[p3] shl PPREC) - cx1) div (py[p3]-py[p1]);
        dx2 := ((px[p3] shl PPREC) - cx2) div (py[p3]-py[p2]);
      end else begin
        cx1 := px[p2] shl PPREC;
        cx2 := px[p1] shl PPREC;
        dx1 := ((px[p3] shl PPREC) - cx1) div (py[p3]-py[p2]);
        dx2 := ((px[p3] shl PPREC) - cx2) div (py[p3]-py[p1]);
      end;
      cy := py[p1];
    end else begin
      cy := py[p3];
    end;
  end;

  { clip it now rather than check in a loop }
  if( cy > 199 ) then exit;

  { Skip anything off the top of the screen }
  if( cy < 0 ) then
  begin
    cx1 := cx1 + (dx1*-cy);
    cx2 := cx2 + (dx2*-cy);
    cy := 0;
  end;

  if( py[p3] > 200 ) then py[p3] := 200;

  { draw second part }
  while( cy < py[p3] ) do
  begin
    dcx1 := cx1 div sprc;
    dcx2 := cx2 div sprc;
    if(( dcx1 < 0 ) and ( dcx2 < 0 ) = false ) then
    begin
      if(( dcx1 > 319 ) and ( dcx2 > 319 ) = false ) then
      begin
        if( dcx1 < 0 )   then dcx1 := 0;
        if( dcx1 > 319 ) then dcx1 := 319;
        if( dcx2 < 0 )   then dcx2 := 0;
        if( dcx2 > 319 ) then dcx2 := 319;
        HorLine( dcx1, dcx2, cy, col, where );
      end;
    end;
    cx1 := cx1 + dx1;
    cx2 := cx2 + dx2;
    Inc( cy );
  end;
end;

{ This is where we actually calculate and draw the tunnel }
procedure draw_tunnel( where:word );
var n,i,ln,c:integer;
    tmpa,tmps:real;
    x,y,z,x2,y2:array[0..7] of longint;

begin

  { each section of the tunnel needs 16 vertices  }
  { to connect and make polygons. (8 vertices per }
  { "loop", 2 loops to join with polygons). Since }
  { each loop joins to the previous one, we can   }
  { re-use calculated vertices as we go down the  }
  { tunnel.                                       }

  for n := 0 to TPOLYS do
  begin

    { Copy the source vertices from the previous }
    { loop to the destination ones for this loop }
    x2 := x;
    y2 := y;

    { If the vertices are infront of the camera }
    { (z>0), calculate them as normal           }
    if( zpos[n] > 0 ) then
    begin

      { Get the source angle for this loop }
      tmpa := ang[n] + spina;

      { Octagonal loop, so 8 vertices to calculate }
      for i := 0 to 7 do
      begin

        { Calculate one vertice }
        x[i] := ( round( sin( tmpa ) * TSIZE + xoff[n]) shl 8 - camx) div zpos[n] + 160;
        y[i] := ( round( cos( tmpa ) * TSIZE + yoff[n]) shl 8 - camy) div zpos[n] + 100;

        { Angle offset for next vertice }
        tmpa := tmpa + TANG;
      end;
    end else begin

      { This loop is behind the camera, but part of it  }
      { might be visible. We can't calculate vertices   }
      { behind us (the standard n*k/z 3d->2d calcs fail }
      { when z is <0), we have to calculate the points  }
      { where the polygons pass the plane at z=1        }

      { Calculate the amount to scale values by }
      tmps := (zpos[n-1]-1)/TSPACE;
          { zpos[n-1]-1 = distance from last vertices to the plane at z=1 }
          { zpos[n-1]-TSPACE = distance to poly behind camera }
          { so.... }
          { (zpos[n-1]-1)/TSPACE = scaler amount }

      { Calculate the angle at the plane of intersection }
      tmpa := ang[n-1] + (ang[n]-ang[n-1])*tmps + spina;

      { (since the tunnel sections are always perpendicular to the }
      { camera, we never have to recalculate x or y, so thats it!  }

      for i := 0 to 7 do
      begin

        { This is exactly the same as above, but since we know }
        { that z=1, we don't have to do any division! Hurrah!  }
        x[i] := ( round( sin( tmpa ) * TSIZE + xoff[n]) shl 8 - camx) + 160;
        y[i] := ( round( cos( tmpa ) * TSIZE + yoff[n]) shl 8 - camy) + 100;
        tmpa := tmpa + TANG;
      end;
    end;

    { Don't draw on the first loop, since we've only }
    { calculated one of the two sets of vertices     }
    if( n > 0 ) then
    begin;

      { Get a value from 1 to 63 for our depthshading }
      c := 63-(zpos[n] div 5);
      if( c<1 ) then c:=1;
      if( c>63 ) then c:=63;

      { Draw filled polygons }
      for i := 0 to 7 do
      begin

        ln := (i+1) and 7; { ln = the next vertice around the loop }

        px[0] := x[i];
        py[0] := y[i];
        px[1] := x2[i];
        py[1] := y2[i];
        px[2] := x2[ln];
        py[2] := y2[ln];
        fillpoly( c+(i*128), Vaddr );

        px[0] := x[i];
        py[0] := y[i];
        px[1] := x[ln];
        py[1] := y[ln];
        px[2] := x2[ln];
        py[2] := y2[ln];
        fillpoly( c+64+(i*128), Vaddr );
      end;
    end;

    { Move this loop towards the camera }
    zpos[n] := zpos[n] - CAMSPEED;
  end;

  { Make the camera follow the tunnel }
  camx := camx + camxd;
  camy := camy + camyd;

  { If the tunnel was wireframe or otherwise  }
  { see-through, we could simply check in the }
  { loop above to see if any tunnel sections  }
  { had gone behind the camera, and just put  }
  { it infront of us. Since this is a filled  }
  { tunnel, we need to keep our z-array depth }
  { sorted, so we have to shuffle it along    }
  { and recalculate the furthest one          }
  if( zpos[TPOLYS-1] <= 0 ) then
  begin

    { part of the tunnel has gone behind us, so }
    { shuffle all the arrays along one, and     }
    { recalculate the furthest away part.       }

    for n := TPOLYS downto 1 do
    begin
      zpos[n] := zpos[n-1];  { shuffly shuffly }
      xoff[n] := xoff[n-1];
      yoff[n] := yoff[n-1];
      ang[n]  := ang[n-1];
    end;

    zpos[0] := TSPACE*TPOLYS;               { Z position set to the horizon }
    xoff[0] := round( sin( nxo ) * XMAX );  { Next X and Y positions }
    yoff[0] := round( cos( nyo ) * YMAX );
    ang[0]  := nang;                        { Next angle }

    { Figure out where the camera has to go }
    camxd := ((xoff[TPOLYS-1] shl 8) - camx) div (TSPACE div CAMSPEED);
    camyd := ((yoff[TPOLYS-1] shl 8) - camy) div (TSPACE div CAMSPEED);

    { Calculate the values for the next time this happens }
    nang := nang + TWIST;
    nxo  := nxo  + 0.2;
    nyo  := nyo  + 0.25;
  end;

end;

var my:integer;
begin
  { precalculate our division ratio }
  { this is because there is no arithmetic shift right }
  { in Borland Turbo Pascal, so we have to use div }
  { on signed numbers (sigh) }
  sprc := 1 shl PPREC;

  { Enter 320x200 mode }
  asm
    mov ax,13h;
    int 10h;
  end;

  { Set up a nice pastel shade palette }
  { 4 colours each with 63 shades }
  { (allows us 4 colours + depth shading }
  for my:=0 to 63 do
  begin
    port[$3c8]:=my;
    port[$3c9]:=my;
    port[$3c9]:=my;
    port[$3c9]:=my;
    port[$3c8]:=my+64;
    port[$3c9]:=my;
    port[$3c9]:=my;
    port[$3c9]:=(my shr 1)+(my shr 2);
    port[$3c8]:=my+128;
    port[$3c9]:=(my shr 1)+(my shr 2);
    port[$3c9]:=my;
    port[$3c9]:=my;
    port[$3c8]:=my+192;
    port[$3c9]:=my;
    port[$3c9]:=(my shr 1)+(my shr 2);
    port[$3c9]:=my;
  end;

  { Set up our virtual screen }
  { (thanks to "Telemachos" for the double buffering routines }
  SetupVirtual(scr2,vaddr);
  Clear(0,$a000);

  { Set up the tunnel variables }
  init_tunnel;

  { Looooop }
  repeat
    clear(0,Vaddr);              { Wipe the old frame }
    draw_tunnel(Vaddr);          { Draw the new one }
    spina := spina + SPIN;       { Spin the tunnel! }
    WaitRetrace;
    FlipScreen( Vaddr, $a000 );  { Not really a flip; just a copy }
  until keypressed;

  readkey; { swallow the key event }

  { Back to DOS text }
  asm
    mov ax,3;
    int 10h;
  end;
end.
