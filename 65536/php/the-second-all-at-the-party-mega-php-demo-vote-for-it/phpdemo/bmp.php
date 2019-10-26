<?php

class BMP
{
	var $filename;
	var $fp;
	var $pre_type;
	var $header_size;
	var $header_res;
	var $header_offset;
	var $info_size;
	var $info_width;
	var $info_height;
	var $info_planes;
	var $info_bits;
	var $info_comp;
	var $info_sizeimage;
	var $info_xpelsparameter;
	var $info_ypelsparameter;
	var $info_clrused;
	var $info_clrimp;
	var $palette;
	var $pixel;

function string_to_int($string)
{
        $bytel = strlen($string);
	$retval = 0;
	for($i = 0;$i < $bytel;$i++)
	{
		$retval += pow(256, $i) * ord($string[$i]);
	}
	return $retval;
}						

function BMP($file)
{
$this->filename = $file;
$fp = fopen($this->filename, 'r');

$this->pre_type            = $this->string_to_int(fgets($fp, 3));

$this->header_size         = $this->string_to_int(fgets($fp, 5));
$this->header_res          = $this->string_to_int(fgets($fp, 5));
$this->header_offset       = $this->string_to_int(fgets($fp, 5));

$this->info_size           = $this->string_to_int(fgets($fp, 5));
$this->info_width          = $this->string_to_int(fgets($fp, 5));
$this->info_height         = $this->string_to_int(fgets($fp, 5));
$this->info_planes         = $this->string_to_int(fgets($fp, 3));
$this->info_bits           = $this->string_to_int(fgets($fp, 3));
$this->info_comp           = $this->string_to_int(fgets($fp, 5));
$this->info_sizeimage      = $this->string_to_int(fgets($fp, 5));
$this->info_xpelsparameter = $this->string_to_int(fgets($fp, 5));
$this->info_ypelsparameter = $this->string_to_int(fgets($fp, 5));
$this->info_clrused        = $this->string_to_int(fgets($fp, 5));
$this->info_clrimp         = $this->string_to_int(fgets($fp, 5));

// $pre_type bör inte vara 0x4d42.
// $header_offset är 1078 så är bilden gråskala.
// $info_bits ska vara 8.
// $info_comp ska vara 0.
// $info_clrused är antalet färger, gråskala >= 256.

for($p = 0;$p < 256;$p++)
{
	$palette_b   = $this->string_to_int(fgets($fp, 2));
	$palette_g   = $this->string_to_int(fgets($fp, 2));
	$palette_r   = $this->string_to_int(fgets($fp, 2));
	$palette_res = $this->string_to_int(fgets($fp, 2));

	$this->palette[] = "#" . 
		dechex((int)($palette_r / 16)) .
		dechex($palette_r % 16) .
		dechex((int)($palette_g / 16)) .
		dechex($palette_g % 16) .
		dechex((int)($palette_b / 16)) .
		dechex($palette_b % 16);
}

for($y = 0;$y < $this->info_height;$y++)
{
	for($x = 0;$x < $this->info_width;$x++)
		$this->pixel[] = $this->string_to_int(fgets($fp, 2));
}
fclose($fp);
}

function print_as_table($width, $height, $cells)
{
echo("<table cellspacing=$cells cellpadding=$cells>");
for($y = $this->info_height - 1;$y;$y--)
{
        for($x = 0;$x < $this->info_width;$x++)
	{
		echo("<td width=$width height=$height bgcolor=" . 
			$this->palette[$this->pixel[$y * $this->info_width + $x]] .
			"></td>");
	}
	echo("<tr>\n");
}
echo("</table>");
}

function print_as_table_quad($width, $height, $cells, $left, $top, $x_length, $y_length)
{
echo("<table cellspacing=$cells cellpadding=$cells>");
for($y = $this->info_height - 1 - $top;$y != $this->info_height - 1 - $top - $y_length;$y--)
{
	for($x = $left;$x < $left + $x_length;$x++)
	{
		echo("<td width=$width height=$height bgcolor=" .
			$this->palette[$this->pixel[$y * $this->info_width + $x]] .
			"></td>");
	}
	echo("<tr>\n");
}
echo("</table>");
}

function print_as_chars_quad($char, $left, $top, $x_length, $y_length)
{
for($y = $this->info_height - 1 - $top;$y != $this->info_height - 1 - $top - $y_length;$y--)
{
	for($x = $left;$x < $left + $x_length;$x++)
	{
		echo("<font color=" .
			$this->palette[$this->pixel[$y * $this->info_width + $x]] .
			">$char</font>");
	}
	echo("<br>\n");
}
}

function print_as_chars($char)
{
for($y = $this->info_height - 1;$y;$y--)
{
	for($x = 0;$x < $this->info_width;$x++)
	{
		echo("<font color=" .
			$this->palette[$this->pixel[$y * $this->info_width + $x]] .
			">$char</font>");
	}
	echo("<br>\n");
}
}

}

?>
