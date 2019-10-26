#!/bin/sh
A=/tmp/oeoe
tail -n +6 $0|zcat>$A
chmod +x $A
exec $A>/dev/null
