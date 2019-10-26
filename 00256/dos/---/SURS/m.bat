@echo off
tasm.exe 256.asm /la /m4 /z >error.txt
rem tasm wygeneruje listing poszerzony, powtorzy 4 razy
rem i wypisze linie z bledem (jezeli bedzie), a wyjscie
rem wyladuje w error.txt

tlink 256.obj /t
