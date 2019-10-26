<?php
	header("Content-type: text/html; charset=iso-8859-1");
	/* Fulkod is the shit...
	   Entry: another-phpdemo-for-deadline-2007
	   Code: kalaspuff
           Released at: Deadline 2007
        */
	echo("<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">");
	echo('<html><head><title>another-phpdemo-for-deadline-2007 by even</title>');
	echo('<style type="text/css">
		<!--table { font-family: "Courier New", serif; font-size:1px;} 
		    .greet {font-family: "Courier New", serif; font-size:15px;} 
                    .sinus {font-family: verdana, serif; font-size:16px;padding:0px;letter-spacing:0px;} 
                    body { font-family: "Courier New", serif; font-size:15px;} -->
	      </style>');
	echo("<meta HTTP-EQUIV='Refresh' content='0;URL=index.php?u=" . ($_GET['u'] != "" ? $_GET['u']+1 : 0) . "'>");
	echo("</head>");
	echo('<body bgcolor="#000000"><center>');
	
	echo("<br><br><br><br>");
	if($_GET['u'] <= 425) {
		include("sinus.php");
		include("tetra.php");
	}
	if($_GET['u'] <= 15)
		new Sinus(" ", 550, 150, 5, $_GET['u']);	
	else if($_GET['u'] <= 145)	
		new Sinus("another-phpdemo-for-deadline-2007", 550, 150, 5, $_GET['u']-15);
	else if($_GET['u'] <= 255)
		new Sinus("coded by kalaspuff of even", 550, 150, 5, $_GET['u']-145);
	else if($_GET['u'] <= 380)
		new Sinus("now i'm running out of cool effects", 600, 150, 5, $_GET['u']-255);
	else if($_GET['u'] <= 425)
		new Sinus(" ", 550, 150, 5, $_GET['u']);
	if($_GET['u'] <= 390)
		new Tetra($_GET['u'], 0, "#a0a0a0");
        else if($_GET['u'] <= 392)
                new Tetra($_GET['u'], 0, "#909090");
        else if($_GET['u'] <= 394)
                new Tetra($_GET['u'], 0, "#808080");
        else if($_GET['u'] <= 396)
                new Tetra($_GET['u'], 0, "#707070");
        else if($_GET['u'] <= 398)
                new Tetra($_GET['u'], 0, "#707070");
        else if($_GET['u'] <= 400)
                new Tetra($_GET['u'], 0, "#707070");
        else if($_GET['u'] <= 402)
                new Tetra($_GET['u'], 0, "#606060");
        else if($_GET['u'] <= 404)
                new Tetra($_GET['u'], 0, "#505050");
        else if($_GET['u'] <= 406)
                new Tetra($_GET['u'], 0, "#404040");
        else if($_GET['u'] <= 408)
                new Tetra($_GET['u'], 0, "#303030");
        else if($_GET['u'] <= 410)
                new Tetra($_GET['u'], 0, "#202020");
        else if($_GET['u'] <= 412)
                new Tetra($_GET['u'], 0, "#101010");
        else if($_GET['u'] <= 425)
                new Tetra($_GET['u'], 0, "#000000");

	if($_GET['u'] > 425) {
		include("text.php");
		if($_GET['u'] < 805) {
			new Text("Greets goes out to...", $_GET['u'] - 426, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0fff0","#e0ffe0","#d0ffd0","#c0ffc0","#b0ffb0","#a0ffa0")); 
		} else if($_GET['u'] < 850) {
			new Text("Greets goes out to...", $_GET['u'] - 783, array("#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#a0ffa0","#b0ffb0","#c0ffc0","#d0ffd0","#e0ffe0","#f0fff0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
		}
		if($_GET['u'] > 475 && $_GET['u'] <= 605) {
			echo("<br><br><table width=400 class=greet><tr><td align=left>");
			new Text("deadline crew", $_GET['u'] - 475, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
			echo("<br>");
                        new Text("padi", $_GET['u'] - 490, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
                        new Text("illuminati", $_GET['u'] - 515, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
                        new Text("hypercube", $_GET['u'] - 530, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
                        new Text("ul(l)ug", $_GET['u'] - 545, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");

			echo("</td></tr></table>");
		}
                if($_GET['u'] > 605 && $_GET['u'] <= 725) {
                        echo("<br><br><table width=400 class=greet><tr><td align=right>");
                        new Text("introx", $_GET['u'] - 605, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0f0ff","#e0e0ff","#d0d0ff","#c0c0ff","#b0b0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#b0b0ff","#c0c0ff","#d0d0ff","#e0e0ff","#f0f0ff","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
			echo("<br>");
                        new Text("fairlight", $_GET['u'] - 620, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0f0ff","#e0e0ff","#d0d0ff","#c0c0ff","#b0b0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#b0b0ff","#c0c0ff","#d0d0ff","#e0e0ff","#f0f0ff","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
                        new Text("rasmus lerdorf", $_GET['u'] - 635, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0f0ff","#e0e0ff","#d0d0ff","#c0c0ff","#b0b0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#b0b0ff","#c0c0ff","#d0d0ff","#e0e0ff","#f0f0ff","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
                        new Text("#even", $_GET['u'] - 650, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0f0ff","#e0e0ff","#d0d0ff","#c0c0ff","#b0b0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#b0b0ff","#c0c0ff","#d0d0ff","#e0e0ff","#f0f0ff","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
                        new Text("cnackers", $_GET['u'] - 665, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0f0ff","#e0e0ff","#d0d0ff","#c0c0ff","#b0b0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#a0a0ff","#b0b0ff","#c0c0ff","#d0d0ff","#e0e0ff","#f0f0ff","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
                        echo("<br>");
			echo("</td></tr></table>");
		}
		if($_GET['u'] > 725) {
			echo("<br><br>");
			new Text("the php demoscene", $_GET['u'] - 725, array("#000000","#101010","#202020","#303030","#404040","#505050","#606060","#707070","#808080","#909090","#a0a0a0","#b0b0b0","#c0c0c0","#d0d0d0","#e0e0e0","#f0f0f0","#ffffff","#f0fff0","#e0ffe0","#d0ffd0","#c0ffc0","#b0ffb0","#a0ffa0","#a0ffa0","#a0ffa0","#b0ffb0","#c0ffc0","#d0ffd0","#e0ffe0","#f0f0ff","#ffffff","#fff0f0","#ffe0e0","#ffd0d0","#ffc0c0","#ffb0b0","#ffa0a0","#ffa0a0","#ffa0a0","#ffb0b0","#ffc0c0","#ffd0d0","#ffe0e0","#fff0f0","#ffffff","#f0f0ff","#e0e0ff","#d0d0ff","#c0c0ff","#b0b0ff","#a0a0ff","#a0a0ff","#a0a0ff","#b0b0ff","#c0c0ff","#d0d0ff","#e0e0ff","#f0f0ff","#ffffff","#f0f0f0","#e0e0e0","#d0d0d0","#c0c0c0","#b0b0b0","#a0a0a0","#909090","#808080","#707070","#606060","#505050","#404040","#303030","#202020","#101010","#000000"));
		}
	}
	if($_GET['u'] > 865) {	
		echo("<font color='#ffffff'>end of dämmo!<br><font size=1>stay 1337...</font></font>");
	}
	
	echo("</center></body></html>");
?>
