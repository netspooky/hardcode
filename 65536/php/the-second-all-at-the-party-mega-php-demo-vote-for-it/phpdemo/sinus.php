<?php

	include('bmp.php');
	echo('<html><head>');
	echo('<style type="text/css"><!--table { font-family: Courier New; font-size:1px;} body { font-family: Courier New; font-size:30px;} --></style>
	');
	echo('</head><body bgcolor=#000000><br><br><center>');

	$xx = $_GET['u'];
	if($xx == 0)
	{
		echo("<meta HTTP-EQUIV='Refresh' content='5;URL=sinus.php?u=" . ($_GET['u'] != "" ? $_GET['u']+1 : 0) . "'>");
		
		echo('<br><br><br>');
		$bmp = new BMP("hejsan.bmp");
		$bmp->print_as_table(3,4,1);

	} else if($xx < 360) {
		echo("<meta HTTP-EQUIV='Refresh' content='0;URL=sinus.php?u=" . ($_GET['u'] != "" ? $_GET['u']+1 : 0) . "'>");
		echo('<br><br><br>br>');
		
		$max_height = 5;
		$max_width  = 70;
		$text = "Illuminati, HyperCube, #fulhack, even, flickor, Alla Remedy Mongon (Crew), Psilodump and paza for their livegigs, the demoscene, the phpdemoscene, PHAADI (php-demo-god) and everyone at Remedy 2004!!           \"php-demo... det är kåta grejer\"                 Ett sista ord från oss sötnosar . . .                              PAAAAAAAAAAARTY!!!!!!";
		for($i = 0;$i < ($max_height+5)*$max_width;$i++)
			$buf[] = " ";
		$x = $max_width - $xx + 1;
		if($x < 0) $x = 0;
		for(;$x < $max_width;$x++)
		{
			$y = (int)(($max_height / 2) + (sin((3.141592 / 180) * ($x*3 + $xx) * 3)) * ($max_height / 2));
			if($xx - ($max_width - $x) >= strlen($text) - 1)
				$buf[$y*$max_width+$x] = " ";
			else
				$buf[$y*$max_width+$x] = $text[$xx - ($max_width - $x)];
		}
			
		echo("<font color=#c0c0c0><b>");
		for($y = 0;$y < $max_height;$y++)
		{
			for($x = 0;$x < $max_width;$x++)
			{
				echo(($buf[$y * $max_width + $x] == ' ' ? "&nbsp;" : $buf[$y * $max_width + $x]));
			}
			echo('<br>');
		}
		echo("</b></font>");
	} else if($xx == 360)
	{
		echo("<meta HTTP-EQUIV='Refresh' content='27;URL=sinus.php?u=" . ($_GET['u'] != "" ? $_GET['u']+1 : 0) . "'>");
		
		echo("<br><br><font color=#ffffff>IF YOU WERE TO LAME TO READ THAT SINUSSCROLLER, THESE WERE GREETED</font><br><br>");
		$bmp = new BMP("greet.bmp");
		//$bmp->print_as_table(3,4,1);
		echo("<font style='font-size:6px;'>");
		$bmp->print_as_chars("#");
		echo("</font>");
	} else if($xx > 360)
	{
		echo("<font color=#ffffff>THE END!<br><font size=1>stay 1337...</font>");
	}

	echo('</center></body></html>');

	
?>
