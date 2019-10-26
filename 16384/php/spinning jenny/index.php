<?php
/* 

Streaming JPEG PHP demo - by Yarrick/kryo
http://kryo.se               yarrick@kryo.se

NOTE: To run, make sure PHP max execution time is a lot more than 30 seconds.
Developed on PHP 5.2.1 with bundled GD 2.0.28 on Linux with lighttpd.

For best performance, run the web server and the browser on different cpus/computers.

*/

// Change this to the path to verdana.ttf and impact.ttf (Probably c:\windows\fonts on Windows)
putenv('GDFONTPATH=/usr/share/fonts/corefonts');

function diff_ms($then, $now) {
	$diff = ($now['sec'] - $then['sec']) * 1000000 + ($now['usec'] - $then['usec']);
	return (int) ($diff / 1000);
}

function interference($image, $frame) {
	global $start;
	global $c_white;
	global $c_black;
	global $c_ag1;

	global $icircle;
	global $icarcle;

	imagecopymerge($image, $icircle, 0, 0, 80, 60, 640, 480, 100);
	$x = sin($frame/25.0);
	$y = cos($frame/15.0);
	imagecopymerge($image, $icarcle, 0, 0, 80 + 65*$x, 60+55*$y, 640, 480, 100);

	if ($frame > 90 && $frame <= 140) {
		$flow = $frame - 90;
		$str1 = substr('KRYO', 0, $flow);
		$flow = max(0, $flow - 4);
		if ($frame > 135) $flow = 0;
		$str2 = substr('presents', 0, $flow);
		$flow = max(0, $flow - 8);
		if ($flow > 0) $flow++; // compensate spaces in str3
		if ($flow > 4) $flow++;
		if ($frame > 130) $flow = 0;
		$str3 = substr('a PHP demo:', 0, $flow);
		imagettftext($image, 72, 30, 330 - 65*$x, 245-25*$y, $c_white, 'verdana.ttf', $str1);
		imagettftext($image, 48, 30, 330 - 65*$x, 315-25*$y, $c_white, 'verdana.ttf', $str2);
		imagettftext($image, 32, 30, 330 - 65*$x, 375-25*$y, $c_white, 'verdana.ttf', $str3);
	}
	
	if ($frame > 150) {
		$th = 480 - ($frame - 150) * 16;

		for ($i = $th; $i < 480; $i++) {
			imagecopy($image, $image, 0, $i+1, 0, $th, 640, 1);
		}
	}
}

function speaker($image, $done, $mouth) {
	global $c_white;

	imageline($image, 133, 350, 133, 350 - 55*(min(1, $done/5)), IMG_COLOR_BRUSHED);
	if ($done <= 5.05) return;
	imagearc($image, 160, 200, 150, 200, 110, 110 + 70*(min(1, ($done-5)/7)), IMG_COLOR_BRUSHED);
	if ($done <= 12.05) return;
	imagearc($image, 80, 175, 30, 50, 80, 80 + 200*(min(1, ($done-12)/5)), IMG_COLOR_BRUSHED);
	if ($done <= 17.05) return;
	imagearc($image, 80, 175, 9, 15, 80, 80 + 200*(min(1, ($done-17)/3)), IMG_COLOR_BRUSHED);
	if ($done <= 20.05) return;
	imagearc($image, 160, 150, 150, 150, 180, 180 + 180*(min(1, ($done-20)/30)), IMG_COLOR_BRUSHED);
	if ($done <= 50.05) return;
	imageline($image, 235, 150, 235, 150 + 20*(min(1,($done-50)/3)), IMG_COLOR_BRUSHED);
	if ($done <= 53.05) return;
	$offset = 40*(min(1,($done-53)/7));
	imageline($image, 235, 170, 235 + 0.6*$offset, 170 + $offset, IMG_COLOR_BRUSHED);
	if ($done <= 60.05) return;
	imagearc($image, 210, 173, 35, 15, 0, 360*(min(1, ($done-60)/4)), IMG_COLOR_BRUSHED);
	if ($done <= 64.05) return;
	imagefilledarc($image, 210, 173, 5, 5, 0, 360, IMG_COLOR_BRUSHED, IMG_ARC_PIE);
	imageline($image, 259, 210, 259 - 24*(min(1,($done-64)/3)), 210, IMG_COLOR_BRUSHED);
	if ($done <= 67.05) return;
	imageline($image, 235, 210, 235, 210 + 25*(min(1,($done-67)/3)), IMG_COLOR_BRUSHED);
	if ($done <= 70.05) return;
	if ($mouth != 0) {
		imagearc($image, 235, 245, 60, 20, 90, 270, IMG_COLOR_BRUSHED);
	} else {
		$val = 180*(min(1, ($done-70)/10));
		imagearc($image, 235, 245, 20, 20, 270 - $val, 270, IMG_COLOR_BRUSHED);
	}
	if ($done <= 80.05) return;
	imagearc($image, 187, 256, 95, 85, 0, 90*(min(1, ($done-80)/7)), IMG_COLOR_BRUSHED);
	if ($done <= 87.05) return;
	imageline($image, 187, 300, 187, 300 + 50*(min(1, ($done-87)/3)), IMG_COLOR_BRUSHED);
	if ($done <= 90.05) return;
	$val = min(1, ($done - 90) / 10);
	$points = array( 
		270, 		245,
		270 + 40*$val,	245 - 55*$val,
		270 + 40*$val,	245 - 210*$val,
		270 + 70*$val,	245 - 230*$val,
		270 + 325*$val,	245 - 230*$val,
		270 + 355*$val,	245 - 210*$val,
		270 + 355*$val,	245 - 45*$val,
		270 + 325*$val,	245 - 25*$val,
		270 + 70*$val,	245 - 25*$val,
		);
	imagefilledpolygon($image, $points, count($points)>>1, $c_white);
}

