
const
    MaxFlakes = 256;
    MinSpeed  = 2;
    MaxSpeed  = 8;

type
    TSnow     = array [0..MaxFlakes-1] of record
        x, y  : integer;
        speed : byte;
    end;
    PSnow     = ^TSnow;

var
    Snow      : PSnow;

procedure PlotFlakes(Screen : PScreen; Snow : PSnow);
var
    i, scrptr, c, x : word;
    a, dumb         : byte;
begin
    portw[$3CE] := $1003;          { logical OR with latches }
    portW[$3C4] := $0F02;
    for i := 0 to MaxFlakes - 1 do begin
      { portw[$3C4] := (Snow^[i].speed and 15) shl 8 + 2; }
        c := Snow^[i].x shr 3; x := Snow^[i].x and 7;
        scrptr := (Snow^[i].y shl 6) + (Snow^[i].y shl 4) + c;
        a := $80 shr x;
        dumb := Screen^[scrptr]; Screen^[scrptr] := a;
    end;
end;

procedure EraseFlakes(Screen : PScreen; Snow : PSnow);
var
    i, scrptr, c : word;
begin
    portw[$3C4] := $0F02;          { use ALL planes! ;) }
    portw[$3CE] := $0003;          { overwrite pixel data }
    for i := 0 to MaxFlakes - 1 do begin
        c := Snow^[i].x shr 3;
        scrptr := (Snow^[i].y shl 6) + (Snow^[i].y shl 4) + c;
        Screen^[scrptr] := $00;
    end;
end;

procedure FillFlakes(Snow : PSnow);
var i : word;
begin
    for i := 0 to MaxFlakes - 1 do begin
        Snow^[i].x     := random(Screen_X);
        Snow^[i].y     := random(Screen_Y);
        Snow^[i].speed := random(MaxSpeed - MinSpeed) + MinSpeed;
    end;
end;

procedure AdjustFlakes(Snow : PSnow);
var i : word;
begin
    for i := 0 to MaxFlakes - 1 do begin
        Snow^[i].x := Snow^[i].x + (random(Snow^[i].speed or 1) - (Snow^[i].speed shr 1));
        inc(Snow^[i].y, Snow^[i].speed);
        if (Snow^[i].y > Screen_Y) then begin
            Snow^[i].x     := random(Screen_X);
            Snow^[i].y     := 0;
            Snow^[i].speed := random(MaxSpeed - MinSpeed) + MinSpeed;
        end;
    end;
end;

