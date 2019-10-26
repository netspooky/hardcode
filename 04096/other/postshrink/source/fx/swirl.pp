function swirl1($i):($x,$y)
  $x=mul(sub(1,mul(dup(sub(1,$i)))),1000)
  $y=sub(mul(mul(dup($i)),960),480)
end

function swirl2($i):($x,$y)
  $x=add(mul($i,20),-25)
  $y=add(mul($i,200),480)
end

function fxSwirl():
  for($i,0,0.01,1)
    $xs1,$ys1=swirl1($i)
    $xe1,$ye1=swirl2($i)
    $xs2,$ys2=swirl1(add($i,0.011))
    $xe2,$ye2=swirl2(add($i,0.011))
    for($js,0,0.01,0.99)
      sethsbcolor($i,mul($js,1.5),sub(1,mul($js,0.75)))
      $je=add($js,0.011)
      $en=sub(1,$js)
      moveto( add(mul($xs1,$js),mul($xe1,$en)), add(mul($ys1,$js),mul($ye1,$en)) )
      lineto( add(mul($xs2,$js),mul($xe2,$en)), add(mul($ys2,$js),mul($ye2,$en)) )
      $en=sub(1,$je)
      lineto( add(mul($xs2,$je),mul($xe2,$en)), add(mul($ys2,$je),mul($ye2,$en)) )
      lineto( add(mul($xs1,$je),mul($xe1,$en)), add(mul($ys1,$je),mul($ye1,$en)) )
      fill(closepath())
    end
  end
end

%-- <demo>
fxSwirl()
% </demo> --%
