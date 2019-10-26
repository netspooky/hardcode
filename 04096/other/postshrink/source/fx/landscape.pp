const LANDSCAPE_U_STEP=10
const LANDSCAPE_V_STEP=10

function LandscapeHeight($u,$v):$h
  $a=sin(add(mul($u,2.52),mul(cos($v),300)))
  $b=cos(add(mul($u,2.37),mul($v,1.52)))
  $h=add($a,$b)
end

function MakeLandscapeVertex($u,$v):($x,$y,$z)
  $h=mul(LandscapeHeight($u,$v),20)
  % transform 1: rotate 45 degrees around the Y axis
  $x=mul(sub(neg($u),$v),0.7)
  $y0=mul(add(neg($u),$v),0.7)
  % transform 2: rotate 45 degrees around the X axis
  $y=mul(sub($y0,$h),0.7)
  $z=mul(add($y0,$h),0.7)
  $z=add($z,1000)
end

function fxLandscape()
  for($u1,-360,LANDSCAPE_U_STEP,359)
    $u2=add($u1,LANDSCAPE_U_STEP)
    for($v1,-360,LANDSCAPE_V_STEP,359)
      $v2=add($v1,LANDSCAPE_V_STEP)
      $h=LandscapeHeight($u1,$v1)
      $i=sub(0.5,mul($h,0.2))
      $i2=mul(dup($i))
      setrgbcolor($i2,$i2,$i)
      $x11,$y11,$z11=MakeLandscapeVertex($u1,$v1)
      $x12,$y12,$z12=MakeLandscapeVertex($u2,$v1)
      $x21,$y21,$z21=MakeLandscapeVertex($u1,$v2)
      $x22,$y22,$z22=MakeLandscapeVertex($u2,$v2)
      Triangle(/fill,-1000, $x11,$y11,$z11, $x22,$y22,$z22, $x12,$y12,$z12)
      Triangle(/fill,-1000, $x11,$y11,$z11, $x21,$y21,$z21, $x22,$y22,$z22)
      setgray(0)
      Triangle(/stroke,-1000, $x11,$y11,$z11, $x22,$y22,$z22, $x12,$y12,$z12)
      Triangle(/stroke,-1000, $x11,$y11,$z11, $x21,$y21,$z21, $x22,$y22,$z22)
    end
  end
end
