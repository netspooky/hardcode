#!/usr/bin/perl
#
# Alternative Party 2003 invitation intro
# by Mikko "Ravel" Tuomela on 18-Nov-2002
#                 version 1.1 20-Nov-2002
# email: mikko@tuomela.net
#
# usage: 
# $ ./invi.pl
# (normal mode, you may have to export COLUMNS and export LINES)
#
# $ ./invi.pl x y
# (x and y are the desired geometry, 10 < x,y < 100)

# $ ./invi.pl x y n
# (x,y = geometry, n = number of objects, default=2)

use strict;

$| = 1;

my $maxcols = 100;
my $maxrows = 100;

my $cols;
my $rows;
if($ARGV[0] eq "" || $ARGV[1] eq "") {
    $cols = $ENV{COLUMNS} - 2;
    $rows = $ENV{LINES} - 2;
} else {
    $cols = $ARGV[0] - 2;
    $rows = $ARGV[1] - 2;
}

if($cols > $maxcols || $rows > $maxrows) {
    print "Your terminal is too big\!\n";
    die;
}

if($cols < 10 || $rows < 10) {
    print "COLUMNS and LINES must be at least 10\!\n";
    die;
}

my $amount = 1;
if($ARGV[2] ne "") {
    $amount = $ARGV[2] - 1;
}

$rows -= 1;

my @dist;
my @altdist;
print "precalc...\n";
for my $y (0 .. 200) {
    for my $x (0 .. 200) {
	$dist[$x][$y] = int(sqrt($x ** 2 + $y ** 2));
	$altdist[$x][$y] = int(sqrt(abs($x ** 2 - $y ** 2)));
    }
}

my @coords;
for my $center (0 .. $amount) {
    $coords[$center] = [rand $cols, rand $rows,  rand 2, rand 2, 0, 0];
    $coords[$center][4] = int($coords[$center][0]);
    $coords[$center][5] = int($coords[$center][1]);
    if(rand 10 < 5) {
	$coords[$center][2] = -$coords[$center][2];
    }
    if(rand 10 < 5) {
        $coords[$center][3] = -$coords[$center][3];
    }
}

my @chars = ("OOOO    ",
	     "  .,+o\$M",
	     "OO  OO  ",
	     "M\¤o+,.  ",
	     "O O O O ",
	     "OO      ",
	     "..  MM  ");

my @text = ("   Ravel presents             ",
	    "   an invitation to           ",
	    "   Alternative Party 2003     ",
	    "   10th-12th January 2003     ",
	    "   Gloria Helsinki Finland    ",
	    "   http://www.altparty.org/   ",
	    "   Press Ctrl-C to stop       ");

my $part = 0;
my $introlength = 7;
my $charset;
my $message;
my $height;
my $type = 0;
my $round = 0;
my $full;

print "\033c";

while(1) {
    $charset = $chars[$part];
    $message = $text[$part];
    $part++;
    if($part == $introlength) {
	$part = 0;
    }

    for my $time (0 .. 100) {
	print "\033[H";
	$full = "";
	for my $y (0 .. $rows) {
	    for my $x (0 .. $cols) {
		$height = 0;
		for my $cent (0 .. $amount) {

		    if($round == 0 || $round == 1) {
			if($type == 0) {
			    $height += $dist[abs($x - $coords[$cent][4])]
				[abs($y - $coords[$cent][5])] % 8;
			} else {
			    $height += $altdist[abs($x - $coords[$cent][4])]
				[abs($y - $coords[$cent][5])] % 8;
			}
		    } else {
			if($type == 0) {
			    $height += (-1) ** ($cent + 2) * 
				$dist[abs($x - $coords[$cent][4])]
				    [abs($y - $coords[$cent][5])];
			} else {
			    $height += (-1) ** ($cent + 2) * 
				$altdist[abs($x - int($coords[$cent][4]))]
				    [abs($y - int($coords[$cent][5]))];
			}
		    }

		}
		if($round == 0 || $round == 1) {
		    $height = int($height / ($amount + 1)) % 8;
		} else {
		    $height = int($height % 8);
		}
		$full .= substr($charset, $height, 1);
	    }
	    $full .= "\n";
	}
	
	print $full . "\033[4m" . $message . "\033[m";
	
	for my $cent (0 .. $amount) {
	    $coords[$cent][0] += $coords[$cent][2];
	    $coords[$cent][1] += $coords[$cent][3];
	    if($coords[$cent][0] < 0 || $coords[$cent][0] > $cols) {
		$coords[$cent][2] = -$coords[$cent][2];
	    }
	    if($coords[$cent][1] < 0 || $coords[$cent][1] > $rows) {
		$coords[$cent][3] = -$coords[$cent][3];
	    }
	    $coords[$cent][4] = int($coords[$cent][0]);
	    $coords[$cent][5] = int($coords[$cent][1]);
	}
    }

    if($part == 0) {
	if($type == 0) {
	    $type = 1;
	} else {
	    $type = 0;
	}
    }
    if($part == 0) {
	$round++;
    }
    if($round == 4) {
	$round = 0;
    }
}
