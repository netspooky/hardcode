raw
%!
%#noremap Helvetica
%#noremap Helvetica-Bold
%#remap all
end

% <pageinit type="normal">
raw
<< /PageSize [640 480]
   /ImagingBBox null
>> setpagedevice
end
% </pageinit> --%

%-- <pageinit type="print">
raw
<< /PageSize [595 842]
   /ImagingBBox null
>> setpagedevice
595 dup 480 sub 2 div sub  842 640 sub 2 div translate 90 rotate
% /Helvetica findfont 8 scalefont setfont 640 -10 moveto
% (printed directly \(without any PDF conversion or stuff like that\) on a HP Color LaserJet 2550L)
% dup stringwidth pop neg 0 rmoveto show
0 0 moveto 640 0 lineto 640 480 lineto 0 480 lineto closepath clip newpath
end
% </pageinit> --%

%------------------------------------------------------------------------------%

use lib/3d.pp
use fx/sierpinski.pp
use fx/ball.pp
use fx/torus.pp
use fx/landscape.pp
use fx/wobble.pp


% <main>

% Landscape background
gsave()
  setlinewidth(0.05)
  translate(320,356)
  scale(dup(4))
  fxLandscape()
grestore()

% Torus, back part
TorusToplevel(-90,90)

% Sierpinski triangle
gsave()
  translate(38,450)
  scale(300,300)
  rotate(-80)
  fxSierpinski(7,0.28,1)
grestore()

% Torus, front part
TorusToplevel(90,270)

% AMIGA ball
gsave()
  translate(600,40)
  rotate(-17)
  scale(dup(2))
  fxBall()
grestore()

% "3D" text
function Draw3D($text)
  gsave()
    scale(1,0.5)
    rotate(-45)
    moveto(0,0)
    show($text)
  grestore()
end
% "PostScript"
setfont(findfont(/Helvetica-Bold),scalefont(32))
gsave()
  translate(82,98)
  for($i,0,0.025,0.5)
    setrgbcolor(0,0,$i)
    Draw3D("PostScript")
    translate(0,1)
  end
  setgray(1)
  Draw3D("PostScript")
grestore()
% "3D"
setfont(findfont(/Helvetica-Bold),scalefont(150))
gsave()
  translate(-8,60)
  for($i,0,0.025,0.5)
    setrgbcolor(0,0,$i)
    Draw3D("3D")
    translate(0,1)
  end
  setgray(1)
  Draw3D("3D")
grestore()

% wobbled cube
gsave()
  translate(550,390)
  setlinewidth(0.1)
  WobbleSide(/MapToTop)
  WobbleSide(/MapToSide)
  WobbleSide(/MapToFront)
grestore()

% Torus text
setfont(findfont(/Courier),scalefont(10))
setgray(0)
gsave()
  moveto(10,124)
  raw
%#symbol ramt
    /ramt 1.2 def
    { /ramt dup load 0.979 mul def ramt rotate }
    (world's first PostScript 4k "intro" +++ ) kshow
    { /ramt dup load 0.997 mul def ramt rotate }
    (containing a real \(but simple\) 3D engine ) kshow
    6 rotate
    { /ramt dup load 1.065 mul def ramt rotate }
    (+++ PostScript rocks!) kshow
  end
grestore()

% greetings
setfont(findfont(/Courier-Bold),scalefont(24))
setgray(1)
function greetings()
raw
  gsave
    606 -176 moveto 180 rotate
    { -3.82 rotate } (                     + deranged +++ moodsplateau ++) kshow
  grestore
  gsave
    606 -200 moveto 180 rotate
    { -3.45 rotate } (                       ++ mfx +++ metalvotze +++ kewlers +++) kshow
  grestore
  gsave
    606 -224 moveto 180 rotate
    { -3.1425 rotate } (                          +++ plastic +++ the black lotus +++) kshow
  grestore
end
end
gsave()
  translate(neg(dup(1.5)))
  greetings(setgray(0))
grestore()
greetings(setgray(1))

% logo
function DrawLogo($light)
  gsave()
  setfont(findfont(/Helvetica-Bold),scalefont(20))
  moveto(144,418)
  rotate(-20)
  def(/ShrinkLight,$light)
  def(/ShrinkHue,0)
  raw
    %#symbol ShrinkHue
    %#symbol ShrinkLight
    ShrinkHue 0.15 ShrinkLight sethsbcolor
    { 1.2 dup scale /ShrinkHue dup load 0.1 add def ShrinkHue 0.15 ShrinkLight sethsbcolor }
    (Post) kshow
    { 0.9 dup scale /ShrinkHue dup load 0.1 add def ShrinkHue 0.15 ShrinkLight sethsbcolor }
    (Shrink) kshow
  end
  grestore()
end
gsave()
translate(dup(neg(1.5)))
DrawLogo(0.3)
grestore()
DrawLogo(1)

% "KeyJ" sign
setgray(0)
gsave()
  translate(608,4)
  scale(dup(0.3))
  setfont(findfont(/Helvetica),scalefont(72))
  show(moveto(0,0),"K")
  show(moveto(64,0),"J")
  setfont(findfont(/Helvetica),scalefont(56))
  show(moveto(24,16),"e")
  show(moveto(46,-4),"y")
grestore()

% done.
showpage()
% </main> --%
