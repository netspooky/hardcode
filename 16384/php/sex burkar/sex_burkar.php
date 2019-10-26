<? 
//$o = $_REQUEST['o'];
/* Jumalauta - ? 
 * code: setae aurinkoinen
 * scroll: 
 * paskaa koodii kännissä partyilla, vittu toimii jotenki. urputukset: jaffa@stc.cx
 */

$stext = "
                                                            
Hello partypeople! It's soluttautuja hitting keys at the moment. This is Jumalauta's first contribution to the php scene with a 
demo called \"Sex burken av öl\" Developed totally on influenced state of mind. Remember the limits, kids! From Helsinki till
Marienhamn you can bring some picnic juices, totally sex burken av öl or one liter of strong spirits. When arriving to Stockholm
you can bring whole 14 cases of beer!!!!! OMG is'nt that something! jUMalAuTa official alchohol team annoynces: ATTENTION! PEOPLE
OF SWEDEN! FIGHT FOR THE FASCIST GOVERNMENT! KILL THE KING!!! FREE THE BEER! FREE SYSTEMBOLAGET! Drow your folköl down from the 
drain
and get the real beer (karhu III) on regular markets! It is supposed that the utopia of social democracy should have some real 
beer in stores. Jumalauta invites you all THE PEOPLE'S PARTY held in People's Democratic Republic of North Korea held in 
June 2005. Surf for jumalauta.org for more information. Soluttautuja fading out and letting new faces to control the 
transmission.   
 Anteeksi neiti, mutta voisinko lainata kupillisen sokeria sharing his divine wisdom at the moment: 
Hejsan, ska vi knulla?!?!?!!!!111ettettettett! We are totally wasted, drunk and under influence of alcoholics. 
It has been a great party, except that all swedish lamers have not boozed with us. WE ARE NOT THAT SCARY (except 90% of us). 
We are your friends, join us now or prepare to meet your doom! 
Everyone who is actually reading this lame scroller are now officially members of jumalauta. 
Just come and ask your jumalauta-handle from me. SKA VI KNULLA!? FITTAN! jag tycker inte om folköl :X 
Everyone who doesn't like the idea of being a member of our right-wing conservative left-wing socialist ultra-islamistic 
peoples democratic should go and fuck themselves (and after that they should shoot their brains out with a  shotgun). 
Btw, by joining jumalauta you get great benefits, for example: Discount from jumalauta promotional goods, fistfuck and 
jumalauta's \"kova ydin\"(hard core) membership (only for n+100000 sek). 
You can also become a member of our hard core-wing by doing anything under the jumalauta-brand. 
WARNING - EVERYTHING YOU ARE READING AFTER THIS NOTIFICATION IS TOP SECRET CONFIDENTAL INFORMATION! - 
YOU ARE ALL FAGGOTS, GO FUCK YOUR SELF, BÖG BÖG BÖG BÖG! - if you are reading this, even if we warned you before - 
don't worry. You are just going to be executed (by crusifying). :):):):):):):)
                                                                                 
                                                                                                  
";

$upper = "
                                                                              
                                                                              
Done by:
isä aurinkoinen *
soluttautuja *
anteeksi neiti mutta saisinko lainata kupillisen sokeria *
lorottaja  


Greetings fly out to: jumalauta * brainlez Coders! * Static * Unseen Fate of JASoft * irc-galleria * matt current * mfx *
gluterol * unique * faktory * fag (Filthy American Government) * flo * iso * moonhazard * DCS * DC-S * DC-11 * Psychad *
all finns at the partyplace * dolph lundgren * GAYTEK * swedish astu * fairlight * kewlers * all swedish elites who are
boozing *  jumalauta

Fuckings to: ALL * unseen fate * freeze's groups * all swedish lamers who are not boozing * kewlers * deus ex machinae * 
systembolaget * kungen * finns being offensive * tre kronor * BREAKPOINT * ALL


";

$l[0] = "         |                   |         ";
$l[1] = "    _ ___|___________________|___ _    ";
$l[2] = "         |    |  |   |  |    |         ";
$l[3] = "         |    |         |    |         ";
$l[4] = "       __|    |         |    |__       ";
$l[5] = "       |      |         |      |       ";
$l[6] = "  _ ___|______|__|___|__|______|___ _  ";
$l[7] = "       |                       |       ";
$l[8] = "       |                       |       ";


