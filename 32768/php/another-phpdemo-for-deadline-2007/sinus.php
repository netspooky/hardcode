<?php
	include("text.php");

	class Sinus
	{
		function Sinus($txt, $w, $h, $jump, $position)
		{
			print "<table width=$w cellspacing=0 cellpadding=0><tr>";

			$n = (int)((360 / strlen($txt)) * 1.5);
			$t = (int)($w / strlen($txt));
			$rh = $h + 30;
			for($i = 0;$i < strlen($txt);$i++)
			{
				$char = $txt[$i];
				$pos = (int)(($h * (sin(($i*$n+($jump*$position))*(3.141592 / 180)))) / 2 + $h / 2 + 30);
				print "<td height=$rh valign=top>";
				print "<table class=sinus cellspacing=0 cellpadding=0 width=$t><tr><td height=$pos valign=bottom>";
				new Text($char, $position-$i*2, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));

				print "</td></tr></table>";
				print "</td>";
			}
			print "</tr></table>";
		}
	}
	
?>
