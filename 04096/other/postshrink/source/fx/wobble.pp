const WOBBLE_SIZE=175
const WOBBLE_STEP=25
const WOBBLE_MAX=WOBBLE_SIZE-1
const WOBBLE_FACTOR=6

function WobbleVertex($xin,$yin,$zin):($xout,$yout,$zout)
  $xdist=add(cos(mul($yin,2.1)), cos(mul($zin,2.2)))
  $ydist=add(cos(mul($zin,2.7)), cos(mul($xin,2.4)))
  $zdist=add(cos(mul($xin,2.3)), cos(mul($yin,2.6)))
  setrgbcolor(add(mul($ydist,0.125),0.7), add(mul($xdist,0.125),0.5), add(mul($zdist,0.125),0.3))
  $xout=add($xin,mul($xdist,WOBBLE_FACTOR))
  $yout=add($yin,mul($ydist,WOBBLE_FACTOR))
  $zout=add($zin,mul($zdist,WOBBLE_FACTOR))
  % rotate 30 degrees left around the Y axis
  $xtmp=add(mul($xout,0.866),mul($zout,0.5))
  $ytmp=$yout
  $ztmp=add(mul($xout,-0.5),mul($zout,0.866))
  % rotate 30 degreed down around the X axis
  $xout=$xtmp
  $yout=add(mul($ytmp,0.866),mul($ztmp,0.5))
  $zout=add(mul($ytmp,-0.5),mul($ztmp,0.866))
  $zout=add($zout,1000)
end

function MapToFront($u,$v):($x,$y,$z)
  $x,$y,$z=WobbleVertex($v,$u,-WOBBLE_SIZE)
end

function MapToTop($u,$v):($x,$y,$z)
  $x,$y,$z=WobbleVertex($v,WOBBLE_SIZE,$u)
end

function MapToSide($u,$v):($x,$y,$z)
  $x,$y,$z=WobbleVertex(WOBBLE_SIZE,neg($v),$u)
end

function WobbleSide($map)
  for($u1,-WOBBLE_SIZE,WOBBLE_STEP,WOBBLE_MAX)
    $u2=add($u1,WOBBLE_STEP)
    for($v1,-WOBBLE_SIZE,WOBBLE_STEP,WOBBLE_MAX)
      $v2=add($v1,WOBBLE_STEP)
      $x11,$y11,$z11=exec($u1,$v1,load($map))
      $x12,$y12,$z12=exec($u1,$v2,load($map))
      $x21,$y21,$z21=exec($u2,$v1,load($map))
      $x22,$y22,$z22=exec($u2,$v2,load($map))
      Triangle(/fill,0, $x11,$y11,$z11, $x12,$y12,$z12, $x22,$y22,$z22)
      Triangle(/fill,0, $x11,$y11,$z11, $x22,$y22,$z22, $x21,$y21,$z21)
      setgray(0)
      Triangle(/stroke,0, $x11,$y11,$z11, $x12,$y12,$z12, $x22,$y22,$z22)
      Triangle(/stroke,0, $x11,$y11,$z11, $x22,$y22,$z22, $x21,$y21,$z21)
    end
  end
end