function face($image, $frame) {
	global $c_white;
	global $c_black;
	global $c_bgface;
	
	imagefilledrectangle($image, 0, 0, 640, 480, $c_bgface);
	$done = min($frame,100);
	if ($done < 100) {
		$mouth = 0;
	} else if ($frame < 175) {
		$mouth = (($frame - 100)/2) % 3;
	} else {
		$mouth = 4;
	}
	speaker($image, $done, $mouth);

	if ($done == 100) {
		$str1 = substr("SPINNING", 0, 0.6+max(0, $frame-100)/6);
		$str2 = substr("JENNY", 0, max(0, $frame-145)/6);
		imagettftext($image, 55, 0, 330, 90, $c_black, 'impact.ttf', $str1);
		imagettftext($image, 92, 0, 330, 200, $c_black, 'impact.ttf', $str2);
	}
}
function drawall($image, $b, $p, $c) {
	global $cols; 
	
	for ($i = 0; $i < 3; $i++) {
		imageline($image, $b[0]+$p[$i][0], $b[1]+$p[$i][1], 
				$b[0]+$p[($i+1)%3][0], $b[1]+$p[($i+1)%3][1], $cols[$c%6]);
	}
}

function zoom($image, $b, $p, $col, $left) {
	global $cols;

	if ($left <= 0) return;

	for ($i = 0; $i < 3; $i++) {
		$g[$i][0] = ($p[$i][0] + $p[($i+1)%3][0])/2;
		$g[$i][1] = ($p[$i][1] + $p[($i+1)%3][1])/2;
	}
	drawall($image, $b, $g, $col);
	zoom($image, $b, $g, $col+1, $left-1);
	if ($left <= 1) return;
	zoom($image, $b, array($p[0], $g[0], $g[2]), $col+1, 1);
	zoom($image, $b, array($g[0], $p[1], $g[1]), $col+1, 1);
	zoom($image, $b, array($g[1], $p[2], $g[2]), $col+1, 1);
}


function trizoom($image, $timer) {
	global $c_white;
	imagesetthickness($image, 2);

	$ext = array(array(0, -1380), array(-1200, 700), array(1200, 700));
	$int = array(array(-600, -340), array(0, 700), array(600, -340));

	$t = ($timer%3000)/3000;
	$color = floor($timer/3000);
	$p = array(
		array($int[0][0] + $t*($ext[0][0]-$int[0][0]), 
		      $int[0][1] + $t*($ext[0][1]-$int[0][1])),
		array($int[1][0] + $t*($ext[1][0]-$int[1][0]), 
		      $int[1][1] + $t*($ext[1][1]-$int[1][1])),
		array($int[2][0] + $t*($ext[2][0]-$int[2][0]), 
		      $int[2][1] + $t*($ext[2][1]-$int[2][1]))
	);
	$b = array(320, 240);
	drawall($image, $b, $p, $color);
	zoom($image, $b, $p, $color+1, 9);
}

function drawGreets($image, $timer) {
	global $c_white;
	
	$count = floor($timer/3000);

	$greet = array(
		"Greetz to", "lft", "kmk", "scene.se", "birdie crew"
	);
	if ($count > count($greet)) return;
	
	imagettftext($image, 36, 60, 240, 290, $c_white, 'verdana.ttf', $greet[$count]);
}

function drawCredits($image, $timer) {
	global $c_bgface;
	global $c_black;

	imagefilledrectangle($image, 350, 30, 610, 380, $c_bgface);
	imagettftext($image, 18, 0, 355, 55, $c_black, 'verdana.ttf', "Code, bugs, design");
	imagettftext($image, 18, 0, 355, 75, $c_black, 'verdana.ttf', "and madness:");
	imagettftext($image, 18, 0, 355, 100, $c_black, 'verdana.ttf', "Yarrick");

	imagettftext($image, 18, 0, 355, 160, $c_black, 'verdana.ttf', "This demo uses");
	imagettftext($image, 18, 0, 355, 180, $c_black, 'verdana.ttf', "PHP and GD to");
	imagettftext($image, 18, 0, 355, 200, $c_black, 'verdana.ttf', "generate JPEGs in");
	imagettftext($image, 18, 0, 355, 220, $c_black, 'verdana.ttf', "realtime, which are");
	imagettftext($image, 18, 0, 355, 240, $c_black, 'verdana.ttf', "streamed to the ");
	imagettftext($image, 18, 0, 355, 260, $c_black, 'verdana.ttf', "browser. Released at");
	imagettftext($image, 18, 0, 355, 280, $c_black, 'verdana.ttf', "Birdie 17, 2007.");
	
	imagettftext($image, 18, 0, 355, 340, $c_black, 'verdana.ttf', "You can press");
	imagettftext($image, 18, 0, 355, 360, $c_black, 'verdana.ttf', "stop now.");
}

