const BALL_SIZE=300
const BALL_Z0=1000
const BALL_DETAIL=10

function fxBall()
  for($alpha,0,BALL_DETAIL,359)
    $ax1=mul(sin($alpha),BALL_SIZE)
    $az1=mul(cos($alpha),BALL_SIZE)
    $a2=add($alpha,10)
    $ax2=mul(sin($a2),BALL_SIZE)
    $az2=mul(cos($a2),BALL_SIZE)
    for($beta,-90,BALL_DETAIL,89)
      $y1=mul(sin($beta),BALL_SIZE)
      $f=cos($beta)
      $x11=mul($f,$ax1)
      $z11=add(mul($f,$az1),BALL_Z0)
      $x12=mul($f,$ax2)
      $z12=add(mul($f,$az2),BALL_Z0)
      $b2=add($beta,10)
      $y2=mul(sin($b2),BALL_SIZE)
      $f=cos($b2)
      $x21=mul($f,$ax1)
      $z21=add(mul($f,$az1),BALL_Z0)
      $x22=mul($f,$ax2)
      $z22=add(mul($f,$az2),BALL_Z0)
      % determine segment color
      $int=sub(sub(div($y1,BALL_SIZE),div($x11,BALL_SIZE)),div(sub($z11,BALL_Z0),BALL_SIZE))
      $int=add(div($int,3.5),0.5)
      $gb=mul(and(xor(cvi(div($alpha,BALL_DETAIL)),cvi(div($beta,BALL_DETAIL))),1),$int)
      setrgbcolor($int,$gb,$gb)
      % draw it
      Triangle(/fill,BALL_SIZE, $x11,$y1,$z11, $x21,$y2,$z21, $x22,$y2,$z22)
      Triangle(/fill,BALL_SIZE, $x11,$y1,$z11, $x22,$y2,$z22, $x12,$y1,$z12)
    end
  end
end

%-- <demo>
setgray(0)
fill(closepath(moveto(-10,-10),lineto(650,-10),lineto(650,490),lineto(-10,490)))
gsave()
  translate(600,40)
  rotate(-17)
  scale(dup(2))
  fxBall()
grestore()
% </demo> --%
