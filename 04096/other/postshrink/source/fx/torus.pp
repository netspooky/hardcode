const TORUS_ALPHA_STEP=5
const TORUS_BETA_STEP=20
const TORUS_ALPHA_RADIUS=400
const TORUS_BETA_RADIUS=100

function MakeTorusVertex($alpha,$beta):($x,$y,$z)
  $r=add(mul(cos($beta),TORUS_BETA_RADIUS),TORUS_ALPHA_RADIUS)
  $x=mul($r,cos($alpha))
  $y=mul($r,sin($alpha))
  $z=mul(sin($beta),TORUS_BETA_RADIUS)
end

function TransformTorusVertex($x0,$y0,$z0):($x0,$y1,$z0)
  % phase 1: rotate 45 degrees by the X axis
  $x1=$x0
  $y1=mul(sub($y0,$z0),0.7)
  $z1=mul(add($y0,$z0),0.7)
  % phase 2: rotate 45 degrees by the Y axis
  $x0=mul(sub($z1,$x1),0.7)
  $z0=mul(add($z1,$x1),0.7)
  $z0=add($z0,1000)
end

function fxTorus($func,$limit,$fillmode,$astart,$aend)
  for($a1,$astart,TORUS_ALPHA_STEP,sub($aend,1))
    $a2=add($a1,TORUS_ALPHA_STEP)
    for($b1,0,TORUS_BETA_STEP,359)
      $b2=add($b1,TORUS_BETA_STEP)
      % determine edge vertices
      $x11,$y11,$z11=TransformTorusVertex(MakeTorusVertex($a1,$b1))
      $x12,$y12,$z12=TransformTorusVertex(MakeTorusVertex($a1,$b2))
      $x21,$y21,$z21=TransformTorusVertex(MakeTorusVertex($a2,$b1))
      $x22,$y22,$z22=TransformTorusVertex(MakeTorusVertex($a2,$b2))
      % calculate lighting
      if($fillmode)
        $cosb=cos($b1)
        $nx=mul($cosb,cos($a1))
        $ny=mul($cosb,sin($a1))
        $nz=sin($b1)
        $i=mul(sub(sub($ny,$nz),$nx),0.4)
        setrgbcolor($i,$i,$i)
      end
      % draw triangles
      Triangle($func,$limit, $x11,$y11,$z11, $x22,$y22,$z22, $x12,$y12,$z12)
      Triangle($func,$limit, $x11,$y11,$z11, $x21,$y21,$z21, $x22,$y22,$z22)
    end
  end
end

function TorusToplevel($astart,$aend)
  gsave()
    translate(160,390)
    scale(dup(2.0))
    setgray(0)
    fxTorus(/fill,-200,&true,$astart,$aend)
    setrgbcolor(1,0.75,0)
    setlinewidth(0.125)
    fxTorus(/stroke,0,&false,$astart,$aend)
  grestore()
end

%-- <demo>
setrgbcolor(0.1,0.2,0.3)
fill(closepath(moveto(-10,-10),lineto(650,-10),lineto(650,490),lineto(-10,490)))
TorusToplevel()
% </demo> --%
