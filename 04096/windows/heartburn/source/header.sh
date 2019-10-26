#!/bin/sh
s=`mktemp`;tail -n+3 $0|lzcat>$s;chmod +x $s;$s;rm $s;exit
