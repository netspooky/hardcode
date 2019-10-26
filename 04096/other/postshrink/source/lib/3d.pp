def(/z0,320)

function XYZtoScreen($x,$y,$z):($x,$y)
  $y=mul(div($y,$z),&z0)
  $x=mul(div($x,$z),&z0)
end

function Triangle($proc,$limit, $x0,$y0,$z0, $x1,$y1,$z1, $x2,$y2,$z2)
  $zz=sub(mul(sub($x1,$x0),sub($y2,$y0)),mul(sub($x2,$x0),sub($y1,$y0)))
  if(gt($zz,$limit))
    $x,$y=XYZtoScreen($x0,$y0,$z0)
    moveto($x,$y)
    $x,$y=XYZtoScreen($x1,$y1,$z1)
    lineto($x,$y)
    $x,$y=XYZtoScreen($x2,$y2,$z2)
    lineto($x,$y)
    closepath()
    exec(load($proc))
  end
end
