<?
function cube($x, $start)
{
	/* Cubecode written 2002-11-12 by Kalaspuff, in C++.
         * Ported to PHP at Deadline Reloaded, December 28
         */
	$x = $x - $start;
	
	for($i = 0;$i < 360;$i++)
	{
        	$Tcos[] = cos($i * (3.141592 / 180));
	        $Tsin[] = sin($i * (3.141592 / 180));
	}
		
	for($i_y = 0;$i_y < 12;$i_y++)
	{
		for($i_x = 0;$i_x < 30;$i_x++)
		{
			$buffert[$i_y][$i_x] = ' ';
		}
	}
	$y_angle = ($x * 4) % 360;
	$x_angle = ($x * 2) % 360;
	$z_angle = ($x * 8) % 360;
	
	$coord = array(array( 1, 1, 1),
   	               array( 1, 1,-1),
                       array( 1,-1,-1),
       	               array( 1,-1, 1),
	               array(-1,-1, 1),
	               array(-1, 1, 1),
	               array(-1, 1,-1),
	               array(-1,-1,-1));

	$scale = 7;
	$distance_x = 15;
	$distance_y = 12;

	echo '<br><br><br><br><br>';

        for($i = 0;$i < 8;$i++)
	{
		$bx = $coord[$i][0] * $scale;
		$by = $coord[$i][1] * $scale;
		$bz = $coord[$i][2] * $scale;
		
		$rx = ($Tcos[$y_angle] * $bx + $Tsin[$y_angle] * $bz);
		$rz = (-$Tsin[$y_angle] * $bx + $Tcos[$y_angle] * $bz);
		
		$ry = ($Tcos[$x_angle] * $by + $Tsin[$x_angle] * $rz);

		$rrx = ($Tcos[$z_angle] * $rx - $Tsin[$z_angle] * $ry);
		$rry = ($Tsin[$z_angle] * $rx + $Tcos[$z_angle] * $ry);

		$point_x[$i] = $distance_x + round($rrx);
		$point_y[$i] = $distance_y - $rry;

		$point_y[$i] = round($point_y[$i] / 2.5);
	}
	
	{
		$lines = array(array(0,5),
			       array(5,4),
			       array(4,3),
			       array(3,0),
			       array(1,2),
			       array(2,7),
			       array(7,6),
			       array(6,1),
			       array(0,1),
			       array(5,6),
			       array(4,7),
			       array(3,2));
		for($n = 0;$n < 12;$n++)
		{
		if($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]] != 0)
		{
		$k = ($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]) / ($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]]);
		$i = (abs($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]]) > abs($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]) ? $point_x[$lines[$n][1]] - $point_x[$lines[$n][0]] : $point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]);
		do
			$buffert[round($point_y[$lines[$n][1]] - ($i * (abs($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]]) > abs($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]) ? $k : 1)))][round($point_x[$lines[$n][1]] - ($i * (abs($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]]) > abs($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]) ? 1 : (1 / $k))))] = '.';

		while ($i += (abs($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]]) > abs($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]) ? ($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]] < 0 ? 1 : -1) : ($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]] < 0 ? 1 : -1)) and $i - (abs($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]]) > abs($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]]) ? ($point_x[$lines[$n][1]] - $point_x[$lines[$n][0]] < 0 ? 1 : -1) : ($point_y[$lines[$n][1]] - $point_y[$lines[$n][0]] < 0 ? 1 : -1)) != 0);
		}
		}
	}
	

	for($i = 0;$i < 8;$i++)
		$buffert[$point_y[$i]][$point_x[$i]] = 'O';
		       
	echo('<center><pre>');
	for($i_y = 0;$i_y < 12;$i_y++)
        {
	        for($i_x = 0;$i_x < 30;$i_x++)
	        {
		        echo($buffert[$i_y][$i_x] . '');
		}
		echo('<br>');
	}
	echo('<br><br>');
	
	$text = '3D-PHP, now available for only $9.98!!';

	if($x >= 5)
		echo(($x >= 7 ? substr($text, 0, $x - 6) : '') . ($x >= 6 ? '<font color=#AAFFAA>' . substr($text, $x - 6, 1) . '</font>' : '') . '<font color=#55FF55>' . substr($text, $x - 5, 1) . '</font>');
	if($x > 60)
		echo('<br><br>That morphing thing above is a cube...');
	echo('</pre></center>');
}

