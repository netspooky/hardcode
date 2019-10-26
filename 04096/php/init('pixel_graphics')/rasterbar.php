<?
if(isset($_GET[t])) {
  $t = $_GET[t];
 } else {
  $t = 0;
 }
$t++;
print("<html>\n");
print("  <head>\n");
print("    <meta http-equiv=\"refresh\" content=\"0;url=rasterbar.php?t=$t\">\n");
print("  </head>\n");
print("  <body bgcolor=\"#000000\" text=\"#ffffff\">\n");
print("    <center>\n");
print("      <table cellspacing=\"0\" cellpadding=\"1\" border=\"1\" bordercolor=\"#ffffff\">\n");

# constant
$height = 100;

$screen = array();

# make entire screen black
for($x=0; $x < $height; $x++) {
  $screen[] = array("r" => "00", "g" => "00", "b" => "00");
 }

#
# modulo, $height är delare
#
# position red bar
$r = bcmod($t,$height);
$screen[$r-7]["r"] = "1f";
$screen[$r-6]["r"] = "3f";
$screen[$r-5]["r"] = "5f";
$screen[$r-4]["r"] = "7f";
$screen[$r-3]["r"] = "9f";
$screen[$r-2]["r"] = "bf";
$screen[$r-1]["r"] = "df";
$screen[$r]  ["r"] = "ff";
$screen[$r+1]["r"] = "df";
$screen[$r+2]["r"] = "bf";
$screen[$r+3]["r"] = "9f";
$screen[$r+4]["r"] = "7f";
$screen[$r+5]["r"] = "5f";
$screen[$r+6]["r"] = "3f";
$screen[$r+7]["r"] = "1f";

#
# sinusgrejja
#
# position green bar
$g = ($height/2.2 * sin($t/20)) + ($height/2);
$screen[$g-7]["g"] = "1f";
$screen[$g-6]["g"] = "3f";
$screen[$g-5]["g"] = "5f";
$screen[$g-4]["g"] = "7f";
$screen[$g-3]["g"] = "9f";
$screen[$g-2]["g"] = "bf";
$screen[$g-1]["g"] = "df";
$screen[$g]  ["g"] = "ff";
$screen[$g+1]["g"] = "df";
$screen[$g+2]["g"] = "bf";
$screen[$g+3]["g"] = "9f";
$screen[$g+4]["g"] = "7f";
$screen[$g+5]["g"] = "5f";
$screen[$g+6]["g"] = "3f";
$screen[$g+7]["g"] = "1f";

#
#  /
# / 
# position blue bar
$b = abs(bcmod((2 * $t),(2 * $height)) - $height);
$screen[$b-7]["b"] = "1f";
$screen[$b-6]["b"] = "3f";
$screen[$b-5]["b"] = "5f";
$screen[$b-4]["b"] = "7f";
$screen[$b-3]["b"] = "9f";
$screen[$b-2]["b"] = "bf";
$screen[$b-1]["b"] = "df";
$screen[$b]  ["b"] = "ff";
$screen[$b+1]["b"] = "df";
$screen[$b+2]["b"] = "bf";
$screen[$b+3]["b"] = "9f";
$screen[$b+4]["b"] = "7f";
$screen[$b+5]["b"] = "5f";
$screen[$b+6]["b"] = "3f";
$screen[$b+7]["b"] = "1f";


# render buffer
for($x=0; $x<$height; $x++) {
  $color = $screen["$x"]["r"].$screen["$x"]["g"].$screen["$x"]["b"];
  print("<tr bgcolor=\"#$color\"><td width=\"320\"></td></tr>\n");
 }

print("      </table>\n");
print("    </center>\n");
print("  </body>\n");
print("</html>\n");
?>