$greets = "UNSSI";

function scroller_print() {
	global $o;
	global $stext;

	$len = 64;
	$beg = (($o * 2) - $les);
	if ($beg < 0) {
		$beg = 0;
	}
?>
	<div style="text: align: right">
<?
		print str_replace(' ', '&nbsp;', substr($stext, $beg, $len));
?>
	</div>
<?
}

function upper_print() {
	global $o;
	global $upper;

	$len = 64;
	$beg = (($o * 2) - $les);
	if ($beg < 0) {
		$beg = 0;
	}
?>
	<div style="text: align: right">
<?
		print str_replace(' ', '&nbsp;', substr($upper, $beg, $len));
?>
	</div>
<?
}

function sin_mob($size = 10, $k = 0, $color = 'd3d3d3') {
	global $o;
	$s = 29 * $k;
	for ($i = 0 + $s; $i < 189 + $s; $i = $i + 9) {
?>
		<div style="
				border-left: 1px solid white; 
				border-right: 1px solid black; 
				color: #<?= $color ?>;
				background-color: #<?= $color ?>;
				width: <?= sin ($o + ($i/20)) * 50 + 50 ?>px;"><br/></div>
<?
	}
}
// slow and ugly, who cares
function mkcolor($r,$g,$b) {
	return sc($r).sc($g).sc($b);
}


	$arr1 = array(
21,0,1,0,0 ,0,0,0,99,0 ,0,0,1,55,0 ,0,0,0,0,0,
0,200,222,222,222 ,222,0,0,99,0 ,0,0,1,55,0 ,0,0,0,0,0,
0,24,1,0,55 ,0,55,0,0,222 ,222,222,1,55,0 ,0,0,55,0,0,
0,0,1,0,55 ,0,0,222,0,0 ,0,0,1,0,0 ,0,0,0,0,0,
0,0,1,0,0 ,0,222,0,99,0 ,0,0,1,0,0 ,0,0,0,0,0,

0,0,0,0,55 ,222,222,0,0,222 ,0,0,0,0,222 ,0,0,0,0,0,
0,0,0,0,0 ,222,0,0,222,0 ,0,0,0,0,0 ,0,0,0,0,0,
0,0,62,0,222 ,0,244,0,222,0 ,0,0,0,0,0 ,0,0,0,0,0,
0,0,0,0,2222 ,0,244,0,222,0 ,0,0,0,0,0 ,0,0,0,0,0,
0,0,0,0,0 ,0,0,0,222,0 ,0,0,0,0,0 ,0,0,0,0,0,

0,0,1,0,0 ,0,0,0,244,0 ,0,0,1,0,0 ,0,0,0,0,0,
0,0,0,0,0 ,0,0,244,0,0 ,0,0,0,0,0 ,0,0,0,0,0,
0,0,222,0,0 ,0,0,222,0,0 ,0,0,1,222,0 ,0,0,222,0,0,
0,0,222,0,0 ,0,0,0,0,0 ,0,0,222,0,0 ,0,0,0,222,0,
0,0,0,0,0 ,0,0,254,0,0 ,0,0,222,0,0 ,0,0,0,0,0,

0,0,0,0,0 ,0,0,0,0,0 ,0,0,0,0,0 ,0,0,0,0,0,
244,0,1,0,0 ,0,0,244,0,0 ,0,0,0,0,0 ,0,0,0,0,0,
0,0,2,0,0 ,0,0,222,0,0 ,0,0,5,0,0 ,0,0,0,0,0,
0,244,1,0,0 ,0,0,250,0,0 ,0,0,0,0,0 ,0,0,0,0,0,
0,0,244,0,0 ,0,0,0,0,0 ,0,0,0,0,0 ,0,0,0,0,0);


$w = 24;
$h = 14;

