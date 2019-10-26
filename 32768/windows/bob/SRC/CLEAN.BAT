@echo off
goto skip


  This file are belong to bob, a 32k game for the
  game compo at Mekka & Symposium 2001.
  Copyright (c) 2001 Kuno Woudt <warp-tmt@dds.nl>.

:skip
if .%1==. clean.bat bob.bin bob.tmp tools.tmp
rem data.tmp

:loop
if .%OS%==.Windows_NT goto del_slash_s

deltree /y %1
goto cont

:del_slash_s
del /s /f /q %1
rd %1

:cont
shift
if not .%1==. goto loop

:end
