const
    SinAmp       = 16;
    ScrollY      = Screen_y - 8;
    ScrollSpeed  = 2;

type
    TFont8x8     = array [0..0] of byte;
    PFont8x8     = ^TFont8x8;

var
    Font8x8      : PFont8x8;

function Get8x8Font : pointer; assembler; asm
    push bp
    mov  ax, 1130h
    mov  bx, 0300h

    int  10h

    mov  ax, bp
    mov  dx, es

    pop  bp
end;

procedure PrintChar(x, y : integer; char : word; Font : PFont8x8; Screen : PScreen);
var

    rx, c, scrptr, fontptr, i : word;
    a, b, dumb                : byte;
begin
    { logical OR with latches }
    {
    rx := x shr 3; c := x and 7;
    fontptr := char shl 3;
    scrptr  := (y shl 6) + (y shl 4) + rx;
    for i := 0 to 7 do begin
        rx := Font^[fontptr] shl (8 - c);
        a := hi(rx); b := lo(rx);
        dumb := Screen^[scrptr]; Screen^[scrptr] := a;
        inc(scrptr);
        dumb := Screen^[scrptr]; Screen^[scrptr] := b;
        inc(scrptr, 79); inc(fontptr);
    end;}
    asm
        push ds

        mov  ax, SegA000
        mov  es, ax

        mov  ax, [x]
        shr  ax, 3
        mov  bx, [y]
        mov  di, bx
        shl  bx, 6
        shl  di, 4
        add  di, bx
        add  di, ax

        lds  si, Font

        mov  ax, [char]
        shl  ax, 3
        add  si, ax

        mov  ax, [x]
        and  ax, 7
        mov  bl, 8
        sub  bl, al

        { BL - shift counter }

        mov  cx, 8

        @loop:
        push cx
        mov  cl, bl
        xor  ax, ax
        lodsb
        shl  ax, cl

        mov  bh, byte ptr [es:di]
        xchg al, ah
        stosb

        mov  bh, byte ptr [es:di]
        xchg al, ah
        stosb

        add  di, 78
        pop  cx
        loop @loop

        pop  ds
    end;
end;

procedure ScrollLine(ax : word; Font : PFont8x8; Screen : PScreen);
var
    x, n, i, c : integer;
begin
    n := 0;
    c := ax shr 3; x := ax and 7;
    for i := 0 to 79 do begin
        PrintChar((i shl 3) - x, ScrollY, textbuf^[(i + c) and 1023], Font, Screen);
    end;
end;
