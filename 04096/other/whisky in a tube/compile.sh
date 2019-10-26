#!/bin/sh

DNLOAD="../../faemiyah-demoscene/dnload/dnload.py"

python "${DNLOAD}" -o whisky_in_a_tube src/intro.cpp -lc -lGL -lSDL -v $*
exit $?
