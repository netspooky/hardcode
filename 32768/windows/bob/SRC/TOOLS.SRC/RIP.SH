#!/bin/sh
mkdir --parents ./ripped
echo - build tools...
make
echo - lbm...
cat ../data.src/drbob2.lbm | ./lbm2raw --act > ./ripped/drbob2.pal
cat ../data.src/drbob2.lbm | ./lbm2raw > ./ripped/drbob2.raw
echo - fonts and sprites...
./fontripper ./ripped/drbob2.raw
./spriteripper ./ripped/drbob2.raw
cat ../data.src/game.xm > ./ripped/game.xm
cat ../data.src/menu.xm > ./ripped/menu.xm
echo - header files...
./bin2h ./ripped/drbob20.jtf
./bin2h ./ripped/drbob21.jtf
./bin2h ./ripped/drbob20.jrs
./bin2h ./ripped/drbob21.jrs
./bin2h ./ripped/drbob2.pal
./bin2h ./ripped/game.xm
./bin2h ./ripped/menu.xm
echo - cleaning...
mkdir ../data.tmp
cat ./ripped/drbob20.jtf.h > ../data.tmp/drbob20.jtf.h
cat ./ripped/drbob21.jtf.h > ../data.tmp/drbob21.jtf.h
cat ./ripped/drbob20.jrs.h > ../data.tmp/drbob20.jrs.h
cat ./ripped/drbob21.jrs.h > ../data.tmp/drbob21.jrs.h
cat ./ripped/drbob2.pal.h > ../data.tmp/drbob2.pal.h
cat ./ripped/game.xm.h > ../data.tmp/game.xm.h
cat ./ripped/menu.xm.h > ../data.tmp/menu.xm.h
rm ./ripped/*
rmdir ./ripped
