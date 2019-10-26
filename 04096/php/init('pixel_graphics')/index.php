<?
print("<html>\n");
print("  <head>\n");
$x = $_GET[x];
if($x < 20) {
$x++;
  print("    <meta http-equiv=\"refresh\" content=\"0;url=index.php?x=$x\">\n");
} else {
  print("    <meta http-equiv=\"refresh\" content=\"0;url=rasterbar.php\">\n");
}
print("  </head>\n");
print("  <body bgcolor=\"#000000\" text=\"#ffffff\">\n");
print("    <center>\n");
print("    <table cellspacing=\"0\" cellpadding=\"8\" border=\"1\" bordercolor=\"#ffffff\">\n");
for($y=0;$y<20;$y++)
  {
    print("      <tr>\n");
    for($x=0;$x<20;$x++)
      {
	$color = dechex(rand(0, 16777215));
	print("        <td bgcolor=\"#$color\"></td>");
      }
    print("      </tr>\n");
  }
print("    </table>\n");
print("    </center>\n");
print("  </body>\n");
print("</html>\n");
?>
