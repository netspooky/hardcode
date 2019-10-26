@echo off
echo Chicken Dance II builder
echo (c)'99 by SquoQuo
echo Released at MS2k-1

tasm /t /m3 tsq-cd2
tlink /t /i /d /3 tsq-cd2
pklite tsq-cd2
del tsq-cd2.obj
del tsq-cd2.map

