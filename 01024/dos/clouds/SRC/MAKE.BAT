rem Built with TCC 2.01, TLINK 2.0, and NASM 2.11.05 under MS-DOS 6.22

tcc -w -w-pro -O -Z -f87 -mt -c intro.c
nasm -f obj stub.asm -o stub.obj
nasm -f obj tools.asm -o tools.obj
tlink /x /n /t stub.obj tools.obj intro.obj, clouds.com
del *.obj

