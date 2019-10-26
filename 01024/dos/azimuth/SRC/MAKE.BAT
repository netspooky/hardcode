rem Built with TCC 2.01, TLINK 2.0, NASM 2.11.05, and aPACK 1.00 under MS-DOS 6.22

tcc -1 -w -w-pro -O -Z -mt -c render.c
nasm -f obj intro.asm -o intro.obj
tlink /x /n /t intro.obj render.obj, intro.com
apack intro.com azimuth.com
del *.obj
del intro.com
