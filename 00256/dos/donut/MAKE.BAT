@echo off
tasm /m /ml /t /w2 /z donut.asm
tlink /3 /t /x donut.obj