function happy($x, $start) {
$x=$x-$start;
$lajn="H a p p y . . .";
echo("<br><br><br><br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;" . substr($lajn, 0, $x) . "");
echo("<br><br><br><br>");
if($x > 30) {
$xmas0="&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
$xmas1="...   ,,,                      ,,,,";
$xmas2=" $$$ $$$    .,., .,.,   .$.   ,$$$$..";
$xmas3="  $$$$$     $$$$ $$$$  $$ $$  $$$'$$$";
$xmas4="   $$$   -  $$$ $ $$$ $$$$$$$ $$$,,,";
$xmas5="  $$$$$     $$$ $ $$$ $$$ $$$  $$$$$,";
$xmas6=" $$$ $$$    $$$   ''' '|' '|' ,,, $$$";
$xmas7="´´´   $$$   '''               $$$,$$$";
$xmas8="       $$$                    '$$$$$'";
$xmas9="       '''";
if($x > 34 && $x < 44) {
    $line[0]=str_replace(" ", "&nbsp;", substr($xmas1, 0, 3)) . '<br>'; }
if($x > 35 && $x < 45) {
    $line[1]=str_replace(" ", "&nbsp;", substr($xmas2, 0, 4)) . '<br>'; }
if($x > 36 && $x < 46) {
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 5)) . '<br>'; }
if($x > 37 && $x < 52) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 6)) . '<br>'; }
if($x > 38 && $x < 48) {
    $line[4]='&nbsp;&nbsp;&nbsp;&nbsp;' . str_replace(" ", "&nbsp;", substr($xmas5, 4, 3)) . '<br>';}
if($x > 39 && $x < 49) {
    $line[5]='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' . str_replace(" ", "&nbsp;", substr($xmas6, 5, 3)) . '<br>';}
if($x > 40 && $x < 50) {
    $line[6]='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' . str_replace(" ", "&nbsp;", substr($xmas7, 6, 3)) . '<br>';}
if($x > 41 && $x < 83) {
    $line[7]='&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' . str_replace(" ", "&nbsp;", substr($xmas8, 7, 3)) . '<br>';}
if($x > 42) {    
    $line[8]=str_replace(" ", "&nbsp;", substr($xmas9, 0, 11)) . '<br>';}
if($x > 43 && $x < 77) {
    $line[0]=str_replace(" ", "&nbsp;", substr($xmas1, 0, 9)) . '<br>'; }
if($x > 44 && $x < 58) {
    $line[1]=str_replace(" ", "&nbsp;", substr($xmas2, 0, 8)) . '<br>'; }
if($x > 45) {
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 7)) . '<br>'; }
if($x > 47 && $x < 56) {
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 7)) . '<br>'; }
if($x > 48 && $x < 55) {    
    $line[5]=str_replace(" ", "&nbsp;", substr($xmas6, 0, 8)) . '<br>'; }
if($x > 49 && $x < 54) {    
    $line[6]=str_replace(" ", "&nbsp;", substr($xmas7, 0, 9)) . '<br>'; }
// going for the -    
if($x > 51 && $x < 56) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 11)) . '<br>'; }

//going for the M

if($x > 52 && $x < 82) {
    $line[6]=str_replace(" ", "&nbsp;", substr($xmas7, 0, 15)) . '<br>'; }
if($x > 53 && $x < 65) {
    $line[5]=str_replace(" ", "&nbsp;", substr($xmas6, 0, 15)) . '<br>'; }
if($x > 54 && $x < 60) {    
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 15)) . '<br>'; }
if($x > 55 && $x < 59) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 15)) . '<br>'; }
if($x > 56 && $x < 62) {
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 16)) . '<br>'; }
if($x > 57 && $x < 61) {
    $line[1]=str_replace(" ", "&nbsp;", substr($xmas2, 0, 16)) . '<br>'; }
if($x > 58 && $x < 63) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 18)) . '<br>'; }
if($x > 59 && $x < 64) {    
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 18)) . '<br>'; }
if($x > 60 && $x < 70) {
    $line[1]=str_replace(" ", "&nbsp;", substr($xmas2, 0, 22)) . '<br>'; }
if($x > 61 && $x < 69) {    
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 22)) . '<br>'; }
if($x > 62 && $x < 68) {    
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 22)) . '<br>'; }
if($x > 63 && $x < 67) {    
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 22)) . '<br>'; }
if($x > 64 && $x < 66) {    
    $line[5]=str_replace(" ", "&nbsp;", substr($xmas6, 0, 22)) . '<br>'; }
    
//going for a

if($x > 65 && $x < 74) {
    $line[5]=str_replace(" ", "&nbsp;", substr($xmas6, 0, 26)) . '<br>'; }
if($x > 66 && $x < 73) {    
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 26)) . '<br>'; }
if($x > 67 && $x < 72) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 26)) . '<br>'; }
if($x > 68 && $x < 71) {    
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 26)) . '<br>'; }
if($x > 69 && $x < 76) {    
    $line[1]=str_replace(" ", "&nbsp;", substr($xmas2, 0, 27)) . '<br>'; }
