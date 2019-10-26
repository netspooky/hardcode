@echo off
ml.exe /c /coff /I"/masm32/include" /Fo"release\metalwork.obj" "metalwork.asm"
Crinkler.exe /ORDERTRIES:120 /HASHTRIES:100 /HASHSIZE:150 /entry:EntryPoint /subsystem:windows /CRINKLER /COMPMODE:fast /out:release\metalwork.exe release\metalwork.obj d3d9.lib kernel32.lib user32.lib winmm.lib d3dx9.lib
del "release\metalwork.obj"