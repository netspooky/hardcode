@echo off
nasmw -o donut1.com donut1.asm
tasm /m /ml /t /w2 /z donut2.asm
tlink /3 /t /x donut2.obj
