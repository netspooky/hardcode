@echo off
rem Ultrinit is needed to reset the GUS,otherwise it might not work
%ultradir%\ultrinit
rem The GUS port MUST be specified. If you don't have one,just specify
rem a free port address.
desert %ultrasnd%
%ultradir%\ultrinit
