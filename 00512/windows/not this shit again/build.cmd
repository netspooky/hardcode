@echo off
nasm.exe -f win32 -o npli-ntsa.obj npli-ntsa.asm && crinkler.exe /subsystem:windows /OUT:npli-ntsa.exe /ENTRY:main /CRINKLER /UNSAFEIMPORT /HASHTRIES:300 /COMPMODE:SLOW /ORDERTRIES:5000 /REPORT:report.html user32.lib kernel32.lib gdi32.lib npli-ntsa.obj


