<?php

	class Text
	{
		function Text($text, $position, $color)
		{
			for($i = 0;$i < strlen($text);$i++)
			{
				$char = $text[$i];
				if($position < $i)
				{
					print "<font color=#000000>$char</font>";
				}
				if($position >= $i)
				{
					$current = ($position - $i >= sizeof($color) ? $color[sizeof($color) - 1] : $color[$position - $i]);
					print "<font color=$current>$char</font>";
				}
			}
		}
	}
	
?>
