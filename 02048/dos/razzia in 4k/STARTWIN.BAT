@echo off

rem Codepage 437 needed!

mode con codepage prepare=((437) c:\windows\command\ega.cpi) > nul
mode con codepage select=437 > nul

start razzia4k.pif
