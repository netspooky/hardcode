@echo off
goto skip


  This file are belong to bob, a 32k game for the
  game compo at Mekka & Symposium 2001.
  Copyright (c) 2001 Kuno Woudt <warp-tmt@dds.nl>.


:skip
if exist ..\bob.exe del ..\bob.exe
d:\tools\upx\upx.exe -9 --overlay=strip --strip-relocs=1 --compress-icons=1 bob.bin\bob.exe -o..\bob.exe
