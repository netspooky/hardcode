<?php
class Fire
{
	function Fire()
	{
		$been_here = $_GET['u'];
		$fp = fopen("fire.pal", "r");
		for($i = 0;$i < 256;$i++)
		{
			$b   = ord(fgetc($fp));
			$g   = ord(fgetc($fp));
			$r   = ord(fgetc($fp));
			$res = ord(fgetc($fp));
			$pal[] = "#" .
				dechex((int)($r / 16)) .
			        dechex($r % 16) .
				dechex((int)($g / 16)) .
				dechex($g % 16) .
				dechex((int)($b / 16)) .
				dechex($b % 16);
		}
		fclose($fp);
		
		$W = 100;
		$H = 50;
		$max_rows = 30;
		
		if($been_here > 0)
			$fp = fopen("fire.buf", "r");
		for($i = 0;$i < $W * $H;$i++)
		{
			if($been_here > 0)
				$buf[] = ord(fgetc($fp));
			else
				$buf[] = 0;
		}
		if($been_here > 0)
			fclose($fp);
			
		$y = $W * ($H - 1);
			
		for($x = 0;$x < $W;$x++)
		{
			$random = 1 + (int)(16.0 * ( rand() / (1)));
			if($random > 11)
				$buf[$y + $x] = 255;
			else
				$buf[$y + $x] = 0;
		}

		for($i = 0;$i < $max_rows;$i++)
		{
			for($x = 0;$x < $W;$x++)
			{
				if(!$x)
				{
					$medel = $buf[($y + $x) - $W] +
						$buf[($y + $x) - $W + 1];
					$medel += ($buf[($y + $x) + 1]);
					$medel = (int)($medel / 10);
				}
				
				else if($x == $W - 1)
				{
					$medel = $buf[($y + $x) - $W] +
						$buf[($y + $x) - $W - 1];
					$medel += ($buf[($y + $x) - 1]);
					$medel = (int)($medel / 10);
				}
				
				else
				{
					$medel = $buf[($y + $x) - $W - 1] +
						$buf[($y + $x) - $W] +
						$buf[($y + $x) - $W + 1];
					$medel += ($buf[($y + $x) - 1] +
						$buf[($y + $x) + 1]);

					if($y == ($W * ($H - 1)))
						$medel = (int)($medel / 8);
					else/* if(!(($y + $x) + $W - 1 < 0 or ($y + $x) + $W - 1 > $H*$W or ($y + $x) + $W < 0 or ($y + $x) + $W > $H*$W or ($y + $x) + $W + 1 < 0 or ($y + $x) + $W + 1 > $H*$W))*/
					{
						$medel += ($buf[($y + $x) + $W - 1] +
							$buf[($y + $x) + $W] +
							$buf[($y + $x) + $W + 1]);
							$medel = (int)($medel / 8);
					}
				}

				if($medel > 0)
					$medel--;

				$buf[($y + $x) - $W] = $medel;
			}
			
			$y -= $W;
		}

		// Rita ut elden.
		for($y = $H;$y >= $max_rows;$y--)
		{
			for($x = 0;$x < $W;$x++)
			{
				echo("<font color=" . 
					$pal[$buf[($y-3)*$W+$x]] .
					">#</font>");
			}
			echo("<br>\n");
		}
		
		$fp = fopen("fire.buf", "w");
		for($i = 0;$i < $W * $H;$i++)
		{
			fwrite($fp, chr($buf[$i]), 1);
		}
		fclose($fp);
	}
}

include("text.php");

if($_GET['u'] >= 80)
	header('location:sinus.php?u=0');

echo("<html><head>");
echo('<style type="text/css"><!--table { font-family: Courier New; font-size:1px;} body { font-family: Courier New; font-size:15px;} --></style>');
echo("<body bgcolor=#000000><center><br><br>");
echo("<meta HTTP-EQUIV='Refresh' content='0;URL=fire.php?u=" . ($_GET['u'] != "" ? $_GET['u']+1 : 0) . "'>");
$fire = new Fire();
echo("<br><br>");
$text = new Text("Yaay, we're winning. Give us a nude Concept-P for prize! ;)", $_GET['u'] - 5, Array("#c0c0ff","#a0a0ff", "#7070ff", "#2020ff", "#0000d0", "#000090"));
echo("</center></body></html>");

?>
