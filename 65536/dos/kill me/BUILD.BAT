call t killme.c e.asm
echo exe derlendi veriler eklenecek
echo killme.c'de exe boyunu degistirmediysen bunu yeniden ayarla
echo simdi eklemediysen ctrl-break yap!
echo.
pause
copy /b killme.exe+picture.pic /b killme.exe
copy /b killme.exe+intro.fnt /b killme.exe
crc killme.exe
