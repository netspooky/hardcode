@ECHO OFF
Tasm Chess32k /t /m9
Tlink Chess32k /x > NUL
Del Chess32k.obj