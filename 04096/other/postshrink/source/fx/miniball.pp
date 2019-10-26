function circle()
  moveto(0,1)
  $x=1.33
  curveto($x,1,$x,-1,0,-1)
  $x=neg($x)
  curveto($x,-1,$x,1,0,1)
  fill()
end

function miniball()
  gsave()
  for($i,1,-0.1,0)
    setgray(sub(1,mul(dup($i))))
    circle()
    scale(dup(0.8))
    translate(dup(0.075))
  end
  grestore()
end

%-- <demo>
translate(320,240)
gsave()
  scale(10,10)
  miniball()
grestore()
% </demo> --%
