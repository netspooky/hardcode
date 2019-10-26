tasm32 /m2 intro.asm, main.obj
tlink /x /3 /m main.obj, main.exe
apack -1 main.exe out.exe

