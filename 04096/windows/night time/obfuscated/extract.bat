;we are currently doing this simple obfuscation (on the fly) to avoid stupid virus scanners detecting the crinkler executables (and then flag the whole site!)
for %%I in (*.obfuscated) do copy /b MZ +%%I %%~nI.exe
del *.obfuscated MZ extract.bat
