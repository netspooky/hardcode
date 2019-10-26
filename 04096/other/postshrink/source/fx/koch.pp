function fxKoch($level,$start,$span)
  $level=sub($level,1)
  $span=div($span,4)
  if(eq($level,0))
    sethsbcolor($start,1,1)
    stroke(moveto(dup(0)),lineto(1,0))
  else
    gsave()
    scale(dup(0.333333))
    fxKoch($level,$start,$span)
    translate(2,0)
    fxKoch($level,add($start,mul($span,3)),$span)
    translate(-1,0)
    rotate(60)
    fxKoch($level,add($start,$span),$span)
    translate(1,0)
    rotate(-120)
    fxKoch($level,add($start,mul($span,2)),$span)
    grestore()
  end
end

%-- <demo>
gsave()
  translate(30,400)
  scale(200,200)
  for($dummy,1,1,3)
    fxKoch(7,0,1)
    translate(1,0)
    rotate(-120)
  end
grestore()
% </demo> --%
