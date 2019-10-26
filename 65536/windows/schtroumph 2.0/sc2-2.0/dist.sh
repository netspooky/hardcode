#!/bin/sh

mkdir dist

./configure --disable-sdl && make clean all && cp src/sc2.exe dist/sc2-compo.exe
./configure && make clean all && cp src/sc2.exe dist/sc2-sdl.exe
make dist && mv sc2-2.0.tar.gz dist/
upx --best dist/*.exe