if($x > 70 && $x < 75) {
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 29)) . '<br>'; }
if($x > 71 && $x < 79) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 29)) . '<br>'; }
if($x > 72 && $x < 80) {
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 29)) . '<br>'; }
if($x > 73 && $x < 81) {
    $line[5]=str_replace(" ", "&nbsp;", substr($xmas6, 0, 29)) . '<br>'; }

//going for s
if($x > 74) {
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 29)) . "&nbsp;&nbsp;&nbsp;" . str_replace(" ", "&nbsp;", substr($xmas3, 29, 4)) . '<br>'; }
if($x > 75) {
    $line[1]=str_replace(" ", "&nbsp;", substr($xmas2, 0, 37)) . '<br>'; }
if($x > 76) {
    $line[0]=str_replace(" ", "&nbsp;", substr($xmas1, 0, 37)) . '<br>'; }
if($x > 77) {    
    $line[2]=str_replace(" ", "&nbsp;", substr($xmas3, 0, 37)) . '<br>'; }
if($x > 78) {
    $line[3]=str_replace(" ", "&nbsp;", substr($xmas4, 0, 37)) . '<br>'; }
if($x > 79) {
    $line[4]=str_replace(" ", "&nbsp;", substr($xmas5, 0, 37)) . '<br>'; }
if($x > 80) {
    $line[5]=str_replace(" ", "&nbsp;", substr($xmas6, 0, 37)) . '<br>'; }
if($x > 81) {
    $line[6]=str_replace(" ", "&nbsp;", substr($xmas7, 0, 37)) . '<br>'; }
if($x > 82) {
    $line[7]=str_replace(" ", "&nbsp;", substr($xmas8, 0, 37)) . '<br>'; }
for($d=0;$d<10;$d++) echo($xmas0 . $line[$d]);
}
}


function cirkel($x, $start) {
$x=$x-$start;
    echo('<br><br><br><br><br><br><center>');

    for($i = 1;$i < 20;$i++)
    {
        $x_value = cos((3.141592 / 180) * (-90 + $i * (360 / (20 * 2)))) * abs(round(35 * cos((3.141592 / 180) * $x * (360 / 25))));
	$x_value=round($x_value);
	echo('<font color="red">(</font>' . (($x + 18) % 25 >= 12 ? '<font color="darkgray">' : '<font color="white">'));
	for($o = 21;$o<$x_value+21;$o++) {echo((($x + 18) % 25 >= 12 ? '#' : '.'));}
	echo('</font><font color="red">)</font><br>');
	
    }
    echo('<br>');
    echo(substr("This is the rotating pussy as in LOTR (The eye-thingie you know)! :)",0,$x));
    echo('</center>');
}

function inserter($place, $text) {
if( $place > strlen($text)) { 
$place=$place-strlen($text);
$texten=str_replace(" ", "&nbsp;", $text);
echo($texten);
} else {
$texten=str_replace(" ", "&nbsp;", substr($text, 0, $place-1)) . "</font>";
echo($texten);
$place=$place-strlen($text);
}    
return $place;
}



