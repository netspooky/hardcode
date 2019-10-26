nasm -fwin32 muziks.asm
"c:\Program Files\CodeBlocks\MinGW\bin\ar" r muziks.lib muziks.obj
"c:\Program Files\CodeBlocks\MinGW\bin\strip" -x muziks.lib
"c:\Program Files\CodeBlocks\MinGW\bin\gcc" -s -c test.c
"c:\Program Files\CodeBlocks\MinGW\bin\ld" test.o muziks.lib -L"c:\Program Files\CodeBlocks\MinGW\lib" -lkernel32 -luser32 -lmsvcrt -lwinmm -s -subsystem console -nostdlib -o test.exe -entry __main
del muziks.obj test.o
