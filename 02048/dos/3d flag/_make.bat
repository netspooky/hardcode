@echo off

c:\asm16\tasm d:\3dflag\3dflag
c:\asm16\tlink d:\3dflag\3dflag /3 /t

del *.map
del *.obj
