function fract($x):$f
  $f=sub($x,floor($x))
end

function fxSierpinski($level,$start,$span)
  $level=sub($level,1)
  $span=div($span,2)
  $next=add($start,$span)
  if(eq($level,0))
    sethsbcolor(fract($start),1,1)
    moveto(0,0)
    lineto(1,0)
    lineto(0.5,0.866)
    fill(closepath())
  else
    gsave()
    scale(dup(0.5))
    fxSierpinski($level,$start,$span)
    translate(1,0)
    fxSierpinski($level,$next,$span)
    translate(-0.5,0.866)
    fxSierpinski($level,$next,$span)
    grestore()
  end
end

%-- <demo>
gsave()
  translate(120,20)
  scale(500,500)
  fxSierpinski(10,0,1)
grestore()
% </demo> --%