function draw_img($image, $frame, $timer) {
	global $start;
	global $c_white;

	if ($frame == 0) {
		imagestring($image, 4, 100, 200, "Press Stop (Esc) and then Reload (F5)", $c_white);
	} else if ($frame > 0 && $timer < 60000) {
		interference($image, $timer/333);
	} else if ($timer >= 60000 && $timer < 110000) {
		face($image, ($timer-60000)/200);
	} else {
		trizoom($image, $timer - 110000);
		if ($timer > 131000 && $timer < 146000)
			drawGreets($image, $timer - 131000);
		if ($timer > 150000)
			drawCredits($image, $timer - 150000);
	}
//	imagestring($image, 4, 5, 5, $frame, $c_white);
//	imagestring($image, 4, 5, 465, sprintf("%.01f FPS", $frame/$timer*1000.0), $c_white);
}

if (!function_exists("imagejpeg")) {
	die("Need gd");
}

if (strstr($_SERVER["HTTP_USER_AGENT"], "MSIE") 
	|| strstr($_SERVER["HTTP_USER_AGENT"], "Opera")) {
	
	die("Use Firefox");
}
header("X-kryo: frozen");
header("Content-Type: multipart/x-mixed-replace; boundary=--l33tstr34m");

$then = gettimeofday();
$start = $then['sec'];
$i = 0;
$delay = 55;
$icircle = imagecreatetruecolor(800, 600);
imagealphablending($icircle, true);
$cc_black = imagecolorallocate($icircle, 0x00, 0x00, 0x00);
$cc_ag1 = imagecolorallocatealpha($icircle, 0xFF, 0xFF, 0xFF, 75);
for ($size = 900; $size >= 20; $size -= 40) {
	imagefilledellipse($icircle, 400, 300, $size, $size, $cc_ag1);
	if ($size - 20 > 5)
		imagefilledellipse($icircle, 400, 300, $size - 20, $size - 20, $cc_black);
}
imagecolortransparent($icircle, $cc_black);

$icarcle = imagecreatetruecolor(800, 600);
imagealphablending($icarcle, true);
$ca_black = imagecolorallocate($icarcle, 0x00, 0x00, 0x00);
$ca_ag1 = imagecolorallocatealpha($icarcle, 0x80, 0x23, 0xd3, 75);
for ($size = 900; $size >= 20; $size -= 40) {
	imagefilledellipse($icarcle, 400, 300, $size, $size, $ca_ag1);
	if ($size - 20 > 5)
		imagefilledellipse($icarcle, 400, 300, $size - 20, $size - 20, $ca_black);
}
imagecolortransparent($icarcle, $ca_black);

$image = imagecreatetruecolor(640, 480);
imagealphablending($image, true);
imagelayereffect($image, IMG_EFFECT_NORMAL);
$c_black = imagecolorallocate($image, 0x00, 0x00, 0x00);
$c_white = imagecolorallocate($image, 0xFF, 0xFF, 0xFF);
$c_bgface = imagecolorallocate($image, 0x99, 0x99, 0x99);

$cols[] = imagecolorallocate($image, 0xfe, 0x00, 0x00);
$cols[] = imagecolorallocate($image, 0x00, 0xfe, 0x00);
$cols[] = imagecolorallocate($image, 0x00, 0x00, 0xfe);
$cols[] = imagecolorallocate($image, 0xfe, 0xfe, 0x00);
$cols[] = imagecolorallocate($image, 0x00, 0xfe, 0xfe);
$cols[] = imagecolorallocate($image, 0xfe, 0x00, 0xfe);
$brush_size = 3;
$facebrush = imagecreatetruecolor($brush_size,$brush_size);
$brush_color = imagecolorallocate($facebrush,0xCC,0x66,0x00);
imagefill($facebrush,0,0,$brush_color);
imagesetbrush($image,$facebrush);
$beginning = gettimeofday();

while (!connection_aborted()) {
	echo "--l33tstr34m\r\n";
	echo "Content-Type: image/jpeg\r\n\r\n";

	imagefilledrectangle($image, 0, 0, 640, 480, $c_black);
	draw_img($image, $i++, diff_ms($beginning, gettimeofday()));
	imagejpeg($image);

	echo "\r\n\r\n";
	ob_flush();
	flush();
	ob_flush();
	flush();

	$now = gettimeofday();
	$diff = diff_ms($then, $now);
	if ($diff < $delay) {
		$utime = ($delay - $diff) * 1000;
		usleep($utime);
	}
	$then = $now;
}
imagedestroy($image);
imagedestroy($icircle);
imagedestroy($icarcle);

?>
