<html xmlns="http://www.w3.org/1999/xhtml">
<!-- functions from http://www.jcmiras.net/jcm/item/72/ -->
<?php
	
           function div($first,$second)
			{
			if(($second['re']==0 && $second['im']==0))
				{return(-1);}
			$a=$first['re'];
			$b=$first['im'];
			$c=$second['re'];
			$d=$second['im'];
                  $e=($a*$c)+($b*$d);
                  $f=($c*$c)+($d*$d);
  			$g=($b*$c)-($a*$d);
			$result['re']=$e/$f;
			$result['im']=$g/$f;
			return($result);
			}
		function add($first,$second)
			{
			$result['re']=$first['re']+$second['re'];
			$result['im']=$first['im']+$second['im'];
			return($result);
			}

		function sub($first,$second)
			{
			$result['re']=$first['re']-$second['re'];
			$result['im']=$first['im']-$second['im'];
			return($result);
			}
		function mul($first,$second)
			{
			$result['re']=($first['re']*$second['re'])-($first['im']*$second['im']);
			$result['im']=($first['re']*$second['im'])+($second['re']*$first['im']);
			return($result);
			}

		function conj($first)
			{
			$result['re']=$first['re'];
			$result['im']=-1.0*$first['im'];
			return($result);
			}

	      function rec2pol($first)
			{
                    
			$result['re']=sqrt(pow($first['re'],2)+pow($first['im'],2));
			$result['im']=rad2deg(atan($first['im']/$first['re']));
			return($result);
			}

	     function pol2rec($first)
			{
			$result['re']=$first['re']*cos(deg2rad($first['im']));
			$result['im']=$first['re']*sin(deg2rad($first['im']));
			return($result);
			}

function abssqr($z) {
  return $z['re']*$z['re']+$z['im']*$z['im'];
}
?>
<!-- Julia function -->
<?php

$max_iter = 24;

$p['re'] = pow(0.9, $_GET['i']/100);
$p['im'] = $_GET['i'];
$c = pol2rec($p);

function julia($z, $c, $max_iter) {
  for($iter = 0; ($iter < $max_iter) && (abssqr($z) < 9); ++$iter) {
    $z = add(mul($z, $z), $c);
  }
  return($iter);
}

$txtjulia = '';

for($row = 0; $row < 30; ++$row) {
  for($col = 0; $col < 50; ++$col) {
    $x['re'] = ($col - 25) / 25;
    $x['im'] = ($row - 15) / 15;
    $i = julia($x, $c, $max_iter);
    echo '<!-- ', $i, '-->';
    $r = 256 - $i*4;
    $g = 128 + $i*3;
    $b = 128 + $i*4;
    $txtjulia .= '<span style="background:#'.dechex($r).dechex($g).dechex($b).'"> -- </span>';
  }
  $txtjulia .= "<br/>\n";
}


$lpos = $_GET['i'] % 160;
if($lpos > 80) { $lpos = 160-$lpos; }

$rpos = ($_GET['i']+50) % 160;
if($rpos > 80) { $rpos = 160-$rpos; }

$op = 0;
if($_GET['i'] > 50) {
  $op = (($_GET['i']-50) % 30)/40;
}
?>
  <head>
    <title>Deadline php demy by rkaj</title>
    <?php echo '<meta http-equiv="refresh" content="0;url=deadline.php?i=', $_GET['i']+1,'"/>'?>
  </head>
  <body style="color: #00ff00; background: #000000;">
    <h1>PHP demo <?php echo $_GET['i'], '; ', $p['re'], ' / ', $p['im'] ?></h1>

    <div style="font: 1em/1em sans-serif;">
<?php echo $txtjulia ?>
    </div>

    <div style="position: absolute; top: <?php echo $rpos ?>%; left: <?php echo $lpos ?>%; background: #000000; width: 12em; padding: 1ex; -moz-opacity: <?php echo $op ?>; border: solid thin #00ff00; -moz-border-radius: 1em;">
      <h2 style="margin: 0;">Greetings</h2>
      <ul>
	<li>Psychad</li>
	<li>Elmindreda</li>
	<li>Dicander</li>
	<li>Capitol</li>
	<li>NiCon</li>
	<li>katy</li>
	<li>haba</li>
	<li>leViMS</li>
	<li>lien</li>
      </ul>
    </div>
  </body>
</html>