function title($x, $start) {
$x=$x-$start;

// Kommentar ->> ME S0 L33T!@#
$logo1=str_replace(" ", "&nbsp;", "                        ¢¢¢¢¢¢¢¢¢¢");
$logo2=str_replace(" ", "&nbsp;", "                       ¢¢¢¢    ¢¢¢ ¢¢¢¢   ¢¢  ¢¢   ¢¢¢¢  ¢¢ ¢¢ ¢¢¢¢¢ ¢¢ ¢¢   ¢¢¢¢");
$logo3=str_replace(" ", "&nbsp;", "                        ¢¢¢¢¢      ¢¢¢ ¢  ¢¢ ¢__¢¢ ¢¢    ¢¢¢¢  ¢¢¢-  ¢¢¢   ¢ ¢  ¢");
$logo4=str_replace(" ", "&nbsp;", "                          ¢¢¢¢¢¢¢¢ ¢¢¢  ¢¢¢¢ ¢  ¢¢ ¢¢¢¢¢ ¢¢  ¢ ¢¢¢¢¢ ¢¢¢   ¢¢¢");   
$even1=str_replace(" ", "&nbsp;", "                                           _____");
$even2=str_replace(" ", "&nbsp;", "                                          |  ___| _ _  ___  ___ ");
$even3=str_replace(" ", "&nbsp;", "                                          |  =__ \ V /| __||   |");
$even4=str_replace(" ", "&nbsp;", "                                          |_____| \_/ |__/ |_|_| .se");
				    
				    
$leetline="Cnackers and Even made this all-at-the-party-mega-php-demo.";
echo('<br><br><br><br><br><br><br><br><br>');
echo($logo1 . "<br>");
echo($logo2 . "<br>");
echo($logo3 . "<br>");
echo($logo4 . "<br>");
echo('<br>');
echo('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
echo('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
echo('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;');
echo(substr($leetline, 0, $x));
echo("<font color='#FF9494'>". substr($leetline, $x, 1) . "</font>");
echo("<font color='#FF5454'>". substr($leetline, $x+1, 1) . "</font>");
echo("<font color='red'>". substr($leetline, $x+2, 1) . "</font>");
echo("<br>");
echo($even1 . "<br>");
echo($even2 . "<br>");
echo($even3 . "<br>");
echo($even4 . "<br>");
    
} 

function school($x, $start) {
$x=$x-$start;
$coolstring="be cool stay in school";
$string1="       _____ _____ _____ _____ __ __ _____ _____ ______ ";
$string2="      |  .__Y     Y  _  Y  .__Y  Y  Y     Y     Y   .__l";
$string3="      |  l  |  |  |     |  l  |    <   l__|  l__|__.   |";
$string4="      l_____l__|__l__|__l_____l__|__l_____|__|  l______l";

$b=$x;
for($rads=0;$rads < 25;$rads++) {
$b++;
$poz=round(35+sin($b/10)*30);

if($rads == 14) {
   $poz = inserter($poz, $string1);
} elseif($rads == 15) {
   $poz = inserter($poz, $string2); 
} elseif($rads == 16) {
   $poz = inserter($poz, $string3); 
} elseif($rads == 17) {
   $poz = inserter($poz, $string4);     
}

for($i=0;$i<$poz;$i++) {echo('&nbsp;');}
   echo( $coolstring . '<br>');
   if($x < 25 && $rads==$x) { $rads=$x; break;}
   }
}

$y=$x+1;
echo('<html><head><title>Staying cool in the year 2003</title>');
echo('<style type="text/css"><!--');
echo('body { font-family: Courier New;');
echo('}--></style></head>');
echo('<body bgcolor="#000000" text="#FFFFFF">');
if ($x < 670) echo('<META HTTP-EQUIV="Refresh" content="0;URL=?x=' . $y .'">');

// Demo Maker 2.0 below...
if($x < 70) {
title($x, 0);
} elseif($x < 200) {
school($x, 70); 
} elseif($x < 300) {
cirkel($x, 200);    
} elseif($x < 400) {
happy($x, 300);
} elseif($x < 490) {
cube($x, 400);
} elseif($x < 660) {
greets($x, 490);      

} else {
echo('<center><br><br><br><font size=10>THE END!</font><br><font size=1>stay 1337...</font></center>');    
}

echo('</body></html>');

function greets($x, $start)
{

    $x = round(($x - $start) / 2);
    
$credz = array("", "", "Greetz", "*****", "Go", "*****", "Out", "*****", "To",
	       "*****", "Deadline Crew", " " ,"Phaadi", " ", 
	       "Fairlight - Nice try dudes :)" ," " , "Even/#even" , " ", 
	       "#fulhack", " ", "", "", "", "", " - - - - - ", "This", 
	       "PHP-demo", "was", "created", "by", "-------", "CODE: ", "",
	       "uvr", "", "who", "", "coolh", "", "Kalaspuff", "", "", "MUSIC:",
	       "?", "", "", "OTHER:",
	       "psychodelia", "", "", "", "", "", "", "", "THANKS", "FROM",
	       "THE", "PHP-DEMO", "NERDS", "", "", "\"PHP-demo Legends\"",
	       "never", "die? :)", "", "", "", "", "---------",
	       "", "", "");
echo('<center><br><br><br><br><br>');
echo('<FONT SIZE="' . 1 . '">' . $credz[$x-8] . '</FONT><BR>');
echo('<FONT SIZE="' . 2 . '">' . $credz[$x-7] . '</FONT><BR>');
echo('<FONT SIZE="' . 3 . '">' . $credz[$x-6] . '</FONT><BR>');
echo('<FONT SIZE="' . 4 . '">' . $credz[$x-5] . '</FONT><BR>');
echo('<FONT SIZE="' . 6 . '">' . $credz[$x-4] . '</FONT><BR>');
echo('<FONT SIZE="' . 4 . '">' . $credz[$x-3] . '</FONT><BR>');
echo('<FONT SIZE="' . 3 . '">' . $credz[$x-2] . '</FONT><BR>');
echo('<FONT SIZE="' . 2 . '">' . $credz[$x-1] . '</FONT><BR>');
echo('<FONT SIZE="' . 1 . '">' . $credz[$x] . '</FONT><BR>');
echo('</center>');
//optimerat''
}
?>
