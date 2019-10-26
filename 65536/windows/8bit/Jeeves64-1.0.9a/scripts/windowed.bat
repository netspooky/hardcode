@echo off

:compress release version with upx. -- Kuno.

copy ..\VisualC\release\test.exe ..\8bit-windowed.exe
f:\tools\upx\upx --best --compress-icons=1 --no-color --overlay=strip ..\8bit-windowed.exe

