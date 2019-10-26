{$A+,B-,D-,E+,F-,G+,I+,L-,N-,O-,P-,Q-,R-,S+,T-,V+,X+}
{$M 16384,0,655360}
{ BUILD IT MUDDAFUKKOR! ;) }

uses mods;

const
    Screen_X  = 640; Screen_Y = 350;
    logo      : string = '#7DF';

type
    TScreen   = array [0..0] of byte;
    PScreen   = ^TScreen;

    TScroll   = array [0..1023] of byte;
    PScroll   = ^TScroll;
var
    Screen               : PScreen;
    Textbuf              : PScroll;
    a                    : char;
    frame, i, scrollpos  : word;
    sinoff               : integer;

{ crt unit replacement ;) }
function keypressed : boolean; assembler; asm
    xor  bx, bx
    mov  ax, 0100h
    int  16h
    jnz  @yes
    mov  ax, 0
    jmp  @done
    @yes:
    mov  ax, 1
    @done:
end;

function readkey   : char; assembler; asm
    xor  ax, ax
    int  16h
end;

procedure Scroll; external;
{$l scroll.obj}
{$I sintab.inc}
{$I snow.pas}
{$I scroll.pas}

procedure AllocateMem;
begin
    new(Snow); fillchar(Snow^, sizeof(TSnow), 0);
    new(textbuf); move(@Scroll^, textbuf^, 1024);
end;

procedure DeAllocateMem;
begin
    dispose(Snow);
    dispose(textbuf);
end;

procedure PrintBigLetters(x, y : integer; char : byte; Font : PFont8x8; Screen : PScreen);
var
    rx, c, scrptr, fontptr, i, ax, ay : word;
    a, b, dumb                        : byte;
    k                                 : byte;
begin
    fontptr := char shl 3;
    for ay := 0 to 7 do begin
        a := Font^[fontptr]; inc(fontptr);
        for ax := 0 to 7 do begin
            k := (a shl ax) and $80;
            if k = $80 then PrintChar(x + (ax shl 3), y + (ay shl 3), 219, Font, Screen);
        end;
    end;
end;

var
    ch : char;
    s  : string;
begin

    writeln('sorry for using modobj... i want to sleep....');
    writeln;
    writeln('select your buzzing device:');
    writeln('0 - PC squeaker');
    writeln('1 - LPT D\A converter');
    writeln('2 - Sound Blaster');
    writeln('3 - no sound (boring...)');
    repeat until keypressed; ch := readkey;
    case ch of
        '0' : device := dvSpeaker;
        '2' : device := dvSBlaster;
        '3' : device := dvNoSound;
        '1' : begin
                  writeln;
                  writeln('select type of your D\A converter:');
                  writeln('1 - D\A converter on LPT1');
                  writeln('2 - D\A converter on LPT2');
                  writeln('3 - D\A converter on LPT3');
                  writeln('4 - D\A converters on LPT1\LPT2 (stereo)');
                  writeln('5 - D\A converters on LPT1\LPT2 (mono)');
                  writeln('6 - Stereo-in-1');
                  writeln('7 - Disney Sound Source on LPT1');
                  writeln('8 - Disney Sound Source on LPT2');
                  writeln('9 - Disney Sound Source on LPT3');
                  repeat until keypressed; ch := readkey;
                  case ch of
                      '1' : device := dvDacLPT1;
                      '2' : device := dvDacLPT2;
                      '3' : device := dvDacLPT3;
                      '4' : device := dvDacLPTs;
                      '5' : device := dvDacLPTm;
                      '6' : device := dvStereoIn1;
                      '7' : device := dvDSSLPT1;
                      '8' : device := dvDSSLPT2;
                      '9' : device := dvDSSLPT3;
                  end;
              end;
    end;
    writeln;
    write('enter mixing rate in Hz: '); readln(s);
    val(s, i, frame);
    if frame <> 0 then device := dvNoSound else MixSpeed := i;

    Screen := ptr(SegA000, 0);
    Font8x8 := Get8x8Font;
    PlayMod('7DF.MOD');
    AllocateMem;

    asm
        mov  ax, 10h
        int  10h
    end;

    Randomize;

    FillFlakes(Snow);

    repeat
        repeat until port[$3DA] and 8 = 8;                                    {
        port[$3c8] := 0; port[$3c9] := 16; port[$3c9] := 16; port[$3c9] := 16;}
        EraseFlakes(Screen, Snow);

        asm
            les  di, Screen;
            mov  di, 150 * 80
            mov  cx, 64 * 40
            xor  ax, ax
            rep  stosw
        end;

        asm
            les  di, Screen;
            mov  di, 342 * 80
            mov  cx, 8 * 40
            xor  ax, ax
            rep  stosw
        end;

        portw[$3CE] := $1003;
        AdjustFlakes(Snow);
        PlotFlakes(Screen, Snow);

        for i := 0 to 3 do begin
            portw[$3C4] := $0202;
            sinoff := (Screen_x - 384) shr 1 + (sintab[(frame + 128) and 255]);
            PrintBigLetters(sinoff + (i shl 6), 150, ord(logo[i+1]), Font8x8, Screen);

            portw[$3C4] := $0402;
            sinoff := (Screen_x - 128) shr 1 + (sintab[frame and 255]);
            PrintBigLetters(sinoff + (i shl 6), 150, ord(logo[i+1]), Font8x8, Screen);
        end;

        portw[$3C4] := $0F02;
        ScrollLine(ScrollPos, Font8x8, Screen);

{        port[$3c8] := 0; port[$3c9] := 0; port[$3c9] := 0; port[$3c9] := 0;}
        inc(frame); inc(ScrollPos, ScrollSpeed);
        repeat until port[$3DA] and 8 <> 8;
    until keypressed; readkey;

    asm
        mov  ax, 3h
        int  10h
    end;
    StopMod;
    DeAllocateMem;
    writeln('hny scene! ;)');
end.
