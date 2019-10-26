<?php

    system("rm screen");
    $fs = fopen("screen", "w");
    fwrite($fs, "");
    fclose($fs);

    system("rm a");
    $fa = fopen("a", "w");
    fwrite($fa, "0.25");
    fclose($fa);

    system("rm b");
    $fb = fopen("b", "w");
    fwrite($fb, "0");
    fclose($fb);

    system("rm c");
    $fc = fopen("c", "w");
    fwrite($fc, "1");
    fclose($fc);
 ?>
  <html>
    <head>
      <meta http-equiv="refresh" content="0;url=julia.php">
    </head>
  </html>
