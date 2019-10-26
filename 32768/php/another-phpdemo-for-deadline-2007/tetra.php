<?php

class Tetra {
function Tetra($x, $start, $color)
{
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

	$coord = array(array( 1,-1, 1),
		       array(-1,-1, 1),
		       array( 0,-1,-1),
		       array( 0, 1, 0));
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
		$lines = array(array(0,1),
			       array(0,2),
			       array(0,3),
			       array(1,2),
			       array(1,3),
			       array(2,3));

                for($n = 0;$n < 6;$n++)
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


        for($i = 0;$i < 4;$i++)
                $buffert[$point_y[$i]][$point_x[$i]] = 'O';

        echo("<pre style='color:$color'>");
        for($i_y = 0;$i_y < 12;$i_y++)
        {
                for($i_x = 0;$i_x < 30;$i_x++)
                {
                        echo($buffert[$i_y][$i_x] . '');
                }
                echo('<br>');
        }
        echo('<br><br>');

        echo('</pre>');
}
}
?>

