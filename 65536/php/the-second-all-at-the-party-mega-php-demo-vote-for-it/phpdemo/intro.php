<?php
	if($_GET['u'] >= 375) header('location:fire.php?u=-1');
	echo('<html><head>');
	echo('<style type="text/css"><!--table { font-family: Courier New; font-size:1px;} body { font-family: Courier New; font-size:15px;} --></style>');
	echo('<body bgcolor=#000000><center>');
	echo("<meta HTTP-EQUIV='Refresh' content='0;URL=intro.php?u=" . ($_GET['u'] != "" ? $_GET['u']+1 : 0) . "'>");
	
	echo("<br><br><br><br>");
	include("text.php");
	$text = new Text("Hi kids! Welcome to another PHP-demo by", $_GET['u'] - 15, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0"));
	echo("<br>");
	$text = new Text("the \"PHP-demo legends [that never die?]\", today featuring", $_GET['u'] - 15 - 40, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0"));
	echo("<br>");
	$text = new Text("Cnackers and Even...", $_GET['u'] - 15 - 40 - 55, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0"));
	echo("<br>");
	echo("<br>");
	$text = new Text("Soo... Wanna go for a ride through \"another\" rotating pussy!?", $_GET['u'] - 15 - 40 - 55 - 40, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0"));
	
	if($_GET['u'] > 15 + 40 + 55 + 40 + 80)
	{
		echo('<br><br><br><br><br>');
		if((($_GET['u'] - 15 + 40 + 55 + 40 + 80) / 10) % 2 == 0)
			echo('&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbspp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbspp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b><font color=#ffffff style="font-size:11px;">[ R E P L A Y ]</font></b><br>');
		else echo('<br>');
		cirkel($_GET['u'], 15 + 40 + 55 + 40 + 80);
		echo('<br><br>');
	}	
	if($_GET['u'] > 15 + 40 + 55 + 40 + 80 + 30)
		$text = new Text("Welcome to 'the-second-all-at-the-party-mega-php-demo-vote-for-it'!", $_GET['u'] - 15 - 40 - 55 - 40 - 80 - 30, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0"));
		
	echo('</center></body></html>');
	
function cirkel($x, $start) {
	$delay = 6;
	$x=$x-$start;
	for($i = 1;$i < 20;$i++)
	{
		$x_value = cos((3.141592 / 180) * (-90 + $i * (360 / (20 * 2)))) * abs(round(35 * cos((3.141592 / 180) * $x * (360 / 25))));
		$x_value=round($x_value);
		echo('<font color=' . fadeup($x, $delay, Array("#000000","#100000","#200000","#300000","#400000","#500000","#600000","#700000","#800000","#900000","#a00000","#b00000","#c00000","#d00000","#e00000","#f00000","#ff0000")) . '>(</font>' . (($x + 18) % 25 >= 12 ? '<font color=' . fadeup($x, $delay, Array("#000000","#0808008","#101010","#181818","#202020","#282828","#303030","#383838","#404040","#484848","#505050","#585858","#606060","#686868","#707070","#787878","#808080")) . '>' : '<font color=' . fadeup($x, $delay, Array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff")) . '>'));
		for($o = 21;$o<$x_value+21;$o++) {echo((($x + 18) % 25 >= 12 ? '#' : '.'));}
		echo('</font><font color=' . fadeup($x, $delay, Array("#000000","#100000","#200000","#300000","#400000","#500000","#600000","#700000","#800000","#900000","#a00000","#b00000","#c00000","#d00000","#e00000","#f00000","#ff0000")) . '>)</font><br>');
	}
	echo('<br>');
}

function fadeup($num, $delay, $color)
{
	$num = (int)($num / $delay);
	$current = ($num >= sizeof($color) ? $color[sizeof($color) - 1] : $color[($num >= 0 ? $num : 0)]);
	return $current;
}

?>
