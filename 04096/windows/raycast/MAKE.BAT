@echo off
\masm32\bin\ml /c /coff ray_aa.asm
\masm32\bin\ml /c /coff raycast.asm
\masm32\bin\link /subsystem:windows ray_aa.obj
\masm32\bin\link /subsystem:windows raycast.obj
upx ray_aa.exe
upx raycast.exe