function plasma_print($arr, $r, $g, $b) {
	global $w;
	global $h;
	for ($y = 1; $y < ($h - 1); $y++) {
		echo "<tr>";
		for ($x = 0; $x < $w; $x++) {


				$p = $arr[$y * $w + $x] ;
				$color = mkcolor(256-$r-$p,256-$g-$p,256-$b-$p);
				echo "<td style=\"
				background-color: #".$color."; 
				color: #". $color.";
				\">M</td>";
		}		
		echo "</tr>";
	}
}

function sc($c) {
        if ($c > 255) {
                $c = 255;
        }
        if ($c < 0) {
                $c = 0;
        }
        $h = dechex($c);
        if ($c < 16) { 
                return '0'.$h;
        }
        return $h;
}

function plasmatize($arr) {
	global $w;
	global $h;
	for($i = 0; $i < $w; $i++) {
		$arr[$i] = rand(0,128);
	}
	for($i = (($w-1)*$h); $i < ($w*$h); $i++) {
		$arr[$i] = rand(0,128);
	}
	for($i = $w + 1; $i < ($w * $h) - $w - 1; $i++) {
		$y = (
			$arr[$i + 1] +
			$arr[$i - 1] +
			$arr[$i + $w] +
			$arr[$i - $w] +
			$arr[$i]) / 4.9; // levis!
			
		if ($y > 235) {
			$y -= 255;
		}
		if ($y < 0) { //?? wtf
			$y += 255;
		}
		$arr[$i] = (int)$y;
	}
	return $arr;
}

function plasma_decode($out) {
	for ($i = 0; $i < strlen($out) ; $i += 2) {
		$yrr[$i/2] = hexdec(substr($out, $i, 2));
	}
	return $yrr;
}

function plasma_encode($arr) {
	global $w;
	global $h;
	global $arr1;
	global $o;
	if ($o < 51) {
		$arr =  $arr1;
	}

	for ($i = 0; $i < $w * $h; $i++) {
		$out .= sc($arr[$i]);
	}
	return $out;
}

$out =  $_REQUEST['out'];
//$out =  $arr2;
$arr = plasma_decode($out);
$arr = plasmatize($arr);

if ($o < 50) {
?>
	<html><head><meta http-equiv="refresh" content="0;URL=demo2.php?o=<?= $_REQUEST['o'] + 1 ?>"></head>
<?
} else {
?>
	<html><head><meta http-equiv="refresh" content="0;URL=demo2.php?o=<?= $_REQUEST['o'] + 1 ?>&out=<?= plasma_encode($arr) ?>"></head>
<?
} 
?>

<body style="background-color: #550055; color: white; font-family: Verdana, Arial; font-size: 12px;">
<? 
print "&lt;?php<br/><br/> ";

?>
<center>
<?
	upper_print();
?>
<table style="border: 2px outset #880088; width: 700px">
<tr>
<td style="width: 70px;"><center>
<?
	$r = (sin($o/19) + 1) * 128;
	$g = 0;
	$b = 255 - $r;
	$color = mkcolor($r, $g, $b);
	sin_mob(20, 0, $color);
?>

</td>
<td style="vertical-align: top;"><center>
<div style="text-align: center; vertical-align: top;">
<pre>
<?
	if ($o < 50) {
		$limit = 24;
	} else {
		$limit = 9;
	}

	if ($o >= 26) {
		for ($i = 0; $i <= 8; $i++) {
			echo $l[$i];				
			echo "\n";
		}
		
	} else {
		for ($i = $o; $i < $limit + $o; $i++) {
			if ($i >= $limit) {
				echo $l[$i - $limit - 1];				
			}
			echo "\n";
		}
	}
?>
</pre>
</div>
<?
	if ($o > 50) {
?>
<table cellspacing="0" cellpadding="0" style="border: 2px outset #880088;">

<?

	plasma_print($arr, $r, $g, $b);
?>

</table>
<? 
	}
?>
</td>
<td style="width: 70px;"><center>
<?
	sin_mob(20, 0, $color);
?>
			</center>
		</td>
	</tr>
</table>
<table>
	<tr>
		<td style="font-family: Verdana, Arial; font-size: 12; text-align: left;">
<?
	scroller_print();
?>
</td></tr></table>
</center>
?&gt;
</body></html>






