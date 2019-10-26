<?php

  $filea = fopen("a", "r");
  $a = fread($filea, filesize("a"));
  fclose($filea);

  $fileb = fopen("b", "r");
  $b = fread($fileb, filesize("b"));
  fclose($fileb);

  $filec = fopen("c", "r");
  $c = fread($filec, filesize("c"));
  fclose($filec);

  print("<html>\n");
  print("  <head>\n");
  print("    <meta http-equiv=\"refresh\" content=\"0;url=julia.php\">\n");
  print("  </head>\n");
  print("  <body bgcolor=\"#000000\" text=\"#FFFFFF\">\n");

  function nextvalue($a, $b, $c)
  {
    if($c == 1) {
      if($a < 0.30) {
        $a = $a + 0.010;
        $d = 1;
      } else {
        $d = 2;
      }
    }

    if($c == 2) {
      if($b < 0.70) {
        $b = $b + 0.005;
        $d = 2;
      } else {
        $d = 3;
      }
    }

    if($c == 3) {
      if($a > -0.30) {
        $a = $a - 0.010;
        $d = 3;
      } else {
        $d = 4;
      }
    }

    if($c == 4) {
      if($b > -0.70) {
        $b = $b - 0.005;
        $d = 4;
      } else {
        $d = 1;
      }
    }

    $c = $d;
    $r[0] = $a;
    $r[1] = $b;
    $r[2] = $d;
    return $r;
  }

  $tmp = nextvalue($a, $b, $c);
  $an = $tmp[0];
  $bn = $tmp[1];
  $cn = $tmp[2];

  system("rm a");
  $fila = fopen("a", "w");
  fwrite($fila, $an);
  fclose($fila);

  system("rm b");
  $filb = fopen("b", "w");
  fwrite($filb, $bn);
  fclose($filb);

  system("rm c");
  $filc = fopen("c", "w");
  fwrite($filc, $cn);
  fclose($filc);

#  function flip($s)
#  {
#    for($y=0; $y<12; $y++) {
#      for($x=0; $x<12; $x++) {
#        print("<font size=\"$size\" color=\"$s[$x][$y]\">##</font>");
#      }
#    }
#    print("<br>\n");
#  }

  function testspot($a, $b, $x, $y)
  {
    $r = 25;
    $c = 0;
    while($c < 25) {
      $xnew = (pow($x, 2)) - (pow($y, 2)) + $a;
      $ynew = (2 * $x * $y) + $b;
      $x = $xnew;
      $y = $ynew;
      if(2 > sqrt(pow($x, 2) + pow($y, 2))) {
        $c++;
      } else {
        $r = $c;
        $c = 25;
      }
    }
    return $r;
  }

  function drawscreen($a, $b, $f)
  {
    $size = 2;
    for($y=0; $y<24; $y++) {
      for($x=0; $x<24; $x++) {

        $xn = ($x - 12) / 10;
        $yn = ($y - 12) / 10;
        $i = testspot($a, $b, $xn, $yn);

        if(24 < $i) {
          $color = "#FFFFFF";
        } elseif(20 < $i) {
          $color = "#FF00FF";
        } elseif(15 < $i) {
          $color = "#8800FF";
        } elseif(10 < $i) {
          $color = "#0000FF";
        } elseif( 5 < $i) {
          $color = "#000088";
        } else {
          $color = "#000000";
        }
        $str = "<font size=\"$size\" color=\"$color\">##</font>";
        fwrite($f, $str);
      }
      fwrite($f, "<br>\n");
    }
  }

  include("screen");
  system("rm screen");
  $file = fopen("screen", "w");
  drawscreen($a, $b, $file);
  fclose($file);
  print("  </body>\n");
  print("</html>\n");
 ?>
