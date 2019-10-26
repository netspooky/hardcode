@REM (Make)file for the Intereor bbsadd
@REM Better have TASM 3+ and TLINK 3+ in path!
@REM I "made" it with TASM 4.0 and TLINK 4.01
@TASM /t /m3 INTEREOR.ASM
@TLINK /t /x INTEREOR.OBJ
@DEL INTEREOR.OBJ
