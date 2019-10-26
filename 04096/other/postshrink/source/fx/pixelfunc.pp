function PlasmaPixelFunc($x,$y)
  $x=add($x,mul(cos(mul($y,1.7)),20))
  $y=add($y,mul(cos(mul($x,2.3)),20))
  $r=div(add(add(sin($x),cos($y)),1),4)
  $g=div(add(add(sin($x),cos(mul($r,360))),1),4)
  $b=div(add(add(sin(mul($r,360)),cos(mul($g,360))),1),4)
  setrgbcolor($r,$g,$b)
end

function fxPixelFunc($MapFunc)
  for($x,-0.1,2.5,639.9)
    for($y,-0.1,2.5,479.9)
      exec($x,$y,load($MapFunc))
      moveto($x,$y)
      rlineto(2.7,0)
      rlineto(0,7.6)
      rlineto(-2.7,0)
      fill(closepath())
    end
  end
end

%-- <demo id="plasma">
fxPixelFunc(/PlasmaPixelFunc)
% </demo> --%
