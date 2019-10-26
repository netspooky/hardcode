@if not exist "%1" goto quit

@del %~n1.pak
@del %~n1.unp

smile -e %1 %~n1.pak
smile -d %~n1.pak %~n1.unp
fc /b %1 %~n1.unp

goto ok

:quit
@echo Usage: test.bat filename

:ok